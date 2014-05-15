
class App
    pause: false

    constructor: (@element_id) ->
        @setup_hotkeys()
        @setup_model()
        @setup_buttons()

    setup_model: () ->
        @model = new CityModel(@element_id, 8, -32, 32, -32, 32)
        $('#seed').val(GPW.pronounceable(8))

    run: () ->
        config = @get_config()
        @model.reset(config, not @paused)

    restart: () ->
        @run()

    get_float_val: (id) ->
        parseFloat($(id).val())

    get_int_val: (id) ->
        parseInt($(id).val())

    get_cb_val: (id) ->
        $(id).prop('checked')

    get_config: () ->
        inspectors:
            node_inspector:
                inspection_radius: @get_int_val('#inspection-area')
                max_distance_factor: @get_int_val('#distance-factor')
            radial_road_inspector:
                ring_radius: @get_int_val('#initial-radius')
                ring_increment: @get_int_val('#radius-increment')
                min_increment: @get_int_val('#min-incr')
                max_increment: @get_int_val('#max-incr')
            grid_road_inspector:
                horizontal_grid_size: @get_int_val('#horizontal-grid')
                vertical_grid_size: @get_int_val('#vertical-grid')
        planners:
            growth_planner:
                base_growth: @get_float_val('#base-growth')
                growth_per_capita: @get_float_val('#growth-pc')
        buildings:
            road:
                road_distance: @get_int_val('#road-distance')
            house:
                max_citizens: @get_int_val('#max-citizens')
                minimum_housing_available: @get_float_val('#min-houses')
                expansion_threshold: @get_float_val('#exp-threshold')
                expansion_factor: @get_float_val('#exp-factor')
            generic:
                hospital:
                    threshold: @get_int_val('#hospital-capacity')
                    radius: @get_int_val('#hospital-radius')
                school:
                    threshold: @get_int_val('#school-capacity')
                    radius: @get_int_val('#school-radius')
                store:
                    threshold: @get_int_val('#store-capacity')
                    radius: @get_int_val('#store-radius')
        debug:
            agents:
                show_states: @get_cb_val('#show-state')
                show_ids: @get_cb_val('#show-id')
                show_logs: @get_cb_val('#show-logs')
        seed: $('#seed').val()

    play_pause_model: () ->
        if @paused
            @model.start()
            $('#play-pause').find('.btn-text').text('Pause')
        else
            @model.stop()
            $('#play-pause').find('.btn-text').text('Play')
        @paused = not @paused
        null

    step_model: () ->
        steps = @get_int_val('input.step')
        @animate(steps)

    set_key_command: (key, fn) ->
        $(document).bind 'keydown', key, fn

    setup_hotkeys: () ->
        @set_key_command 'r', () => @restart()

    setup_buttons: () ->
        $('#play-pause').click () =>
            @play_pause_model()
            $('#play-pause span.glyphicon').toggleClass('glyphicon-play').toggleClass('glyphicon-pause')

        $('a#step').click () =>
            @step_model()

        $('#reload').click () =>
            @restart()

        $('input.j-update-debug-info').click () =>
            @update_debug_info()

        $('#save-button').click () =>
            save_string = @model.save()
            $('#save-input').val(save_string)

        $('#load-button').click () =>
            save_string = $('#load-input').val()
            @model.load(save_string)

    update_debug_info: () ->
        config =
            agents:
                show_states: @get_cb_val('#show-state')
                show_ids: @get_cb_val('#show-id')
                show_logs: @get_cb_val('#show-logs')

        @model.update_debug_config(config)

    get_model: () ->
        return @model

    animate: (ticks) ->
        start = new Date().getTime();

        @model.stop()
        i = 0
        while i < ticks
            @model.anim.step()
            i += 1
        if not @paused
            @model.start()
        else
            @model.anim.draw()

        end = new Date().getTime();
        time = end - start;
        console.log('Execution time: ' + time);
