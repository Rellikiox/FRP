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

    @spawn_road_inspector: (patch) ->
        return @spawn_inspector(patch, RoadInspector.prototype)

    @spawn_node_inspector: (patch) ->
        return @spawn_inspector(patch, NodeInspector.prototype)

    @spawn_inspector: (patch, prototype) ->
        inspector = patch.sprout(1, @inspectors)[0]
        extend(inspector, prototype)
        inspector.init()
        return inspector

    current_state: null
    speed: 0.05

    init: () ->

    step: () ->
        @current_state()

    _set_state: (new_state) ->
        console.log("Transitioning from #{@label} to #{new_state}")
        @label = new_state
        @current_state = @['s_' + new_state]

    _move: (point) ->
        @_face_point point
        @forward(@speed)

    _face_point: (point) ->
        heading = @_angle_between_points(point, @)
        turn = ABM.util.subtractRads heading, @heading
        @rotate turn

    _angle_between_points: (point_a, point_b) ->
        dx = point_a.x - point_b.x
        dy = point_a.y - point_b.y
        return Math.atan2(dy, dx)

    _in_point: (point) ->
        return 0.1 > ABM.util.distance @x, @y, point.x, point.y

    _get_path_to: (point) ->
        return CityModel.instance.terrainAStar.getPath(@, point)


class NodeInspector extends Inspector

    current_message: null
    nodes_under_investigation: []

    init: () ->
        @_set_state('get_message')
        @msg_boards =
            inspect: MessageBoard.get_reader('inspect_endpoint')
            connect: MessageBoard.get_reader('connect_nodes')

    s_get_message: () ->
        @current_message = @msg_boards.inspect.get_message()
        if @current_message?
            @path = CityModel.instance.roadAStar.getPath(@, @current_message.patch)
            @_set_state('go_to_endpoint')

    s_go_to_endpoint: () ->
        @_move(@path[0])

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @path = null
                @nodes_under_investigation = @_get_close_nodes()
                @_set_state('inspect_endpoint')

    s_inspect_endpoint: () ->

        @_inspect_node(@nodes_under_investigation.shift())

        if @nodes_under_investigation.length is 0
            @current_message = null
            @_set_state('get_message')


    _inspect_node: (node) ->
        real_dist = @distance(node)
        road_dist = Road.get_road_distance(@, node)

        factor = road_dist / real_dist
        if factor > 4
            @msg_boards.connect.post_message({node_a: @.p.node, node_b: node})

    _get_close_nodes: () ->
        RoadNode.road_nodes.inRadius(@.p.node, 10)


class RoadInspector extends Inspector

    ring_increment: 3
    ring_radius: 6

    init: () ->
        @_set_state('get_inspection_point')
        @msg_board = MessageBoard.get_reader('build_endpoint')

    s_get_inspection_point: () ->
        @inspection_point = @_get_point_to_inspect()

        if @inspection_point?
            @_set_state('go_to_inspection_point')

    s_go_to_inspection_point: () ->
        if not @inspection_point?
            @_set_state('get_inspection_point')
            return

        if not @path?
            @path = @_get_path_to(@inspection_point)

        @_move(@path[0])

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @path = null
                @_set_state('find_new_endpoint')

    s_find_new_endpoint: () ->
        if Road.get_connectivity(@p) > 3
            @msg_board.post_message({patch: @p})
            @_set_state('get_inspection_point')
        else
            @_set_state('get_away_from_road')

    s_get_away_from_road: () ->
        if not @circular_direction?
            @circular_direction = ABM.util.oneOf([-1, 1])

        @_circular_move()
        if Road.get_connectivity(@p) > 3
            @circular_direction = null
            @_set_state('find_new_endpoint')

    _get_point_to_inspect: () ->
        rand_angle  = ABM.util.randomFloat(2 * Math.PI)
        x = Math.round(@ring_radius * Math.cos(rand_angle))
        y = Math.round(@ring_radius * Math.sin(rand_angle))
        return {x: x, y: y}

    _circular_move: () ->
        polar_coords = @_get_polar_coords()
        angle_increment = (@speed / polar_coords.radius) * @circular_direction
        angle = polar_coords.angle + angle_increment
        point = @_point_from_polar_coords(polar_coords.radius, angle)
        @_move(point)

    _point_from_polar_coords: (radius, angle) ->
        point =
            x: radius * Math.cos(angle)
            y: radius * Math.sin(angle)
        return point

    _get_polar_coords: () ->
        polar_coords =
            angle: Math.atan2(@y, @x)
            radius: ABM.util.distance(0, 0, @x, @y)
        return polar_coords



    # s_exit_city: () ->
    #     point = @_get_point_away_from_city()
    #     @_move(point)

    #     if @_connectivity_under_threshold()
    #         @_set_state('roam_unconnected_zone')

    # s_roam_unconnected_zone: () ->
    #     console.log "now what?"

    # _connectivity_under_threshold: () ->
    #     return Road.get_connectivity(@p) > 5

    # _get_point_away_from_city: () ->
    #     city_center = @_get_weighted_city_center()
    #     angle = @_angle_between_points(@, city_center)

    #     point =
    #         x: @x + Math.cos(angle)
    #         y: @y + Math.sin(angle)

    #     return point

    # _get_weighted_city_center: () ->
    #     nodes = RoadNode.road_nodes
    #     avg_point = {x: 0, y: 0}
    #     for node in nodes
    #         avg_point.x += node.x
    #         avg_point.y += node.y
    #     avg_point.x /= nodes.length
    #     avg_point.y /= nodes.length
    #     return avg_point



