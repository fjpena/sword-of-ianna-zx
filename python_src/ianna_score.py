import pygame
import time
import scripts

"""
Score class
 
Handles all the score area
 
package: ianna
"""

class IannaScore():
	def __init__ (self, buffer, screen, game_entities):
		self.score_image  = pygame.image.load('artwork/marcador.png').convert()
		self.font = pygame.image.load('artwork/font.png').convert()
		self.chars = []
		self.buffer = buffer
		self.screen = screen
		self.game_entities = game_entities
		self.weapons = []
		self.weapons.append(pygame.image.load('artwork/marcador_armas_sword.png').convert())
		self.weapons.append(pygame.image.load('artwork/marcador_armas_eclipse.png').convert())
		self.weapons.append(pygame.image.load('artwork/marcador_armas_axe.png').convert())
		self.weapons.append(pygame.image.load('artwork/marcador_armas_blade.png').convert())	
		self.first_object_in_inventory = 0
		# We have 64 chars, in ASCII order starting by BLANK (32)
		# There are some special chars, look at the font!

		for tile_x in range (0,32):
	            rect = (tile_x*8, 0, 8, 8)
	            self.chars.append(self.font.subsurface(rect))
		for tile_x in range (0,32):
	            rect = (tile_x*8, 8, 8, 8)
	            self.chars.append(self.font.subsurface(rect))
	

	def clean_text_area(self):
		for y in range(0,3):
			for x in range(0,30):
				self.buffer.blit(self.chars[0],(8+x*8,168+y*8))

	def print_string(self,string):
		fpsClock = pygame.time.Clock()   
		y=0
		x=0
		i=0
		while i < len(string):
			word = ""
			# Find the word
			while string[i] != ',' and string[i] != '.' and string[i] != ' ':
				word = word + string[i]
				i = i + 1

			# Add the punctuation character
			word = word + string[i]
			i = i + 1
	
			# Now print it 
			if x + len(word) > 30:
				y = y + 1
				x = 0
				if y == 3: # We need to wait until the player presses any key
					self.buffer.blit(self.chars[32],(240,184))
					pygame.transform.scale(self.buffer,(256*3,192*3),self.screen)
					pygame.display.flip()
					self.wait_for_keypress()
					y = 0
					self.clean_text_area()
							
			j = 0
			while j < len(word):
				char = ord(word[j]) - 32
				self.buffer.blit(self.chars[char],(8+x*8,168+y*8))
				x = x + 1
				j = j + 1
				pygame.transform.scale(self.buffer,(256*3,192*3),self.screen)
				pygame.display.flip()
				fpsClock.tick(25) # run at 10 fps

		self.buffer.blit(self.chars[32],(240,184))
		pygame.transform.scale(self.buffer,(256*3,192*3),self.screen)
		pygame.display.flip()
		self.wait_for_keypress()

	def print_char(self,char,x,y):
		char = ord(str(char)) - 32
		self.buffer.blit(self.chars[char],(x,y))


	def wait_for_keypress(self):
		'''
		Silly function, just wait for a keypress to happen
		In the Spectrum version, it should be way better
		'''
		keypressed = False
		keyreleased = False
		key = None
		while (not keypressed) and (not keyreleased):
			events = pygame.event.get()
			for event in events:
				if event.type == pygame.KEYDOWN: # keypressed, wait until it is released
					key = event.key
					keypressed = True
				if event.type == pygame.KEYUP: # keypressed, wait until it is released
					if key == event.key:
						keyreleased = True

	def print_meter(self,x,value, color):
		'''
		Display an entity health, on X
		'''
		y=191
		value = value*23/100

		rect = [x+2,y-value,5,value]
		pygame.draw.rect(self.buffer,color,rect)	
	

	def print_inventory(self,player):
		'''
		Display the inventory
		'''
		currentx = 24
		x = 0

		if player.current_object > self.first_object_in_inventory + 2:
			self.first_object_in_inventory = self.first_object_in_inventory + 1
		elif player.current_object < self.first_object_in_inventory:
			self.first_object_in_inventory = self.first_object_in_inventory - 1

		for item in player.inventory[self.first_object_in_inventory:]:
			if x == 3:
				break			
			self.buffer.blit(player.map.tile_table[self.tiles_per_pickable_object[item]], (currentx,168))
			currentx = currentx + 24
			x = x + 1

		# Use a marker for the current selected object
		self.buffer.blit(self.chars[63],(24+(player.current_object-self.first_object_in_inventory)*24,184))


	def draw(self):
		self.buffer.set_clip(pygame.Rect(0,160,256,192)) # set clipping area for game, should then set clipping for score area
		self.buffer.blit(self.score_image,(0,160))
		# Print barbarian energy
		self.print_meter(168,(self.game_entities[0].energy*100) / self.game_entities[0].get_entity_max_energy(),(255,0,0))
		# Print barbarian level
		self.print_meter(176,(self.game_entities[0].experience*100) / self.game_entities[0].get_player_max_exp(),(0,255,255))
		# Print current weapon
		self.buffer.blit(self.weapons[self.game_entities[0].weapon-1],(112,168))

		if self.game_entities[1] and self.game_entities[1].enemy_type != "OBJECT_ENEMY_ROCK":
			entity = self.game_entities[1]
			energy = (entity.energy*100) / entity.enemy_energy[entity.enemy_type][entity.level]
			self.print_meter(192,energy,(0,255,0))
			# Print energy in numbers
			if entity.energy > 99:
				print "WARNING: enemy energy is > 100"
			else:
				self.print_char(entity.energy/10,200,176)
				self.print_char(entity.energy%10,208,176)
			self.print_char(entity.level,208,184)
		if self.game_entities[2] and self.game_entities[2].enemy_type not in ('OBJECT_ENEMY_ROCK','OBJECT_ENEMY_SECONDARY'):
			entity = self.game_entities[2]
			energy = (entity.energy*100) / entity.enemy_energy[entity.enemy_type][entity.level]
			self.print_meter(216,energy,(0,255,0))
			if entity.energy > 99:
				print "WARNING: enemy energy is > 100"
			else:
				self.print_char(entity.energy/10,224,176)
				self.print_char(entity.energy%10,232,176)
			self.print_char(entity.level,232,184)
		
		self.print_inventory(self.game_entities[0])


	# Remember to copy this from scripts.py when new objects are created
	tiles_per_pickable_object =  { "OBJECT_KEY_GREEN": 217,
								   "OBJECT_KEY_BLUE": 218,
  								   "OBJECT_KEY_YELLOW": 219,
								   "OBJECT_BREAD": 220,
								   "OBJECT_MEAT": 221,
								   "OBJECT_HEALTH": 222,
								   "OBJECT_KEY_RED": 223,
								   "OBJECT_KEY_WHITE": 224,
								   "OBJECT_KEY_PURPLE": 225,
		}
