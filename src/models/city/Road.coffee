class Road
    # Agentscript stuff
    @roads: null
    @default_color: [80, 80, 80]


    @initialize_module: (patches, road_breed) ->
        @roads = road_breed
        @roads.setDefault("color", @default_color)
        patches.setDefault("road_distance", null)

    @makeHere: (patch) ->
        @roads.setBreed patch

        CityModel.instance.roadAStar.setWalkable(patch)

        @_update_distance(patch, 0)
        null

    @recalculate_distances: () ->
        @_update_distance(road, 0) for road in @roads

    @_update_distance: (patch, road_distance) ->
        patch.road_distance = road_distance
        # patch.label = 0
        roads_to_update = @_get_roads_to_update(patch, 0)
        while roads_to_update.length > 0
            [road, new_distance] = roads_to_update.pop()
            road.road_distance = new_distance
            # road.label = new_distance
            roads_to_update.push(n_road) for n_road in @_get_roads_to_update(road, new_distance)
        null

    @_get_roads_to_update: (road, new_distance) ->
        to_update = []
        for n_road in road.n4
            if not n_road.road_distance? or n_road.road_distance > new_distance + 1
                to_update.push([n_road, new_distance + 1])
        return to_update

    @_spread_connectivity: (patch) ->
        new_distance = patch.road_distance + 1
        for n_patch in patch.n4
            if not n_patch.road_distance? or n_patch.road_distance > new_distance
                @_set_distance_to_road(n_patch, new_distance)
        null

    @is_road_here: (patch) ->
        return patch.breed is @roads
