class Plot

    @plots: null
    @global_id = 0

    @initialize: () ->
        @plots = []
        @global_id = 0

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

        for plot in @plots when plot.has_free_space()
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
    id: null
    distances: null

    constructor: (patches) ->
        @blocks = []
        @under_construction = false
        @id = Plot.global_id++

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
            if block.is_available() or House.has_house(block) and block.building.has_free_space()
                return @blocks[i]
        return null

    has_free_space: () ->
        return @free_space() > 0

    free_space: () ->
        return @space() - @citizens()

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

    space: () ->
        sum = 0
        for block in @blocks
            if House.has_house(block) or block.is_available()
                sum += House.max_citizens
        return sum

    citizens: () ->
        sum = 0
        for block in @blocks
            if House.has_house(block)
                sum += block.building.citizens
        return sum


CityModel.register_module(Plot, [], [])



class Block
    @blocks: null

    @initialize: (@blocks) ->
        House.initialize()

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
    building: null

    init: (plot) ->
        @plot = plot
        @color = ABM.util.randomGray(140, 170)
        @distances = {}

    destroy: () ->
        CityModel.get_patches().setBreed(@)

    is_available: () ->
        return not @building?

    building_type: () ->
        return @building?._building_type

    is_of_type: (type) ->
        return @building_type() == type

    dist_to_need: (need) ->
        if need of @distances
            return @distances[need]
        else
            return null

    set_dist_to_need: (need, dist) ->
        @distances[need] = dist

    _manhatan_distance_to: (patch) ->
        return Math.abs(@x - patch.x) + Math.abs(@y - patch.y)

CityModel.register_module(Block, [], ['blocks'])


class House

    @hsl_color: [1.0, 1.0, 0.5]

    @max_citizens: 10

    @minimum_housing_available = 0.5

    @explansion_threshold = 0.5
    @explansion_factor = 1.25

    @population = 0

    @initialize: () ->
        @population = 0

    @get_or_create: (block) ->
        house = null
        if Block.is_block(block)
            if House.has_house(block)
                house = block.building
            else if block.is_available()
                house = House.make_here(block)

        return house

    @make_here: (block) ->
        if Block.is_block(block)
            block.building = new House(block)
            return block.building

    @has_house: (patch) ->
        return Block.is_block(patch) and patch.is_of_type('house')

    @houses_below_minimum: () ->
        free_space = 0
        total_space = 0
        for block in Block.blocks when House.has_house(block)
            total_space += block.house.space
            free_space += block.house.free_space()

        return (free_space / total_space) < House.minimum_housing_available

    @_update_navigation: (house) ->
        # CityModel.set_terrain_nav_patch_walkable(house, false)

    @get_available_block: () ->


    _building_type: 'house'

    color: [100, 0, 0]

    blocks: null
    citizens: 0
    space: House.max_citizens

    constructor: (block) ->
        @blocks = []

        @blocks.push(block)
        House._update_navigation(@)

        block.color = @color

    has_free_space: () ->
        return @citizens < @space

    free_space: () ->
        return @space - @citizens

    increase_citizens: () ->
        if @has_free_space()
            @citizens += 1
            House.population += 1
            @blocks[0].color = ABM.util.scaleColor(@blocks[0].color, 1.05)
            @_check_for_expansion()

    reallocate_citizens: () ->
        for i in [0..@citizens]
            House.population -= 1
            HouseBuilder.spawn_house_builder(@blocks[0], Plot.get_available_block())

    _check_for_expansion: () ->


    is_1x1: () ->
        return @blocks.length == 1

    is_2x1: () ->
        return @blocks.length == 2

    is_2x2: () ->
        return @blocks.length == 4

    _check_2x1: () ->
        if @is_1x1()
            for block in @block.n4 when House.has_house(block)
                if block.house.is_1x1()
                    1


class GenericBuilding
    @hospital_color: [0.44, 1.0, 0.5]
    @school_color: [0.50, 1.0, 0.5]
    @store_color: [0.56, 1.0, 0.5]

    @info:
        hospital:
            threshold: 400
            radius: 20
            hsl_color: @hospital_color
            rgb_color: Colors.hslToRgb(@hospital_color...).map((f) -> Math.round(f))
            size: '2x2'
        school:
            threshold: 100
            radius: 10
            hsl_color: @school_color
            rgb_color: Colors.hslToRgb(@school_color...).map((f) -> Math.round(f))
            size: '2x1'
        store:
            threshold: 50
            radius: 5
            hsl_color: @store_color
            rgb_color: Colors.hslToRgb(@store_color...).map((f) -> Math.round(f))
            size: '1x1'

    @_get_shape:
        '1x1': (patch) -> return [patch] if Block.is_block(patch)
        '2x1': (patch) ->
            if Block.is_block(patch)
                neighbours = (p for p in patch.n4 when Block.is_block(p))
                if neighbours.length > 0
                    return [patch, ABM.util.oneOf(neighbours)]
        '2x2': (patch) ->
            _get_patch = (patch, offset) ->
                return CityModel.get_patch_at({x: patch.x + offset.x, y: patch.y + offset.y})
            _check_patch = (patch, offset) ->
                return Block.is_block(_get_patch(patch, offset))
            offsets = [
                [{x: -1, y: 0}, {x: -1, y: 1}, {x: 0, y: 1}, {x: 0, y: 0}],
                [{x: 0, y: 1}, {x: 1, y: 1}, {x: 1, y: 0}, {x: 0, y: 0}],
                [{x: 1, y: 0}, {x: 1, y: -1}, {x: 0, y: -1}, {x: 0, y: 0}],
                [{x: 0, y: -1}, {x: -1, y: -1}, {x: -1, y: 0}, {x: 0, y: 0}]]

            available = (offset for offset in offsets when not offset.some((offset) -> not _check_patch(patch, offset)))
            if available.length > 0
                shape = ABM.util.oneOf(available)
                return (_get_patch(patch, offset) for offset in shape)

    @get_shape: (patch, type) ->
        size = @info[type].size
        return @_get_shape[size](patch)

    @make_here: (blocks, subtype) ->
        if not blocks.some((b) -> not Block.is_block(b))

            for block in blocks
                if House.has_house(block)
                    block.building.reallocate_citizens()

                block.building = new GenericBuilding(blocks, subtype)

    @is_building: (patch) ->
        return Block.is_block(patch) and patch.is_of_type('building')

    @get_of_subtype: (subtype) ->
        return (block for block in Block.blocks when block.is_of_type('building') and block.building.is_of_subtype(subtype))

    @fits_here: (patch, type) ->
        return @get_shape(patch, type).length > 0


    _building_type: 'building'

    building_subtype: null
    color: [174, 131, 0]

    constructor: (@blocks, @building_subtype) ->
        @_set_distances()

        for block in blocks
            block.color = GenericBuilding.info[@building_subtype].rgb_color


    _set_distances: () ->
        blocks_in_radius = Block.blocks.inRadius(@blocks[0], 10)
        for block in blocks_in_radius when House.has_house(block)
            m_dist = @blocks[0]._manhatan_distance_to(block)
            block_dist = block.dist_to_need(@building_subtype)
            if not block_dist? or block_dist > m_dist
                block.set_dist_to_need(@building_subtype, m_dist)

    is_of_subtype: (subtype) ->
        return @building_subtype == subtype



