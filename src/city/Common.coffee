class BaseAgent

    current_state: null

    init: () ->

    step: () ->
        @current_state()

    _set_state: (new_state) ->
        CityModel.log("#{@id}: #{@label} -> #{new_state}")
        @label = new_state
        @current_state = @['s_' + new_state]

    _set_initial_state: (state) ->
        CityModel.log("#{@id}: @#{state}")
        @label = state
        @current_state = @['s_' + state]

    _move: (point) ->
        @_face_point point
        @forward(@speed)

    _face_point: (point) ->
        heading = @_angle_between_points(point, @)
        turn = ABM.util.subtractRads heading, @heading
        @rotate turn

    _angle_between_points: (point_a, point_b) ->
        dx = point_a.x - point_b.x
        dy = point_a.y - point_b.y
        return Math.atan2(dy, dx)

    _in_point: (point) ->
        return 0.1 > ABM.util.distance @x, @y, point.x, point.y

    _get_terrain_path_to: (point) ->
        return CityModel.instance.terrainAStar.getPath(@, point)

    _get_road_path_to: (point) ->
        return CityModel.instance.roadAStar.getPath(@, point)
