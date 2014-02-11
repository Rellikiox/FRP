class Road
    # Agentscript stuff
    @breed_name: 'roads'
    @breed: null

    @patchSet: ->
        if not @breed?
            for breed in ABM.patches.breeds
                if breed.name is @breed_name
                    @breed = breed 
                    break
        return @breed

    @makeHere: (patch) ->
        @patchSet().setBreed patch

    @isRoadHere: (patch) ->
        return patch.breed is @patchSet()