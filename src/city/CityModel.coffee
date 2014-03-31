u = ABM.util # ABM.util alias, u.s is also ABM.shape accessor.


class CityModel extends ABM.Model

    @modules: []
    @agent_breeds_names: ""
    @patch_breeds_names: ""

    @register_module: (klass, agents, patches) ->
        module =
            klass: klass
            agent_breeds: agents
            patch_breeds: patches

        @modules.push(module)
        @load_module(module)

    @load_module: (module) ->
        @agent_breeds_names += " " + breed_name for breed_name in module.agent_breeds
        @patch_breeds_names += " " + breed_name for breed_name in module.patch_breeds
        @agent_breeds_names.trim()
        @patch_breeds_names.trim()

    @instance: null

    @log = (msg) ->
        console.log msg if @instance?.debugging

    @debug_info: () ->
        return @instance?.config.debug

    @get_patch_at: (point) ->
        return @instance.patches.patchXY(Math.round(point.x), Math.round(point.y))

    @is_on_world: (point) ->
        return @instance.patches.isOnWorld(Math.round(point.x), Math.round(point.y))

    @link_agents: (agent_a, agent_b) ->
        @instance.links.create(agent_a, agent_b)

    @set_road_nav_patch_walkable: (patch, walkable=true) ->
        CityModel.instance.roadAStar.setWalkable(patch, walkable)

    reset: (@config, start) ->
        super(start)

        @set_default_params()
        @initialize_modules()

        CityModel.instance = this
        @set_up_AStar_helpers()

        @init_patches()
        @spawn_entities()

    setup: ->

    step: ->
        # console.log @anim.toString() if @anim.ticks % 100 == 0

        agent.step?() for agent in @agents by -1

        # road_maker.step() for road_maker in @road_makers
        # house_maker.step() for house_maker in @house_makers

    # draw: ->
    #     switch @draw_mode
    #         when "normal" then @draw_normal_color()
    #         when "connectivity" then @draw_connectivity_color()
    #     super

    update_debug_config: (debug_config) ->
        @config.debug = debug_config
        @set_agent_debug_info()
        agent.update_label?() for agent in @agents

    initialize_modules: () ->
        for module in CityModel.modules
            @initialize_module(module)

    initialize_module: (module) ->
        breeds = []
        breeds.push(@[breed_name]) for breed_name in module.agent_breeds
        breeds.push(@[breed_name]) for breed_name in module.patch_breeds

        module.klass.initialize(breeds..., @config)

    create_city_hall: (x, y) ->
        patch = @patches.patchXY(x, y)
        patch.color = patch.default_color = [0, 0, 100]
        patch.dist_to_city_hall = 0
        return patch

    set_default_params: () ->
        @patchBreeds(CityModel.patch_breeds_names)
        @agentBreeds(CityModel.agent_breeds_names)

        @anim.setRate(120, false)
        @refreshPatches = true
        @draw_mode = "normal"

        @set_agent_debug_info()

    set_agent_debug_info: () ->
        for key, value of @config.debug.agents
            @agents.setDefault(key, value)

    spawn_entities: () ->
        @city_hall = @create_city_hall(0, 0)
        Road.set_breed(patch, 1) for patch in @city_hall.n4
        for patch in @city_hall.n
            Road.set_breed(patch, 2) if not (patch.breed is @roads)

        @spawn_house_makers(0)
        @spawn_inspectors(1)
        @spawn_planners(1)

    spawn_road_makers: (ammount) ->
        i = 0
        while i < ammount
            patch = u.oneOf(@city_hall.n4)
            RoadBuilder.spawn_road_maker(patch)
            i += 1

    spawn_house_makers: (ammount) ->
        i = 0
        while i < ammount
            patch = u.oneOf(@city_hall.n4)
            HouseBuilder.spawn_house_maker(patch)
            i += 1

    spawn_inspectors: (ammount) ->
        i = 0
        while i < ammount
            patch = u.oneOf(@city_hall.n4)
            Inspector.spawn_node_inspector(patch)
            Inspector.spawn_road_inspector(patch)
            Inspector.spawn_plot_inspector(patch)
            i += 1

    spawn_planners: (ammount) ->
        i = 0
        while i < ammount
            Planner.spawn_road_planner()
            Planner.spawn_node_planner()
            Planner.spawn_growth_planner()
            Planner.spawn_plot_planner()
            Planner.spawn_housing_planner()
            Planner.spawn_plot_keeper_planner()
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
            p.color = u.randomGray(100, 150)
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
