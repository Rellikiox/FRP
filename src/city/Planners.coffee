class Planner
    @planners = null

    @initialize: (@planners) ->
        @planners.setDefault 'hidden', true
        PlotKeeperPlanner.initialize()
        NeedsPlanner.initialize()

    @spawn_road_planner: () ->
        return @spawn_planner(RoadPlanner)

    @spawn_node_planner: () ->
        return @spawn_planner(NodeInterconnectivityPlanner)

    @spawn_bulldozer_planner: () ->
        return @spawn_planner(BulldozerPlanner)

    @spawn_growth_planner: () ->
        return @spawn_planner(GrowthPlanner)

    @spawn_plot_planner: () ->
        return @spawn_planner(PlotPlanner)

    @spawn_housing_planner: () ->
        return @spawn_planner(HousingPlanner)

    @spawn_plot_keeper_planner: () ->
        return @spawn_planner(PlotKeeperPlanner)

    @spawn_needs_planner: () ->
        return @spawn_planner(NeedsPlanner)

    @spawn_planner: (klass) ->
        planner = @planners.create(1)[0]
        extend(planner, FSMAgent, klass)
        planner.init()
        return planner


class NodeInterconnectivityPlanner extends Planner

    init: () ->
        @msg_reader = MessageBoard.get_board('nodes_unconnected')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @msg_reader.get_message()
        if @message?
            @_set_state('emit_road_connector')

    s_emit_road_connector: () ->
        if not @message?
            @_set_state('get_message')
            return

        RoadBuilder.spawn_road_connector(@message.path)
        @message = null
        @_set_state('get_message')


class RoadPlanner

    init: () ->
        @msg_reader = MessageBoard.get_board('possible_node')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @msg_reader.get_message()
        if @message?
            @_set_state('send_road_extender')

    s_send_road_extender: () ->
        if not @message?
            @_set_state('get_message')
            return

        RoadBuilder.spawn_road_extender(@message.patch)
        @message = null
        @_set_state('get_message')


class PlotPlanner

    init: () ->
        @boards =
            possible: MessageBoard.get_board('possible_plot')
            inspect: MessageBoard.get_board('inspect_plot')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @boards.possible.get_message()
        if @message?
            @_set_state('send_plot_inspector')

    s_send_plot_inspector: () ->
        if not @message?
            @_set_state('get_message')
            return

        @boards.inspect.post_message({patch: @message.patch})
        @message = null
        @_set_state('get_message')


class PlotKeeperPlanner

    @available_plots: []

    @initialize: () ->
        @available_plots = []


    init: () ->
        @board = MessageBoard.get_board('plot_built')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @board.get_message()
        if @message?
            PlotKeeperPlanner.available_plots.push(@message.plot)


class HousingPlanner

    init: () ->
        @default_starting_point = CityModel.instance.city_hall
        @board = MessageBoard.get_board('new_citizen')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @board.get_message()
        if @message?
            @_set_state('send_house_builder')

    s_send_house_builder: () ->
        block = Plot.get_available_block()
        if block?
            starting_point = if @message.starting_point? then @message.starting_point else @default_starting_point
            HouseBuilder.spawn_house_builder(starting_point, block)
            @message = null
            @_set_state('get_message')


class GrowthPlanner

    ticks_per_citizen: 30

    init: () ->
        @msg_reader = MessageBoard.get_board('new_citizen')
        @ticks_since_last_citizen = 0
        @_set_initial_state('wait_until_ready')

    s_wait_until_ready: () ->
        @ticks_since_last_citizen += 1
        if @ticks_since_last_citizen >= @ticks_per_citizen
            @_set_state('grow_population')

    s_grow_population: () ->
        @msg_reader.post_message()
        @ticks_since_last_citizen = 0
        @_set_state('wait_until_ready')


class BulldozerPlanner

    init: () ->
        @msg_reader = MessageBoard.get_board('bulldoze_path')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @msg_reader.get_message()
        if @message?
            @_set_state('emit_bulldozer')

    s_emit_bulldozer: () ->
        if not @message?
            @_set_state('get_message')
            return

        Bulldozer.spawn_bulldozer(@message.path)
        @message = null
        @_set_state('get_message')


class NeedsPlanner
    @needs:
        hospital: {}

    @supplied_needs:
        hospital: 0

    @initialize: () ->
        @needs.hospital = {}
        @supplied_needs.hospital = 0


    init: () ->
        @msg_reader = MessageBoard.get_board('population_needs')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @msg_reader.get_message()
        if @message?
            @_set_state('process_message')

    s_process_message: () ->
        switch @message.need
            when 'hospital' then @_process_hospital_need(@message.house)

        @message = null
        @_set_state('get_message')

    _process_hospital_need: (house) ->
        if not (house.id of NeedsPlanner.needs.hospital)
            NeedsPlanner.needs.hospital[house.id] = house

        people = 0
        for id, house of NeedsPlanner.needs.hospital
            people += house.citizens
        needed_ammount = Math.floor(people / 100)
        if needed_ammount > NeedsPlanner.supplied_needs.hospital
            houses_array = (house for id, house of NeedsPlanner.needs.hospital)
            kmeans = new KMeans(houses_array, needed_ammount)
            kmeans.run()
            NeedsPlanner.supplied_needs.hospital = kmeans.centroids().length

            for building in Building.get_of_type('hospital')
                Bulldozer.spawn_bulldozer([building])

            for patch in @_get_patches(kmeans.centroids())
                BuildingBuilder.spawn_building_builder(CityModel.instance.city_hall, patch, 'hospital')


    _get_patches: (points) ->
        points = (x: Math.round(point.x), y: Math.round(point.y) for point in points)
        return (Block.closest_block(CityModel.get_patch_at(point)) for point in points)


CityModel.register_module(Planner, ['planners'], [])

