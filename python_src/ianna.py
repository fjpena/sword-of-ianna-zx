#!/usr/bin/env python

import pygame
import pygame.locals
import tmxlib
import sys
import constants
import os
from tiled_map import *
from sev_sprite import *
from ianna_entity import *
from mapa import *
from timer import *
from ianna_score import *
import gc

class IannaGame():
	def __init__ (self):
		self.keyboard=[0,0,0,0,0,0]	# 0 is not pressed, 1 is pressed
   		pygame.init()
		self.screen = pygame.display.set_mode((256*3, 192*3))
		pygame.display.set_caption('Ianna - Press F12 to set fullscreen')
		self.screen.fill((0, 0, 0))
		self.buffer = pygame.Surface((256,192))
		self.fpsClock = pygame.time.Clock()
		self.pause_image = pygame.image.load('artwork/pausa.png').convert()

	def toggle_fullscreen(self):
		tmp = self.screen.convert()
		caption = pygame.display.get_caption()
		cursor = pygame.mouse.get_cursor()  
		w,h = self.screen.get_width(),self.screen.get_height()
		flags = self.screen.get_flags()
		bits = self.screen.get_bitsize()

		pygame.display.quit()
		pygame.display.init()    
		print "Setting display with "+str(w)+"x"+str(h)+" with "+str(bits)+" bits and "+str(flags)+" as flags"
		if flags:
			self.screen = pygame.display.set_mode((w,h),0,bits)
		else:
			self.screen = pygame.display.set_mode((w,h),pygame.FULLSCREEN,bits)
		self.screen.blit(tmp,(0,0))
		pygame.display.set_caption(*caption)
		pygame.key.set_mods(0) 
		pygame.mouse.set_cursor( *cursor )

	def pause_menu(self):
		self.buffer.set_clip(pygame.Rect(0,0,256,160)) # set clipping area for game, should then set clipping for score area
		self.buffer.blit(self.pause_image,(60,60))
		pygame.transform.scale(self.buffer,(256*3,192*3),self.screen)
		pygame.display.flip()
		done = False
		while not done:
			events = pygame.event.get()
			for event in events:
				if event.type == pygame.locals.QUIT:
					sys.exit(0)
		    		elif event.type == pygame.KEYDOWN:
					if event.key == pygame.K_o:
						current = self.game_entities[0].current_object
						if current > 0:
							current = current - 1
							self.game_entities[0].current_object = current
						self.scorearea.draw()
						pygame.transform.scale(self.buffer,(256*3,192*3),self.screen)
						pygame.display.flip()
					elif event.key == pygame.K_p:
						current = self.game_entities[0].current_object
						if current < len(self.game_entities[0].inventory)-1:
							current = current + 1
							self.game_entities[0].current_object = current
						self.scorearea.draw()
						pygame.transform.scale(self.buffer,(256*3,192*3),self.screen)
						pygame.display.flip()
					elif event.key == pygame.K_a:
						current = self.game_entities[0].weapon						
						while True:
							current = current - 1
							if current == 0:
								current = 4
							if self.player_weapons[current-1]:
								# switch weapon in game
								self.game_entities[0].weapon = current
								break
						self.game_entities[0].load_weapon()
						self.scorearea.draw()
						pygame.transform.scale(self.buffer,(256*3,192*3),self.screen)
						pygame.display.flip()
					elif event.key == pygame.K_SPACE:
						# Consume object, if it is "consumable"
						player = self.game_entities[0]
						if player.current_object < len(player.inventory):
							if player.inventory[player.current_object] == "OBJECT_HEALTH":
								player.energy = player.get_entity_max_energy()
								player.inventory.remove("OBJECT_HEALTH")
								self.scorearea.draw()
								pygame.transform.scale(self.buffer,(256*3,192*3),self.screen)
								pygame.display.flip()
					elif event.key == pygame.K_h:
						done = True					
						self.waitforkeyrelease(pygame.K_h)
					elif event.key == pygame.K_x:
						self.export_menu()
					elif event.key == pygame.K_d:
						self.waitforkeyrelease(pygame.K_d)
						self.dump_menu()
						done = True
					elif event.key == pygame.K_s:
						self.export_sprites()


	def dump_menu(self):
		# Show object state in current level
		print("Object state: ")
		for i in range(0,128):
			print("Obj %d: %d %d" % (i, self.mymap.objects[i*2], self.mymap.objects[i*2+1]))
		# Dump entities in current screen
		for entity in self.game_entities:
			if entity:
				entity.dump_entity()

	def export_sprites(self):
		if not os.path.exists('export_sprites'):
			os.mkdir('export_sprites')
		self.export_single_sprite(self.entity_player, 'export_sprites/sprite_barbaro.asm', player=True)
		self.export_player_weapon(self.entity_player, 'export_sprites/barbaro_sword.asm', constants.WEAPON_SWORD)
		self.export_player_weapon(self.entity_player, 'export_sprites/barbaro_eclipse.asm', constants.WEAPON_ECLIPSE)
		self.export_player_weapon(self.entity_player, 'export_sprites/barbaro_axe.asm', constants.WEAPON_AXE)
		self.export_player_weapon(self.entity_player, 'export_sprites/barbaro_blade.asm', constants.WEAPON_BLADE)

		for enemy_type in ['OBJECT_ENEMY_SKELETON',  'OBJECT_ENEMY_ORC', 'OBJECT_ENEMY_MUMMY', 'OBJECT_ENEMY_TROLL',
				   			'OBJECT_ENEMY_ROCK', 'OBJECT_ENEMY_KNIGHT', 'OBJECT_ENEMY_GOLEM', 'OBJECT_ENEMY_OGRE',
							'OBJECT_ENEMY_MINOTAUR', 'OBJECT_ENEMY_DEMON', 'OBJECT_ENEMY_DALGURAK']:
			entity = IannaCharacter(Map.enemy_spritedir[enemy_type], None, None, None, None, player=False) 
			self.export_single_sprite(entity, "export_sprites/sprite_"+Map.enemy_spritedir[enemy_type]+".asm")

		for enemy_type in ('OBJECT_ENEMY_GOLEM','OBJECT_ENEMY_OGRE','OBJECT_ENEMY_MINOTAUR','OBJECT_ENEMY_DEMON'):
			entity2 = IannaCharacter(Map.enemy_sprite2dir[enemy_type], None, None, None, None, player=False)
			self.export_single_sprite(entity2, "export_sprites/sprite_"+Map.enemy_sprite2dir[enemy_type]+".asm")


	def export_single_sprite(self, entity, filename, player=False):
		entity.sp_idle.export(filename)
		entity.sp_turn.export(filename)
		entity.sp_walk.export(filename)
		entity.sp_fall.export(filename)
		entity.sp_crouch.export(filename)
		entity.sp_unsheathe.export(filename)
		entity.sp_idle_sword.export(filename)
		entity.sp_walk_sword.export(filename)
		entity.sp_high_sword.export(filename)
		entity.sp_forw_sword.export(filename)
		entity.sp_combo1_sword.export(filename)
		entity.sp_low_sword.export(filename)
		entity.sp_back_sword.export(filename)
		entity.sp_ouch_sword.export(filename)
		entity.sp_die.export(filename)
		if player is True:
			entity.sp_ouch.export(filename)
			entity.sp_jump_up.export(filename)
			entity.sp_shortjump.export(filename)
			entity.sp_longjump.export(filename)
			entity.sp_run.export(filename)
			entity.sp_brake.export(filename)
			entity.sp_braketurn.export(filename)
			entity.sp_switch.export(filename)
			entity.sp_grab.export(filename)

	def export_player_weapon(self, entity, filename, weapon):
		entity.weapon = weapon
		entity.load_weapon()
		entity.sp_idle_sword.export(filename)
		entity.sp_walk_sword.export(filename)
		entity.sp_high_sword.export(filename)
		entity.sp_forw_sword.export(filename)
		entity.sp_combo1_sword.export(filename)
		entity.sp_low_sword.export(filename)
		entity.sp_back_sword.export(filename)
		entity.sp_ouch_sword.export(filename)


	def export_menu(self):
		# get the tileset from the same directory, from a file called "levelname.asm" instead of tmx
		# FIXME a bit hardcoded for now, but well...
		tilefile = self.mapfile.replace(".tmx",".asm")
		tileset=IannaTileset(tilefile,self.mymap.map.tilesets[0].image.height / 8,self.mymap.map.tilesets[0].image.width / 8 )
		try:
			os.mkdir("export")
		except OSError as e:
			print "Export directory already exists"

		levelscripts=["ACTION_NONE","ACTION_PLAYER","ACTION_SECONDARY"]
		levelstrings=[]
		levelstrings_en=[]

		# Scripts for pickable objects: should always be in the same place!!!
		for kk, script in IannaScript.scripts_per_pickable_object.iteritems():
			if script not in levelscripts:
				levelscripts.append(script)			

		# Scripts for enemy attacks: should always be in the same place!!!
		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_SKELETON"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_ORC"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_MUMMY"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_TROLL"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_ROCK"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_KNIGHT"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_GOLEM"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_OGRE"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_MINOTAUR"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_DEMON"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_DALGURAK"]:
			if script not in levelscripts:
				levelscripts.append(script)

		# Scripts for player in specific screens
		for y in range(0,self.mymap.map.height/10):
			for x in range(0,self.mymap.map.width/16):
				try:
					scriptid = "script-"+str(x)+"_"+str(y)
					script = self.mymap.map.properties[scriptid]
					if script not in levelscripts:
						levelscripts.append(script)
				except KeyError:
					pass

		# Create the list of all scripts in the level
		for y in range(0,self.mymap.map.height/10):
			for x in range(0,self.mymap.map.width/16):
				screen=IannaScreen(self.mymap.map.layers['Fondo'], self.mymap.objset, self.mymap.map.layers['Dureza'], self.mymap.map.width,self.mymap.map.height, x, y, properties=self.mymap.map.properties)
				screenscripts = screen.get_scripts_from_screen()
				for script in screenscripts:
					if script not in levelscripts:
						levelscripts.append(script)
	
		print "We have",len(levelscripts),"different scripts in the level"

		# Create the list of all strings in the level
		counter = 0
		while True:
			stringid = "string-"+str(counter)
			try:
				string = self.mymap.map.properties[stringid]
				levelstrings.append(string)
				# Append the English string as well
				string = self.mymap.map.properties[stringid+"-en"]
				levelstrings_en.append(string)
				counter = counter + 1
			except KeyError:
				break

		print "We have",len(levelstrings),"different strings in the level"


		initialcoords = self.mymap.map.properties["InitialCoords"].split(',')
		mapposx=int(initialcoords[0])
		mapposy=int(initialcoords[1])
		initialscreen = self.mymap.map.properties["InitialScreen"].split(',')
		mapscreenx = int(initialscreen[0])
		mapscreeny = int(initialscreen[1])

		mainfile = file("export/map.asm","w")
		self.mymap.tilemap.print_mapinfo(mainfile,len(levelscripts),len(levelstrings),mapposx,mapposy,mapscreenx,mapscreeny)

		tilefile = file("export/map_tiles.asm","w")
		tileset.print_tiles(tilefile)
		tilefile.close()
		tilefile = file("export/map_stiles.asm","w")
		tileset.print_stiles(tilefile)
		tilefile.close()	
		tilefile = file("export/map_stilecolors.asm","w")
		tileset.print_tilecolors(tilefile)
		tilefile.close()	


		# Write strings and scripts to file
		f = file("export/map_strings.asm","w")
		f.write("org $7800\n")
		f.write("map_strings: dw string_list\nmap_scripts: dw current_script_pointer\n\n")
		f.write(";LEVEL STRING POINTERS\n\n")
		f.write("string_list: dw ")
		counter = 0
		linecounter = 0
		for string in levelstrings:
			if counter == len(levelstrings) - 1:
				f.write("string"+str(counter))
			elif linecounter < 10:
				f.write("string"+str(counter)+", ")
				linecounter = linecounter + 1
			else:
				f.write("string"+str(counter)+"\n\t\tdw ")
				linecounter = 0
			counter = counter + 1
		f.write("\n\n; STRINGS\n\n")
		counter = 0
		for string in levelstrings:
			f.write("string"+str(counter)+":\t db \'"+string+"\',0\n")
			counter = counter + 1

		f.write("\n\n; Pickable object types\n")
		f.write("OBJECT_KEY_GREEN	EQU 11\n")
		f.write("OBJECT_KEY_BLUE    EQU 12\n")
		f.write("OBJECT_KEY_YELLOW	EQU 13\n")
		f.write("OBJECT_BREAD		EQU 14\n")
		f.write("OBJECT_MEAT	    EQU 15\n")
		f.write("OBJECT_HEALTH		EQU 16\n")
		f.write("OBJECT_KEY_RED		EQU 17\n")
		f.write("OBJECT_KEY_WHITE   EQU 18\n")
		f.write("OBJECT_KEY_PURPLE	EQU 19\n")

		f.write("; Flag descriptions, will be used as parameters to functions\n")
		f.write("FLAG_PATROL_NONE:	EQU 0\n")
		f.write("FLAG_PATROL_NOFALL:	EQU 1	; do not jump blindly on platforms\n")
		f.write("FLAG_FIGHT_NONE:		EQU 0\n")
		f.write("FLAG_FIGHT_NOFALL:	EQU 1	; do not jump blindly when fighting\n")

		f.write("; script action definitions\n")
		f.write("ACTION_NONE:		EQU 0	; do nothing, no parameters\n")
		f.write("ACTION_JOYSTICK:	EQU 1	; control position/animation with joystick, no parameters\n")
		f.write("ACTION_PLAYER:		EQU 2	; player control\n")
		f.write("ACTION_PATROL:		EQU 3	; move left-right in the area, waiting until the player is in its view area\n")
		f.write("ACTION_FIGHT:		EQU 4	; Fight\n")
		f.write("ACTION_SECONDARY:	EQU 5	; script for secondary entities\n")
		f.write("ACTION_STRING:		EQU 6	; print a string in the notification area, useful for cutscenes. One parameter (db): string id\n")
		f.write("ACTION_WAIT:		EQU 7	; do nothing for a number of game frames. One parameter (db): number of frames\n")
		f.write("ACTION_MOVE:		EQU 8	; move for a number of game frames. Two parameter (db): direction, number of frames\n")
		f.write("ACTION_WAIT_SWITCH_ON:	EQU 9	; wait for a switch to be changed from 0 to 1 or 2. One parameter (db): object id\n")
		f.write("ACTION_WAIT_DEAD:	EQU 9	; wair for an enemy to be dead (its parameter is 1). One parameter (db): object id\n")
		f.write("ACTION_WAIT_DESTROYED:	EQU 9	; wair for an object to be destroyed (its parameter is 1). One parameter (db): object id\n")
		f.write("ACTION_WAIT_SWITCH_OFF:	EQU 10	; wait for a switch to be changed from 1/2 to 0. One parameter (db): object id\n")
		f.write("ACTION_TOGGLE_SWITCH_ON:	EQU 11	; toggle a switch. It will change the switch from 1 to 2, and also update the tiles. One parameter (db): object id\n")
		f.write("ACTION_TOGGLE_SWITCH_OFF: EQU 12	; toggle a switch. It will change the switch from 2 to 0, and also update the tiles. One parameter (db): object id\n")
		f.write("ACTION_OPEN_DOOR:	 EQU 13	; open a door. It will change the object value from 0 to 1, then to 2 when done, and update the tiles. One parameter (db): object id\n")
		f.write("ACTION_CLOSE_DOOR:	 EQU 14	; close a door. It will change the object value from 2 to 1, then to 0 when done, and update the tiles. One parameter (db): object id \n")
		f.write("ACTION_REMOVE_BOXES:	 EQU 15	; remove a group of boxes. One parameter (db): object id\n")
		f.write("ACTION_RETURN_SUBSCRIPT: EQU 16  ; return from a subscript\n")
		f.write("ACTION_RESTART_SCRIPT:	EQU 17 	; restart the script\n")
		f.write("ACTION_TELEPORT:	EQU 18	; teleport. 4 params (db): x,y of screen to go, x,y position in screen (in pixels)\n")
		f.write("ACTION_KILL_PLAYER:	EQU 19	; immediately kill the player\n")
		f.write("ACTION_ENERGY:		EQU 20	; add/reduce energy on entity touching it. 1 param (db): amount of energy to add/reduce\n")
		f.write("ACTION_SET_TIMER:	EQU 21	; set global timer, which will be decremented on every frame. 1 param(db): value to set\n")
		f.write("ACTION_WAIT_TIMER_SET:	EQU 22	; wait until global timer is != 0\n")
		f.write("ACTION_WAIT_TIMER_GONE:	EQU 23	; wait until global timer is == 0\n")
		f.write("ACTION_WAIT_CONTACT:	EQU 24	; wait until the player touches the entity\n")
		f.write("ACTION_MOVE_STILE:	EQU 25	; move stile. 5 params(db): x,y for stile, deltax, deltay per frame, number of frames.\n")
		f.write("ACTION_CHANGE_OBJECT:	EQU 26  ; switch to other object. 1 param(db): id of new object\n")
		f.write("ACTION_WAIT_PICKUP:	EQU 27	; used for objects, wait until picked up\n")
		f.write("ACTION_IDLE:		EQU 28	; set the state to idle\n")
		f.write("ACTION_ADD_INVENTORY:	EQU 29	; add object to inventory. 1 param(db): id of object to add to inventory\n")
		f.write("ACTION_REMOVE_JAR:	EQU 30	; remove a jar. One parameter (db): object id\n")
		f.write("ACTION_REMOVE_DOOR:	EQU 31	; remove a door. One parameter (db): object id\n")	
		f.write("ACTION_ADD_ENERGY:  EQU 32  ; add energy. One parameter (db): amount of energy to add\n")
		f.write("ACTION_CHECK_OBJECT_IN_INVENTORY: EQU 33  ; wait until an object is in the inventory. One parameter (db): object id\n")
		f.write("ACTION_REMOVE_OBJECT_FROM_INVENTORY: EQU 34  ; remove object from inventory. One parameter (db): object id\n")
		f.write("ACTION_CHECKPOINT: EQU 35	; set checkpoint. No parameters\n")
		f.write("ACTION_FINISH_LEVEL: EQU 36 ; end level. One parameter (db): 0 -> get back to main menu. 1 -> Go to next level.\n")
		f.write("ACTION_ADD_WEAPON: EQU 37   ; add weapon to inventory. One parameter (db): 1-> eclipse, 2-> axe, 3-> blade\n")
		f.write("ACTION_WAIT_CROSS_DOOR: EQU 38   ; wait until player is crossing our door\n")
		f.write("ACTION_CHANGE_STILE: EQU 39  ; change stile. 3 parameters (db): x, y in stile coords, and stile number (0-255)\n")
		f.write("ACTION_CHANGE_HARDNESS: EQU 40   ; change hardness for stile. 3 parameters (db): x, y in stile coords, hardness value (0-3)\n")
		f.write("ACTION_SET_OBJECT_STATE: EQU 41  ; set object state. 2 parameters (db): object id, state value (0: normal, 1: transitioning, 2: dead/changed, 3-255: other)\n")
		f.write("ACTION_WAIT_OBJECT_STATE: EQU 42  ; wait until the object state has a specific value. 2 parameters (db): object id, state value\n")
		f.write("ACTION_NOP: EQU 43  ; no-op action\n")
		f.write("ACTION_WAIT_CONTACT_EXT: EQU 44  ; wait for contact with area. 4 parameters (db): upper-left X in chars, upper-left Y in chars, width, height in chars\n")
		f.write("ACTION_TELEPORT_EXT:	EQU 45	; teleport without waiting for contact. 4 params (db): x,y of screen to go, x,y position in screen (in pixels)\n")
		f.write("ACTION_TELEPORT_ENEMY: EQU 46  ; teleport enemy to a different location in this screen. 2 params (db): x, y (in pixels)\n")
		f.write("ACTION_MOVE_OBJECT: EQU 47     ; move object in screen. 4 params (db): objid, deltax, deltay per frame, number of frames\n")
		f.write("ACTION_WAIT_PICKUP_INVENTORY:	EQU 48	; used for objects, wait until picked up and make sure there is space in the inventory\n")
		f.write("ACTION_FX:	EQU 49	; play an FX. 1 param (db): effect\n")

		f.write("current_script_pointer: dw ")
		counter = 0
		linecounter = 0
		for script in levelscripts:
			if counter == len(levelscripts) - 1:
				f.write("script"+str(counter))
			elif linecounter < 10:
				f.write("script"+str(counter)+", ")
				linecounter = linecounter + 1
			else:
				f.write("script"+str(counter)+"\n\t\tdw ")
				linecounter = 0
			counter = counter + 1
		f.write("\n\n; SCRIPTS\n\n")
		counter = 0
		for script in levelscripts:
			f.write("script"+str(counter)+":\t db "+script+"\n")
			counter = counter + 1
		f.close()

		# Write strings in English and scripts to file
		f = file("export/map_strings_en.asm","w")
		f.write("org $7800\n")
		f.write("map_strings: dw string_list\nmap_scripts: dw current_script_pointer\n\n")
		f.write(";LEVEL STRING POINTERS\n\n")
		f.write("string_list: dw ")
		counter = 0
		linecounter = 0
		for string in levelstrings_en:
			if counter == len(levelstrings_en) - 1:
				f.write("string"+str(counter))
			elif linecounter < 10:
				f.write("string"+str(counter)+", ")
				linecounter = linecounter + 1
			else:
				f.write("string"+str(counter)+"\n\t\tdw ")
				linecounter = 0
			counter = counter + 1
		f.write("\n\n; STRINGS\n\n")
		counter = 0
		for string in levelstrings_en:
			f.write("string"+str(counter)+":\t db \""+string+"\",0\n")
			counter = counter + 1

		f.write("\n\n; Pickable object types\n")
		f.write("OBJECT_KEY_GREEN	EQU 11\n")
		f.write("OBJECT_KEY_BLUE    EQU 12\n")
		f.write("OBJECT_KEY_YELLOW	EQU 13\n")
		f.write("OBJECT_BREAD		EQU 14\n")
		f.write("OBJECT_MEAT	    EQU 15\n")
		f.write("OBJECT_HEALTH		EQU 16\n")
		f.write("OBJECT_KEY_RED		EQU 17\n")
		f.write("OBJECT_KEY_WHITE   EQU 18\n")
		f.write("OBJECT_KEY_PURPLE	EQU 19\n")

		f.write("; Flag descriptions, will be used as parameters to functions\n")
		f.write("FLAG_PATROL_NONE:	EQU 0\n")
		f.write("FLAG_PATROL_NOFALL:	EQU 1	; do not jump blindly on platforms\n")
		f.write("FLAG_FIGHT_NONE:		EQU 0\n")
		f.write("FLAG_FIGHT_NOFALL:	EQU 1	; do not jump blindly when fighting\n")

		f.write("; script action definitions\n")
		f.write("ACTION_NONE:		EQU 0	; do nothing, no parameters\n")
		f.write("ACTION_JOYSTICK:	EQU 1	; control position/animation with joystick, no parameters\n")
		f.write("ACTION_PLAYER:		EQU 2	; player control\n")
		f.write("ACTION_PATROL:		EQU 3	; move left-right in the area, waiting until the player is in its view area\n")
		f.write("ACTION_FIGHT:		EQU 4	; Fight\n")
		f.write("ACTION_SECONDARY:	EQU 5	; script for secondary entities\n")
		f.write("ACTION_STRING:		EQU 6	; print a string in the notification area, useful for cutscenes. One parameter (db): string id\n")
		f.write("ACTION_WAIT:		EQU 7	; do nothing for a number of game frames. One parameter (db): number of frames\n")
		f.write("ACTION_MOVE:		EQU 8	; move for a number of game frames. Two parameter (db): direction, number of frames\n")
		f.write("ACTION_WAIT_SWITCH_ON:	EQU 9	; wait for a switch to be changed from 0 to 1 or 2. One parameter (db): object id\n")
		f.write("ACTION_WAIT_DEAD:	EQU 9	; wair for an enemy to be dead (its parameter is 1). One parameter (db): object id\n")
		f.write("ACTION_WAIT_DESTROYED:	EQU 9	; wair for an object to be destroyed (its parameter is 1). One parameter (db): object id\n")
		f.write("ACTION_WAIT_SWITCH_OFF:	EQU 10	; wait for a switch to be changed from 1/2 to 0. One parameter (db): object id\n")
		f.write("ACTION_TOGGLE_SWITCH_ON:	EQU 11	; toggle a switch. It will change the switch from 1 to 2, and also update the tiles. One parameter (db): object id\n")
		f.write("ACTION_TOGGLE_SWITCH_OFF: EQU 12	; toggle a switch. It will change the switch from 2 to 0, and also update the tiles. One parameter (db): object id\n")
		f.write("ACTION_OPEN_DOOR:	 EQU 13	; open a door. It will change the object value from 0 to 1, then to 2 when done, and update the tiles. One parameter (db): object id\n")
		f.write("ACTION_CLOSE_DOOR:	 EQU 14	; close a door. It will change the object value from 2 to 1, then to 0 when done, and update the tiles. One parameter (db): object id \n")
		f.write("ACTION_REMOVE_BOXES:	 EQU 15	; remove a group of boxes. One parameter (db): object id\n")
		f.write("ACTION_RETURN_SUBSCRIPT: EQU 16  ; return from a subscript\n")
		f.write("ACTION_RESTART_SCRIPT:	EQU 17 	; restart the script\n")
		f.write("ACTION_TELEPORT:	EQU 18	; teleport. 4 params (db): x,y of screen to go, x,y position in screen (in pixels)\n")
		f.write("ACTION_KILL_PLAYER:	EQU 19	; immediately kill the player\n")
		f.write("ACTION_ENERGY:		EQU 20	; add/reduce energy on entity touching it. 1 param (db): amount of energy to add/reduce\n")
		f.write("ACTION_SET_TIMER:	EQU 21	; set global timer, which will be decremented on every frame. 1 param(db): value to set\n")
		f.write("ACTION_WAIT_TIMER_SET:	EQU 22	; wait until global timer is != 0\n")
		f.write("ACTION_WAIT_TIMER_GONE:	EQU 23	; wait until global timer is == 0\n")
		f.write("ACTION_WAIT_CONTACT:	EQU 24	; wait until the player touches the entity\n")
		f.write("ACTION_MOVE_STILE:	EQU 25	; move stile. 5 params(db): x,y for stile, deltax, deltay per frame, number of frames.\n")
		f.write("ACTION_CHANGE_OBJECT:	EQU 26  ; switch to other object. 1 param(db): id of new object\n")
		f.write("ACTION_WAIT_PICKUP:	EQU 27	; used for objects, wait until picked up\n")
		f.write("ACTION_IDLE:		EQU 28	; set the state to idle\n")
		f.write("ACTION_ADD_INVENTORY:	EQU 29	; add object to inventory. 1 param(db): id of object to add to inventory\n")
		f.write("ACTION_REMOVE_JAR:	EQU 30	; remove a jar. One parameter (db): object id\n")
		f.write("ACTION_REMOVE_DOOR:	EQU 31	; remove a door. One parameter (db): object id\n")	
		f.write("ACTION_ADD_ENERGY:  EQU 32  ; add energy. One parameter (db): amount of energy to add\n")
		f.write("ACTION_CHECK_OBJECT_IN_INVENTORY: EQU 33  ; wait until an object is in the inventory. One parameter (db): object id\n")
		f.write("ACTION_REMOVE_OBJECT_FROM_INVENTORY: EQU 34  ; remove object from inventory. One parameter (db): object id\n")
		f.write("ACTION_CHECKPOINT: EQU 35	; set checkpoint. No parameters\n")
		f.write("ACTION_FINISH_LEVEL: EQU 36 ; end level. One parameter (db): 0 -> get back to main menu. 1 -> Go to next level.\n")
		f.write("ACTION_ADD_WEAPON: EQU 37   ; add weapon to inventory. One parameter (db): 1-> eclipse, 2-> axe, 3-> blade\n")
		f.write("ACTION_WAIT_CROSS_DOOR: EQU 38   ; wait until player is crossing our door\n")
		f.write("ACTION_CHANGE_STILE: EQU 39  ; change stile. 3 parameters (db): x, y in stile coords, and stile number (0-255)\n")
		f.write("ACTION_CHANGE_HARDNESS: EQU 40   ; change hardness for stile. 3 parameters (db): x, y in stile coords, hardness value (0-3)\n")
		f.write("ACTION_SET_OBJECT_STATE: EQU 41  ; set object state. 2 parameters (db): object id, state value (0: normal, 1: transitioning, 2: dead/changed, 3-255: other)\n")
		f.write("ACTION_WAIT_OBJECT_STATE: EQU 42  ; wait until the object state has a specific value. 2 parameters (db): object id, state value\n")
		f.write("ACTION_NOP: EQU 43  ; no-op action\n")
		f.write("ACTION_WAIT_CONTACT_EXT: EQU 44  ; wait for contact with area. 4 parameters (db): upper-left X in chars, upper-left Y in chars, width, height in chars\n")
		f.write("ACTION_TELEPORT_EXT:	EQU 45	; teleport without waiting for contact. 4 params (db): x,y of screen to go, x,y position in screen (in pixels)\n")
		f.write("ACTION_TELEPORT_ENEMY: EQU 46  ; teleport enemy to a different location in this screen. 2 params (db): x, y (in pixels)\n")
		f.write("ACTION_MOVE_OBJECT: EQU 47     ; move object in screen. 4 params (db): objid, deltax, deltay per frame, number of frames\n")
		f.write("ACTION_WAIT_PICKUP_INVENTORY:	EQU 48	; used for objects, wait until picked up and make sure there is space in the inventory\n")
		f.write("ACTION_FX:	EQU 49	; play an FX. 1 param (db): effect\n")

		f.write("current_script_pointer: dw ")
		counter = 0
		linecounter = 0
		for script in levelscripts:
			if counter == len(levelscripts) - 1:
				f.write("script"+str(counter))
			elif linecounter < 10:
				f.write("script"+str(counter)+", ")
				linecounter = linecounter + 1
			else:
				f.write("script"+str(counter)+"\n\t\tdw ")
				linecounter = 0
			counter = counter + 1
		f.write("\n\n; SCRIPTS\n\n")
		counter = 0
		for script in levelscripts:
			f.write("script"+str(counter)+":\t db "+script+"\n")
			counter = counter + 1
		f.close()


		# Now print all screens

		for y in range(0,self.mymap.map.height/10):
			for x in range(0,self.mymap.map.width/16):
				filenam = "export/screen_"+str(y)+"_"+str(x)+".asm"
				scfile = file(filenam,"w")
				screen=IannaScreen(self.mymap.map.layers['Fondo'], self.mymap.objset, self.mymap.map.layers['Dureza'], self.mymap.map.width,self.mymap.map.height, x, y, properties=self.mymap.map.properties)
				screen.print_screen(scfile, levelscripts)
				scfile.close()

		# Write pointers to all compressed screens in the main file
		for y in range(0,self.mymap.map.height/10):
			for x in range(0,self.mymap.map.width/16):
				scnam = "screen_"+str(y)+"_"+str(x)
				mainfile.write(scnam+"_addr: DW "+scnam+"\n")

		# And write the includes as well
		for y in range(0,self.mymap.map.height/10):
			for x in range(0,self.mymap.map.width/16):
				scnam = "screen_"+str(y)+"_"+str(x)
				filenam_cmp= "screen_"+str(y)+"_"+str(x)+".cmp"
				mainfile.write(scnam+" INCBIN "+"\""+filenam_cmp+"\"\n")

		# And includes for tiles and supertiles
		mainfile.write("level_tiles: INCBIN \"map_tiles.cmp\"\n")
		mainfile.write("level_stiles: INCBIN \"map_stiles.cmp\"\n")
		mainfile.write("level_stilecolors: INCBIN \"map_stilecolors.cmp\"\n")
		mainfile.write("level_strings: INCBIN \"map_strings.cmp\"\n")
		mainfile.write("level_strings_en: INCBIN \"map_strings_en.cmp\"\n")
		mainfile.close()

		# Finally, create makefile

		makefile =  file("export/makefile","w")
		makefile.write("all: map.bin\n\n")
		makefile.write("clean:\n")
		makefile.write("\trm *.bin\n")
		makefile.write("\trm *.cmp\n")

		screen_list=""
		for y in range(0,self.mymap.map.height/10):
			for x in range(0,self.mymap.map.width/16):
				filenam = " screen_"+str(y)+"_"+str(x)+".cmp"
				screen_list = screen_list + filenam

		makefile.write("map.bin: map.asm map_tiles.cmp map_stiles.cmp map_stilecolors.cmp map_strings.cmp map_strings_en.cmp"+screen_list+"\n")
		makefile.write("\tpasmo map.asm map.bin map.sym\n\n")

		makefile.write("map_tiles.cmp: map_tiles.asm\n")
		makefile.write("\tpasmo map_tiles.asm map_tiles.bin\n")
		makefile.write("\tapack map_tiles.bin map_tiles.cmp\n\n")

		makefile.write("map_stiles.cmp: map_stiles.asm\n")
		makefile.write("\tpasmo map_stiles.asm map_stiles.bin\n")
		makefile.write("\tapack map_stiles.bin map_stiles.cmp\n\n")

		makefile.write("map_stilecolors.cmp: map_stilecolors.asm\n")
		makefile.write("\tpasmo map_stilecolors.asm map_stilecolors.bin\n")
		makefile.write("\tapack map_stilecolors.bin map_stilecolors.cmp\n\n")

		makefile.write("map_strings.cmp: map_strings.asm\n")
		makefile.write("\tpasmo map_strings.asm map_strings.bin\n")
		makefile.write("\tapack map_strings.bin map_strings.cmp\n\n")

		makefile.write("map_strings_en.cmp: map_strings_en.asm\n")
		makefile.write("\tpasmo map_strings_en.asm map_strings_en.bin\n")
		makefile.write("\tapack map_strings_en.bin map_strings_en.cmp\n\n")

		for y in range(0,self.mymap.map.height/10):
			for x in range(0,self.mymap.map.width/16):
				filenam = "screen_"+str(y)+"_"+str(x)
				makefile.write(filenam+".cmp: "+filenam+".asm\n")
				makefile.write("\tpasmo "+filenam+".asm "+filenam+".bin\n")
				makefile.write("\tapack "+filenam+".bin "+filenam+".cmp\n\n")

		makefile.close()
		sys.exit(0)


	def waitforkeyrelease(self,key):
		while True:
			events = pygame.event.get()
			for event in events:
				if event.type == pygame.locals.QUIT:
					sys.exit(0)
				elif event.type == pygame.KEYUP:
					if event.key == key:
						return

	# Keys will be OPQA, SPACE for fire and CAPS SHIFT for action
	def read_keyboard(self):
		events = pygame.event.get()
		for event in events:
			if event.type == pygame.locals.QUIT:
				sys.exit(0)
	    		elif event.type == pygame.KEYDOWN:
					if event.key == pygame.K_o:
						self.keyboard[0] = 1
					elif event.key == pygame.K_p:
						self.keyboard[1] = 1
					elif event.key == pygame.K_q:
						self.keyboard[2] = 1
					elif event.key == pygame.K_a:
						self.keyboard[3] = 1
					elif event.key == pygame.K_SPACE:
						self.keyboard[4] = 1
					elif event.key == pygame.K_RSHIFT:
						self.keyboard[5] = 1
					elif event.key == pygame.K_ESCAPE:
						self.ingame = False
					elif event.key == pygame.K_h:
						self.pause_menu()
					elif event.key == pygame.K_F12:
						self.toggle_fullscreen()
	    		elif event.type == pygame.KEYUP:
					if event.key == pygame.K_o:
						self.keyboard[0] = 0
					elif event.key == pygame.K_p:
						self.keyboard[1] = 0
					elif event.key == pygame.K_q:
						self.keyboard[2] = 0
					elif event.key == pygame.K_a:
						self.keyboard[3] = 0
					elif event.key == pygame.K_SPACE:
						self.keyboard[4] = 0
					elif event.key == pygame.K_RSHIFT:
						self.keyboard[5] = 0	
		return


	def CheckGravities(self):
		self.game_entities[0].apply_gravity()
		for entity in [self.game_entities[1],self.game_entities[2]]:
			if entity:
				entity.apply_gravity()

	def ProcessState(self):
		for entity in [self.game_entities[0],self.game_entities[1],self.game_entities[2]]:
			if entity:
				if entity.keyboard:
					entity.process_state(entity.keyboard)
					entity.keyboard=None
				else:
					entity.process_state([0,0,0,0,0,0])

	def DrawSprites(self):
		for entity in [self.game_entities[0],self.game_entities[1],self.game_entities[2]]:
			if entity:
				try:
					self.buffer.blit(entity.current_anim.frames[entity.anim_pos],(entity.posx,entity.posy))
				except AttributeError:
					print "WARNING: ", entity.current_anim, "is a list, not a SevenuP object. Check!"
					print "Entidades: ",entity,self.game_entities[0],self.game_entities[1],self.game_entities[2]
					print "posx:",entity.posx,"posy:",entity.posy,"anim_pos:",entity.anim_pos
				if entity.extra_sprite:
					if entity.state & 1: # looking right
						self.buffer.blit(entity.extra_sprite,(entity.posx+24,entity.posy))
					else:
						self.buffer.blit(entity.extra_sprite,(entity.posx-24,entity.posy))

	def RunScripts(self):
		for entity in self.game_entities:
			if entity:
				try:
					if entity.state != constants.STATE_DEAD and entity.script:
						entity.script.run_script(entity)
				except AttributeError:
					if entity.script:
						entity.script.run_script(entity)

	def CheckMapLimits(self):
		levelscripts=["ACTION_NONE","ACTION_PLAYER","ACTION_SECONDARY"]
		levelstrings=[]
		levelstrings_en=[]

		# Scripts for pickable objects: should always be in the same place!!!
		for kk, script in IannaScript.scripts_per_pickable_object.iteritems():
			if script not in levelscripts:
				levelscripts.append(script)			

		# Scripts for enemy attacks: should always be in the same place!!!
		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_SKELETON"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_ORC"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_MUMMY"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_TROLL"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_ROCK"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_KNIGHT"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_GOLEM"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_OGRE"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_MINOTAUR"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_DEMON"]:
			if script not in levelscripts:
				levelscripts.append(script)

		for script in IannaCharacter.enemy_attack_patterns["OBJECT_ENEMY_DALGURAK"]:
			if script not in levelscripts:
				levelscripts.append(script)

		# Scripts for player in specific screens
		for y in range(0,self.mymap.map.height/10):
			for x in range(0,self.mymap.map.width/16):
				try:
					scriptid = "script-"+str(x)+"_"+str(y)
					script = self.mymap.map.properties[scriptid]
					if script not in levelscripts:
						levelscripts.append(script)
				except KeyError:
					pass

		# Create the list of all scripts in the level
		for y in range(0,self.mymap.map.height/10):
			for x in range(0,self.mymap.map.width/16):
				screen=IannaScreen(self.mymap.map.layers['Fondo'], self.mymap.objset, self.mymap.map.layers['Dureza'], self.mymap.map.width,self.mymap.map.height, x, y, properties=self.mymap.map.properties)
				screenscripts = screen.get_scripts_from_screen()
				for script in screenscripts:
					if script not in levelscripts:
						levelscripts.append(script)
	
		print "We have",len(levelscripts),"different scripts in the level, out of a maximum of 255"

		bytecount=0
		for script in levelscripts:
			bytecount = bytecount + len(script.split(','))
		bytecount = bytecount + 2*len(levelscripts)

		if bytecount > 1023:
			print "WARNING!!",
		print "Scripts use",bytecount,"bytes, out of a maximum of 1024"

		# Create the list of all strings in the level
		counter = 0
		while True:
			stringid = "string-"+str(counter)
			try:
				string = self.mymap.map.properties[stringid]
				levelstrings.append(string)
				# Append the English string as well
				string = self.mymap.map.properties[stringid+"-en"]
				levelstrings_en.append(string)
				counter = counter + 1
			except KeyError:
				break

		print "We have",len(levelstrings),"different strings in the level"

		bytecount=0
		for string in levelstrings:
			bytecount = bytecount + len(string)
		bytecount = bytecount + 3*len(levelstrings)

		if bytecount > 1023:
			print "WARNING!!",
		print "Strings use",bytecount,"bytes, out of a maximum of 1024"

		bytecount=0
		for string in levelstrings_en:
			bytecount = bytecount + len(string)
		bytecount = bytecount + 3*len(levelstrings_en)

		if bytecount > 1023:
			print "WARNING!!",
		print "Strings in English use",bytecount,"bytes, out of a maximum of 1024"



	# For now it is not the most beautiful menu ever... but it works :)

	def MainMenu(self):
		' Initial menu, displays list of maps to load'
		' OUTPUT:'
		' 	- Filename of map to be loaded'
		self.screen.fill((0, 0, 0))

		listoftmx=[]

		for dirname, dirnames, filenames in os.walk('./maps/'):
			for filename in filenames:
				if '.tmx' in filename:
					listoftmx.append(os.path.join(dirname, filename))

		myfont = pygame.font.SysFont("console",32)
	
		self.screen.blit(myfont.render("Select map with Q/A keys and SPACE:",False,(0,255,255)),(0,0))
		selected=0
		done=False

		while not done:
			y=32
			i=0
			for filename in listoftmx:
				if i == selected:
					color=(255,255,255)
				else:
					color=(0,255,255)
				self.screen.blit(myfont.render(filename,False,color),(64,y))
				y = y+32
				i = i + 1
			pygame.display.flip()
			self.read_keyboard()
			if self.keyboard[2] == 1: # UP
				if selected > 0:
					selected = selected - 1
				while self.keyboard[2] == 1:
					self.read_keyboard()
			elif self.keyboard[3] == 1: # DOWN
				if selected < len(listoftmx)-1:
					selected = selected + 1
				while self.keyboard[3] == 1:
					self.read_keyboard()
			elif self.keyboard[4] == 1: # SPACE
				while self.keyboard[4] == 1:
					self.read_keyboard()
				done = True
		return listoftmx[selected]


	def mainloop(self):
		self.ingame = True
		animate_stiles=0

		while self.ingame:
			self.read_keyboard() 
			# call AnimateSTiles
			animate_stiles = animate_stiles + 1
			if animate_stiles & 1:
				self.mymap.anim_stiles()
			self.entity_player.keyboard=self.keyboard
			self.RunScripts()
			self.ProcessState()
			self.CheckGravities()
			# Redrawscreen
			# draw sprites
			self.buffer.set_clip(pygame.Rect(0,0,256,160)) # set clipping area for game, should then set clipping for score area
			self.mymap.draw_screen(self.buffer)
			self.DrawSprites()
			self.scorearea.draw()
			pygame.transform.scale(self.buffer,(256*3,192*3),self.screen)
			pygame.display.flip()
			self.fpsClock.tick(10) # run at 10 fps
	  	    	global_timer.tick()

	def Play(self):
	    while True:
		    gc.collect()  # Force garbage collection on every iteration
		    self.mapfile = self.MainMenu()

		    self.mymap = Map(self.mapfile)
		    self.CheckMapLimits()
		    self.game_entities = [None, None, None, None, None, None, None, None ]
#		    self.player_weapons = [True,False,False,False] # True if weapon is active, False if not
		    self.player_weapons = [True, True, True, True] # True if weapon is active, False if not

		    self.scorearea = IannaScore(self.buffer,self.screen,self.game_entities)	    
		    self.entity_player = IannaCharacter("barbaro", self.mymap, self.game_entities, self.scorearea, self.player_weapons, player=True)
		    initialcoords = self.mymap.map.properties["InitialCoords"].split(',')
		    self.entity_player.posx=int(initialcoords[0])
		    self.entity_player.posy=int(initialcoords[1])
		    self.entity_player.energy=self.entity_player.get_entity_max_energy() # FIXME this is cheating!!
		    self.game_entities[0] = self.entity_player
		    self.mymap.load_tile_table(os.path.dirname(self.mapfile),16, 16)
		    self.mymap.set_screen(self.mymap.current_x,self.mymap.current_y, self.game_entities, self.scorearea)	
		    self.mainloop()



if __name__ == '__main__':
	game = IannaGame()
	game.Play()



