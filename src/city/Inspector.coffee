class Inspector
    # Agentscript stuff
    @inspectors: null

    # Appearance
    @default_color: [0, 0, 255]

    # Behavior
    @radius_increment = 3

    @initialize_module: (inspectors_breed) ->
        @inspectors = inspectors_breed
        @inspectors.setDefault('color', @default_color)

    @spawn_inspector: (patch) ->
        inspector = patch.sprout(1, @inspectors)[0]
        extend(inspector, Inspector_instance_properties)
        inspector.init()
        return inspector


Inspector_instance_properties =
    current_message: null
    current_state: null

    init: () ->
        @current_state = @get_message_state

    step: () ->
        @current_state()


    get_message_state: () ->
        @current_message = Planner.get_message('inspect_endpoint')
        if @current_message?
            @path = CityModel.instance.roadAStar.getPath(@, @current_message.patch)
            @current_state = @go_to_endpoint_state


    go_to_endpoint_state: () ->
        @move(@path[0])

        if @in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @current_state = @inspect_endpoint_state

    inspect_endpoint_state: () ->
        console.log('Inspecting the endpoint')
        @current_message = null
        @current_state = @get_message_state


    move: (point) ->
        @face_point point
        @forward(0.05)

    face_point: (point) ->
        dx = point.x - @x
        dy = point.y - @y
        heading = Math.atan2 dy, dx
        turn = ABM.util.subtractRads heading, @heading
        @rotate turn

    in_point: (point) ->
        return 0.1 > ABM.util.distance @x, @y, point.x, point.y



