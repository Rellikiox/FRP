class Inspector
    # Agentscript stuff
    @inspectors: null

    # Appearance
    @default_color: [0, 0, 255]

    @initialize: (@inspectors, config) ->
        @inspectors.setDefault('color', @default_color)

        RoadInspector.initialize()
        GridRoadInspector.initialize()

        for key, value of config.inspectors.node_inspector
            NodeInspector.prototype[key] = value
        for key, value of config.inspectors.road_inspector
            RadialRoadInspector.prototype[key] = value
        null

    @spawn_road_inspector: (patch) ->
        inspector = @spawn_inspector(patch, GridRoadInspector)
        inspector.init()
        inspector = @spawn_inspector(patch, GridRoadInspector)
        inspector.init()
        return inspector

    @spawn_node_inspector: (patch) ->
        inspector = @spawn_inspector(patch, NodeInspector)
        inspector.init()
        inspector = @spawn_inspector(patch, NodeInspector)
        inspector.init()
        inspector = @spawn_inspector(patch, NodeInspector)
        inspector.init()
        return inspector

    @spawn_plot_inspector: (patch) ->
        inspector = @spawn_inspector(patch, PlotInspector)
        inspector.init()
        return inspector

    @spawn_house_inspector: (patch) ->
        inspector = @spawn_inspector(patch, HouseInspector)
        inspector.init(patch)
        return inspector

    @spawn_inspector: (patch, klass) ->
        inspector = patch.sprout(1, @inspectors)[0]
        extend(inspector, FSMAgent, MovingAgent, klass)
        return inspector

    speed: 0.05

    test: 1


class NodeInspector extends Inspector

    current_message: null
    nodes_under_investigation: []
    inspection_radius: 20
    max_distance_factor: 3

    init: () ->
        @_set_initial_state('get_message')
        @msg_boards =
            inspect: MessageBoard.get_board('node_built')
            connect: MessageBoard.get_board('nodes_unconnected')
            bulldoze: MessageBoard.get_board('bulldoze_path')
            construction: MessageBoard.get_board('under_construction')

    s_get_message: () ->
        @current_message = @msg_boards.inspect.get_message()
        if @current_message?
            @_set_state('go_to_endpoint')

    s_go_to_endpoint: () ->
        if not @path?
            @path = CityModel.instance.roadAStar.getPath(@, @current_message.patch)

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
            path = @_get_terrain_path_to(node.node.p)
            crosses_plot = false
            for patch in path
                if Block.is_block(patch)
                    crosses_block = true
                    patch.under_construction = true
                    @msg_boards.construction.post_message({patch: patch})
                patch.under_construction = true
            if crosses_plot
                @msg_boards.bulldoze.post_message({path: path})
            else
                @msg_boards.connect.post_message({path: path})
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

    @construction_points: []

    @initialize: () ->
        @construction_points = []


    s_get_inspection_point: () ->
        @inspection_point = @_get_point_to_inspect()

        if RoadInspector._valid_point(@inspection_point)
            @_set_state('go_to_inspection_point')

    s_go_to_inspection_point: () ->
        if not @inspection_point?
            @_set_state('get_inspection_point')
            return

        @_move(@inspection_point)

        if @_in_point(@inspection_point)
            @_set_state('find_new_endpoint')


    _is_valid_construction_point: (patch) ->
        road_dist = Road.get_connectivity(patch)
        construction_dist = RoadInspector._get_construction_dist(patch)
        return road_dist > Road.too_connected_threshold && (not construction_dist? or construction_dist > Road.too_connected_threshold)

    _issue_construction: (patch) ->
        RoadInspector.construction_points.push(patch)
        @build_endpoint_board.post_message({patch: patch})

    @_valid_point: (point) ->
        return point? and CityModel.is_on_world(point) and not Road.is_road(CityModel.get_patch_at(point))

    @_get_construction_dist: (patch) ->
        min_dist = null
        for point in RoadInspector.construction_points
            dist_to_point = ABM.util.distance(patch.x, patch.y, point.x, point.y)
            if (not min_dist?) or dist_to_point < min_dist
                min_dist = dist_to_point
        return min_dist



class RadialRoadInspector extends RoadInspector
    ring_increment: 4
    ring_radius: 6

    min_increment: 3
    max_increment: 6

    init: () ->
        @radius = ABM.util.randomFloat(2 * Math.PI)
        @direction = ABM.util.oneOf([-1, 1])

        @_set_initial_state('get_inspection_point')
        @build_endpoint_board = MessageBoard.get_board('possible_node')
        @nodes_built_board = MessageBoard.get_board('node_built')


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
            @_set_state('increment_radius')
            @circular_direction = null
            @start_angle = null

    s_increment_radius: () ->
        @ring_radius += @ring_increment
        @_set_state('get_inspection_point')



    _get_point_to_inspect: () ->
        arc_length = ABM.util.randomInt2(@min_increment, @max_increment)
        polar_coords = @_get_polar_coords()
        arc_radians = arc_length / @ring_radius

        new_angle = polar_coords.angle + arc_radians * @direction

        x = Math.round(@ring_radius * Math.cos(new_angle))
        y = Math.round(@ring_radius * Math.sin(new_angle))
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

    _lap_completed: () ->
        return @angle_moved >= 2 * Math.PI


