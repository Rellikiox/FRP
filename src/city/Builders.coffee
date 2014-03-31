class RoadBuilder
    # Agentscript stuff
    @road_builders: null

    # Appearance
    @default_color: [255,255,255]

    # Behavior
    @radius_increment = 3

    @initialize: (@road_builders) ->
        @road_builders.setDefault('color', @default_color)

    @spawn_road_connector: (road_a, road_b) ->
        road_builder = @spawn_road_builder(road_a, RoadConnector)
        road_builder.init(road_b)
        return road_builder

    @spawn_road_extender: (endpoint) ->
        road_builder = @spawn_road_builder(CityModel.instance.city_hall, RoadExtender)
        road_builder.init(endpoint)
        return road_builder

    @spawn_road_builder: (patch, klass) ->
        road_builder = patch.sprout(1, @road_builders)[0]
        extend(road_builder, FSMAgent, MovingAgent, klass)
        return road_builder

    # Utils

    speed: 0.05

    _drop_road: ->
        Road.set_breed(@p)

    s_build_to_point_state: ->
        if not @path?
            @path = @_get_terrain_path_to(@endpoint)

        @_move @path[0]

        if not Road.is_road @p
            @_drop_road()

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                for point in @points_to_report
                    @msg_reader.post_message({patch: point})
                @_set_state('die')

    s_die: ->
        @die()


class RoadExtender extends RoadBuilder

    init: (endpoint) ->
        @endpoint = endpoint
        @points_to_report = [@endpoint]

        @_set_initial_state('go_to_point_state')
        @msg_reader = MessageBoard.get_board('node_built')

    s_go_to_point_state: ->
        if not @path?
            closest_road_to_target = Road.get_closest_road_to(@endpoint)
            @path = @_get_terrain_path_to(closest_road_to_target)

        @_move(@path[0])

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @path = CityModel.instance.terrainAStar.getPath(@, @endpoint)
                @_set_state('build_to_point_state')


class RoadConnector extends RoadBuilder

    init: (endpoint) ->
        @startpoint = @p
        @endpoint = endpoint

        @points_to_report = [@startpoint, @endpoint]

        @_set_initial_state('build_to_point_state')

        @msg_boards =
            node: MessageBoard.get_board('node_built')
            plot: MessageBoard.get_board('possible_plot')

    s_build_to_point_state: ->
        if not @path?
            @path = @_get_terrain_path_to(@endpoint)

        @_move @path[0]

        if not Road.is_road @p
            @_drop_road()
            @_check_for_plots()

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                for point in @points_to_report
                    @msg_boards.node.post_message({patch: point})
                @_set_state('die')

    _check_for_plots: () ->
        if Road.get_road_neighbours(@p).length >= 2
            @msg_boards.plot.post_message({patch: @p})


CityModel.register_module(RoadBuilder, ['road_builders'], [])


class HouseBuilder
    # Agentscript stuff
    @house_builders: null

    # Appearance
    @default_color: [100,0,0]

    @initialize: (@house_builders) ->
        @house_builders.setDefault('color', @default_color)

    @spawn_house_builder: (patch) ->
        house_builder = CityModel.instance.city_hall.sprout(1, @house_builders)[0]
        extend(house_builder, FSMAgent, MovingAgent, HouseBuilder)
        house_builder.init(patch)
        return house_builder

    speed: 0.05

    init: (@block) ->
        @_set_initial_state('go_to_plot')

    s_go_to_plot: ->
        if not @path? or @path.length is 0
            closest_road_to_target = Road.get_closest_road_to(@block)
            @path = @_get_road_path_to(closest_road_to_target)

        @_move(@path[0])

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @_set_state('go_to_block')

    s_go_to_block: () ->
        @_move(@block)

        if @_in_point(@block)
            @_house_citizen(@p)
            @_set_state('die')

    s_die: () ->
        @die()

    _house_citizen: (patch) ->
        if not House.is_house(patch)
            House.make_here(patch)

        if patch.has_free_space()
            patch.increase_citizens()
        else
            @block = patch.plot.get_available_block



CityModel.register_module(HouseBuilder, ['house_builders'], [])
