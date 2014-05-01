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

    @destroy_plot: (plot) ->
        ABM.util.removeItem(@plots, plot)
        plot._unset_patch_references()


    patches: null
    blocks: null
    under_construction: null
    constructor: (@patches) ->
        @blocks = []
        @under_construction = false

        for p in @patches
            if not House.is_house(p)
                p.color = ABM.util.randomGray(140, 170)

        @_set_patch_references()

    _set_patch_references: () ->
        for patch in @patches
            patch.plot = @

    _unset_patch_references: () ->
        for patch in @patches
            patch.plot = null

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

    @minimum_housing_available = 0.3


    @initialize: (@houses) ->
        @houses.setDefault('color', @default_color)

    @make_here: (patch) ->
        @houses.setBreed(patch)
        extend(patch, House)
        patch.init()

    @is_house: (patch) ->
        return patch.breed is @houses

    @houses_below_minimum: () ->
        free_space = 0
        total_space = 0
        for house in @houses
            total_space += house.space
            free_space += house.free_space()

        return (free_space / total_space) < House.minimum_housing_available

    @_update_navigation: (house) ->
        # CityModel.set_terrain_nav_patch_walkable(house, false)


    block: null
    citizens: 0
    space: 0

    init: () ->
        @block = new Block(@)
        House._update_navigation(@)
        @citizens = 0
        @space = House.max_citizens
        @inspector = Inspector.spawn_house_inspector(@)
        @board = MessageBoard.get_board('new_citizen')
        @hospital_distance = 1

    has_free_space: () ->
        return @citizens < @space

    free_space: () ->
        return @space - @citizens

    increase_citizens: () ->
        if @has_free_space()
            @citizens += 1
            @color = ABM.util.scaleColor(@color, 1.05)

    reallocate_citizens: () ->
        for i in [0..@citizens]
            @board.post_message()
        @inspector.die()


CityModel.register_module(House, [], ['houses'])


