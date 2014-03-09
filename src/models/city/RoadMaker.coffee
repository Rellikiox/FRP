class RoadMaker extends ABM.Agent
    # Agentscript stuff
    @breed_name: 'roadMakers'
    @breed: null

    # Appearance
    @default_color: [255,255,255]
    @size:  1

    # Behavior
    @radius_increment = 10

    # Default vars
    target_point: null
    path: null
    local_point: null
    ring_radius: 10

    @agentSet: ->
        if not @breed?
            for breed in ABM.agents.breeds
                if breed.name is @breed_name
                    @breed = breed
                    break
        return @breed

    @makeNew: (x,y) ->
        road_maker = new RoadMaker x, y, @default_color, 1
        @agentSet().add road_maker
        return road_maker

    constructor: (x, y, @color, @size) ->
        super
        @setXY x, y
        @starting_position = {x: x, y: y}

        @target_point = @getTargetPoint()
        @path = CityModel.instance.terrainAStar.getPath(@, @target_point)
        @current_state = @seekTargetPointState

    step: ->
        @current_state()

    # States

    goToStartingPositionState: ->
        @move @starting_position

        if @inStartingPosition()
            @target_point = @getTargetPoint()
            @path = CityModel.instance.terrainAStar.getPath(@, @target_point)
            @current_state = @seekTargetPointState

    seekTargetPointState: ->
        @move @path[0]

        if not Road.is_road_here @p
            @dropRoad()

        if @inPoint(@path[0])
            @path.shift()
            if @path.length is 0
                @current_state = @goToStartingPositionState


    # Utils

    dropRoad: ->
        Road.makeHere(@p)

    inTargetPoint: ->
        return @inPoint @target_point

    inStartingPosition: ->
        return @inPoint @starting_position

    inPoint: (point) ->
        return 0.1 > ABM.util.distance @x, @y, point.x, point.y

    getTargetPoint: ->
        angle  = ABM.util.randomFloat(2 * Math.PI)
        x = Math.round(@x + @ring_radius * Math.cos(angle))
        y = Math.round(@y + @ring_radius * Math.sin(angle))
        return {x: x, y: y}

    facePoint: (point) ->
        dx = point.x - @x
        dy = point.y - @y
        heading = Math.atan2 dy, dx
        turn = ABM.util.subtractRads heading, @heading
        @rotate turn

    move: (point) ->
        @facePoint point
        @forward(0.05)

    getLocalPoint: (point) ->
        dx = point.x - @x
        dy = point.y - @y
        heading = Math.round(Math.atan2(dy, dx) / (Math.PI / 2))
        switch
            when heading is 0 then return {x: @p.x + 1, y: @p.y}
            when heading is 1 then return {x: @p.x, y: @p.y + 1}
            when heading is -1 then return {x: @p.x, y: @p.y - 1}
            when heading is 2 or heading is -2 then return {x: @p.x - 1, y: @p.y}




