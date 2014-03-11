
(($, window) ->

    # Define the plugin class
    class CitySimulation

        defaults:
            paramA: 'foo'
            paramB: 'bar'

        constructor: (el, options) ->
            @options = $.extend({}, @defaults, options)
            @$el = $(el)

            @setup_hotkeys()
            @setup_model()

        # Additional plugin methods go here
        setup_model: () ->
            @model = new CityModel(@$el.attr('id'), 16, -16, 16, -16, 16)
            @seed = GPW.pronounceable(8)
            @seed = "ousphoun"

        run: () ->
            Math.seedrandom(@seed);
            @model.debug();
            @model.start();

        restart: () ->
            @model.reset()
            @setup_model()
            @run()

        set_key_command: (key, fn) ->
            $(document).bind 'keydown', key, fn

        setup_hotkeys: () ->
            @set_key_command 'a', () -> console.log 'A'
            @set_key_command 'alt+r', () => @restart()

        get_model: () ->
            return @model


    # Define the plugin
    $.fn.extend CitySimulation: (option, args...) ->
        ret_val = null
        @each ->
            $this = $(this)
            data = $this.data('CitySimulation')

            if !data
                ret_val = $this.data 'CitySimulation', (data = new CitySimulation(this, option))
            if typeof option == 'string'
                ret_val = data[option].apply(data, args)
        return if ret_val? then ret_val else $(this)

) window.jQuery, window
