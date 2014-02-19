class Road
    # Agentscript stuff
    @breed_name: 'roads'
    @breed: null

    @connectivity_threshold: 0.2

    @patchSet: ->
        if not @breed?
            for breed in ABM.patches.breeds
                if breed.name is @breed_name
                    @breed = breed
                    break
        return @breed

    @makeHere: (patch) ->
        @patchSet().setBreed patch

        CityModel.instance.roadAStar.setWalkable(patch)

        patch.color = [0,100,0]
        patch.connectivity = 1.0
        for n_patch in patch.n
            if n_patch.connectivity < patch.connectivity
                @setConnectivity n_patch, 1.0
        null

    @setConnectivity: (patch, connectivity) ->
        patch.connectivity = connectivity

        if connectivity == 1 then patch.connectivity_color = [30, 130, 30]
        else if connectivity == 0.5 then patch.connectivity_color = [60, 160, 60]
        else if connectivity == 0.25 then patch.connectivity_color = [90, 190, 90]

        @spreadConnectivity patch


    @spreadConnectivity: (patch) ->
        new_connectivity = (patch.connectivity / 2)
        if new_connectivity > @connectivity_threshold
            for n_patch in patch.n
                if n_patch.connectivity < patch.connectivity
                    @setConnectivity n_patch, new_connectivity
        null

    @isRoadHere: (patch) ->
        return patch.breed is @patchSet()
