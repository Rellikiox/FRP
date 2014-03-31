class Planner
    @planners = null

    @initialize_module: (planners_breed) ->
        @planners = planners_breed
        @planners.setDefault 'hidden', true
        LotKeeperPlanner.available_lots = []

    @spawn_road_planner: () ->
        return @spawn_planner(RoadPlanner)

    @spawn_node_planner: () ->
        return @spawn_planner(NodeInterconnectivityPlanner)

    @spawn_growth_planner: () ->
        return @spawn_planner(GrowthPlanner)

    @spawn_lot_planner: () ->
        return @spawn_planner(LotPlanner)

    @spawn_housing_planner: () ->
        return @spawn_planner(HousingPlanner)

    @spawn_lot_keeper_planner: () ->
        return @spawn_planner(LotKeeperPlanner)

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
            @_set_state('send_road_extender')

    s_send_road_extender: () ->
        if not @message?
            @_set_state('get_message')
            return

        RoadBuilder.spawn_road_extender(@message.patch)
        @message = null
        @_set_state('get_message')


class LotPlanner

    init: () ->
        @boards =
            possible: MessageBoard.get_board('possible_lot')
            inspect: MessageBoard.get_board('inspect_lot')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @boards.possible.get_message()
        if @message?
            @_set_state('send_lot_inspector')

    s_send_lot_inspector: () ->
        if not @message?
            @_set_state('get_message')
            return

        @boards.inspect.post_message({patch: @message.patch})
        @message = null
        @_set_state('get_message')


class LotKeeperPlanner

    @available_lots: []

    init: () ->
        @board = MessageBoard.get_board('lot_built')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @board.get_message()
        if @message?
            LotKeeperPlanner.available_lots.push(@message.lot)


class HousingPlanner

    init: () ->
        @board = MessageBoard.get_board('new_citizen')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @board.get_message()
        if @message?
            @_set_state('send_house_builder')

    s_send_house_builder: () ->
        if LotKeeperPlanner.available_lots.length > 0
            lot = @_random_choice(LotKeeperPlanner.available_lots)
            block = @_random_choice(lot)
            HouseBuilder.spawn_house_maker(block)
            @_set_state('get_message')

    _random_choice: (list) ->
        return list[ABM.util.randomInt(list.length)]


class GrowthPlanner

    ticks_per_citizen: 30

    init: () ->
        @msg_reader = MessageBoard.get_board('new_citizen')
        @ticks_since_last_citizen = 0
        @_set_initial_state('wait_until_ready')

    s_wait_until_ready: () ->
        @ticks_since_last_citizen += 1
        if @ticks_since_last_citizen >= @ticks_per_citizen
            @_set_state('grow_population')

    s_grow_population: () ->
        @msg_reader.post_message()
        @ticks_since_last_citizen = 0
        @_set_state('wait_until_ready')

