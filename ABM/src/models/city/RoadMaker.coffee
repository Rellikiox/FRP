class RoadMaker extends ABM.Agent
    # Agentscript stuff
    @breed_name: 'roadMakers'
    @breed: null

    # Appearance
    @color: [0,255,0]
    @size:  1

    # Behavior
    @radius_increment = 10

    # Default vars
    target_point: null
    ring_radius: 10

    @agentSet: ->
        if not @breed?
            for breed in ABM.agents.breeds
                if breed.name is @breed_name
                    @breed = breed
                    break
        return @breed

    @makeNew: (x,y) ->
        road_maker = new RoadMaker x, y, [0,255,0], 1
        @agentSet().add road_maker
        return road_maker

    constructor: (x, y, @color, @size) ->
        super
        @setXY x, y
        @starting_position = {x: x, y: y}

        @target_point = @getTargetPoint()
        @current_state = @seekTargetPointState

    step: ->
        @current_state()

    # States

    goToStartingPositionState: ->
        @facePoint @starting_position
        @move()

        if @inStartingPosition()
            @target_point = @getTargetPoint()
            @current_state = @seekTargetPointState

    seekTargetPointState: ->
        @facePoint @target_point
        @move()
        @dropRoad()

        if @inTargetPoint()
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
        angle  = ABM.util.randomFloat 360
        x = @x + @ring_radius * Math.cos(angle)
        y = @y + @ring_radius * Math.sin(angle)
        return {x: x, y: y}

    facePoint: (point) ->
        dx = point.x - @x
        dy = point.y - @y
        heading = Math.atan2 dy, dx
        turn = ABM.util.subtractRads heading, @heading # angle from h to a
        #turn = u.clamp turn, -@maxTurn, @maxTurn # limit the turn
        @rotate turn

    move: ->
        @forward(0.1)








