u = ABM.util # ABM.util alias, u.s is also ABM.shape accessor.

extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj

class CityModel extends ABM.Model

    @instance: null

    @get_patch_at: (point) ->
        return @instance.patches.patchXY(Math.round(point.x), Math.round(point.y))

    @is_on_world: (point) ->
        return @instance.patches.isOnWorld(Math.round(point.x), Math.round(point.y))

    @link_agents: (agent_a, agent_b) ->
        @instance.links.create(agent_a, agent_b)

    setup: ->
        CityModel.instance = this
        @set_up_AStar_helpers()

        @set_default_params()
        @initialize_modules()

        @init_patches()
        @spawn_entities()

    step: ->
        # console.log @anim.toString() if @anim.ticks % 100 == 0
        road_maker.step() for road_maker in @road_makers
        house_maker.step() for house_maker in @house_makers

    draw: ->
        switch @draw_mode
            when "normal" then @draw_normal_color()
            when "connectivity" then @draw_connectivity_color()
        super

    initialize_modules: () ->
        Road.initialize_module(@roads)
        RoadNode.initialize_module(@road_nodes)
        RoadMaker.initialize_module(@road_makers)
        HouseMaker.initialize_module(@house_makers)

    create_city_hall: (x, y) ->
        agent = (@agents.create 1)[0]
        agent.setXY x, y
        agent.color = [0,0,100]
        agent.shape = "square"
        agent.size = 1
        agent.p.dist_to_city_hall = 0
        return agent

    set_default_params: () ->
        @patchBreeds "city_hall roads houses"
        @agentBreeds "road_makers house_makers road_nodes"
        @anim.setRate 120, false
        @refreshPatches = true

        @links.setDefault "labelColor", [255,0,0]

        @patches.setDefault("free", true)

        @draw_mode = "normal"

    spawn_entities: () ->
        @city_hall = @create_city_hall(0, 0)
        Road.set_breed(patch, 1) for patch in @city_hall.p.n4
        for patch in @city_hall.p.n
            Road.set_breed(patch, 2) if not (patch.breed is @roads)

        @spawn_road_makers(1)
        @spawn_house_makers(0)

    spawn_road_makers: (ammount) ->
        i = 0
        while i < ammount
            patch = u.oneOf(@city_hall.p.n4)
            road_maker = RoadMaker.spawn_road_maker(patch)
            @links.create(@city_hall, road_maker)
            i += 1

    spawn_house_makers: (ammount) ->
        i = 0
        while i < ammount
            patch = u.oneOf(@city_hall.p.n4)
            HouseMaker.spawn_house_maker(patch)
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

    draw_mode: (mode) ->
        @draw_mode = mode

    draw_normal_color: ->
        for patch in @patches when patch.breed.name is "patches"
            patch.color = patch.default_color

    draw_connectivity_color: ->
        for patch in @patches when patch.breed.name is "patches"
            patch.color = if patch.connectivity_color? then patch.connectivity_color else patch.color
