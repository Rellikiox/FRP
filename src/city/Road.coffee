class Road
    # Agentscript stuff
    @roads: null
    @default_color: [80, 80, 80]

    @too_connected_threshold = 2


    @initialize_module: (road_breed) ->
        @roads = road_breed
        @roads.setDefault("color", @default_color)

    @set_breed: (patch, city_hall_dist=null) ->
        @roads.setBreed patch
        CityModel.instance.roadAStar.setWalkable(patch)
        @_update_distances(patch, 0, city_hall_dist)
        if RoadNode.check_patch(patch)
            RoadNode.spawn_node(patch)
        null

    @recalculate_distances: () ->
        @_update_distances(road, 0, null) for road in @roads

    @_update_distances: (patch, dist_to_road, city_hall_dist) ->
        city_hall_dist ?= @_get_min_neighbour(patch, "dist_to_city_hall", get_value: true) + 1
        patch.dist_to_road = dist_to_road
        @_set_city_hall_dist(patch, city_hall_dist)
        roads_to_update = @_get_roads_to_update(patch, 0)
        while roads_to_update.length > 0
            [road, new_distance] = roads_to_update.pop()
            road.dist_to_road = new_distance
            # road.label = new_distance
            roads_to_update.push(n_road) for n_road in @_get_roads_to_update(road, new_distance)
        null

    @_set_city_hall_dist: (road, dist_to_city_hall) ->
        road.dist_to_city_hall = dist_to_city_hall
        # road.label = road.dist_to_city_hall
        for n_road in road.n4 when n_road.breed is @roads
            if not n_road.dist_to_city_hall? or n_road.dist_to_city_hall > dist_to_city_hall + 1
                @_set_city_hall_dist(n_road, dist_to_city_hall + 1)

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


class RoadNode
    # Agentscript stuff
    @road_nodes: null
    @default_color: [160,160,160]

    @initialize_module: (road_nodes_breed) ->
        @road_nodes = road_nodes_breed
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
        upstream_node = RoadNode._find_upstream_node(road)
        downstream_node = RoadNode._find_downstream_node(road)

        RoadNode._remove_link_between(upstream_node, downstream_node)

        node = RoadNode._make_node(road)

        CityModel.link_agents(upstream_node, node)
        CityModel.link_agents(node, downstream_node)

    @_make_node: (road) ->
        new_node = road.sprout(1, @road_nodes)[0]
        extend(new_node, RoadNode_instance_properties)
        road.node = new_node
        return new_node

    @_prepare_neighbour_roads: (road) ->
        for n_road in road.n4 when Road.is_road(n_road) and not n_road.node?
            RoadNode.split_link_at(n_road)

    @_find_upstream_node: (road) ->
        while not road.node?
            road = Road._get_max_neighbour(road, "dist_to_city_hall", {filter: (p) ->  Road.is_road(p) and not p.node?.creating})
        return road.node

    @_find_downstream_node: (road) ->
        while not road.node?
            road = Road._get_min_neighbour(road, "dist_to_city_hall", {})
        return road.node

    @_remove_link_between: (node_a, node_b) ->
        link.die() for link in node_a.myLinks() when link.otherEnd(node_a) is node_b
        null


RoadNode_instance_properties =
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


