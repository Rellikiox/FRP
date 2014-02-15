class House
    # Agentscript stuff
    @breed_name: 'houses'
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
        patch.color = [100,0,0]

    @isHouseHere: (patch) ->
        return patch.breed is @patchSet()
