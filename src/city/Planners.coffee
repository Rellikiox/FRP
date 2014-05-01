class Planner
    @planners = null

    @initialize: (@planners) ->
        @planners.setDefault 'hidden', true
        PlotKeeperPlanner.available_plots = []

    @spawn_road_planner: () ->
        return @spawn_planner(RoadPlanner)

    @spawn_node_planner: () ->
        return @spawn_planner(NodeInterconnectivityPlanner)

    @spawn_bulldozer_planner: () ->
        return @spawn_planner(BulldozerPlanner)

    @spawn_growth_planner: () ->
        return @spawn_planner(GrowthPlanner)

    @spawn_plot_planner: () ->
        return @spawn_planner(PlotPlanner)

    @spawn_housing_planner: () ->
        return @spawn_planner(HousingPlanner)

    @spawn_plot_keeper_planner: () ->
        return @spawn_planner(PlotKeeperPlanner)

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

        RoadBuilder.spawn_road_connector(@message.path)
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


class PlotPlanner

    init: () ->
        @boards =
            possible: MessageBoard.get_board('possible_plot')
            inspect: MessageBoard.get_board('inspect_plot')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @boards.possible.get_message()
        if @message?
            @_set_state('send_plot_inspector')

    s_send_plot_inspector: () ->
        if not @message?
            @_set_state('get_message')
            return

        @boards.inspect.post_message({patch: @message.patch})
        @message = null
        @_set_state('get_message')


class PlotKeeperPlanner

    @available_plots: []

    init: () ->
        @board = MessageBoard.get_board('plot_built')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @board.get_message()
        if @message?
            PlotKeeperPlanner.available_plots.push(@message.plot)


class HousingPlanner

    init: () ->
        @board = MessageBoard.get_board('new_citizen')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @board.get_message()
        if @message?
            @_set_state('send_house_builder')

    s_send_house_builder: () ->
        plot = Plot.get_random_plot()
        if plot?
            block = plot.get_available_block()
            if block?
                HouseBuilder.spawn_house_builder(block)
                @_set_state('get_message')


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


class BulldozerPlanner

    init: () ->
        @msg_reader = MessageBoard.get_board('bulldoze_path')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @msg_reader.get_message()
        if @message?
            @_set_state('emit_bulldozer')

    s_emit_bulldozer: () ->
        if not @message?
            @_set_state('get_message')
            return

        Bulldozer.spawn_bulldozer(@message.path)
        @message = null
        @_set_state('get_message')


class NeedsPlanner
    @needs = {}

    init: () ->
        @msg_reader = MessageBoard.get_board('population_needs')
        @_set_initial_state('get_message')

    s_get_message: () ->
        @message = @msg_reader.get_message()
        if @message?
            @_set_state('process_message')

    s_process_message: () ->


        @message = null
        @_set_state('get_message')

CityModel.register_module(Planner, ['planners'], [])

