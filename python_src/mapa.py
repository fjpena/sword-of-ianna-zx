import pygame
import tmxlib
from tiled_map import *
from scripts import *
import constants
import os

class Map():
	""" Game map """
	def __init__ (self, filename):
		self.map=tmxlib.Map.open(filename)
		if constants.DEBUG:
			print "El tamano del mapa es " + str(self.map.size)
		self.tilemap=IannaMap(self.map.layers['Fondo'],self.map.width,self.map.height)
		self.objset=IannaObjectSet(self.map.layers['Objetos'],self.map.width,self.map.height)
		self.objects = [0] * 256 # create a simple 256 byte table for the object state
		self.tilefile=self.map.tilesets[0].image.source

		initialscreen = self.map.properties["InitialScreen"].split(',')
		self.current_x = int(initialscreen[0])
		self.current_y = int(initialscreen[1])

		self.strings = []
		stringid = 0
		while True:
			if constants.LANGUAGE == 0:
				newid = "string-"+str(stringid)
			else:
				newid = "string-"+str(stringid)+"-en"

			# Set script for player
			try:
				self.strings.append(self.map.properties[newid])
				stringid = stringid + 1
			except KeyError:
				return


	def load_tile_table(self, directory, width, height):
	    self.tile_table = []
	    image = pygame.image.load(directory+'/'+self.tilefile).convert()
	    image_width, image_height = image.get_size()    
	    for tile_y in range(0, image_height/height):
	    	for tile_x in range(0, image_width/width):    
	            rect = (tile_x*width, tile_y*height, width, height)
	            self.tile_table.append(image.subsurface(rect))

	def set_screen (self, x, y, entity_array, scorearea):
		self.thisscreen=IannaScreen(self.map.layers['Fondo'], self.objset, self.map.layers['Dureza'], self.map.width,self.map.height, x, y)
		# Declare 20*32 array for hardness
		self.hardnessmap=[]
		for y1 in range(0,20):
			line = [None] * 32
			self.hardnessmap.append(line)
		for y1 in range(0,10):
			for x1 in range(0,16):
				myvalue = self.thisscreen.dureza[y1][x1]
				if myvalue == 0 :   # empty hardness
					self.hardnessmap[2*y1][2*x1] = 0
					self.hardnessmap[2*y1][2*x1+1] = 0
					self.hardnessmap[2*y1+1][2*x1] = 0
					self.hardnessmap[2*y1+1][2*x1+1] = 0
				elif myvalue == 1:  # full hardness
					self.hardnessmap[2*y1][2*x1] = 1
					self.hardnessmap[2*y1][2*x1+1] = 1
					self.hardnessmap[2*y1+1][2*x1] = 1
					self.hardnessmap[2*y1+1][2*x1+1] = 1
				elif myvalue == 2:  # up is full, low is empty
					self.hardnessmap[2*y1][2*x1] = 1
					self.hardnessmap[2*y1][2*x1+1] = 1
					self.hardnessmap[2*y1+1][2*x1] = 0
					self.hardnessmap[2*y1+1][2*x1+1] = 0
				elif myvalue == 3:  # up is empty, low is full
					self.hardnessmap[2*y1][2*x1] = 0
					self.hardnessmap[2*y1][2*x1+1] = 0
					self.hardnessmap[2*y1+1][2*x1] = 1
					self.hardnessmap[2*y1+1][2*x1+1] = 1
				else:
					print "Invalid value ",myvalue," in hardness map for screen ",pant
					raise

		# Load enemies, objects and scripts for this level
		entity_array[1] = None
		entity_array[2] = None
		entity_array[3] = None
		entity_array[4] = None
		entity_array[5] = None
		entity_array[6] = None
		entity_array[7] = None

		current_enemy = 0
		for obj in self.thisscreen.objlist:
			if obj[1].find("ENEMY") != -1:	# This is an enemy
				self.load_enemy(obj, current_enemy, entity_array, scorearea)
				current_enemy = current_enemy + 1
		
		current_object = 0
		for obj in self.thisscreen.objlist:
			if obj[1].find("ENEMY") == -1:	# This is an object
				self.load_object(obj, current_object, entity_array, scorearea)
				current_object = current_object + 1

		# Set script for player
		try:
			scriptid = "script-"+str(x)+"_"+str(y)
			if constants.DEBUG_SCRIPT:
				print "trying to load ",scriptid
			entity_array[0].script = IannaScript(self.map.properties[scriptid])
		except KeyError:
			entity_array[0].script = IannaScript("ACTION_PLAYER")
		entity_array[0].script_pos = 0

	def load_enemy(self, obj, objnumber, game_entities, scorearea):
		'''
		Load an enemy
		'''
		if self.objects[int(obj[0])*2] == 0: # enemy is alive, so load
			entity = IannaCharacter(self.enemy_spritedir[obj[1]], self, game_entities, scorearea, None, player=False) 
			game_entities[1+objnumber] = entity			
			entity.objid= int(obj[0])
			entity.enemy_type=obj[1]
			#print obj[1]
			entity.posx = int(obj[2])*16
			entity.posy = (int(obj[3])+1)*16
			entity.script = IannaScript(obj[5])
			entity.script_pos=0
			entity.level = int(obj[4])
			#print entity.enemy_type,entity.level
			entity.energy = entity.enemy_energy[entity.enemy_type][entity.level]
			if constants.DEBUG:
				print "Enemy energy is: ",entity.energy
		
			if entity.enemy_type in ('OBJECT_ENEMY_GOLEM','OBJECT_ENEMY_OGRE','OBJECT_ENEMY_MINOTAUR','OBJECT_ENEMY_DEMON'):
				print "This is an enemy with a secondary part"
				entity2 = IannaCharacter(self.enemy_sprite2dir[obj[1]], self, game_entities, scorearea, None, player=False)
				game_entities[2+objnumber] = entity2
				entity2.objid= 0
				entity2.enemy_type='OBJECT_ENEMY_SECONDARY'
				entity2.posx = entity.posx
				entity2.posy = entity.posy - 32
				entity2.script = IannaScript('ACTION_NONE')
				entity2.script_pos=0
				entity2.level = 0
				entity2.energy = 0
				entity2.state = constants.STATE_SECONDARY_LEFT
