
define [], () ->

    console.log "Loaded city/RoadNodes.coffee"

    RoadManager = null

    class RoadNodeManager

        default_color: [160,160,160]

        constructor: (@road_nodes, road_manager) ->
            RoadManager = road_manager
            @road_nodes.setDefault('color', @default_color)
            @road_nodes.setDefault('shape', 'circle')
            @road_nodes.setDefault('size', 0.4)

        check_patch: (patch) ->
            return Road.is_road(patch) and not patch.node?

        spawn_node: (patch) ->
            node = RoadNode._make_node(patch)
            RoadNode._prepare_neighbour_roads(patch)
            node.connect()
            return node

        split_link_at: (road) ->
            [node_a, node_b] = RoadNode._get_nodes_connecting(road)
            # upstream_node = RoadNode._find_upstream_node(road)
            # downstream_node = RoadNode._find_downstream_node(road)

            RoadNode._remove_link_between(node_a, node_b)

            node = RoadNode._make_node(road)
            node.creating = false

            CityModel.link_agents(node_a, node)
            CityModel.link_agents(node, node_b)

        _make_node: (road) ->
            new_node = road.sprout(1, @road_nodes)[0]
            extend(new_node, RoadNode.prototype)
            road.node = new_node
            return new_node

        _prepare_neighbour_roads: (road) ->
            for n_road in road.n4 when Road.is_road(n_road) and not n_road.node?
                RoadNode.split_link_at(n_road)

        _get_nodes_connecting: (road) ->
            neighbour_roads = Road._get_road_neighbours(road)
            [road_a, road_b] = @_get_aligned_patches(neighbour_roads)
            [a_dir, b_dir] = @_get_direction(road_a, road_b)

            while not road_a.node?
                road_a = @_get_neighbour_with_offset(road_a, a_dir)
            while not road_b.node?
                road_b = @_get_neighbour_with_offset(road_b, b_dir)

            return [road_a.node, road_b.node]

        _get_aligned_patches: (patches) ->
            if @_are_aligned(patches[0], patches[1])
                return [patches[0], patches[1]]
            else if @_are_aligned(patches[1], patches[2])
                return [patches[1], patches[2]]
            else
                return [patches[0], patches[2]]

        _are_aligned: (patch_a, patch_b) ->
            return patch_a.x == patch_b.x or patch_a.y == patch_b.y

        _get_direction: (patch_a, patch_b) ->
            dx = (patch_a.x - patch_b.x) / 2
            dy = (patch_a.y - patch_b.y) / 2
            return [{x: dx, y: dy}, {x: -dx, y: -dy}]

        _get_neighbour_with_offset: (patch, offset) ->
            for n in patch.n4
                if n.x == patch.x + offset.x and n.y == patch.y + offset.y
                    return n

        _remove_link_between: (node_a, node_b) ->
            link.die() for link in node_a.myLinks() when link.otherEnd(node_a) is node_b
            null

    class RoadNode

        creating: true

        step: () ->

        connect: () ->
            if @_any_neighbours_nodes()
                @_connect_to_neighbours()
                @_smooth_neighbours()
            @creating = false

        _connect_to_neighbours: () ->
            neighbour_nodes = @_get_node_neighbours()
            for node in neighbour_nodes
                CityModel.link_agents(@, node)

        _any_neighbours_nodes: () ->
            return @_get_node_neighbours().length > 0

        _smooth_neighbours: () ->
            nodes = @_get_node_neighbours()
            nodes.push(@)
            for node in nodes
                node._smooth_node()

        _get_node_neighbours: () ->
            return (patch.node for patch in @p.n4 when patch.node?)

        _is_aligned_with: (node) ->
            return @p.x == node.p.x or @p.y == node.p.y

        _smooth_node: () ->
            neighbours = @linkNeighbors()
            if neighbours.length == 2
                [node_a, node_b] = neighbours
                if node_a._is_aligned_with(node_b)
                    CityModel.link_agents(node_a, node_b)
                    # smooth node_a and node_b ?
                    @p.node = null
                    @die()

    return RoadNodeManager
