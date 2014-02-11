class RoadMaker extends ABM.Agent
    # Agentscript stuff
    @breed_name: 'roadMakers'
    @breed: null

    # Appearance
    @color: [0,255,0]
    @size:  1

    # Behavior
    @point_radius = 10

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
        @target_point = null

    step: ->
        if @target_point?
            if not @isInTarget()
                @facePoint @target_point
                @forward(0.1)
                if not Road.isRoadHere(@p)
                    @dropRoad()
            else
                @target_point = @getTargetPoint()
        else
            @target_point = @getTargetPoint()

    dropRoad: ->
        Road.makeHere(@p)

    isInTarget: ->
        return 0.1 > ABM.util.distance @x, @y, @target_point.x, @target_point.y

    getTargetPoint: ->
        radius = ABM.util.randomFloat @constructor.point_radius
        angle  = ABM.util.randomFloat 360
        x = @x + radius * Math.cos(angle)
        y = @y + radius * Math.sin(angle)
        return {x: x, y: y}

    facePoint: (point) ->
        dx = point.x - @x
        dy = point.y - @y
        heading = Math.atan2 dy, dx
        turn = ABM.util.subtractRads heading, @heading # angle from h to a
        #turn = u.clamp turn, -@maxTurn, @maxTurn # limit the turn
        @rotate turn






