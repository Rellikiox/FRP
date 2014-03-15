class Planner

    @message_queues: {}

    @initialize_module: () ->
        @message_queues = {}

    @get_message: (type) ->
        return @message_queues[type]?.shift()

    @post_message: (type, message) ->
        queue = @_get_or_create_queue(type)
        queue.push(message)

    @_get_or_create_queue: (type) ->
        if not @message_queues[type]?
            @message_queues[type] = []
        return @message_queues[type]



