u = ABM.util # ABM.util alias, u.s is also ABM.shape accessor.
class MyModel extends ABM.Model
    setup: ->
        # No optimizations: 30fps
        @patches.usePixels() # 57+fps
        # @patches.cacheAgentsHere() # 28-9fps, not needed * overhead
        # two: 57+fps, fast patches get us to max
        
        # globals
        @density = 25

        @anim.setRate 10, false
        
        p.alive = yes for p in @patches when u.randomInt(100) < @density

    countLiveNeighbors: (patch) ->
        neighbors = (n for n in patch.n when n.alive)
        neighbors.length

    step: ->
        console.log @anim.toString() if @anim.ticks % 10 is 0

        for p in @patches
            neighbors = @countLiveNeighbors p
            switch neighbors
                when 2 then p.new_alive = p.alive
                when 3 then p.new_alive = yes
                else p.new_alive = no       

        for p in @patches
            p.alive = p.new_alive     
            if p.alive
                p.color = [255,0,0]
            else
                p.color = [255,255,255]


# div, patchSize, minX, maxX, minY, maxY, isTorus, hasNeighbors
#   Defaults: 13, -16, 16, -16, 16, false, true
model = new MyModel "layers", 10, -25, 25, -20, 20, true
model.debug() # Debug: Put Model vars in global name space
model.start() # Run model immediately after startup initialization