#!/usr/bin/python

import pygame
from pygame.locals import *
from planar import Vec2
import pymunk

import random

import util

city = None

def to_int_pair(p):
	return (int(p[0]), int(p[1]))

class App(util.Singleton, util.BaseEntity):
	def init(self, width, height):
		self.font = pygame.font.SysFont("monospace", 15)

		global city
		city = City(width, height)
		city.grow()

	def render(self, screen):
		city.render(screen)

	def get_font(self):
		return self.font


class City(util.BaseEntity):
	def __init__(self, width, height):
		self.width = width
		self.height = height
		self.roads = []
		self.markers = []
		self.space = pymunk.Space()
		self.space.gravity = 0,0


	def grow(self):	
		size = 4
		if random.randint(0,1): # horizontal
			y_pos = util.PseudoRandom.randint(0, self.height, 3)
			road = Road(Vec2(0, y_pos), Vec2(self.width - 1, y_pos + size * 2), size)
		else: #vertical
			x_pos = util.PseudoRandom.randint(0, self.width, 3)
			road = Road(Vec2(x_pos, 0), Vec2(x_pos + size * 2, self.height - 1), size)

		self.add_road(road)
		road.grow()

	def render(self, screen):
		for road in self.roads:
			road.render(screen)
		for marker in self.markers:
			marker.render(screen)

	def add_entity(self, entity):
		self.entities.append(entity)

	def add_road(self, road):
		self.space.add(road.shape)
		self.roads.append(road)

	def get_space(self):
		return self.space

	def add_marker(self, pos, text = None):
		self.markers.append(Marker(pos, text))

class Road(util.BaseEntity):
	def __init__(self, start_pos, end_pos, size, parent = None):
		self.start_pos = start_pos
		self.end_pos = end_pos
		self.size = size
		self.child_roads = []
		self.parent = parent
		self.shape = pymunk.Segment(city.get_space().static_body, start_pos, end_pos, size)
		self.shape.cache_bb()

	def grow(self):
		if self.size == 1:
			return False

		for i in range(util.PseudoRandom.randint(1, self.size, 2)):
			offset = util.PseudoRandom.random(2)
			side = random.choice(['r', 'l'])

			self.child_roads.append(Road.make_road(self, offset, side, self.size - 1))

		for road in self.child_roads:
			road.grow()

	def render(self, screen):
		pygame.draw.rect(screen, (255,255,255), (self.start_pos.x, self.start_pos.y, self.end_pos.x - self.start_pos.x, self.end_pos.y - self.start_pos.y))


	def is_horizontal(self):
		return self.width() > self.height()

	def width(self):
		return abs(self.start_pos.x - self.end_pos.x)

	def height(self):
		return abs(self.start_pos.y - self.end_pos.y)

	@classmethod
	def make_road(cls, parent, offset, side, size):
		if parent.is_horizontal():
			x1 = (parent.end_pos.x - parent.start_pos.x) * offset + parent.start_pos.x
			x2 = x1 + size * 2
			if side == 'r':
				y1 = parent.end_pos.y
				y2 = 600
			else:
				y1 = 0
				y2 = parent.start_pos.y
		else:
			y1 = (parent.end_pos.y - parent.start_pos.y) * offset + parent.start_pos.y
			y2 = y1 + size * 2
			if side == 'r':
				x1 = parent.end_pos.x
				x2 = 800
			else:
				x1 = 0
				x2 = parent.start_pos.x
		road = Road(Vec2(x1, y1), Vec2(x2, y2), size, parent)

		shapes_overlaping = city.get_space().bb_query(road.shape.bb)
		for shape in shapes_overlaping:
			segment_query = shape.segment_query(road.shape.a, road.shape.b)
			if segment_query:
				city.add_marker(segment_query.get_hit_point(), str(segment_query.t))

		city.add_road(road)
		return road

class Marker(util.BaseEntity):
	color = (255, 0, 0)
	radius = 5
	label = None
	def __init__(self, pos, text = None, color = None, radius = None):
		self.pos = to_int_pair(pos)
		self.color = color or self.color
		self.radius = radius or self.radius
		if text:
			self.label = App().get_font().render(text[:4], 1, self.color)

	def render(self, screen):
		if self.label:
			screen.blit(self.label, self.pos)
		pygame.draw.circle(screen, self.color, self.pos, self.radius, 1)




