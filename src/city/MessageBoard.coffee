class MessageBoard
    @message_queues: {}

    @initialize: () ->
        @message_queues = {}

    @_get_or_create_queue: (type) ->
        if not @message_queues[type]?
            @message_queues[type] = []
        return @message_queues[type]

    @get_board: (topic) ->
        return new MessageBoard(topic)

    @get_combined_board: (topics) ->
        return new MultiReader(topics)


class MultiReader

    constructor: (@topics) ->
        @queues = (MessageBoard._get_or_create_queue(topic) for topic in @topics)

    get_message: () ->
        first_message = null
        queue_of_message = null
        for queue in @queues when queue.length > 0
            if not first_message? or first_message > queue[0].timestamp
                first_message = queue[0].timestamp
                queue_of_message = queue
        if first_message?
            return queue_of_message.shift()


class Board

    constructor: (@topic) ->
        @queue = MessageBoard._get_or_create_queue(topic)

    get_message: () ->
        return @queue.shift()

    post_message: (message) ->
        message ?= {}
        message.type = @topic
        message.timestamp = Date.now()
        @queue.push(message)

    message_count: () ->
        return @queue.length


CityModel.register_module(MessageBoard, [], [])
