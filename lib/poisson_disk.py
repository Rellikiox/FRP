import random
import math

import os
parentdir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.sys.path.insert(0,parentdir) 

from planar import Vec2

class RandomQueue(object):
	def __init__(cls):
		cls.objs = []

	def append(cls, obj):
		cls.objs.append(obj)

	def pop(cls, index=None):
		if index is not None:
			return cls.objs.pop(index)
		else:
			index = random.randint(0, len(cls.objs) - 1)
			return cls.objs.pop(index)

	def empty(cls):
		return not cls.objs

class PoissonDisk(object):

	@classmethod
	def generate(cls, width, height, min_dist, point_count):
		cls.cell_size = min_dist / 1.414214;
		cls.width = width
		cls.height = height
		cls.min_dist = min_dist
		cls.grid_width = int(math.ceil(width / cls.cell_size))
		cls.grid_height = int(math.ceil(height / cls.cell_size))

		cls.grid = [ [ None for j in range(cls.grid_width) ] for i in range(cls.grid_height)]

		process_list = RandomQueue()
		sample_list = []	

		first_point = Vec2(random.random() * width, random.random() * height)
		process_list.append(first_point)
		sample_list.append(first_point)

		grid_x, grid_y = cls.get_grid_coords(first_point)
		cls.grid[grid_y][grid_x] = first_point

		while not process_list.empty():
			new_point = process_list.pop()
			print new_point
			for i in range(0, point_count):
				point_around = cls.get_point_around(new_point)
				if cls.is_within_boundaries(point_around) and not cls.has_close_neighbours(point_around):
					process_list.append(point_around)
					sample_list.append(point_around)
					grid_x, grid_y = cls.get_grid_coords(point_around)
					cls.grid[grid_y][grid_x] = point_around

		return sample_list

	@classmethod
	def get_grid_coords(cls, point):
		return int(point.x / cls.cell_size), int(point.y / cls.cell_size)

	@classmethod
	def get_point_around(cls, point):
		radius = cls.min_dist * (random.random() + 1)
		angle = 360 * random.random() - 180
		return Vec2.polar(angle, radius)

	@classmethod
	def is_within_boundaries(cls, point):
		return point.x >= 0 and point.x < cls.width	and point.y >= 0 and point.y < cls.height

	@classmethod
	def has_close_neighbours(cls, point):
		return any(point.distance_to(neighbour) < cls.min_dist for neighbour in cls.get_neighbour_points(point))


	@classmethod
	def get_neighbour_points(cls, point):
		grid_x, grid_y = cls.get_grid_coords(point)

		min_x = max(0, grid_x - 1)
		min_y = max(0, grid_y - 1)
		max_x = min(cls.grid_width - 1,  grid_x + 1)
		max_y = min(cls.grid_height - 1, grid_y + 1)

		return [cls.grid[i][j] for i in range(min_y, max_y) for j in range(min_x, max_x) if cls.grid[i][j] is not None]

## @brief Gives a Poisson sample of points of a rectangle.
##
# @param width
#		The width of the rectangle to sample
# @param height
#		The height of the rectangle to sample
# @param r
#		The mimum distance between points, in terms of 
#		rectangle units. For example, in a 10 by 10 grid, a mimum distance of 
#		10 will probably only give you one sample point.
# @param k
#		The algorithm generates k points around points already 
#		in the sample, and then check if they are not too close
#		to other points. Typically, k = 30 is sufficient. The larger 
#		k is, the slower th algorithm, but the more sample points
#		are produced.
# @return A list of tuples representing x, y coordinates of
#		of the sample points. The coordinates are not necesarily
#		integers, so that the can be more accurately scaled to be
#		used on larger rectangles.
def sample_poisson_uniform(width, height, r, k):
	#Convert rectangle (the one to be sampled) coordinates to 
	# coordinates in the grid.
	def grid_coordinates((x, y)):
		return (int(x*inv_cell_size), int(y*inv_cell_size))
	
	# Puts a sample point in all the algorithm's relevant containers.
	def put_point(p):
		process_list.push(p)
		sample_points.append(p)  
		grid[grid_coordinates(p)] = p

	# Generates a point randomly selected around
	# the given point, between r and 2*r units away.
	def generate_random_around((x, y), r):
		rr = uniform(r, 2*r)
		rt = uniform(0, 2*pi)
		
		return rr*sin(rt) + x, rr*cos(rt) + y
		
	# Is the given point in the rectangle to be sampled?
	def in_rectangle((x, y)):
		return 0 <= x < width and 0 <= y < height
		
	def in_neighbourhood(p):
		gp = gx, gy = grid_coordinates(p)
		
		if grid[gp]: return True
		
		for cell in grid.square_iter(gp, 2):
			if cell and sqr_dist(cell, p) <= r_sqr:
				return True
		return False

	#Create the grid
	cell_size = r/math.sqrt(2)
	inv_cell_size = 1 / cell_size	
	r_sqr = r*r
	
	grid = Grid2D((int(ceil(width/cell_size)),
		int(ceil(height/cell_size))))
		
	process_list = RandomQueue()
	sample_points = []	
	
	#generate the first point
	put_point((rand(width), rand(height)))
	
	#generate other points from points in queue.
	while not process_list.empty():
		p = process_list.pop()
		
		for i in xrange(k):
			q = generate_random_around(p, r)
			if in_rectangle(q) and not in_neighbourhood(q):
					put_point(q)
	
	return sample_points


def main():
	#PoissonDisk.generate(10,15,1,10)

	points = sample_poisson_uniform(10,15,1,10)
	print points


if __name__ == "__main__":
	main()
