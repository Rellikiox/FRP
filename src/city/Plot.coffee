class Plot

    @plots: null
    @initialize: () ->
        @plots = []

    @make_plot: (patches) ->
        if patches? and patches.length > 0
            plot = new Plot(patches)
            @plots.push(plot)
            return plot

    @is_part_of_plot: (patch) ->
        return patch?.plot?

    @get_random_plot: () ->
        if @plots.length > 0
            for i in ABM.util.shuffle([0..@plots.length-1])
                plot = @plots[i]
                if plot.is_available() and plot.has_free_space()
                    return plot
        return null

    patches: null
    blocks: null
    under_construction: null
    constructor: (@patches) ->
        @blocks = []
        @under_construction = false

        for p in @patches
            p.color = ABM.util.randomGray(140, 170)

        @_set_patch_references()

    _set_patch_references: () ->
        for patch in @patches
            patch.plot = @

    get_available_block: () ->
        for i in ABM.util.shuffle([0..@patches.length-1])
            if not House.is_house(@patches[i]) or @patches[i].has_free_space()
                return @patches[i]
        return null

    has_free_space: () ->
        return @get_available_block()?

    get_closes_patch_to: (patch) ->
        min_dist = null
        min_patch = null
        for p in @patches
            dist = ABM.util.distance(p.x, p.y, patch.x, patch.y)
            if not min_dist? or dist < min_dist
                min_dist = dist
                min_patch = p
        return min_patch

    is_available: () ->
        return not @under_construction


CityModel.register_module(Plot, [], [])



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


