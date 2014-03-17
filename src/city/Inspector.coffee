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

        node_connected = @_inspect_node(@nodes_under_investigation.shift())

        if node_connected or @nodes_under_investigation.length is 0
            @nodes_under_investigation = []
            @current_message = null
            @_set_state('get_message')


    _inspect_node: (node) ->
        if node.factor > 4
            @msg_boards.connect.post_message({patch_a: @.p, patch_b: node.node.p})
            return true
        return false

    _get_close_nodes: () ->
        nodes = []
        if @.p.node?
            nodes_to_check = RoadNode.road_nodes.inRadius(@.p.node, 10)
        else
            nodes_to_check = RoadNode.road_nodes.inRadius(@, 10)
        for node in nodes_to_check
            factor = @_get_node_distance_factor(node)
            nodes.push({node: node, factor: factor})
        nodes.sort( (a, b) -> if a.factor < b.factor then 1 else -1 )
        return nodes

    _get_node_distance_factor: (node) ->
        real_dist = @distance(node)
        road_dist = Road.get_road_distance(@, node)
        factor = road_dist / real_dist


class RoadInspector extends Inspector

    @construction_points = []

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
        if @_is_valid_construction_point(@p)
            @_issue_construction(@p)
            @_set_state('get_inspection_point')
        else
            @_set_state('get_away_from_road')

    s_get_away_from_road: () ->
        if not @circular_direction?
            @circular_direction = ABM.util.oneOf([-1, 1])

        @_circular_move()
        if @_is_valid_construction_point(@p)
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

    _is_valid_construction_point: (patch) ->
        road_dist = Road.get_connectivity(@p)
        construction_dist = @_get_construction_dist(@p)
        return road_dist > 3 && (not construction_dist? or construction_dist > 3)

    _issue_construction: (patch) ->
        @constructor.construction_points.push(patch)
        @msg_board.post_message({patch: patch})

    _get_construction_dist: (patch) ->
        min_dist = null
        for point in @constructor.construction_points
            dist_to_point = ABM.util.distance(patch.x, patch.y, point.x, point.y)
            if (not min_dist?) or dist_to_point < min_dist
                min_dist = dist_to_point
        return min_dist




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



