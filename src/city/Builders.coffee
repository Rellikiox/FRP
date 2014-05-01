class RoadBuilder
    # Agentscript stuff
    @road_builders: null

    # Appearance
    @default_color: [255,255,255]

    # Behavior
    @radius_increment = 3

    @initialize: (@road_builders) ->
        @road_builders.setDefault('color', @default_color)

    @spawn_road_connector: (path) ->
        road_builder = @spawn_road_builder(path[0], RoadConnector)
        road_builder.init(path)
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

    _drop_road: () ->
        if not Road.is_road @p
            @p.under_construction = false
            Road.set_breed(@p)
            @_check_for_plots()

    _check_for_plots: () ->
        if Road.get_roads_in_n8(@p).length >= 2
            @msg_boards.plot.post_message({patch: @p})

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
                    @msg_boards.node.post_message({patch: point})
                @_set_state('die')

    s_die: ->
        @die()


class RoadExtender extends RoadBuilder

    init: (endpoint) ->
        @endpoint = endpoint
        @points_to_report = [@endpoint]

        @_set_initial_state('go_to_point_state')

        @msg_boards =
            node: MessageBoard.get_board('node_built')
            plot: MessageBoard.get_board('possible_plot')

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

    init: (@path) ->
        @startpoint = @path[0]
        @endpoint = @path[@path.length-1]

        @points_to_report = [@startpoint, @endpoint]

        @_set_initial_state('build_to_point')

        @msg_boards =
            node: MessageBoard.get_board('node_built')
            plot: MessageBoard.get_board('possible_plot')

    s_build_to_point: ->
        if not @path?
            @path = @_get_terrain_path_to(@endpoint)

        @_move @path[0]

        @_drop_road()

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                for point in @points_to_report
                    @msg_boards.node.post_message({patch: point})
                @_set_state('die')


CityModel.register_module(RoadBuilder, ['road_builders'], [])


class HouseBuilder
    # Agentscript stuff
    @house_builders: null

    # Appearance
    @default_color: [100,0,0]

    @initialize: (@house_builders) ->
        @house_builders.setDefault('color', @default_color)

    @spawn_house_builder: (starting_point, patch) ->
        house_builder = starting_point.sprout(1, @house_builders)[0]
        extend(house_builder, FSMAgent, MovingAgent, HouseBuilder)
        house_builder.init(patch)
        return house_builder

    speed: 0.05

    init: (@block) ->
        @board = MessageBoard.get_board('new_citizen')

        if Road.get_road_neighbours(@p).length > 0
            @_set_initial_state('go_to_plot')
        else
            @_set_initial_state('go_to_road')

    s_go_to_road: () ->
        if not @road?
            @road = Road.get_closest_road_to(@p)

        @_move(@road)

        if @_in_point(@road)
            @_set_state('go_to_plot')


    s_go_to_plot: () ->
        if not @path? or @path.length is 0
            patch = @block.plot.get_closes_patch_to(@p)
            road = ABM.util.oneOf(Road.get_road_neighbours(patch))
            @path = @_get_road_path_to(road)

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
            @board.post_message()

CityModel.register_module(HouseBuilder, ['house_builders'], [])



class Bulldozer
    @bulldozers: null
    @default_color: [255, 255, 0]

    @initialize: (@bulldozers) ->
        @bulldozers.setDefault('color', @default_color)

    @spawn_bulldozer: (path) ->
        bulldozer = path[0].sprout(1, @bulldozers)[0]
        extend(bulldozer, FSMAgent, MovingAgent, Bulldozer)
        bulldozer.init(path)
        return bulldozer

    init: (@path) ->
        @path_copy = (p for p in @path)
        @_set_initial_state('bulldoze_to_point')
        @board = MessageBoard.get_board('nodes_unconnected')

    s_bulldoze_to_point: ->
        if not @path?
            @path = @_get_terrain_path_to(@endpoint)

        @_move @path[0]

        if not Road.is_road(@p)
            @_bulldoze_patch()

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @board.post_message({path: @path_copy})
                @_set_state('die')

    s_die: () ->
        @die()


    _bulldoze_patch: () ->
        if House.is_house(@p)
            @p.reallocate_citizens()
            CityModel.get_patches().setBreed(@p)

        @p.color = ABM.util.randomGray(100, 150)
        [r, g, b] = @p.color
        @p.color = [r, g * 2, b]




CityModel.register_module(Bulldozer, ['bulldozers'], [])

