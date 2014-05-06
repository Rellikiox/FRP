class KMeans
    @max_iters: 100

    @_copy_point: (point) ->
        return x: point.x, y: point.y

    @_init_centroids: (points, number_of_clusters) ->
        centroids = []
        for i in [0...number_of_clusters]
            index = ABM.util.randomInt(points.length)
            centroids.push(point: KMeans._copy_point(points[index]), points: [])
        return centroids

    @_dist: (point_a, point_b) ->
        return ABM.util.distance(point_a.x, point_a.y, point_b.x, point_b.y)

    @_closest_centroid: (distances) ->
        return ABM.util.minOneOf(distances, (point) -> point.distance).centroid

    @_points_are_equal: (point_a, point_b) ->
        return @_dist(point_a, point_b) < 0.1

    constructor: (@points, @number_of_clusters) ->
        @centroids = KMeans._init_centroids(@points, @number_of_clusters)
        @converged = false

    run: () ->
        iters = 0
        while not @converged and iters < KMeans.max_iters
            @step()
            iters += 1

    step: () ->
        @assign_centroids()
        @converged = @move_centroids()

    assign_centroids: () ->
        for centroid in @centroids
            centroid.points = []

        for point in @points
            distances = (distance: KMeans._dist(point, centroid.point), centroid: centroid for centroid in @centroids)
            KMeans._closest_centroid(distances).points.push(point)

    move_centroids: () ->
        moved = false
        for centroid in @centroids
            mean_position = x: 0, y: 0
            for point in centroid.points
                mean_position.x += point.x
                mean_position.y += point.y
            mean_position.x /= centroid.points.length
            mean_position.y /= centroid.points.length

            moved |= not KMeans._points_are_equal(centroid.point, mean_position)
            centroid.point = mean_position
        return moved










