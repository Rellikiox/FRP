class RoadMaker extends ABM.Agent
    # Agentscript stuff
    @breed_name: 'inspectors'
    @breed: null

    # Appearance
    @color: [255,255,0]
    @size:  1

    # Behavior
    @radius_increment = 10

    # Default vars
    target_point: null
    local_point: null
    ring_radius: 10

    @agentSet: ->
        if not @breed?
            for breed in ABM.agents.breeds
                if breed.name is @breed_name
                    @breed = breed
                    break
        return @breed

    @makeNew: (x,y) ->
        road_maker = new RoadMaker x, y, [0,255,0], 1
        @agentSet().add road_maker
        return road_maker
