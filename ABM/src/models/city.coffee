u = ABM.util # ABM.util alias, u.s is also ABM.shape accessor.
class MyModel extends ABM.Model
    setup: ->
        
        @patchBreeds "city_hall"
        @agentBreeds "roadMakers roads" 
        @anim.setRate 30, false

        @roads.setDefault "color", [0, 0, 255]
        @roads.setDefault "shape", "circle"
        @roads.setDefault "size", 0.3

        @links.setDefault "labelColor", [255,0,0]

        for p in @patches
            p.color = u.randomGray()


        @city_hall = @createCityHall 0, 0
        patch = u.oneOf @city_hall.p.n
        @createRoadMaker patch.x, patch.y 


    step: ->
        console.log @anim.toString() if @anim.ticks % 100 == 0

        for a in @roadMakers
            a.rotate u.randomCentered(u.degToRad(30))
            a.forward 0.1
            if not @patchHasRoad a.p
                @dropRoad a
            


    patchHasRoad: (patch) ->
        return true for agent in patch.agentsHere() when agent.breed is @roads

    dropRoad: (agent) ->
        road = (agent.p.sprout 1, @roads)[0]
        if agent.previous_node?
            @links.create road, agent.previous_node
        agent.previous_node = road


        
    createCityHall: (x, y) ->
        agent = (@agents.create 1)[0]
        agent.setXY x, y
        agent.color = [255,0,0]
        agent.shape = "square"
        agent.size = 1
        agent

    createRoadMaker: (x, y) ->
        agent = (@roadMakers.create 1)[0]
        agent.setXY x, y
        agent.color = [0,255,0]
        agent.size = 1
        agent.previous_node = null

        

# div, patchSize, minX, maxX, minY, maxY, isTorus, hasNeighbors
#   Defaults: 13, -16, 16, -16, 16, false, true
model = new MyModel "layers", 16, -16, 16, -16, 16
model.debug() # Debug: Put Model vars in global name space
model.start() # Run model immediately after startup initialization