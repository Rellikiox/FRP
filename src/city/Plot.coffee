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
            total_free_space += plot.free_space()

        random_number = ABM.util.randomInt(total_free_space)

        for plot in @plots
            random_number -= plot.free_space()
            if random_number <= 0
                return plot
        return null

    @destroy_plot: (plot) ->
        ABM.util.removeItem(@plots, plot)
        plot._unset_block_references()

    @get_available_block: () ->
        return @get_random_plot()?.get_available_block()


    blocks: null
    space: 0

    constructor: (patches) ->
        @blocks = []
        @under_construction = false
        @space = patches.length * 10

        for p in patches
            if not Block.is_block(p)
                Block.make_here(p, @)
            else
                p.plot = @
            @blocks.push(p)

    _unset_block_references: () ->
        for block in @blocks
            block.plot = null

    get_available_block: () ->
        for i in ABM.util.shuffle([0..@blocks.length-1])
            block = @blocks[i]
            if block.is_available() or House.is_house(block) and block.has_free_space()
                return @blocks[i]
        return null

    has_free_space: () ->
        return @get_available_block()?

    free_space: () ->
        return @space - @citizens()


    get_closest_block_to: (patch) ->
        min_dist = null
        min_patch = null
        for p in @blocks
            dist = ABM.util.distance(p.x, p.y, patch.x, patch.y)
            if not min_dist? or dist < min_dist
                min_dist = dist
                min_patch = p
        return min_patch

    is_available: () ->
        for block in @blocks
            if block.is_available()
                return true
        return false

    citizens: () ->
        sum = 0
        for block in @blocks
            if House.is_house(block)
                sum += block.citizens
        return sum


CityModel.register_module(Plot, [], [])



class Block
    @blocks: null

    @initialize: (@blocks) ->

    @make_here: (patch, plot) ->
        @blocks.setBreed(patch)
        extend(patch, Block)
        patch.init(plot)

    @closest_block: (patch) ->
        open_list = [patch]
        closed_list = []
        while open_list.length > 0
            p = open_list.shift()
            if Block.is_block(p)
                return p
            open_list.push(n) for n in p.n4 when not ABM.util.contains(open_list, n) and not ABM.util.contains(closed_list, n)
            closed_list.push(p)
        return null

    @is_block: (patch) ->
        return patch.breed is @blocks

    plot: null
    block_type: 'block'

    init: (plot) ->
        @plot = plot
        @color = ABM.util.randomGray(140, 170)

    destroy: () ->
        CityModel.get_patches().setBreed(@)

    is_available: () ->
        return @block_type == 'block'

CityModel.register_module(Block, [], ['blocks'])


class House

    @default_color: [100, 0, 0]

    @max_citizens: 10

    @minimum_housing_available = 0.5

    @total_citizens = 0

    @make_here: (block) ->
        if Block.is_block(block)
            extend(block, House)
            block.init()

    @is_house: (patch) ->
        return Block.is_block(patch) and patch.block_type is 'house'

    @houses_below_minimum: () ->
        free_space = 0
        total_space = 0
        for house in Block.blocks when house.block_type is 'house'
            total_space += house.space
            free_space += house.free_space()

        return (free_space / total_space) < House.minimum_housing_available

    @_update_navigation: (house) ->
        # CityModel.set_terrain_nav_patch_walkable(house, false)

    @get_available_block: () ->



    block_type: 'house'
    color: [100, 0, 0]

    citizens: 0
    space: 0

    init: () ->
        House._update_navigation(@)
        @citizens = 0
        @space = House.max_citizens
        @inspector = Inspector.spawn_house_inspector(@)
        @board = MessageBoard.get_board('new_citizen')

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
