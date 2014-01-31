u = ABM.util # ABM.util alias, u.s is also ABM.shape accessor.
class MyModel extends ABM.Model
    setup: ->
        @agentBreeds "embers fires"
        @patchBreeds "trees"

        @agents.setDefault "shape", "square"
        @agents.setDefault "heading", 0 # override promotion to random angle
        
        @fires.setDefault "color", [255,0,0]

        @ember_default_color = [255,34,34]
        @embers.setDefault "color", @ember_default_color
        @embers.setDefault "intensity", 1
        
        @trees.setDefault "color", [0,255,0]
        @trees.setDefault "burnt", false

        @refreshPatches = false 
        @anim.setRate 60, false
        
        @density = 65 # percent
        @ember_decay_rate = 0.3

        @spread_time = 0
        @cooloff_time = 0
        @iters = 0
        @n_fires = 0
        @n_embers = 0


        @trees.setBreed patch for patch in @patches when u.randomInt(100) < @density

        #@ignite u.oneOf @trees
        @ignite tree for tree in @trees when tree.x is @patches.minX by -1

    ignite: (tree) ->
        tree.sprout 1, @fires
        tree.burnt = true
        tree.color = [0,0,0]
        tree.draw @contexts.patches

    spread: (fire) ->
        @ignite tree for tree in fire.p.n4 when tree.breed.name is "trees" and not tree.burnt
        fire.p.sprout 1, @embers
        fire.die()

    coolOff: (ember) ->
        ember.intensity *= 1 - @ember_decay_rate
        ember.color = u.scaleColor @ember_default_color, ember.intensity
        if ember.intensity < .5
            ember.die()

    step: ->
        unless @agents.any()
            console.log "..stopping, fire done at tick: #{@anim.ticks}"
            @stop()

        @n_embers += @embers.length
        iter_start = performance.now()
        @coolOff ember for ember in @embers by -1
        iter_end = performance.now()
        @cooloff_time += iter_end - iter_start

        @n_fires += @fires.length
        iter_start = performance.now()
        @spread fire for fire in @fires by -1
        iter_end = performance.now()
        @spread_time += iter_end - iter_start

        @iters++

        if @anim.ticks % 10 is 0
            console.log @anim.toString()
            #console.log "spread: #{@spread_time / @iters} --- coolOff: #{@cooloff_time / @iters}"
            #console.log "#{@n_embers / @iters} --- #{@n_fires / @iters}"
            @spread_time = 0
            @cooloff_time = 0
            @iters = 0
            @n_fires = 0
            @n_embers = 0
        

# div, patchSize, minX, maxX, minY, maxY, isTorus, hasNeighbors
#   Defaults: 13, -16, 16, -16, 16, false, true
model = new MyModel "layers", 2, -125, 125, -125, 125
model.debug() # Debug: Put Model vars in global name space
model.start() # Run model immediately after startup initialization