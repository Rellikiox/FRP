
import pygame
from planar import Vec2
import colorsys
import random

from poisson_disk.poisson_disk import sample_poisson_uniform

class App(object):
	def __init__(self):
		self.solar_system = SolarSystem(Vec2(300, 300))

		#sun = CelestialObject(Vec2(0, 0), 0, 30, (255, 217, 0))

		self.planet = CelestialObject(Vec2(70, 0), 50, 10, (168, 91, 24))

		#moon = CelestialObject(Vec2(10,20), 70, 5, (181,181,181))

		#planet.add_orbiter(moon)
		#sun.add_orbiter(planet)

		self.solar_system.add_object(self.planet)

	def update(self, step_size):
		self.solar_system.update(step_size)

	def render(self, screen):
		self.solar_system.draw(screen)



class SolarSystem(object):
	"""This class represents a solar system composed of different celestial objects"""
	def __init__(self, position):
		super(SolarSystem, self).__init__()
		self.position = position
		self.objects = []

	def add_object(self, obj):
		self.objects.append(obj)

	def update(self, step_size):
		for obj in self.objects:
			obj.update(step_size)

	def draw(self, surface):
		for obj in self.objects:
			obj.draw(surface, self.position)

	@classmethod
	def make_solar_system(cls, seed=None):
		random.seed(seed)
		

class CelestialObject(object):
	"""This class represents a celestial object, such as a sun, a planet or an asteroid"""
	def __init__(self, position, velocity, radius, color):
		super(CelestialObject, self).__init__()
		self.position = position
		self.velocity = velocity
		self.radius = radius
		self.color = color
		self.orbiters = []

	def add_orbiter(self, orbiter):
		self.orbiters.append(orbiter)

	def update(self, step_size):
		rotated_angle = (step_size / 1000.0) * self.velocity
		self.position = self.position.rotated(rotated_angle)
		for obj in self.orbiters:
			obj.update(step_size)

	def draw(self, surface, origin):
		if not self.position.is_null:
			# Draw the objects orbit
			orbit_color = tone_down_color(self.color, 0.5)
			pygame.draw.circle(surface, orbit_color, (int(origin[0]), int(origin[1])), int(self.position.length), 1)

		# Draw object
		global_position = translate_position(self.position, origin)
		pygame.draw.circle(surface, self.color, global_position, self.radius)

		for obj in self.orbiters:
			obj.draw(surface, Vec2(global_position[0],global_position[1]))


""" Returns a translated position from the given origin""" 
def translate_position(local_position, origin):
	global_position = origin + local_position
	return (int(global_position[0]), int(global_position[1]))

def tone_down_color(color, percentage):
	r,g,b = map(lambda x: x / 255.0, color)
	h,s,v = colorsys.rgb_to_hsv(r,g,b)
	s *= percentage
	rgb = colorsys.hsv_to_rgb(h, s, v)
	return map(lambda x: int(x * 255), rgb)
