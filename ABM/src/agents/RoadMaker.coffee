class Road
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

        

class RoadMaker extends ABM.Agent
    @breed_name: 'roadMakers'
    @breed: null
    @color: [0,255,0]
    @size:  1

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

    constructor: (x, y, @color, @size) ->
        super
        @setXY x, y
        @target_point = null

    step: ->
        @forward(0.1)
        if not Road.isRoadHere(@p)
            @dropRoad()

    dropRoad: ->
        Road.makeHere(@p)
