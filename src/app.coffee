
class App
    pause: false

    constructor: (@element_id) ->
        @setup_hotkeys()
        @setup_model()
        @setup_buttons()

    setup_model: () ->
        @model = new CityModel(@element_id, 16, -16, 16, -16, 16)
        $('#seed').val(GPW.pronounceable(8))
        # @seed = "therinet"


    run: () ->
        config = @get_config()
        @get_and_update_seed()
        @model.reset(config, not @paused)

    restart: () ->
        @run()

    get_and_update_seed: () ->
        @seed = $('#seed').val()
        Math.seedrandom(@seed)

    get_int_val: (id) ->
        parseInt($(id).val())

    get_cb_val: (id) ->
        $(id).prop('checked')

    get_config: () ->
        inspectors:
            node_inspector:
                inspection_radius: @get_int_val('#inspection-area')
                max_distance_factor: @get_int_val('#distance-factor')
            road_inspector:
                ring_radius: @get_int_val('#initial-radius')
                ring_increment: @get_int_val('#radius-increment')
        debug:
            agents:
                show_states: @get_cb_val('#show-state')
                show_ids: @get_cb_val('#show-id')
                show_logs: @get_cb_val('#show-logs')

    play_pause_model: () ->
        if @paused
            @model.start()
            $('#step').attr('disabled', true);
            $('#play-pause').find('.btn-text').text('Pause')
        else
            @model.stop()
            $('#step').attr('disabled', false);
            $('#play-pause').find('.btn-text').text('Play')
        @paused = not @paused
        null

    step_model: () ->
        if @paused
            @model.anim.step()
            @model.anim.draw()

    set_key_command: (key, fn) ->
        $(document).bind 'keydown', key, fn

    setup_hotkeys: () ->
        @set_key_command 'r', () => @restart()

    setup_buttons: () ->
        $('#play-pause').click () =>
            @play_pause_model()
            $('#play-pause span.glyphicon').toggleClass('glyphicon-play').toggleClass('glyphicon-pause')

        $('#step').click () =>
            @step_model()

        $('#reload').click () =>
            @restart()

        $('button.j-iterate-over').click(() =>
            @animate(parseInt($('input.j-iterate-over').val())))

        $('button.j-iterate-until').click(() =>
            @animateTo(parseInt($('input.j-iterate-until').val())))

        $('input.j-update-debug-info').click () =>
            @update_debug_info()

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
        @model.stop()
        i = 0
        while i < ticks
            @model.anim.step()
            i += 1
        if not @paused
            @model.start()
        else
            @model.anim.draw()

    animateTo: (ticks) ->
        @model.stop()
        while @model.anim.ticks < ticks
            @model.anim.step()
        if not @paused
            @model.start()
        else
            @model.anim.draw()
