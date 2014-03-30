
extend = (obj, mixin_list...) ->
    for mixin in mixin_list
        for name, method of mixin.prototype
            obj[name] = method
        obj


class FSMAgent

    current_state: null
    current_state_name: null

    init: () ->

    step: () ->
        @current_state()

    _set_state: (new_state) ->
        @_log("#{@id}: #{@current_state_name} -> #{new_state}")
        @_update_state(new_state)


    _set_initial_state: (state) ->
        @_log("#{@id}: @#{state}")
        @_update_state(state)

    _update_state: (state) ->
        @current_state_name = state
        @label = @_get_label()
        @current_state = @['s_' + @current_state_name]

    update_label: () ->
        @label = @_get_label()

    _get_label: () ->
        label = "#{@id}" if @show_ids
        label += ": " if @show_ids and @show_states
        label += "#{@current_state_name}" if @show_states
        return label

    _log: (msg) ->
        console.log(msg) if @show_logs

    _link_to: (agent) ->
        CityModel.link_agents(@, agent) if @show_links

    _clear_links: () ->
        link.die() for link in @myLinks()


class MovingAgent

    speed: 0.05

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
