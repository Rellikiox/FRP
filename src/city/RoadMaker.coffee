class RoadMaker
    # Agentscript stuff
    @road_makers: null

    # Appearance
    @default_color: [255,255,255]

    # Behavior
    @radius_increment = 3

    @initialize_module: (road_makers_breed) ->
        @road_makers = road_makers_breed
        @road_makers.setDefault('color', @default_color)

    @spawn_road_connector: (road_a, road_b) ->
        road_maker = @spawn_road_maker(road_a, RoadConnector.prototype)
        road_maker.init(road_b)
        return road_maker

    @spawn_road_extender: (endpoint) ->
        road_maker = @spawn_road_maker(CityModel.instance.city_hall, RoadExtender.prototype)
        road_maker.init(endpoint)
        return road_maker

    @spawn_road_maker: (patch, prototype) ->
        road_maker = patch.sprout(1, @road_makers)[0]
        extend(road_maker, BaseAgent.prototype)
        extend(road_maker, prototype)
        return road_maker

    # Utils

    speed: 0.05

    _drop_road: ->
        Road.set_breed(@p)

    s_die: ->
        @die()


class RoadExtender extends RoadMaker

    init: (endpoint) ->
        @endpoint = endpoint
        @_set_state('go_to_point_state')
        @msg_reader = MessageBoard.get_reader('inspect_endpoint')

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

    s_build_to_point_state: ->
        @_move @path[0]

        if not Road.is_road @p
            @_drop_road()

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @msg_reader.post_message({patch: @p})
                @_set_state('die')


class RoadConnector extends RoadMaker

    init: (endpoint) ->
        @startingpoint = @p
        @endpoint = endpoint

        @_set_state('build_to_point_state')
        @msg_reader = MessageBoard.get_reader('inspect_endpoint')

    s_build_to_point_state: () ->
        if not @path?
            @path = @_get_terrain_path_to(@endpoint)

        @_move @path[0]

        if not Road.is_road @p
            @_drop_road()

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @msg_reader.post_message({patch: @startingpoint})
                @msg_reader.post_message({patch: @endpoint})
                @_set_state('die')
