#!/usr/bin/python

import pygame
from pygame.locals import *

from city import App

def main():
	pygame.init()
	screen = pygame.display.set_mode((800, 600))
	
	app = App()
	app.init(800,600)

	#time is specified in milliseconds
	#fixed simulation step duration
	step_size = 16
	#max duration to render a frame
	max_frame_time = 100

	now = pygame.time.get_ticks()
	running = True
	while running:
		#handle events
		for event in pygame.event.get():
			if event.type == QUIT or event.type == KEYDOWN and (event.key in [K_ESCAPE, K_q]): 
				running = False

		#get the current real time
		T = pygame.time.get_ticks()

		#if elapsed time since last frame is too long...
		if T-now > max_frame_time:
			#slow the game down by resetting clock
			now = T - step_size
			#alternatively, do nothing and frames will auto-skip, which
			#may cause the engine to never render!

		#this code will run only when enough time has passed, and will
		#catch up to wall time if needed.
		while(T-now >= step_size):
			
			app.update(step_size)

			now += step_size
		else:
			pygame.time.wait(10)

		screen.fill((0,0,0))

		#render game state. use 1.0/(step_size/(T-now)) for interpolation
		app.render(screen)

		pygame.display.flip()

import sys
import random
if __name__ == "__main__":
	if len(sys.argv) > 1:
		random.seed(sys.argv[1])
	main()