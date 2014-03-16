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

class RoadPlanner
    @road_planners = null

    @initialize_module: (road_planners_breed) ->
        @road_planners = road_planners_breed
        @road_planners.setDefault 'hidden', true

    @spawn_road_planner: () ->
        road_planner = @road_planners.create(1)[0]
        extend(road_planner, RoadPlanner.prototype)
        road_planner.init()
        return road_planner

    init: () ->
        @msg_reader = MessageBoard.get_reader('build_road')

    step: () ->
        msg = @msg_reader.get_message()
        if msg?
            RoadMaker.spawn_road_maker(msg.node_a.p)



