class Planner
    @planners = null

    @initialize: (@planners) ->
        @planners.setDefault 'hidden', true
        GenericPlanner.initialize()
        NeedsPlanner.initialize()

    @spawn_generic_planner: () ->
        return @spawn_planner(GenericPlanner)

    @spawn_growth_planner: () ->
        return @spawn_planner(GrowthPlanner)

    @spawn_housing_planner: () ->
        return @spawn_planner(HousingPlanner)

    @spawn_needs_planner: () ->
        return @spawn_planner(NeedsPlanner)

    @spawn_planner: (klass) ->
        planner = @planners.create(1)[0]
        extend(planner, FSMAgent, klass)
        planner.init()
        return planner


class GenericPlanner extends Planner
    @actions:
        nodes_unconnected: (message) -> RoadBuilder.spawn_road_builder(message.path)
        possible_node: (message) ->
            closest_road = Road.get_closest_road_to(message.patch)
            point_path = CityModel.instance.terrainAStar.getPath(closest_road, message.patch)
            path = (CityModel.get_patch_at(p) for p in point_path)
            RoadBuilder.spawn_road_builder(path)
        bulldoze_path: (message) -> Bulldozer.spawn_bulldozer(message.path, () => @boards.nodes_unconnected.post_message({path: message.path}))

    @boards:
        nodes_unconnected: null

    @initialize: () ->
        for key, value of @boards
            @boards[key] = MessageBoard.get_board(key)


    init: () ->
        topics = (key for key, value of GenericPlanner.actions)

        @board = MessageBoard.get_combined_board(topics)
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @board.get_message()
        if @message?
            @_set_state('run_action')

    s_run_action: () ->
        GenericPlanner.actions[@message.type](@message)
        @message = null
        @_set_state('get_message')


class HousingPlanner

    init: () ->
        @board = MessageBoard.get_board('new_citizen')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @board.get_message()
        if @message?
            @_set_state('send_house_builder')

    s_send_house_builder: () ->
        block = Plot.get_available_block()
        if block?
            @message.starting_point ?= Road.get_closest_road_to(block)
            HouseBuilder.spawn_house_builder(@message.starting_point, block)
            @message = null
            @_set_state('get_message')


class GrowthPlanner

    base_growth: 0.03  # 1 person every 6 days (1 person/ (6 days * 5 ticks per day))

    ###
        10% population growth per year. Each 1 person contributes to 10/100 of a new person each year
    ###
    growth_per_capita: (1 / 1825) * (10 / 100)

    init: () ->
        @msg_reader = MessageBoard.get_board('new_citizen')
        @citizen_percentage = 0
        @_set_initial_state('grow_population')

    s_grow_population: () ->
        @citizen_percentage += @base_growth + @growth_per_capita * House.population
        if @citizen_percentage >= 1
            @citizen_percentage -= 1
            @_set_state('spawn_citizen')

    s_spawn_citizen: () ->
        @msg_reader.post_message()
        @_set_state('grow_population')


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
                Bulldozer.spawn_bulldozer([building], () -> Block.make_here(@p, building.plot))

            for patch in @_get_patches(kmeans.centroids())
                BuildingBuilder.spawn_building_builder(CityModel.instance.city_hall, patch, 'hospital')


    _get_patches: (points) ->
        points = (x: Math.round(point.x), y: Math.round(point.y) for point in points)
        return (Block.closest_block(CityModel.get_patch_at(point)) for point in points)


CityModel.register_module(Planner, ['planners'], [])

