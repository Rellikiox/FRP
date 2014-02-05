u = ABM.util # ABM.util alias, u.s is also ABM.shape accessor.
class MyModel extends ABM.Model
    setup: ->
        
        @patchBreeds "city_hall road"
        @agentBreeds "roadMakers" 
        @anim.setRate 1, false

        for p in @patches
            p.color = u.randomGray()



        @city_hall = @createCityHall 0, 0
        patch = u.oneOf @city_hall.p.n
        @createRoadMaker patch.x, patch.y 


    step: ->
        console.log @anim.toString()
        
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

    stepRoadMaker: (agent) ->
        next_patch = u.oneOF agent.p.n

        

# div, patchSize, minX, maxX, minY, maxY, isTorus, hasNeighbors
#   Defaults: 13, -16, 16, -16, 16, false, true
model = new MyModel "layers", 16, -16, 16, -16, 16
model.debug() # Debug: Put Model vars in global name space
model.start() # Run model immediately after startup initialization