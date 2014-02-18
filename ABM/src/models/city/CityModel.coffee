u = ABM.util # ABM.util alias, u.s is also ABM.shape accessor.

class CityModel extends ABM.Model

    @instance: null

    setup: ->
        CityModel.instance = this

        @patchBreeds "city_hall roads houses aaa"
        @agentBreeds "roadMakers houseMakers"
        @anim.setRate 30, false
        @refreshPatches = true

        @links.setDefault "labelColor", [255,0,0]

        @patches.setDefault "connectivity", 0.0

        @draw_mode = "connectivity"

        for p in @patches
            p.color = u.randomGray(120, 220)
            p.default_color = p.color

        @city_hall = @createCityHall(0, 0)
        Road.makeHere patch for patch in @city_hall.p.n

        patch = u.oneOf(@city_hall.p.n4)
        road_maker = RoadMaker.makeNew patch.x, patch.y
        @links.create(@city_hall, road_maker)

        # patch = u.oneOf(@city_hall.p.n4)
        # house_maker = HouseMaker.makeNew patch.x, patch.y

    step: ->
        console.log @anim.toString() if @anim.ticks % 100 == 0
        road_maker.step() for road_maker in @roadMakers
        house_maker.step() for house_maker in @houseMakers

    draw: ->
        switch @draw_mode
            when "normal" then @drawNormalColor()
            when "connectivity" then @drawConnectivityColor()

        super

    createCityHall: (x, y) ->
        agent = (@agents.create 1)[0]
        agent.setXY x, y
        agent.color = [0,0,100]
        agent.shape = "square"
        agent.size = 1
        return agent

    drawMode: (mode) ->
        @draw_mode = mode

    drawNormalColor: ->
        for patch in @patches when patch.breed.name is "patches"
            patch.color = patch.default_color

    drawConnectivityColor: ->
        for patch in @patches when patch.breed.name is "patches"
            patch.color = if patch.connectivity_color? then patch.connectivity_color else patch.color
