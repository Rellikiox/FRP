
jQuery ($) ->
    set_key_command = (key, fn) ->
        $(document).bind 'keypress', key, fn

    set_key_command 'a', () -> console.log 'A'