class GridRoadInspector extends RoadInspector

    @open_list: []
    @closed_list: []

    @initialize: () ->
        @open_list = []
        @closed_list = []


    horizontal_grid_size: 6
    vertical_grid_size: 4

    init: () ->
        if GridRoadInspector.open_list.length is 0
            GridRoadInspector.open_list.push(CityModel.instance.city_hall)


        @_set_initial_state('get_inspection_point')
        @build_endpoint_board = MessageBoard.get_board('possible_node')

    s_populate_open_list: () ->
        @_populate_open_list()
        @_set_state('get_inspection_point')

    s_find_new_endpoint: () ->
        if @_is_valid_construction_point(@p)
            @_issue_construction(@p)
        @_set_state('populate_open_list')



    _get_point_to_inspect: () ->
        node = GridRoadInspector.open_list.shift()
        GridRoadInspector.closed_list.push(node)
        return node

    _populate_open_list: () ->
        for node in @_get_possible_nodes()
            if not (node in GridRoadInspector.closed_list) and not (node in GridRoadInspector.open_list)
                GridRoadInspector.open_list.push(node)

    _get_possible_nodes: () ->
        points = [{x: @p.x, y: @p.y + @vertical_grid_size},
                  {x: @p.x + @horizontal_grid_size, y: @p.y},
                  {x: @p.x, y: @p.y - @vertical_grid_size},
                  {x: @p.x - @horizontal_grid_size, y: @p.y}]
        ABM.util.shuffle(points)
        return (CityModel.get_patch_at(point) for point in points)




class PlotInspector

    init: () ->
        @_set_initial_state('get_message')
        @patches_to_check = []
        @msg_boards =
            inspect: MessageBoard.get_board('inspect_plot')
            built: MessageBoard.get_board('plot_built')

    s_get_message: () ->
        @current_message = @msg_boards.inspect.get_message()
        if @current_message?
            @inspection_point = @current_message.patch
            @_set_state('go_to_point')

    s_go_to_point: () ->
        if not @inspection_point?
            @_set_state('s_get_message')
            return

        @_move(@inspection_point)

        if @_in_point(@inspection_point)
            @_set_state('check_possible_plots')

    # This checks each of the 8 surrounding patches
    # to see if they are part of a completed plot
    s_check_possible_plots: () ->
        if @patches_to_check.length is 0
            @patches_to_check = @_get_patches_to_check()

        @_check_patch(@patches_to_check.shift())

        if @patches_to_check.length is 0
            @_set_state('get_message')

    _get_patches_to_check: () ->
        patches = (p for p in @p.n when not Road.is_road(p))

        invalid = []
        for i in [patches.length-1..0] by -1
            for j in [0..patches.length-1]
                if i == j
                    break
                if @_adyacent(patches[i], patches[j])
                    invalid.push(patches[j])

        return (p for p in patches when not ABM.util.contains(invalid, p))


    _adyacent: (patch_a, patch_b) ->
        horizontal = Math.abs(patch_a.x - patch_b.x) == 1 and patch_a.y == patch_b.y
        adyacent = horizontal or patch_a.x == patch_b.x and Math.abs(patch_a.y - patch_b.y) == 1
        return adyacent

    _check_patch: (patch) ->
        if Plot.is_part_of_plot(patch)
            Plot.destroy_plot(patch.plot)

        if not @_any_edge_visible(patch)
            possible_plot = @_get_plot(patch)
            if possible_plot?
                plot = Plot.make_plot(possible_plot)
                @msg_boards.built.post_message({plot: plot})

    _any_edge_visible: (patch) ->
        current_patch = patch

        offsets = [{x: 0, y: 1}, {x: 1, y: 0}, {x: 0, y: -1}, {x: -1, y: 0}]
        # Look north
        edge = false
        for offset in offsets
            current_patch = patch
            while not edge
                current_patch = @_get_path_with_offset(current_patch, offset)
                if current_patch? and Road.is_road(current_patch)
                    break
                if not current_patch? or current_patch.isOnEdge()
                    edge = true
            if edge
                break
        return edge

    _get_path_with_offset: (patch, offset) ->
        point = {x: patch.x + offset.x, y: patch.y + offset.y}
        return CityModel.get_patch_at(point)

    # It's just a flood fill
    _get_plot: (patch) ->
        closed_list = []
        open_list = [patch]
        invalid = false
        while open_list.length > 0
            p = open_list.shift()
            if p.isOnEdge() or p.under_construction
                invalid = true
                break
            open_list.push(n) for n in p.n4 when not Road.is_road(n) and not ABM.util.contains(open_list, n) and not ABM.util.contains(closed_list, n)
            closed_list.push(p)
        if not invalid
            return closed_list
        else
            return null


class HouseInspector
    @ticks_per_report = 100

    init: (@house) ->
        @hidden = true
        @_set_initial_state('report_state')
        @msg_board = MessageBoard.get_board('population_needs')

    s_report_state: () ->
        @msg_board.post_message(
            'need': 'hospital'
            'house': @house
        )
        @ticks_since_report = 0
        @_set_state('wait')

    s_wait: () ->
        if @ticks_since_report > HouseInspector.ticks_per_report
            @_set_state('report_state')
        else
            @ticks_since_report += 1


CityModel.register_module(Inspector, ['inspectors'], [])

