class HouseMaker
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
        @_set_state('move_and_place')

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

