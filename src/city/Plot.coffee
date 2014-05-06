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
        if @plots.length is 0
            return null

        total_free_space = 0
        for plot in @plots
            if plot.is_available()
                total_free_space += plot.free_space()

        random_number = ABM.util.randomInt(total_free_space)

        for plot in @plots
            if plot.is_available()
                random_number -= plot.free_space()
                if random_number <= 0
                    return plot
        return null

    @destroy_plot: (plot) ->
        ABM.util.removeItem(@plots, plot)
        plot._unset_patch_references()

    @get_available_block: () ->
        return @get_random_plot()?.get_available_block()


    patches: null
    blocks: null
    under_construction: null
    space: 0

    constructor: (@patches) ->
        @blocks = []
        @under_construction = false
        @space = @patches.length * 10

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

    free_space: () ->
        return @space - @citizens()


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

    citizens: () ->
        sum = 0
        for block in @blocks
            sum += block.citizens()
        return sum


CityModel.register_module(Plot, [], [])



class Block
    @blocks: null

    CityModel.register_module(House, [], ['houses'])

    @initialize: (@blocks) ->

    @closest_block: (patch) ->
        open_list = [patch]
        closed_list = []
        while open_list.length > 0
            p = open_list.shift()
            if p.block?
                return p
            open_list.push(n) for n in p.n4 when not ABM.util.contains(open_list, n) and not ABM.util.contains(closed_list, n)
            closed_list.push(p)
        return null

    houses: null
    plot: null
    space: 0

    constructor: (house) ->
        @houses = [house]
        @plot = house.plot
        @space = house.space

    citizens: () ->
        sum = 0
        for house in @houses
            sum += house.citizens
        return sum


class House

    @default_color: [100, 0, 0]

    @max_citizens: 10

    @minimum_housing_available = 0.5

    @total_citizens = 0

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
            House.total_citizens += 1
            @color = ABM.util.scaleColor(@color, 1.05)

    reallocate_citizens: () ->
        for i in [0..@citizens]
            HouseBuilder.spawn_house_builder(@, Plot.get_available_block())
        @inspector.die()



class Building
    @buildings: null

    @default_color: [174, 131, 0]

    @initialize: (@buildings) ->
        @buildings.setDefault('color', @default_color)

    @make_here: (patch) ->
        @buildings.setBreed(patch)
        extend(patch, Building)
        patch.init()

    @is_building: (patch) ->
        return patch.breed is @buildings

    init: () ->

CityModel.register_module(Building, [], ['buildings'])