#			print entity
		if constants.DEBUG:
			print game_entities

	def load_object(self, obj, objnumber, game_entities, scorearea):
		'''
		Load an object
		'''
		if objnumber >= 5:
			print "WARNING: there are more than 5 objects in this room !!!!"
			return

		entity = IannaObject(self,game_entities, scorearea) 
		game_entities[3+objnumber] = entity			
		entity.objid= int(obj[0])
		entity.object_type=obj[1]
		if constants.DEBUG:
			print obj[1]
		entity.posx = int(obj[2])*16
		entity.posy = (int(obj[3])+1)*16
		entity.script = IannaScript(obj[5])
		entity.script_pos=0

		if self.objects[int(obj[0])*2] == 0: # object is active, so load
		        entity.energy =	int(obj[4])
			if constants.DEBUG:
				print entity
		else:  # inactive object, load but set the inactive state
		        entity.energy =	0	# energy for inactive objects is always 0
			if constants.DEBUG:
				print entity
			entity.inactive_object_functions[entity.object_type](entity)


	def draw_screen (self, pant):
		for y1 in range(0,10):
			for x1 in range(0,16):
				pant.blit(self.tile_table[self.thisscreen.screenmap[y1][x1]], (x1*16,y1*16))

	def anim_stiles (self):
		animated = 0
		for y1 in range(0,10):
			for x1 in range(0,16):
				if self.thisscreen.screenmap[y1][x1] >= 240:
					value = self.thisscreen.screenmap[y1][x1] 
					highvalue = value & 252
					lowvalue = (value + 1 ) & 3
					self.thisscreen.screenmap[y1][x1] = highvalue | lowvalue
					animated = animated + 1
		if animated > 15:
			print "WARNING: this screen has more than 15 animated stiles!!"

	def HighYBelow(self,x,y):
		'''
		Get highest possible Y with something not vacuum below or ar the specified position
		Returns: highest Y
		'''
		y1 = y/16
		x1 = x/16
		while y1 < 10:
			value = self.GetHardness(x1,y1)
			if value == 0:
				y1 = y1 + 1
			elif value == 1:
				return y1*2
			elif value == 2:
				return y1*2
			elif value == 3:
				return y1*2+1
		return 25

	def GetHardness(self,x,y):
		'''
		Get the hardness position at (x,y)
		OUTPUT:
			- Hardness value (0,1,2 or 3)
		'''
		return self.thisscreen.dureza[y][x]


	def SetHardness(self,x,y,hardness):
		'''
		Set the hardness position at (x,y)
			- Hardness value (0,1,2 or 3)
		'''
		self.thisscreen.dureza[y][x] = hardness

	enemy_spritedir = {	
		'OBJECT_ENEMY_SKELETON':'esqueleto',
		'OBJECT_ENEMY_ORC':'orc',
		'OBJECT_ENEMY_MUMMY':'mummy',
		'OBJECT_ENEMY_TROLL':'troll',
		'OBJECT_ENEMY_ROCK':'rollingstone',
		'OBJECT_ENEMY_KNIGHT'  :'caballerorenegado',
		'OBJECT_ENEMY_GOLEM'   :'golem_inf',
		'OBJECT_ENEMY_OGRE'    :'ogro_inf',
		'OBJECT_ENEMY_MINOTAUR':'minotauro_inf',
		'OBJECT_ENEMY_DEMON'   :'demonio_inf',
		'OBJECT_ENEMY_DALGURAK':'dalgurak',
	}

	enemy_sprite2dir = {
		'OBJECT_ENEMY_GOLEM'   :'golem_sup',
		'OBJECT_ENEMY_OGRE'    :'ogro_sup',
		'OBJECT_ENEMY_MINOTAUR':'minotauro_sup',
		'OBJECT_ENEMY_DEMON'   :'demonio_sup',
	}
