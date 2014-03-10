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
        extend(house_maker, HouseMaker_instance_properties)
        return house_maker


HouseMaker_instance_properties =

    step: ->
        # Check if there are any patches where a house might go
        near_patches = ABM.util.shuffle @p.n
        for patch in near_patches
            if not House.isHouseHere(patch) and not Road.is_road_here(patch)
                @placeHouse patch
                # Exit as soon as we place one
                break

        # Move to a random new patch
        near_patches = ABM.util.shuffle @p.n4
        for patch in near_patches
            if Road.is_road_here patch
                @move patch
                break

    placeHouse: (patch) ->
        House.set_breed patch

    inPoint: (point) ->
        return 0.1 > ABM.util.distance @x, @y, point.x, point.y

    move: (point) ->
        if not @local_point? or @inPoint(@local_point)
            @local_point = @getLocalPoint point

        @facePoint @local_point
        @forward(0.05)

    getLocalPoint: (point) ->
        dx = point.x - @x
        dy = point.y - @y
        heading = Math.round(Math.atan2(dy, dx) / (Math.PI / 2))
        switch
            when heading is 0 then return {x: @p.x + 1, y: @p.y}
            when heading is 1 then return {x: @p.x, y: @p.y + 1}
            when heading is -1 then return {x: @p.x, y: @p.y - 1}
            when heading is 2 or heading is -2 then return {x: @p.x - 1, y: @p.y}

    facePoint: (point) ->
        dx = point.x - @x
        dy = point.y - @y
        heading = Math.atan2 dy, dx
        # clamp the heading to the nearest 90º
        turn = ABM.util.subtractRads heading, @heading # angle from h to a
        #turn = u.clamp turn, -@maxTurn, @maxTurn # limit the turn
        @rotate turn



