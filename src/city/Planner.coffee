class Planner
    @planners = null

    @initialize_module: (planners_breed) ->
        @planners = planners_breed
        @planners.setDefault 'hidden', true

    @spawn_road_planner: () ->
        return @spawn_planner(RoadPlanner.prototype)

    @spawn_node_planner: () ->
        return @spawn_planner(NodeInterconnectivityPlanner.prototype)

    @spawn_planner: (prototype) ->
        planner = @planners.create(1)[0]
        extend(planner, prototype)
        planner.init()
        return planner


class NodeInterconnectivityPlanner extends Planner

    init: () ->
        @msg_reader = MessageBoard.get_reader('connect_nodes')

    step: () ->
        msg = @msg_reader.get_message()
        if msg?
            RoadMaker.spawn_road_connector(msg.node_a.p, msg.node_b.p)


class RoadPlanner

    init: () ->
        @msg_reader = MessageBoard.get_reader('build_endpoint')

    step: () ->
        msg = @msg_reader.get_message()
        if msg?
            RoadMaker.spawn_road_extender(msg.patch)



