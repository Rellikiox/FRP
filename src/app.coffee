
class App
    pause: false

    setup: (@element) ->
        @setup_hotkeys()
        @setup_model()
        @setup_buttons()

    setup_model: () ->
        @model = new CityModel(@element.attr('id'), 16, -16, 16, -16, 16)
        @seed = GPW.pronounceable(8)
        @seed = "therinet"

    run: () ->
        Math.seedrandom(@seed);
        @model.debug();
        @model.start();

    restart: () ->
        Math.seedrandom(@seed);
        @model.reset(true)

    play_pause_model: () ->
        if @paused
            @model.start()
        else
            @model.stop()
        @paused = not @paused
        null

    set_key_command: (key, fn) ->
        $(document).bind 'keydown', key, fn

    setup_hotkeys: () ->
        @set_key_command 'r', () => @restart()

    setup_buttons: () ->
        $('#play-pause').click () =>
            @play_pause_model()
            $('#play-pause span').toggleClass('glyphicon-play').toggleClass('glyphicon-pause')
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
