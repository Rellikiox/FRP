class Planner
    @planners = null

    @initialize: (@planners) ->
        @planners.setDefault 'hidden', true
        GenericPlanner.initialize()

    @spawn_generic_planner: () ->
        return @spawn_planner(GenericPlanner)

    @spawn_growth_planner: () ->
        return @spawn_planner(GrowthPlanner)

    @spawn_housing_planner: () ->
        return @spawn_planner(HousingPlanner)

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
        building_needed: (message) ->
            patch = CityModel.instance.city_hall
            BuildingBuilder.spawn_building_builder(patch, message.block, message.type)

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


CityModel.register_module(Planner, ['planners'], [])

