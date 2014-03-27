
class App
    pause: false

    constructor: (@element_id) ->
        @setup_hotkeys()
        @setup_model()
        @setup_buttons()

    setup_model: () ->
        @model = new CityModel(@element_id, 16, -16, 16, -16, 16)
        @seed = GPW.pronounceable(8)
        @seed = "therinet"

    run: () ->
        Math.seedrandom(@seed)
        @model.reset(true)

    restart: () ->
        Math.seedrandom(@seed)
        @model.reset(true)

    play_pause_model: () ->
        if @paused
            @model.start()
            $('#step').attr('disabled', true);
        else
            @model.stop()
            $('#step').attr('disabled', false);
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
            $('#play-pause span').toggleClass('glyphicon-play').toggleClass('glyphicon-pause')

        $('#step').click () =>
            @step_model()

        $('#reload').click () =>
            @restart()

        $('button.j-iterate-over').click(() =>
            @animate(parseInt($('input.j-iterate-over').val())))

        $('button.j-iterate-until').click(() =>
            @animateTo(parseInt($('input.j-iterate-until').val())))

    get_model: () ->
        return @model

    animate: (ticks) ->
        @model.stop()
        i = 0
        while i < ticks
            @model.anim.step()
            i += 1
        @model.start()

    animateTo: (ticks) ->
        @model.stop()
        while @model.anim.ticks < ticks
            @model.anim.step()
        @model.start()
