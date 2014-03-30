class Planner
    @planners = null

    @initialize_module: (planners_breed) ->
        @planners = planners_breed
        @planners.setDefault 'hidden', true

    @spawn_road_planner: () ->
        return @spawn_planner(RoadPlanner.prototype)

    @spawn_node_planner: () ->
        return @spawn_planner(NodeInterconnectivityPlanner.prototype)

    @spawn_growth_planner: () ->
        return @spawn_planner(GrowthPlanner.prototype)

    @spawn_planner: (prototype) ->
        planner = @planners.create(1)[0]
        extend(planner, prototype)
        planner.init()
        return planner


class NodeInterconnectivityPlanner extends Planner

    init: () ->
        @msg_reader = MessageBoard.get_board('nodes_unconnected')

    step: () ->
        msg = @msg_reader.get_message()
        if msg?
            RoadBuilder.spawn_road_connector(msg.patch_a, msg.patch_b)


class RoadPlanner

    init: () ->
        @msg_reader = MessageBoard.get_board('possible_node')

    step: () ->
        msg = @msg_reader.get_message()
        if msg?
            RoadBuilder.spawn_road_extender(msg.patch)


class GrowthPlanner

    ticks_per_citizen: 30

    init: () ->
        @msg_reader = MessageBoard.get_board('new_citizen')
        @ticks_since_last_citizen = 0

    step: () ->
        @_grow_population()

    _grow_population: () ->
        @ticks_since_last_citizen += 1

        if @ticks_since_last_citizen >= @ticks_per_citizen
            @msg_reader.post_message()
            @ticks_since_last_citizen = 0
