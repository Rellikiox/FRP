#!/usr/bin/python

import pygame
from pygame.locals import *
import random

from planar import Vec2
import util

class App(util.BaseEntity):
	def __init__(self, width, height):
		self.city = City(width, height)
		self.city.grow()


	def render(self, screen):
		self.city.render(screen)

class City(util.BaseEntity):
	def __init__(self, width, height):
		self.width = width
		self.height = height

	def grow(self):	
		size = 4
		if random.randint(0,1): # horizontal
			y_pos = util.PseudoRandom.randint(0, self.height, 3)
			self.road = Road(Vec2(0, y_pos), Vec2(self.width - 1, y_pos + size), size)
		else: #vertical
			x_pos = util.PseudoRandom.randint(0, self.width, 3)
			self.road = Road(Vec2(x_pos, 0), Vec2(x_pos + size, self.height - 1), size)

		self.road.grow()

	def render(self, screen):
		self.road.render(screen)

class Road(util.BaseEntity):
	def __init__(self, start_pos, end_pos, size):
		self.start_pos = start_pos
		self.end_pos = end_pos
		self.size = size
		self.child_roads = []

	def grow(self):
		if self.size == 1:
			return False

		for i in range(self.size):
			offset = util.PseudoRandom.random(2)
			side = random.choice(['r', 'l'])

			self.child_roads.append(Road.make_road(self, offset, side, self.size - 1))

		for road in self.child_roads:
			road.grow()

	def render(self, screen):
		pygame.draw.rect(screen, (255,255,255), (self.start_pos.x, self.start_pos.y, self.end_pos.x - self.start_pos.x, self.end_pos.y - self.start_pos.y))
		for road in self.child_roads:
			road.render(screen)

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
			x2 = x1 + size
			if side == 'r':
				y1 = parent.end_pos.y
				y2 = 599
			else:
				y1 = 0
				y2 = parent.start_pos.y
		else:
			y1 = (parent.end_pos.y - parent.start_pos.y) * offset + parent.start_pos.y
			y2 = y1 + size
			if side == 'r':
				x1 = parent.end_pos.x
				x2 = 799
			else:
				x1 = 0
				x2 = parent.start_pos.x

		return Road(Vec2(x1, y1), Vec2(x2, y2), size)



