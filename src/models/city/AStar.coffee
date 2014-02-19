class AStarHelper
    @createGrid: (width, height, walkable) ->
        val = if walkable then 0 else 1
        for y in [1..height]
            for x in [1..width]
                val

    grid: null
    finder: null

    xToGridTransform: null
    yToGridTransform: null
    xToWorldTransform: null
    yToWorldTransform: null

    constructor: (width, height, walkable=true) ->
        @grid = new PF.Grid(width, height, AStarHelper.createGrid(width, height, walkable))
        @finder = new PF.AStarFinder()

    setWalkable: (x, y, walkable=true) ->
        @grid.setWalkableAt(x, y, walkable)
        null

    getPath: (x1, y1, x2, y2) ->
        [x1, y1] = transformPointToGrid(x1, y1)
        [x2, y2] = transformPointToGrid(x2, y2)

        path = finder.findPath(x1, y1, x2, y2, @grid)

        return (transformPointToWorld(x,y) for [x,y] in path)

    setToGridTransforms: (xTr, yTr) ->
        @xToGridTransform = xTr
        @yToGridTransform = yTr
        null

    setToWorldTransforms: (xTr, yTr) ->
        @xToWorldTransform = xTr
        @yToWorldTransform = yTr
        null

    transformPointToGrid: (x, y) ->
        return [@xToGridTransform(x), @yToGridTransform(y)]

    transformPointToWorld: (x, y) ->
        return [@xToWorldTransform(x), @yToWorldTransform(y)]

