class KMeans
    @max_iters: 100

    @_prepare_points: (points) ->
        return (KMeans._copy_point(point) for point in points)

    @_copy_point: (point) ->
        return x: point.x, y: point.y, weight: 1

    @_init_clusters: (points, number_of_clusters) ->
        clusters = []
        for i in [0...number_of_clusters]
            index = ABM.util.randomInt(points.length)
            clusters.push(center: KMeans._copy_point(points[index]), points: [])
        return clusters

    @_dist: (point_a, point_b) ->
        return ABM.util.distance(point_a.x, point_a.y, point_b.x, point_b.y)

    @_closest_centroid: (distances) ->
        return ABM.util.minOneOf(distances, (point) -> point.distance).cluster

    @_points_are_equal: (point_a, point_b) ->
        return @_dist(point_a, point_b) < 0.1

    constructor: (points, number_of_clusters) ->
        @points = KMeans._prepare_points(points)
        @clusters = KMeans._init_clusters(@points, number_of_clusters)
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
        for cluster in @clusters
            cluster.points = []

        for point in @points
            distances = (distance: KMeans._dist(point, cluster.center), cluster: cluster for cluster in @clusters)
            KMeans._closest_centroid(distances).points.push(point)

    move_centroids: () ->
        moved = false
        for cluster in @clusters
            mean_position = x: 0, y: 0
            summed_weights = 0
            for point in cluster.points
                mean_position.x += point.x * point.weight
                mean_position.y += point.y * point.weight
                summed_weights += point.weight
            mean_position.x /= summed_weights
            mean_position.y /= summed_weights

            moved = moved or not KMeans._points_are_equal(cluster.center, mean_position)
            cluster.center = mean_position
        return moved

    centroids: () ->
        return (cluster.center for cluster in @clusters)
