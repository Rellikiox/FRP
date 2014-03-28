class Inspector
    # Agentscript stuff
    @inspectors: null

    # Appearance
    @default_color: [0, 0, 255]

    @initialize_module: (inspectors_breed, config) ->
        @inspectors = inspectors_breed
        @inspectors.setDefault('color', @default_color)

        for key, value of config.node_inspector
            NodeInspector.prototype[key] = value
        for key, value of config.road_inspector
            RoadInspector.prototype[key] = value
        null

    @spawn_road_inspector: (patch) ->
        return @spawn_inspector(patch, RoadInspector.prototype)

    @spawn_node_inspector: (patch) ->
        return @spawn_inspector(patch, NodeInspector.prototype)

    @spawn_inspector: (patch, prototype) ->
        inspector = patch.sprout(1, @inspectors)[0]
        extend(inspector, BaseAgent.prototype)
        extend(inspector, prototype)
        inspector.init()
        return inspector

    speed: 0.05


class NodeInspector extends Inspector

    current_message: null
    nodes_under_investigation: []
    inspection_radius: 20
    max_distance_factor: 3

    init: () ->
        @_set_initial_state('get_message')
        @msg_boards =
            inspect: MessageBoard.get_board('inspect_node')
            connect: MessageBoard.get_board('connect_nodes')

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
        if node.factor > @max_distance_factor
            @msg_boards.connect.post_message({patch_a: @.p, patch_b: node.node.p})
            return true
        return false

    _get_close_nodes: () ->
        nodes = []
        if @.p.node?
            nodes_to_check = RoadNode.road_nodes.inRadius(@.p.node, @inspection_radius)
        else
            nodes_to_check = RoadNode.road_nodes.inRadius(@, @inspection_radius)
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

    ring_increment: 4
    ring_radius: 6

    init: () ->
        @_set_initial_state('get_inspection_point')
        @build_endpoint_board = MessageBoard.get_board('build_endpoint')

    s_get_inspection_point: () ->
        @inspection_point = @_get_point_to_inspect()

        if @inspection_point?
            @_set_state('go_to_inspection_point')

    s_go_to_inspection_point: () ->
        if not @inspection_point?
            @_set_state('get_inspection_point')
            return

        @_move(@inspection_point)

        if @_in_point(@inspection_point)
            @_set_state('find_new_endpoint')

    s_find_new_endpoint: () ->
        if @_is_valid_construction_point(@p)
            @_issue_construction(@p)
            @_set_state('get_inspection_point')
        else
            @_set_state('get_away_from_road')

    s_get_away_from_road: () ->
        if not @circular_direction?
            @angle_moved = 0
            @circular_direction = ABM.util.oneOf([-1, 1])

        @_circular_move()
        if @_is_valid_construction_point(@p)
            @circular_direction = null
            @angle_moved = 0
            @_set_state('find_new_endpoint')

        if @_lap_completed()
            @circular_direction = null
            @start_angle = null
            @ring_radius += @ring_increment
            @_set_state('get_inspection_point')


    _get_point_to_inspect: () ->
        rand_angle  = ABM.util.randomFloat(2 * Math.PI)
        x = Math.round(@ring_radius * Math.cos(rand_angle))
        y = Math.round(@ring_radius * Math.sin(rand_angle))
        return {x: x, y: y}

    _circular_move: () ->
        polar_coords = @_get_polar_coords()
        angle_increment = (@speed / polar_coords.radius) * @circular_direction
        @angle_moved += Math.abs(angle_increment)
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
        return road_dist > 2 && (not construction_dist? or construction_dist > 2)

    _issue_construction: (patch) ->
        @constructor.construction_points.push(patch)
        @build_endpoint_board.post_message({patch: patch})

    _get_construction_dist: (patch) ->
        min_dist = null
        for point in @constructor.construction_points
            dist_to_point = ABM.util.distance(patch.x, patch.y, point.x, point.y)
            if (not min_dist?) or dist_to_point < min_dist
                min_dist = dist_to_point
        return min_dist

    _lap_completed: () ->
        return @angle_moved >= 2 * Math.PI
