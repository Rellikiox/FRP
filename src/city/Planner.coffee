class Planner
    @planners = null

    @initialize_module: (planners_breed) ->
        @planners = planners_breed
        @planners.setDefault 'hidden', true

    @spawn_planner: () ->
        planner = @planners.create(1)[0]
        extend(planner, Planner.prototype)
        planner.init()
        return planner

    init: () ->
        @msg_reader = MessageBoard.get_reader('connect_nodes')

    step: () ->
        msg = @msg_reader.get_message()
        if msg?
            RoadMaker.spawn_road_maker(msg.node_a.p)



