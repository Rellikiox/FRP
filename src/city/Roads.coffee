define [], () ->

    console.log "Loaded city/Roads.coffee"

    class RoadManager

        too_connected_threshold = 2

        default_color: [80, 80, 80]

        constructor: (@roads) ->
            @roads.setDefault("color", @default_color)

        set_breed: (patch, city_hall_dist=null) ->
            @roads.setBreed patch
            CityModel.instance.roadAStar.setWalkable(patch)
            @_update_distances(patch, 0, city_hall_dist)
            if RoadNode.check_patch(patch)
                RoadNode.spawn_node(patch)
            null

        recalculate_distances: () ->
            @_update_distances(road, 0, null) for road in @roads

        _update_distances: (patch, dist_to_road, city_hall_dist) ->
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

        _set_city_hall_dist: (road, dist_to_city_hall) ->
            road.dist_to_city_hall = dist_to_city_hall
            # road.label = road.dist_to_city_hall
            for n_road in road.n4 when n_road.breed is @roads
                if not n_road.dist_to_city_hall? or n_road.dist_to_city_hall > dist_to_city_hall + 1
                    @_set_city_hall_dist(n_road, dist_to_city_hall + 1)

        _get_roads_to_update: (road, new_distance) ->
            to_update = []
            for n_road in road.n4
                if not n_road.dist_to_road? or n_road.dist_to_road > new_distance + 1
                    to_update.push([n_road, new_distance + 1])
            return to_update

        _spread_connectivity: (patch) ->
            new_distance = patch.dist_to_road + 1
            for n_patch in patch.n4
                if not n_patch.dist_to_road? or n_patch.dist_to_road > new_distance
                    @_set_distance_to_road(n_patch, new_distance)
            null

        is_road: (patch) ->
            return patch.breed is @roads

        get_closest_road_to: (point) ->
            patch = CityModel.get_patch_at(point)
            while patch.dist_to_road != 0
                patch = @_get_min_neighbour(patch, "dist_to_road", {})
            return patch

        is_too_connected: (point) ->
            patch = CityModel.get_patch_at(point)
            return patch.dist_to_road <= @too_connected_threshold

        _get_min_neighbour: (patch, param, {get_value, filter, neighbours}) ->
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

        _get_max_neighbour: (patch, param, {get_value, filter, neighbours}) ->
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

        add_road_node: (road) ->
            @road_nodes.push(road)

        _get_distance: (road_a, road_b) ->
            dx = Math.abd(road_a.x, road_b.x)
            dy = Math.abd(road_a.y, road_b.y)
            return dx + dy

        get_road_distance: (road_a, road_b) ->
            return CityModel.instance.roadAStar.getPath(road_a, road_b).length

        get_connectivity: (patch) ->
            return patch.dist_to_road

        _get_road_neighbours: (patch) ->
            return (road for road in patch.n4 when @is_road(road))

