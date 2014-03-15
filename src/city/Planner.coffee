class Planner
    @planners = null

    @message_queues: {}

    @initialize_module: (planners_breed) ->
        @planners = planners_breed
        @planners.setDefault 'hidden', true

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

    @spawn_planner: () ->
        planner = @planners.create(1)[0]
        extend(planner, Planner_instance_properties)
        planner.init()
        return planner

Planner_instance_properties =

    init: () ->

    step: () ->
        msg = Planner.get_message('connect_nodes')
        if msg?
            RoadMaker.spawn_road_maker(msg.node_a.p)



