class Plot
    constructor: () ->



class Block

    patches: []

    constructor: (patch) ->
        @patches.push(patch)


class House
    @houses: null

    @default_color: [100, 0, 0]

    @initialize: (@houses) ->
        @houses.setDefault('color', @default_color)

    @make_here: (patch) ->
        @houses.setBreed(patch)
        extend(patch, House)
        patch.init()

    @is_house: (patch) ->
        return patch.breed is @houses


    block: null

    init: () ->
        @block = new Block(@)
        CityModel.instance.terrainAStar.setWalkable(@, false)



CityModel.register_module(House, [], ['houses'])


