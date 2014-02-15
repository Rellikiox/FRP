class HouseMaker extends ABM.Agent
    # Agentscript stuff
    @breed_name: 'houseMakers'
    @breed: null

    # Appearance
    @color: [255,0,0]
    @size:  1

    @agentSet: ->
        if not @breed?
            for breed in ABM.agents.breeds
                if breed.name is @breed_name
                    @breed = breed
                    break
        return @breed

    @makeNew: (x,y) ->
        house_maker = new HouseMaker x, y, @color, 1
        @agentSet().add house_maker
        return house_maker

    constructor: (x, y, @color, @size) ->
        super
        @setXY x, y

    step: ->
        # Check if there are any patches where a house might go
        near_patches = ABM.util.shuffle @p.n
        for patch in near_patches
            if not House.isHouseHere(patch) and not Road.isRoadHere(patch)
                @placeHouse patch
                # Exit as soon as we place one
                break

        # Move to a random new patch
        for patch in near_patches
            if Road.isRoadHere patch
                @moveTo patch

    placeHouse: (patch) ->
        House.makeHere patch

    moveTo: (patch) ->
        @setXY patch.x, patch.y



