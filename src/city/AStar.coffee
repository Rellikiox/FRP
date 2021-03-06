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

    constructor: (width, height, walkable=true, heuristic=null) ->
        @grid = new PF.Grid(width, height, AStarHelper.createGrid(width, height, walkable))
        @finder = new PF.AStarFinder({
            heuristic: (current_node, end_node) =>
                dx = Math.abs(end_node.x - current_node.x)
                dy = Math.abs(end_node.y - current_node.y)
                val = dx + dy
                if CityModel.get_patch_at(@transformPointToWorld(current_node.x, current_node.y)).dist_to_road == 1
                    val += 1
                return val
            })

    setWalkable: (p, walkable=true) ->
        [x,y] = @transformPointToGrid(p)
        @grid.setWalkableAt(x, y, walkable)
        null

    getPath: (p1, p2) ->
        [x1, y1] = @transformPointToGrid(p1)
        [x2, y2] = @transformPointToGrid(p2)

        _grid = @grid.clone()
        path = @finder.findPath(x1, y1, x2, y2, @grid)
        @grid = _grid

        return (@transformPointToWorld(x,y) for [x,y] in path)

    setToGridTransforms: (xTr, yTr) ->
        @xToGridTransform = xTr
        @yToGridTransform = yTr
        null

    setToWorldTransforms: (xTr, yTr) ->
        @xToWorldTransform = xTr
        @yToWorldTransform = yTr
        null

    transformPointToGrid: (p) ->
        return [@xToGridTransform(Math.round(p.x)), @yToGridTransform(Math.round(p.y))]

    transformPointToWorld: (x, y) ->
        return {x:@xToWorldTransform(x), y:@yToWorldTransform(y)}

