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
        extend(road_maker, prototype)
        return road_maker

    init: () ->


    step: () ->
        @current_state()



       # Utils

    _get_path_to: (point) ->
        return CityModel.instance.terrainAStar.getPath(@, point)

    drop_road: ->
        Road.set_breed(@p)

    is_target_point: ->
        return @in_point @target_point

    in_starting_position: ->
        return @in_point @starting_position

    in_point: (point) ->
        return 0.1 > ABM.util.distance @x, @y, point.x, point.y

    face_point: (point) ->
        dx = point.x - @x
        dy = point.y - @y
        heading = Math.atan2 dy, dx
        turn = ABM.util.subtractRads heading, @heading
        @rotate turn

    move: (point) ->
        @face_point point
        @forward(0.05)


class RoadExtender extends RoadMaker

    init: (endpoint) ->
        @endpoint = endpoint
        @current_state = @go_to_point_state
        @msg_reader = MessageBoard.get_reader('inspect_endpoint')


    # States

    go_to_point_state: ->
        if not @path?
            closest_road_to_target = Road.get_closest_road_to(@endpoint)
            @path = @_get_path_to(closest_road_to_target)

        @move(@path[0])

        if @in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @path = CityModel.instance.terrainAStar.getPath(@, @endpoint)
                @label = "build_to_point_state"
                @current_state = @build_to_point_state

    build_to_point_state: ->
        @move @path[0]

        if not Road.is_road @p
            @drop_road()

        if @in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @msg_reader.post_message({patch: @p})
                @die()


class RoadConnector extends RoadMaker

    init: (endpoint) ->
        @startingpoint = @p
        @endpoint = endpoint
        @current_state = @build_to_point_state
        @msg_reader = MessageBoard.get_reader('inspect_endpoint')


    # States

    build_to_point_state: () ->
        if not @path?
            @path = @_get_path_to(@endpoint)

        @move @path[0]

        if not Road.is_road @p
            @drop_road()

        if @in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @msg_reader.post_message({patch: @startingpoint})
                @msg_reader.post_message({patch: @endpoint})
                @die()
