class Plot

    @make_plot: (patches) ->
        if patches? and patches.length > 0
            return new Plot(patches)


    patches: null
    blocks: null
    constructor: (@patches) ->
        blocks = []

        for p in patches
            p.color = ABM.util.randomGray(140, 170)

    _set_patch_references: () ->
        for patch in patches
            patch.lot = @

    get_available_block: () ->
        shuffled = @patches
        ABM.util.shuffle(shuffled)

        for patch in @patches
            if not House.is_house(patch) or patch.has_free_space()
                return patch


class Block

    houses: null
    plot: null

    constructor: (house) ->
        @houses = [house]
        @plot = house.plot


class House
    @houses: null

    @default_color: [100, 0, 0]

    @max_citizens: 10

    @initialize: (@houses) ->
        @houses.setDefault('color', @default_color)

    @make_here: (patch) ->
        @houses.setBreed(patch)
        extend(patch, House)
        patch.init()

    @is_house: (patch) ->
        return patch.breed is @houses

    @_update_navigation: (house) ->
        CityModel.set_terrain_nav_patch_walkable(house, false)


    block: null
    citizens: 0

    init: () ->
        @block = new Block(@)
        House._update_navigation(@)
        @citizens = 0

    has_free_space: () ->
        return @citizens < House.max_citizens

    increase_citizens: () ->
        if @has_free_space()
            @citizens += 1
            @color = ABM.util.scaleColor(@color, 1.05)



CityModel.register_module(House, [], ['houses'])


