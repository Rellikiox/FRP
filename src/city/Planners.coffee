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
        @msg_reader = MessageBoard.get_board('connect_nodes')

    step: () ->
        msg = @msg_reader.get_message()
        if msg?
            RoadBuilder.spawn_road_connector(msg.patch_a, msg.patch_b)


class RoadPlanner

    init: () ->
        @msg_reader = MessageBoard.get_board('build_endpoint')

    step: () ->
        msg = @msg_reader.get_message()
        if msg?
            RoadBuilder.spawn_road_extender(msg.patch)



