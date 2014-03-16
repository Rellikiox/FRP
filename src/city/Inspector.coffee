class Inspector
    # Agentscript stuff
    @inspectors: null

    # Appearance
    @default_color: [0, 0, 255]

    # Behavior
    @radius_increment = 3

    @initialize_module: (inspectors_breed) ->
        @inspectors = inspectors_breed
        @inspectors.setDefault('color', @default_color)

    @spawn_inspector: (patch) ->
        inspector = patch.sprout(1, @inspectors)[0]
        extend(inspector, Inspector_instance_properties)
        inspector.init()
        return inspector


Inspector_instance_properties =
    current_message: null
    current_state: null
    nodes_under_investigation: []

    init: () ->
        @current_state = @get_message_state
        @msg_boards =
            inspect: MessageBoard.get_reader('inspect_endpoint')
            connect: MessageBoard.get_reader('connect_nodes')

    step: () ->
        @current_state()


    get_message_state: () ->
        @current_message = @msg_boards.inspect.get_message()
        if @current_message?
            @path = CityModel.instance.roadAStar.getPath(@, @current_message.patch)
            @current_state = @go_to_endpoint_state

    go_to_endpoint_state: () ->
        @move(@path[0])

        if @in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @nodes_under_investigation = @_get_close_nodes()
                @current_state = @inspect_endpoint_state

    inspect_endpoint_state: () ->

        @_inspect_node(@nodes_under_investigation.shift())

        if @nodes_under_investigation.length is 0
            @current_message = null
            @current_state = @get_message_state


    _inspect_node: (node) ->
        real_dist = @distance(node)
        road_dist = Road.get_road_distance(@, node)

        factor = road_dist / real_dist
        if factor > 4
            @msg_boards.connect.post_message({node_a: @.p.node, node_b: node})


    move: (point) ->
        @face_point point
        @forward(0.05)

    face_point: (point) ->
        dx = point.x - @x
        dy = point.y - @y
        heading = Math.atan2 dy, dx
        turn = ABM.util.subtractRads heading, @heading
        @rotate turn

    in_point: (point) ->
        return 0.1 > ABM.util.distance @x, @y, point.x, point.y

    _get_close_nodes: () ->
        RoadNode.road_nodes.inRadius(@.p.node, 10)




