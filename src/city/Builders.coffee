class RoadBuilder
    # Agentscript stuff
    @road_makers: null

    # Appearance
    @default_color: [255,255,255]

    # Behavior
    @radius_increment = 3

    @initialize_module: (road_makers_breed) ->
        @road_makers = road_makers_breed
        @road_makers.setDefault('color', @default_color)

    @spawn_road_connector: (road_a, road_b) ->
        road_maker = @spawn_road_maker(road_a, RoadConnector.prototype)
        road_maker.init(road_b)
        return road_maker

    @spawn_road_extender: (endpoint) ->
        road_maker = @spawn_road_maker(CityModel.instance.city_hall, RoadExtender.prototype)
        road_maker.init(endpoint)
        return road_maker

    @spawn_road_maker: (patch, prototype) ->
        road_maker = patch.sprout(1, @road_makers)[0]
        extend(road_maker, BaseAgent.prototype)
        extend(road_maker, prototype)
        return road_maker

    # Utils

    speed: 0.05

    _drop_road: ->
        Road.set_breed(@p)

    s_build_to_point_state: ->
        if not @path?
            @path = @_get_terrain_path_to(@endpoint)

        @_move @path[0]

        if not Road.is_road @p
            @_drop_road()

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                for point in @points_to_report
                    @msg_reader.post_message({patch: point})
                @_set_state('die')

    s_die: ->
        @die()


class RoadExtender extends RoadBuilder

    init: (endpoint) ->
        @endpoint = endpoint
        @points_to_report = [@endpoint]

        @_set_initial_state('go_to_point_state')
        @msg_reader = MessageBoard.get_board('inspect_node')

    s_go_to_point_state: ->
        if not @path?
            closest_road_to_target = Road.get_closest_road_to(@endpoint)
            @path = @_get_terrain_path_to(closest_road_to_target)

        @_move(@path[0])

        if @_in_point(@path[0])
            @path.shift()
            if @path.length is 0
                @path = CityModel.instance.terrainAStar.getPath(@, @endpoint)
                @_set_state('build_to_point_state')


class RoadConnector extends RoadBuilder

    init: (endpoint) ->
        @startpoint = @p
        @endpoint = endpoint

        @points_to_report = [@startpoint, @endpoint]

        @_set_initial_state('build_to_point_state')
        @msg_reader = MessageBoard.get_board('inspect_node')



class HouseBuilder
    # Agentscript stuff
    @house_makers: null

    # Appearance
    @default_color: [255,0,0]

    @initialize_module: (house_makers_breed) ->
        @house_makers = house_makers_breed
        @house_makers.setDefault('color', @default_color)

    @spawn_house_maker: (patch) ->
        house_maker = patch.sprout(1, @house_makers)[0]
        extend(house_maker, BaseAgent.prototype)
        extend(house_maker, HouseMaker.prototype)
        house_maker.init()
        return house_maker


    speed: 0.05

    init: () ->
        @_set_initial_state('move_and_place')

    s_move_and_place: () ->
        # Check if there are any patches where a house might go
        near_patches = ABM.util.shuffle @p.n
        for patch in near_patches
            if not House.isHouseHere(patch) and not Road.is_road(patch)
                @_place_house(patch)
                # Exit as soon as we place one
                break

        # Move to a random new patch
        near_patches = ABM.util.shuffle @p.n4
        for patch in near_patches
            if Road.is_road patch
                @_move(patch)
                break

    _place_house: (patch) ->
        House.set_breed patch

