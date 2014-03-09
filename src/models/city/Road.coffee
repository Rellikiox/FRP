class Road
    # Agentscript stuff
    @roads: null
    @default_color: [80, 80, 80]

    @too_connected_threshold = 2


    @initialize_module: (patches, road_breed) ->
        @roads = road_breed
        @roads.setDefault("color", @default_color)
        patches.setDefault("dist_to_road", null)

    @makeHere: (patch) ->
        @roads.setBreed patch
        CityModel.instance.roadAStar.setWalkable(patch)
        @_update_distances(patch, 0)
        null

    @recalculate_distances: () ->
        @_update_distances(road, 0) for road in @roads

    @_update_distances: (patch, dist_to_road) ->
        patch.dist_to_road = dist_to_road
        @_set_city_hall_dist(patch, @_get_min_neighbour(patch, ((p) -> p.n4), "dist_to_city_hall", true) + 1)
        roads_to_update = @_get_roads_to_update(patch, 0)
        while roads_to_update.length > 0
            [road, new_distance] = roads_to_update.pop()
            road.dist_to_road = new_distance
            # road.label = new_distance
            roads_to_update.push(n_road) for n_road in @_get_roads_to_update(road, new_distance)
        null

    @_set_city_hall_dist: (road, dist_to_city_hall) ->
        road.dist_to_city_hall = dist_to_city_hall
        road.label = road.dist_to_city_hall

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

    @is_road_here: (patch) ->
        return patch.breed is @roads

    @get_closest_road_to: (point) ->
        patch = CityModel.get_patch_at(point)
        while patch.dist_to_road != 0
            patch = @_get_min_neighbour(patch, ((p) -> p.n4), "dist_to_road")
        return patch

    @is_too_connected: (point) ->
        patch = CityModel.get_patch_at(point)
        return patch.dist_to_road <= Road.too_connected_threshold

    @_get_min_neighbour: (patch, neighbours, param, get_value=false) ->
        min_patch = patch
        for neighbour in neighbours(patch)
            if not min_patch[param]? or neighbour[param] < min_patch[param]
                min_patch = neighbour
        if get_value
            return min_patch[param]
        else
            return min_patch


