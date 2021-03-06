    u = ABM.util # ABM.util alias, u.s is also ABM.shape accessor.
    class MyModel extends ABM.Model
        setup: ->
            
            # Set up our breeds. Fires burn trees and turn into embers. Embers decay overtime and eventualy they die.
            @agentBreeds "embers fires"
            @patchBreeds "trees"

            # Set up default values
            @agents.setDefault "shape", "square"
            @agents.setDefault "heading", 0 # override promotion to random angle
            
            @fires.setDefault "color", [255,0,0]

            @default_ember_color = [255,34,34]
            @ash_threshold = 0.5
            @embers.setDefault "color", @ember_default_color
            @embers.setDefault "intensity", 1

            @ash_color = [34,34,34]
            @trees.setDefault "color", [0,255,0]
            @trees.setDefault "burnt", false

            # Set up agentscript options
            @refreshPatches = false 
            @anim.setRate 60, false
            
            ###
              Set up options for our simulation:
                - density: percentaje of patches that will be trees
                - ember_decay_rate: rate at which an ember decays and eventually transforms into ash. 
                    1 is inmediately, 0 is never. The lower this number is the more embers there will 
                    be at any given time, and thus, the slower the animation will be.
            ###
            @density = 100 # percent
            @ember_decay_rate = 0.01

            # Create our trees
            @trees.setBreed patch for patch in @patches when u.randomInt(100) < @density

            # Start with a random tree
            #@ignite u.oneOf @trees
            # Start with the leftmost column of trees
            @ignite tree for tree in @trees when tree.x is @patches.minX by -1

        # Ignite a tree. This spawns a fire in this patch and burns the tree
        ignite: (tree) ->
            tree.sprout 1, @fires
            tree.burnt = true
            tree.color = @ash_color
            # Draw this patch, since we set @refreshPatches to false 
            tree.draw @contexts.patches

        # Spread a fire agent. This calls ignite for all surrounding trees that are not already burnt, then the fire dies.
        spread: (fire) ->
            @ignite tree for tree in fire.p.n4 when tree.breed is @trees and not tree.burnt
            #fire.p.sprout 1, @embers
            fire.die()

        # Cool off an ember. Decrease the intensity by the given decay rate, update the color and kill the agent if it goes under the ash threshold
        coolOff: (ember) ->
            ember.intensity *= 1 - @ember_decay_rate
            if ember.intensity < @ash_threshold
                ember.die()
            else
              ember.color = u.scaleColor @default_ember_color, ember.intensity

        # Step over all fires and embers
        step: ->
            unless @agents.any()
                console.log "..stopping, fire done at tick: #{@anim.ticks}"
                @stop()

            #@coolOff ember for ember in @embers by -1
            @spread fire for fire in @fires by -1

            console.log @anim.toString() if @anim.ticks % 100 is 0
            

    # div, patchSize, minX, maxX, minY, maxY, isTorus, hasNeighbors
    #   Defaults: 13, -16, 16, -16, 16, false, true
    model = new MyModel "layers", 2, -125, 125, -125, 125
    model.debug() # Debug: Put Model vars in global name space
    model.start() # Run model immediately after startup initialization