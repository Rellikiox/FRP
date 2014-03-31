class Road
    # Agentscript stuff
    @roads: null
    @default_color: [80, 80, 80]

    @too_connected_threshold = 2


    @initialize: (@roads) ->
        @roads.setDefault("color", @default_color)

    @set_breed: (patch, city_hall_dist=null) ->
        @roads.setBreed(patch)
        extend(patch, Road)
        patch.init(city_hall_dist)

    init: (city_hall_dist) ->
        @_update_navigation()
        @_update_distances(0, city_hall_dist)
        if RoadNode.check_patch(@)
            RoadNode.spawn_node(@)
        null

    _update_navigation: () ->
        CityModel.set_road_nav_patch_walkable(@)

    _update_distances: (@dist_to_road, city_hall_dist) ->
        city_hall_dist ?= Road._get_min_neighbour(@, "dist_to_city_hall", get_value: true) + 1
        @_set_city_hall_dist(city_hall_dist)
        roads_to_update = Road._get_roads_to_update(@, 0)
        while roads_to_update.length > 0
            [road, new_distance] = roads_to_update.pop()
            road.dist_to_road = new_distance
            # road.label = new_distance
            roads_to_update.push(n_road) for n_road in Road._get_roads_to_update(road, new_distance)
        null

    _set_city_hall_dist: (@dist_to_city_hall) ->
        for n_road in @n4 when Road.is_road(n_road)
            if not n_road.dist_to_city_hall? or n_road.dist_to_city_hall > dist_to_city_hall + 1
                @_set_city_hall_dist(n_road, dist_to_city_hall + 1)


    @recalculate_distances: () ->
        @_update_distances(road, 0, null) for road in @roads

    @_get_roads_to_update: (road, new_distance) ->
        to_update = []
        for n_road in road.n4
            if not n_road.dist_to_road? or n_road.dist_to_road > new_distance + 1
                to_update.push([n_road, new_distance + 1])
        return to_update

    @_spread_connectivity: (patch) ->
        new_distance = patch.dist_to_road + 1
        for n_patch in patch.n4
            if not n_patch.dist_to_road? or n_patch.dist_to_road > new_distance
                @_set_distance_to_road(n_patch, new_distance)
        null

    @is_road: (patch) ->
        return patch.breed is @roads

    @get_closest_road_to: (point) ->
        patch = CityModel.get_patch_at(point)
        while patch.dist_to_road != 0
            patch = @_get_min_neighbour(patch, "dist_to_road", {})
        return patch

    @is_too_connected: (point) ->
        patch = CityModel.get_patch_at(point)
        return patch.dist_to_road <= Road.too_connected_threshold

    @_get_min_neighbour: (patch, param, {get_value, filter, neighbours}) ->
        get_value ?= false
        filter ?= (() -> true)
        neighbours ?= ((p) -> p.n4)

        min_patch = patch
        for neighbour in neighbours(patch) when filter(neighbour)
            if not min_patch[param]? or neighbour[param] < min_patch[param]
                min_patch = neighbour
        if get_value
            return min_patch[param]
        else
            return min_patch

    @_get_max_neighbour: (patch, param, {get_value, filter, neighbours}) ->
        get_value ?= false
        filter ?= (() -> true)
        neighbours ?= ((p) -> p.n4)

        max_patch = patch
        for neighbour in neighbours(patch) when filter(neighbour)
            if not max_patch[param]? or neighbour[param] > max_patch[param]
                max_patch = neighbour
        if get_value
            return max_patch[param]
        else
            return max_patch

    @add_road_node: (road) ->
        @road_nodes.push(road)

    @_get_distance: (road_a, road_b) ->
        dx = Math.abd(road_a.x, road_b.x)
        dy = Math.abd(road_a.y, road_b.y)
        return dx + dy

    @get_road_distance: (road_a, road_b) ->
        return CityModel.instance.roadAStar.getPath(road_a, road_b).length

    @get_connectivity: (patch) ->
        return patch.dist_to_road

    @get_road_neighbours: (patch) ->
        return (road for road in patch.n4 when Road.is_road(road))

CityModel.register_module(Road, [], ['roads'])



class RoadNode
    @breed_name: 'road_nodes'

    # Agentscript stuff
    @road_nodes: null
    @default_color: [160,160,160]

    @initialize: (@road_nodes) ->
        @road_nodes.setDefault('color', @default_color)
        @road_nodes.setDefault('shape', 'circle')
        @road_nodes.setDefault('size', 0.4)

    @check_patch: (patch) ->
        return Road.is_road(patch) and not patch.node?

    @spawn_node: (patch) ->
        node = RoadNode._make_node(patch)
        RoadNode._prepare_neighbour_roads(patch)
        node.connect()
        return node

    @split_link_at: (road) ->
        [node_a, node_b] = RoadNode._get_nodes_connecting(road)
        # upstream_node = RoadNode._find_upstream_node(road)
        # downstream_node = RoadNode._find_downstream_node(road)

        RoadNode._remove_link_between(node_a, node_b)

        node = RoadNode._make_node(road)
        node.creating = false

        CityModel.link_agents(node_a, node)
        CityModel.link_agents(node, node_b)

    @_make_node: (road) ->
        new_node = road.sprout(1, @road_nodes)[0]
        extend(new_node, RoadNode)
        road.node = new_node
        return new_node

    @_prepare_neighbour_roads: (road) ->
        for n_road in road.n4 when Road.is_road(n_road) and not n_road.node?
            RoadNode.split_link_at(n_road)

    @_get_nodes_connecting: (road) ->
        neighbour_roads = Road.get_road_neighbours(road)
        [road_a, road_b] = @_get_aligned_patches(neighbour_roads)
        [a_dir, b_dir] = @_get_direction(road_a, road_b)

        while not road_a.node?
            road_a = @_get_neighbour_with_offset(road_a, a_dir)
        while not road_b.node?
            road_b = @_get_neighbour_with_offset(road_b, b_dir)

        return [road_a.node, road_b.node]

    @_get_aligned_patches: (patches) ->
        if @_are_aligned(patches[0], patches[1])
            return [patches[0], patches[1]]
        else if @_are_aligned(patches[1], patches[2])
            return [patches[1], patches[2]]
        else
            return [patches[0], patches[2]]

    @_are_aligned: (patch_a, patch_b) ->
        return patch_a.x == patch_b.x or patch_a.y == patch_b.y

    @_get_direction: (patch_a, patch_b) ->
        dx = (patch_a.x - patch_b.x) / 2
        dy = (patch_a.y - patch_b.y) / 2
        return [{x: dx, y: dy}, {x: -dx, y: -dy}]

    @_get_neighbour_with_offset: (patch, offset) ->
        for n in patch.n4
            if n.x == patch.x + offset.x and n.y == patch.y + offset.y
                return n

    @_remove_link_between: (node_a, node_b) ->
        link.die() for link in node_a.myLinks() when link.otherEnd(node_a) is node_b
        null



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


CityModel.register_module(RoadNode, ['road_nodes'], [])
