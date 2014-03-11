
jQuery ($) ->

    $.model =

    setup_hotkeys()




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

            @model = new CityModel(@$el.attr('id'), 16, -16, 16, -16, 16)
            @seed = GPW.pronounceable(8)
            @seed = "ousphoun"

        # Additional plugin methods go here
        run: () ->
            Math.seedrandom(@seed);
            @model.debug();
            @model.start();

        restart: () ->
            @model.reset()
            @model = new CityModel(@$el.attr('id'), 16, -16, 16, -16, 16)
            @run()


        set_key_command: (key, fn) ->
            $(document).bind 'keydown', key, fn

        setup_hotkeys: () ->
            @set_key_command 'a', () -> console.log 'A'
            @set_key_command 'alt+r', () => @restart()


    # Define the plugin
    $.fn.extend CitySimulation: (option, args...) ->
        @each ->
            $this = $(this)
            data = $this.data('CitySimulation')

            if !data
                $this.data 'CitySimulation', (data = new CitySimulation(this, option))
            if typeof option == 'string'
                data[option].apply(data, args)

) window.jQuery, window
