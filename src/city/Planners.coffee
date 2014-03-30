class Planner
    @planners = null

    @initialize_module: (planners_breed) ->
        @planners = planners_breed
        @planners.setDefault 'hidden', true

    @spawn_road_planner: () ->
        return @spawn_planner(RoadPlanner)

    @spawn_node_planner: () ->
        return @spawn_planner(NodeInterconnectivityPlanner)

    # @spawn_growth_planner: () ->
    #     return @spawn_planner(GrowthPlanner)

    @spawn_planner: (klass) ->
        planner = @planners.create(1)[0]
        extend(planner, FSMAgent, klass)
        planner.init()
        return planner


class NodeInterconnectivityPlanner extends Planner

    init: () ->
        @msg_reader = MessageBoard.get_board('nodes_unconnected')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @msg_reader.get_message()
        if @message?
            @_set_state('emit_road_connector')

    s_emit_road_connector: () ->
        if not @message?
            @_set_state('get_message')
            return

        RoadBuilder.spawn_road_connector(@message.patch_a, @message.patch_b)
        @message = null
        @_set_state('get_message')


class RoadPlanner

    init: () ->
        @msg_reader = MessageBoard.get_board('possible_node')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @msg_reader.get_message()
        if @message?
            @_set_state('emit_road_extender')

    s_emit_road_extender: () ->
        if not @message?
            @_set_state('get_message')
            return

        RoadBuilder.spawn_road_extender(@message.patch)
        @message = null
        @_set_state('get_message')


# class GrowthPlanner

#     ticks_per_citizen: 30

#     init: () ->
#         @msg_reader = MessageBoard.get_board('new_citizen')
#         @ticks_since_last_citizen = 0

#     step: () ->
#         @_grow_population()

#     _grow_population: () ->
#         @ticks_since_last_citizen += 1

#         if @ticks_since_last_citizen >= @ticks_per_citizen
#             @msg_reader.post_message()
#             @ticks_since_last_citizen = 0
