require.config
    paths:
        'agentscript': 'agentscript/agentscript'
    shim:
        'agentscript':
            exports: 'ABM'


define ['agentscript', 'city/Inspectors', 'city/Planners', 'city/Roads', 'city/RoadNodes'],
(ABM, InspectorManager, PlannerManager, RoadManager, RoadNodeManager) ->

    console.log "Loaded city/CityModel.coffee"

    class CityModel extends ABM.Model

        @instance: null

        @get_patch_at: (point) ->
            return @instance.patches.patchXY(Math.round(point.x), Math.round(point.y))

        @is_on_world: (point) ->
            return @instance.patches.isOnWorld(Math.round(point.x), Math.round(point.y))

        @link_agents: (agent_a, agent_b) ->
            @instance.links.create(agent_a, agent_b)


        constructor: () ->
            @agent_breeds = []
            @patch_breeds = []
            CityModel.instance = this
            super

        setup: ->
            # @set_up_AStar_helpers()

            @set_default_params()
            @initialize_modules()

            @init_patches()
            # @spawn_entities()

        step: ->
            # console.log @anim.toString() if @anim.ticks % 100 == 0

            agent.step() for agent in @agents by -1

            # road_maker.step() for road_maker in @road_makers
            # house_maker.step() for house_maker in @house_makers

        # draw: ->
        #     switch @draw_mode
        #         when "normal" then @draw_normal_color()
        #         when "connectivity" then @draw_connectivity_color()
        #     super

        initialize_modules: () ->
            # inspector_breed = InspectorManager.inspector_breed
            # @agent_breeds.push(inspector_breed)

            # planner_breed = PlannerManager.planner_breed
            # @agent_breeds.push(planner_breed)

            @agent_breeds = ['inspectors', 'planners', 'road_nodes']

            @initialize_breeds()

            @road_node_manager = new RoadNodeManager(@['road_nodes'])
            @inspector_manager = new InspectorManager(@['inspectors'])
            @planner_manager = new PlannerManager(@['planners'])
            # Road.initialize_module(@roads)
            # RoadNode.initialize_module(@road_nodes)
            # RoadMaker.initialize_module(@road_makers)
            # HouseMaker.initialize_module(@house_makers)
            # Inspector.initialize_module(@inspectors)
            # Planner.initialize_module(@planners)
            # MessageBoard.initialize_module()

        initialize_breeds: () ->

            @patchBreeds @patch_breeds.join(' ')
            @agentBreeds @agent_breeds.join(' ')


        create_city_hall: (x, y) ->
            patch = @patches.patchXY(x, y)
            patch.color = patch.default_color = [0, 0, 100]
            patch.dist_to_city_hall = 0
            return patch

        set_default_params: () ->
            @patchBreeds "roads houses"
            @agentBreeds "road_makers house_makers road_nodes inspectors planners"
            @anim.setRate 120, false
            @refreshPatches = true
            @draw_mode = "normal"

        spawn_entities: () ->
            @city_hall = @create_city_hall(0, 0)
            Road.set_breed(patch, 1) for patch in @city_hall.n4
            for patch in @city_hall.n
                Road.set_breed(patch, 2) if not (patch.breed is @roads)

            # @spawn_house_makers(1)
            @spawn_inspectors(1)
            @spawn_planners(1)

        spawn_road_makers: (ammount) ->
            i = 0
            while i < ammount
                patch = ABM.util.oneOf(@city_hall.n4)
                RoadMaker.spawn_road_maker(patch)
                i += 1

        spawn_house_makers: (ammount) ->
            i = 0
            while i < ammount
                patch = ABM.util.oneOf(@city_hall.n4)
                HouseMaker.spawn_house_maker(patch)
                i += 1

        spawn_inspectors: (ammount) ->
            i = 0
            while i < ammount
                patch = ABM.util.oneOf(@city_hall.n4)
                Inspector.spawn_node_inspector(patch)
                Inspector.spawn_road_inspector(patch)
                i += 1

        spawn_planners: (ammount) ->
            i = 0
            while i < ammount
                Planner.spawn_road_planner()
                Planner.spawn_node_planner()
                i += 1


        set_up_AStar_helpers: ->
            width = @world.maxX - @world.minX
            height = @world.maxY - @world.minY

            x_to_grid_transform = (x) => x - @world.minX
            y_to_grid_transform = (y) => -y - @world.minY

            x_to_world_transform = (x) => x + @world.minX
            y_to_world_transform = (y) => -(y + @world.minY)

            @roadAStar = new AStarHelper(width, height, false)
            @roadAStar.setToGridTransforms(x_to_grid_transform, y_to_grid_transform)
            @roadAStar.setToWorldTransforms(x_to_world_transform, y_to_world_transform)

            @terrainAStar = new AStarHelper(width, height, true)
            @terrainAStar.setToGridTransforms(x_to_grid_transform, y_to_grid_transform)
            @terrainAStar.setToWorldTransforms(x_to_world_transform, y_to_world_transform)

        init_patches: () ->
            for p in @patches
                p.color = ABM.util.randomGray(100, 150)
                [r, g, b] = p.color
                p.color = [r, g * 2, b]
                p.default_color = p.color

        set_draw_mode: (mode) ->
            @draw_mode = mode

        draw_normal_color: ->
            for patch in @patches when patch.breed.name is "patches"
                patch.color = patch.default_color

        draw_connectivity_color: ->
            for patch in @patches when patch.breed.name is "patches"
                patch.color = if patch.connectivity_color? then patch.connectivity_color else patch.color
