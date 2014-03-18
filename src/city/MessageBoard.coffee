class MessageBoard
    @message_queues: {}

    @initialize_module: () ->
        @message_queues = {}

    @_get_or_create_queue: (type) ->
        if not @message_queues[type]?
            @message_queues[type] = []
        return @message_queues[type]

    @get_board: (topic) ->
        return new MessageBoard(topic)


    constructor: (topic) ->
        @queue = @constructor._get_or_create_queue(topic)

    get_message: () ->
        return @queue.shift()

    post_message: (message) ->
        @queue.push(message)


