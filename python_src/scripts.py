import random
import constants
from timer import *
from ianna_entity import *

"""
Generic script class
"""
class IannaScript():
	'''
	Load script
	'''
	def __init__ (self, script, parent=None):
		self.script = []
		if constants.DEBUG_SCRIPT:
			print "Loading script: ",script
		tokenlist = script.split(',')
		curtoken=0
		listlength = len(tokenlist)
		if constants.DEBUG_SCRIPT:
			print listlength, tokenlist		
		# Now we need to parse each token and its parameters individually
		while curtoken < listlength:
			action = [tokenlist[curtoken].strip()]	
			nparams = self.script_nparams[tokenlist[curtoken].strip()]
			curtoken = curtoken + 1
			if nparams > 0:
				for i in range(0,nparams):
					action.append(tokenlist[curtoken+i].strip())
			curtoken = curtoken + nparams
			self.script.append(action)
		self.parent=parent
		self.scratch_area=[0,0,0,0,0,0,0,0]	# 8 bytes for scratch area
		if constants.DEBUG_SCRIPT:	
			print self.script

	'''
	Execute script on specified entity
	'''
	def run_script(self, entity):
		newoffset = self.script_function[entity.script.script[entity.script_pos][0]](self,entity.script.script[entity.script_pos],entity)
		entity.script_pos = entity.script_pos + newoffset

	def action_none(self, params, entity):
		return 0

	def action_joystick(self,params,entity):
		return 0

	def script_player(self,params,entity):
		#entity.process_state(entity.keyboard)
		return 0

	def call_subscript(self,entity,newscript):
		script = IannaScript(newscript,parent=self)
		entity.previous_script_pos.append(entity.script_pos)
		entity.script_pos=0
		entity.script = script
		return


	def action_patrol(self,params,entity):
		direction = entity.state & 1	# 0 is left, 1 is right
		flags = params[1]
		# Check if the player is in the line of sight
		# If so, go to fight mode
		player = entity.game_entities[0]
		if entity.state == constants.STATE_FALLING_LOOK_LEFT or entity.state == constants.STATE_FALLING_LOOK_RIGHT:
			# When falling, there is nothing to do
			return 0

		if entity.state != constants.STATE_TURNING_LEFT and entity.state != constants.STATE_TURNING_RIGHT: 
			if player.posy == entity.posy:  # same Y, check line of sight
				if direction == 0 and entity.posx > player.posx:	
					entity.keyboard=[0,0,0,0,0,1] # unsheathe
					return 1 # next action in script
				elif direction == 1 and entity.posx < player.posx:			
					entity.keyboard=[0,0,0,0,0,1] # unsheathe
					return 1 # next action in script
		# in any other case, continue with patrol
		if entity.state == constants.STATE_WALK_LEFT or entity.state == constants.STATE_TURNING_LEFT or entity.state == constants.STATE_IDLE_RIGHT:
			if flags == "FLAG_PATROL_NOFALL":
				# check if we would fall if we moved left
				if entity.state == constants.STATE_IDLE_RIGHT:
					entity.keyboard=[1,0,0,0,0,0]
				elif entity.WouldFall_IfMoved(direction,8):
					entity.entity_setidle(direction)		
				else:
					entity.keyboard=[1,0,0,0,0,0]
			else:
				entity.keyboard=[1,0,0,0,0,0] # move left
				return 0			
		else:
			if flags == "FLAG_PATROL_NOFALL":
				# check if we would fall if we moved right
				if entity.state == constants.STATE_IDLE_LEFT:
					entity.keyboard=[0,1,0,0,0,0]
				elif entity.WouldFall_IfMoved(direction,8):
					entity.entity_setidle(direction)		
				else:
					entity.keyboard=[0,1,0,0,0,0] # move right
			else:
				entity.keyboard=[0,1,0,0,0,0] # move right
				return 0
		return 0

	def action_fight(self,params,entity):
		direction = entity.state & 1	# 0 is left, 1 is right
		flags = params[1]

		if entity.state == constants.STATE_IDLE_RIGHT or entity.state == constants.STATE_IDLE_LEFT:
			#we did some action before, and now went idle.
			return -1 # go to previous action

		# Check if the player is still in the line of sight
		# If not, go back to patrol mode
		player = entity.game_entities[0]
		if abs(player.posy - entity.posy) >= 8:
			entity.keyboard=[0,0,0,0,0,1] # sheathe
			print "Player gone up or down"
			return 0		
		if direction == 0 and entity.posx < player.posx:	
			print "player is on the right, looking left"
			entity.keyboard=[0,0,0,0,0,1] # sheathe
			return 0
		elif direction == 1 and entity.posx > player.posx:
			print "player is on the left, looking right"			
			entity.keyboard=[0,0,0,0,0,1] # sheathe
			return 0

		# If higher than the maximum distance, just get closer
		if abs (player.posx - entity.posx) > constants.PLAYER_MAX_DIST: 
			if flags == "FLAG_FIGHT_NOFALL":
				if entity.WouldFall_IfMoved(direction,8):
					entity.entity_setidle_sword(direction)
				else:
					if direction == 0:
						entity.keyboard=[1,0,0,0,0,0] # move left
					else:
						entity.keyboard=[0,1,0,0,0,0] # move right				
					return 0
			else:
				if direction == 0:
					entity.keyboard=[1,0,0,0,0,0] # move left
				else:
					entity.keyboard=[0,1,0,0,0,0] # move right				
				return 0
		# If in medium distance, check if we should run the long attack
		elif abs (player.posx - entity.posx) > constants.PLAYER_MED_DIST: 
			probability = entity.enemy_prob_longrange[entity.enemy_type][entity.level]
			if random.randint(0,255) < probability: # do not attack
				if constants.DEBUG_SCRIPT:
					print "Long attack"
				# The long attack will mean we will try to get closer to the player
				# If we can fall, we should not do it if we have the FLIGHT_FLAG_NOFALL flag as 1
				if flags == "FLAG_FIGHT_NOFALL":
					if entity.WouldFall_IfMoved(direction,8):
						return 0
				self.call_subscript(entity,entity.enemy_attack_patterns[entity.enemy_type][0])
				return 0
			else: 
				if flags == "FLAG_FIGHT_NOFALL":
					if entity.WouldFall_IfMoved(direction,8):
						entity.entity_setidle_sword(direction)
					else:
						if direction == 0:
							entity.keyboard=[1,0,0,0,0,0] # move left
						else:
							entity.keyboard=[0,1,0,0,0,0] # move right				
						return 0
				else:
					if direction == 0:
						entity.keyboard=[1,0,0,0,0,0] # move left
					else:
						entity.keyboard=[0,1,0,0,0,0] # move right				
					return 0
		# Short distance, check if we should run the short attack, or block, or do nothing
		elif abs (player.posx - entity.posx) > constants.PLAYER_MIN_DIST: 
			if entity.game_entities[0].state >= constants.STATE_SWORD_HIGHSLASH_LEFT and entity.game_entities[0].state <= constants.STATE_SWORD_BACKSLASH_RIGHT:
				# The player is trying to hit us, should we block?
				probability = entity.enemy_prob_block[entity.enemy_type][entity.level]
				if random.randint(0,255) < probability: # block
					entity.keyboard=[0,0,1,0,0,0] # block
					return 0
			probability = entity.enemy_prob_shortrange[entity.enemy_type][entity.level]
			if random.randint(0,255) < probability: # attack
				if random.randint(0,255) > 180 : # harder attack
					self.call_subscript(entity,entity.enemy_attack_patterns[entity.enemy_type][2])
				else:
					self.call_subscript(entity,entity.enemy_attack_patterns[entity.enemy_type][1])
			return 0
		elif player.posx == entity.posx:
			# Go away from the player, as we are right together
			if flags == "FLAG_FIGHT_NOFALL":
				if entity.WouldFall_IfMoved(direction,8):
					entity.entity_setidle_sword(direction)
				else:
					if direction == 0:
						entity.keyboard=[0,1,0,0,0,0] # move right
					else:
						entity.keyboard=[1,0,0,0,0,0] # move left
		else:
			if random.randint(0,100) > 49:
				if constants.DEBUG_SCRIPT:
					print "Short attack"
				if random.randint(0,255) > 180 : # harder attack
					self.call_subscript(entity,entity.enemy_attack_patterns[entity.enemy_type][2])
				else:
					self.call_subscript(entity,entity.enemy_attack_patterns[entity.enemy_type][1])
				return 0
			else:
				if flags == "FLAG_FIGHT_NOFALL":
					if entity.WouldFall_IfMoved(direction,8):
						entity.entity_setidle_sword(direction)
					else:
						if direction == 0:
							entity.keyboard=[0,1,0,0,0,0] # move right
						else:
							entity.keyboard=[1,0,0,0,0,0] # move left
						return 0
		return 0

	def action_destroy(self,params,entity):
		print "action_destroy"
		return 0

	def action_string(self,params,entity):
		stringid = int(params[1])

		entity.scorearea.buffer.set_clip(pygame.Rect(0,160,256,192)) # set clipping area for game, should then set clipping for score area
		entity.scorearea.buffer.blit(entity.scorearea.score_image,(0,160))

		entity.scorearea.clean_text_area()
		entity.scorearea.print_string(entity.map.strings[stringid])

		entity.scorearea.draw()
		pygame.transform.scale(entity.scorearea.buffer,(256*3,192*3),entity.scorearea.screen)
		pygame.display.flip()

		return 1

	def action_wait(self,params,entity):
		' Scratch area'
		'	- Byte 0: used to check if the action is already started'
		' 	- Byte 1: current number of frames executing action'
		if self.scratch_area[0] != constants.ACTION_WAIT:
			self.scratch_area[0] = constants.ACTION_WAIT
			self.scratch_area[1] = int(params[1])

		self.scratch_area[1] = self.scratch_area[1] - 1
		if self.scratch_area[1] == 0:
			return 1
		else:
			return 0

	def action_idle(self,params,entity):
		direction = entity.state & 1	# 0 is left, 1 is right		
		entity.entity_setidle(direction)
		return 1

	def action_move(self,params,entity):
		' Scratch area'
		'	- Byte 0: used to check if the action is already started'
		' 	- Byte 1: used to store the movement direction'
		' 	- Byte 2: current number of frames executing action'


		if self.scratch_area[0] != constants.ACTION_MOVE:
			self.scratch_area[0] = constants.ACTION_MOVE
			self.scratch_area[1] = int(params[1])
			self.scratch_area[2] = int(params[2])
			direction = entity.state & 1	# 0 is left, 1 is right		

		newkeyboard=[0,0,0,0,0,0]

		direction = entity.state & 1	# 0 is left, 1 is right

		if self.scratch_area[1] & constants.MOVE_UP:
			newkeyboard[2]=1
		if self.scratch_area[1] & constants.MOVE_DOWN:
			newkeyboard[3]=1
		if self.scratch_area[1] & constants.MOVE_LEFT:
			newkeyboard[0] = 1
		if self.scratch_area[1] & constants.MOVE_RIGHT:
			newkeyboard[1] = 1	
		if self.scratch_area[1] & constants.MOVE_FORWARD:
			if direction == 0: # left
				newkeyboard[0] = 1
			else: # right
				newkeyboard[1] = 1
		if self.scratch_area[1] & constants.MOVE_BACKWARD:
			if direction == 0: # left
				newkeyboard[1] = 1
			else: # right
				newkeyboard[0] = 1
		if self.scratch_area[1] & constants.MOVE_FIRE:
			newkeyboard[4]=1
		if self.scratch_area[1] & constants.MOVE_SELECT:
			newkeyboard[5]=1

		entity.keyboard = newkeyboard
		
		self.scratch_area[2] = self.scratch_area[2] - 1

		if self.scratch_area[2] == 0:
			self.scratch_area[0] = 0 # reset
			return 1
		else:
			return 0

	def action_wait_switch_on(self,params,entity):
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid
		if entity.map.objects[objnumber*2] == 0:
			return 0
		else:
			return 1


	def action_wait_switch_off(self,params,entity):
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid
		if entity.map.objects[objnumber*2] == 2:
			return 0
		else:
			return 1

	def action_toggle_switch_on(self,params,entity):
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid
		entity.map.objects[objnumber*2] = 2 # switch is now definitely on
		# now update supertiles in map
		# Find entity
		for switch in [entity.game_entities[3],entity.game_entities[4],entity.game_entities[5],entity.game_entities[6],entity.game_entities[7]]:
			if switch.objid == objnumber:
				y1 = switch.posy / 16
				x1 = switch.posx / 16
				tile1 =  entity.map.thisscreen.screenmap[y1][x1]
				tile1 = tile1 + 2
				entity.map.thisscreen.screenmap[y1][x1] = tile1
				tile2 = entity.map.thisscreen.screenmap[y1+1][x1]
				tile2 = tile2 + 2
				entity.map.thisscreen.screenmap[y1+1][x1] = tile2
				return 1
		print "WARNING: toggle_switch_on used with objid not in this screen"
		return 0

	def action_toggle_switch_off(self,params,entity):
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid
		entity.map.objects[objnumber*2] = 0 # switch is now definitely off
		# now update supertiles in map
		# Find entity
		for switch in [entity.game_entities[3],entity.game_entities[4],entity.game_entities[5],entity.game_entities[6],entity.game_entities[7]]:
			if switch.objid == objnumber:
				y1 = switch.posy / 16
				x1 = switch.posx / 16
				tile1 =  entity.map.thisscreen.screenmap[y1][x1]
				tile1 = tile1 - 2
				entity.map.thisscreen.screenmap[y1][x1] = tile1
				tile2 = entity.map.thisscreen.screenmap[y1+1][x1]
				tile2 = tile2 - 2
				entity.map.thisscreen.screenmap[y1+1][x1] = tile2
				return 1
		print "WARNING: toggle_switch_off used with objid not in this screen"
		return 0

	def action_open_door(self,params,entity):
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid

		if entity.map.objects[objnumber*2] == 2:
			print "WARNING: door is open and we are trying to open it again!"
			return 1

		step = entity.map.objects[objnumber*2+1]
		if step == 3:
			entity.map.objects[objnumber*2] = 2 # door is open			
			entity.map.objects[objnumber*2+1] = 0 # cleanup
			return 1 # and next action
		else:
			# Find entity
			for door in [entity.game_entities[3],entity.game_entities[4],entity.game_entities[5],entity.game_entities[6],entity.game_entities[7]]:
				if door.objid == objnumber:
					y1 = door.posy / 16
					x1 = door.posx / 16		
					entity.map.thisscreen.screenmap[y1+2-step][x1] = entity.map.thisscreen.screenmap[y1+3-step][x1]
					entity.map.thisscreen.screenmap[y1+3-step][x1] = 0
					entity.map.SetHardness(x1,y1+3-step,0)			
					step = step + 1
					entity.map.objects[objnumber*2+1] = step
					return 0

		print "WARNING: open_door used with objid not in this screen"
		return 0

	def action_close_door(self,params,entity):
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid

		if entity.map.objects[objnumber*2] == 0:
			print "WARNING: door is closed and we are trying to close it again!"
			return 1

		step = entity.map.objects[objnumber*2+1]
		if step == 3:
			entity.map.objects[objnumber*2] = 0 # door is closed
			entity.map.objects[objnumber*2+1] = 0 # cleanup
			return 1 # and next action
		else:
			# Find entity
			for door in [entity.game_entities[3],entity.game_entities[4],entity.game_entities[5],entity.game_entities[6],entity.game_entities[7]]:
				if door.objid == objnumber:
					y1 = door.posy / 16
					x1 = door.posx / 16		
					entity.map.thisscreen.screenmap[y1+step+1][x1] = entity.map.thisscreen.screenmap[y1+step][x1]
					entity.map.thisscreen.screenmap[y1+step][x1] = entity.map.thisscreen.screenmap[y1+step][x1] - 1
					entity.map.SetHardness(x1,y1+step+1,1)			
					step = step + 1
					entity.map.objects[objnumber*2+1] = step
					# are we killing any entity?
					entityRect = pygame.Rect(x1*16,(y1+step+1)*16, 16, 16)
					for player in [entity.game_entities[0],entity.game_entities[1],entity.game_entities[2]]:
						if player:
							playerRect = pygame.Rect(player.posx,player.posy,player.current_anim.sizex, player.current_anim.sizey)
							if playerRect.colliderect(entityRect):	
								player.energy = 0
								if  player.state != constants.STATE_DYING_LEFT and player.state != constants.STATE_DYING_RIGHT and player.state != constants.STATE_DEAD: # should now die
									direction = player.state & 1	# 0 is left, 1 is right		
									player.state = constants.STATE_DYING_LEFT + direction
									player.current_anim = player.sp_die
									player.anim_pos = player.current_anim.nframes * (1-direction)
									player.anim_wait = 0	
									player.map.objects[player.objid*2] = 1
					return 0
		print "WARNING: close_door used with objid not in this screen"
		return 0


	def action_remove_boxes(self,params,entity):
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid
		step = entity.map.objects[objnumber*2+1]

		# Find entity
		for box in [entity.game_entities[3],entity.game_entities[4],entity.game_entities[5],entity.game_entities[6],entity.game_entities[7]]:
				if box.objid == objnumber:
					entity=box
					break

		if entity.object_type == "OBJECT_BOX_RIGHT":
			if step == 4:
				y1 = entity.posy / 16
				x1 = entity.posx / 16	
				entity.map.objects[objnumber*2] = 2 # boxes are gone
				entity.map.thisscreen.screenmap[y1][x1] = 0
				entity.map.thisscreen.screenmap[y1+1][x1] = 0
				entity.map.thisscreen.screenmap[y1][x1-1] = 0
				entity.map.thisscreen.screenmap[y1+1][x1-1] = 0
				entity.map.SetHardness(x1,y1,0)
				entity.map.SetHardness(x1-1,y1,0)
				entity.map.SetHardness(x1,y1+1,0)
				entity.map.SetHardness(x1-1,y1+1,0)
				entity.map.objects[objnumber*2+1] = 0 # cleanup
				return 1 # and next action
			else:
				tilenumber = 236+step
				y1 = entity.posy / 16
				x1 = entity.posx / 16		
				entity.map.thisscreen.screenmap[y1][x1] = tilenumber
				entity.map.thisscreen.screenmap[y1+1][x1] = tilenumber
				entity.map.thisscreen.screenmap[y1][x1-1] = tilenumber
				entity.map.thisscreen.screenmap[y1+1][x1-1] = tilenumber
				step = step + 1
				entity.map.objects[objnumber*2+1] = step
			return 0
		else: # OBJECT_BOX_LEFT
			if step == 4:
				y1 = entity.posy / 16
				x1 = entity.posx / 16	
				entity.map.objects[objnumber*2] = 2 # boxes are gone
				entity.map.thisscreen.screenmap[y1][x1] = 0
				entity.map.thisscreen.screenmap[y1+1][x1] = 0
				entity.map.thisscreen.screenmap[y1][x1+1] = 0
				entity.map.thisscreen.screenmap[y1+1][x1+1] = 0
				entity.map.SetHardness(x1,y1,0)
				entity.map.SetHardness(x1+1,y1,0)
				entity.map.SetHardness(x1,y1+1,0)
				entity.map.SetHardness(x1+1,y1+1,0)
				entity.map.objects[objnumber*2+1] = 0 # cleanup
				return 1 # and next action
			else:
				tilenumber = 236+step
				y1 = entity.posy / 16
				x1 = entity.posx / 16		
				entity.map.thisscreen.screenmap[y1][x1] = tilenumber
				entity.map.thisscreen.screenmap[y1+1][x1] = tilenumber
				entity.map.thisscreen.screenmap[y1][x1+1] = tilenumber
				entity.map.thisscreen.screenmap[y1+1][x1+1] = tilenumber
				step = step + 1
				entity.map.objects[objnumber*2+1] = step
			return 0


	def action_remove_door(self,params,entity):
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid
		step = entity.map.objects[objnumber*2+1]
		if step == 4:
			y1 = entity.posy / 16
			x1 = entity.posx / 16	
			entity.map.objects[objnumber*2] = 2 # door is gone
			entity.map.thisscreen.screenmap[y1][x1] = 0
			entity.map.thisscreen.screenmap[y1+1][x1] = 0
			entity.map.thisscreen.screenmap[y1-1][x1] = 0
			entity.map.SetHardness(x1,y1,0)
			entity.map.SetHardness(x1,y1+1,0)
			entity.map.SetHardness(x1,y1-1,0)
			entity.map.objects[objnumber*2+1] = 0 # cleanup
			return 1 # and next action
		else:
			tilenumber = 236+step
			y1 = entity.posy / 16
			x1 = entity.posx / 16		
			entity.map.thisscreen.screenmap[y1][x1] = tilenumber
			entity.map.thisscreen.screenmap[y1+1][x1] = tilenumber
			entity.map.thisscreen.screenmap[y1-1][x1] = tilenumber
			step = step + 1
			entity.map.objects[objnumber*2+1] = step
		return 0

	def action_remove_jar(self,params,entity):
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid
		step = entity.map.objects[objnumber*2+1]
		# Find entity
		for jar in [entity.game_entities[3],entity.game_entities[4],entity.game_entities[5],entity.game_entities[6],entity.game_entities[7]]:
				if jar.objid == objnumber:
					entity=jar
					break

		if step == 4:
			y1 = entity.posy / 16
			x1 = entity.posx / 16	
			entity.map.objects[objnumber*2] = 2 # jar is gone
			entity.map.thisscreen.screenmap[y1][x1] = 0
			entity.map.SetHardness(x1,y1,0)
			entity.map.objects[objnumber*2+1] = 0 # cleanup
			return 1 # and next action
		else:
			tilenumber = 236+step
			y1 = entity.posy / 16
			x1 = entity.posx / 16		
			entity.map.thisscreen.screenmap[y1][x1] = tilenumber
			step = step + 1
			entity.map.objects[objnumber*2+1] = step
		return 0




	def action_return_subscript(self,params,entity):
		oldposition = entity.previous_script_pos.pop()
		entity.script_pos = oldposition
		entity.script = self.parent
		return 0		


	def action_teleport(self,params,entity):
		# We basically check if the player rect and the teleporter rectangle collide
		player = entity.game_entities[0]
		screenx=int(params[1])
		screeny=int(params[2])
		x_in_screen=int(params[3])
		y_in_screen=int(params[4])

		playerRect = pygame.Rect(player.posx,player.posy,player.current_anim.sizex, player.current_anim.sizey)
		entityRect = pygame.Rect(entity.posx,entity.posy, 16, 16)
		if playerRect.colliderect(entityRect):
			player.map.current_x = screenx
			player.map.current_y = screeny
			player.map.set_screen(player.map.current_x,player.map.current_y,player.game_entities,player.scorearea)
			player.posx=x_in_screen
			player.posy=y_in_screen
		return 0		


	def action_teleport_ext(self,params,entity):
		# Teleport, unconditionally
		player = entity.game_entities[0]
		screenx=int(params[1])
		screeny=int(params[2])
		x_in_screen=int(params[3])
		y_in_screen=int(params[4])

		player.map.current_x = screenx
		player.map.current_y = screeny
		player.map.set_screen(player.map.current_x,player.map.current_y,player.game_entities,player.scorearea)
		player.posx=x_in_screen
		player.posy=y_in_screen
		return 0


	def action_kill_player(self,params,entity):
		# Kill the player if stepping on the object, only if it is active
		if entity.map.objects[entity.objid*2] != 0:
			return 0	
		player = entity.game_entities[0]	
		playerRect = pygame.Rect(player.posx,player.posy,player.current_anim.sizex, player.current_anim.sizey)
		entityRect = pygame.Rect(entity.posx,entity.posy, 16, 16)
		if playerRect.colliderect(entityRect):
			if  player.state != constants.STATE_DYING_LEFT and player.state != constants.STATE_DYING_RIGHT and player.state != constants.STATE_DEAD: # should now die
				player.energy = 0
				direction = player.state & 1	# 0 is left, 1 is right		
				player.state = constants.STATE_DYING_LEFT + direction
				player.current_anim = player.sp_die
				player.anim_pos = player.current_anim.nframes * (1-direction)	
				player.anim_wait = 0	
				return 0
		return 0

	def action_energy(self,params,entity):
		delta_energy = int(params[1])
		entityRect = pygame.Rect(entity.posx,entity.posy, 16, 16)
		for player in [entity.game_entities[0],entity.game_entities[1],entity.game_entities[2]]:
			if player:
				playerRect = pygame.Rect(player.posx,player.posy,player.current_anim.sizex, player.current_anim.sizey)
				if playerRect.colliderect(entityRect):	
					if player.energy > 0:
						# print "Touching energy", player.energy
						delta_energy =  delta_energy * player.get_entity_max_energy() / 100	# We make delta_energy a percentage
						player.energy = player.energy + delta_energy
						if player.energy > player.get_entity_max_energy():
							player.energy = player.get_entity_max_energy()
						if player.energy <= 0 and player.state != constants.STATE_DYING_LEFT and player.state != constants.STATE_DYING_RIGHT and player.state != constants.STATE_DEAD: # should now die
							direction = player.state & 1	# 0 is left, 1 is right		
							player.state = constants.STATE_DYING_LEFT + direction
							player.current_anim = player.sp_die
							player.anim_pos = player.current_anim.nframes * (1-direction)	
							player.anim_wait = 0	
							player.map.objects[player.objid*2] = 1
		return 0


	def action_restart_script(self,params,entity):
		entity.script_pos = 0
		return 0

	def action_set_timer(self,params,entity):
		value = int(params[1])
		global_timer.setvalue(value)
		global_timer.activate()
		return 1

	def action_wait_timer_set(self,params,entity):
		if global_timer.getvalue() != 0:
			return 1
		return 0

	def action_wait_timer_gone(self,params,entity):
		if global_timer.getvalue() == 0:
			return 1
		return 0

	def action_wait_contact(self,params,entity):
		# We basically check if the player rect and the teleporter rectangle collide
		player = entity.game_entities[0]

		playerRect = pygame.Rect(player.posx,player.posy,player.current_anim.sizex, player.current_anim.sizey)
		entityRect = pygame.Rect(entity.posx,entity.posy, 16, 16)
		if playerRect.colliderect(entityRect):
			return 1
		return 0	
	

	def action_wait_contact_ext(self, params, entity):
		# Check if the player and a script-defined rectangle collide
		startx = int(params[1])
		starty = int(params[2])
		width = int(params[3])
		height = int(params[4])

		player = entity.game_entities[0]
		playerRect = pygame.Rect(player.posx,player.posy,player.current_anim.sizex, player.current_anim.sizey)
		entityRect = pygame.Rect(startx*8,starty*8, width*8, height*8)
		if playerRect.colliderect(entityRect):
			return 1
		return 0		


	def action_wait_pickup(self,params,entity):
		# We check for contact, and then if the player is in a crouch position
		if self.action_wait_contact(params,entity) == 1: # there is contact
			player = entity.game_entities[0]			
			if player.state == constants.STATE_CROUCH_LEFT or player.state == constants.STATE_CROUCH_RIGHT:
				return 1
		return 0

	def action_wait_pickup_inventory(self,params,entity):
		return self.action_wait_pickup(params, entity)

	def action_wait_cross_door(self,params,entity):
		# Check if the player rect and the teleporter rectangle collide AND
	    # the player is crossing a door (this door)
		if self.action_wait_contact(params,entity) == 1: # there is contact
			player = entity.game_entities[0]			
			if player.state == constants.STATE_DOOR_LEFT or player.state == constants.STATE_DOOR_RIGHT:
				return 1
		return 0

	def action_add_energy(self,params,entity):
		# Add some energy to the player
		delta_energy = int(params[1])
		player = entity.game_entities[0]
		print "Adding energy", player.energy
		delta_energy =  delta_energy * player.get_entity_max_energy() / 100	# We make delta_energy a percentage
		player.energy = player.energy + delta_energy  
		if player.energy > player.get_entity_max_energy():
			player.energy = player.get_entity_max_energy()
		if player.energy <= 0 and player.state != constants.STATE_DYING_LEFT and player.state != constants.STATE_DYING_RIGHT and player.state != constants.STATE_DEAD: # should now die
			direction = player.state & 1	# 0 is left, 1 is right		
			player.state = constants.STATE_DYING_LEFT + direction
			player.current_anim = player.sp_die
			player.anim_pos = player.current_anim.nframes * (1-direction)	
			player.anim_wait = 0	
			player.map.objects[player.objid*2] = 1

		print "Added energy", player.energy
		return 1


	def action_move_stile(self,params,entity):
		' Scratch area'
		'	- Byte 0: used to check if the action is already started'
		' 	- Byte 1: store stile X'
		'	- Byte 2: store stile Y'
		'	- Byte 3: pending number of frames to finish'
		if self.scratch_area[0] != 1:
			self.scratch_area[0] = 1
			self.scratch_area[1] = int(params[1])
			self.scratch_area[2] = int(params[2])
			self.scratch_area[3] = int(params[5])

		deltax = int(params[3])
		deltay = int(params[4])

		x1 = self.scratch_area[1]
		y1 = self.scratch_area[2]

		xnew = x1 + deltax
		ynew = y1 + deltay
		self.scratch_area[1] = xnew
		self.scratch_area[2] = ynew


		entity.map.thisscreen.screenmap[ynew][xnew] = entity.map.thisscreen.screenmap[y1][x1]
		entity.map.thisscreen.screenmap[y1][x1] = 0
		entity.map.SetHardness(xnew,ynew,entity.map.GetHardness(x1,y1))			
		entity.map.SetHardness(x1,y1,0)			

		value = self.scratch_area[3] - 1
		if value == 0:
			self.scratch_area[0] = 0
			return 1
		else:
			self.scratch_area[3] = value
			return 0

	def action_move_object(self,params,entity):
		'params[1]: objid'
		'params[2]: Delta X (in chars)'
		'params[3]: Delta Y (in chars)'
		'params[4]: number of frames to move object'
		' Scratch area'
		'	- Byte 0: used to check if the action is already started'
		'	- Byte 1: pending number of frames to finish'
		if self.scratch_area[0] != 1:
			self.scratch_area[0] = 1
			self.scratch_area[1] = int(params[4])	# number of frames
		objnumber=int(params[1])
		if objnumber == 255:
			objnumber = entity.objid
		# Find entity
		for obj in [entity.game_entities[3],entity.game_entities[4],entity.game_entities[5],entity.game_entities[6],entity.game_entities[7]]:
			if obj and obj.objid == objnumber:
				x1 = obj.posx / 16
				y1 = obj.posy / 16
				obj.posx = obj.posx + int(params[2]) * 16
				obj.posy = obj.posy + int(params[3]) * 16

				entity.map.thisscreen.screenmap[obj.posy/16][obj.posx/16] = entity.map.thisscreen.screenmap[y1][x1]
				entity.map.thisscreen.screenmap[y1][x1] = 0
				entity.map.SetHardness(obj.posx / 16, obj.posy / 16, entity.map.GetHardness(x1,y1))			
				entity.map.SetHardness(x1,y1,0)	

				self.scratch_area[1] = self.scratch_area[1] - 1
				if self.scratch_area[1] == 0:
					self.scratch_area[0] = 0
					return 1
		return 0

	def action_change_object(self,params,entity):
		' params[1]: new object type'
		entity.map.objects[entity.objid*2] = 0
		entity.object_type=params[1]
		entity.script = IannaScript(self.scripts_per_pickable_object[entity.object_type])
		entity.script_pos=0
		x1 = entity.posx/16
		y1 = entity.posy/16
		if entity.map.GetHardness(x1,y1+1) == 0:
			y1 = y1 + 1
			entity.posy = y1*16
		entity.map.thisscreen.screenmap[y1][x1] = self.tiles_per_pickable_object[entity.object_type]
		return 0

	def action_add_inventory(self,params,entity):
		' params[1]: object to add to inventory'
		player = entity.game_entities[0]
		player.inventory.append(params[1])
		print player.inventory
		return 1
		
	def action_check_object_in_inventory(self,params,entity):
		' params[1]: object to check if in inventory'
		obj = params[1]
		player = entity.game_entities[0]
		if obj in player.inventory:
			return 1	# Object IS in inventory, go ahead
		return 0 # Object NOT in inventory

	def action_remove_object_from_inventory(self,params,entity):
		'params[1]: object to remove from inventory'
		obj = params[1]
		player = entity.game_entities[0]
		if obj in player.inventory:
			player.inventory.remove(obj)
			return 1
		else:
			print "Hey, we are trying to remove an object that is not there!"
			return 1

	def action_checkpoint(self,params,entity):
		print "WARNING: checkpoints not yet implemented in Python version"
		return 1

	def action_fx(self,params,entity):
		print "WARNING: FXs are not yet implemented in Python version"
		return 1

	def action_finish_level(self,params,entity):
		'params[1]: 0 -> get back to main menu. 1 -> Go to next level.'
		print "WARNING: finish level is not yet implemented in Python version"
		return 1


	def action_add_weapon(self,params,entity):
		'params[1]: 0 -> weapon to add. 1: eclipse, 2: axe, 3: blade'
		weapon = params[1]
		player = entity.game_entities[0]
		player.player_weapons[int(weapon)] = True
		player.weapon = int(weapon) + 1
		player.load_weapon()
		return 1

	def action_change_stile(self,params,entity):
		'params[1]: X'
		'params[2]: Y'
		'params[3]: stile'
		x = int(params[1])
		y = int(params[2])
		entity.map.thisscreen.screenmap[y][x] = int(params[3])
		return 1

	def action_change_hardness(self,params,entity):
		'params[1]: X'
		'params[2]: Y'
		'params[3]: hardness'
		x = int(params[1])
		y = int(params[2])
		entity.map.SetHardness(x,y,int(params[3]))
		return 1
		
	def action_set_object_state(self,params,entity):
		'params[1]: objid'
		'params[2]: value'
		objnumber = int(params[1])
		entity.map.objects[objnumber*2] = int(params[2])
		entity.map.objects[objnumber*2+1] = 0			 # cleanup any additional state
		return 1

	def action_wait_object_state(self,params,entity):
		'params[1]: objid'
		'params[2]: value'
		objnumber = int(params[1])
		current_state = entity.map.objects[objnumber*2]
		if current_state == int(params[2]):
			return 1
		else:
			return 0

        def action_nop(self,params,entity):
                return 1

	def action_teleport_enemy(self,params,entity):
		'params[1]: x'
		'params[2]: y'
		' Scratch area'
		'	- Byte 0: used to check if the action is already started'
		if self.scratch_area[0] != 1:
			self.scratch_area[0] = 1
			direction = entity.state & 1	# 0 is left, 1 is right		
			entity.state = constants.STATE_TELEPORT_PHASE1_LEFT + direction
			entity.current_anim = entity.sp_low_sword
			entity.anim_pos = entity.current_anim.nframes * (1-direction)
			entity.anim_wait = 0
		else:
			print("Teleporting, anim_wait is %s" % entity.anim_wait)
			if entity.anim_wait == 3:
				x = int(params[1])
				y = int(params[2])
				entity.posx = x
				entity.posy = y
				direction = entity.state & 1	# 0 is left, 1 is right		
				entity.state = constants.STATE_TELEPORT_PHASE2_LEFT + direction
				entity.current_anim = entity.sp_low_sword
				entity.anim_pos = entity.current_anim.nframes * (1-direction) + 3
			elif entity.anim_wait == 6:
				direction = entity.state & 1	# 0 is left, 1 is right		
				entity.entity_setidle(direction)
				return 1
		return 0


	script_nparams = { 	"ACTION_NONE": 		0,
				"ACTION_JOYSTICK":	0,
				"ACTION_PLAYER":	0,
				"ACTION_PATROL":	1,
				"ACTION_FIGHT":		1,
				"ACTION_DESTROY":	0,
				"ACTION_STRING":	1,
				"ACTION_WAIT":		1,
				"ACTION_MOVE":		2,
				"ACTION_WAIT_SWITCH_ON":1,
				"ACTION_WAIT_DEAD":	1,
				"ACTION_WAIT_DESTROYED":1,
				"ACTION_WAIT_SWITCH_OFF":1,
				"ACTION_TOGGLE_SWITCH_ON":1,
				"ACTION_TOGGLE_SWITCH_OFF":1,
				"ACTION_OPEN_DOOR":	1,
				"ACTION_CLOSE_DOOR":	1,
				"ACTION_REMOVE_BOXES":	1,
				"ACTION_RETURN_SUBSCRIPT":0,
				"ACTION_TELEPORT": 4,
				"ACTION_REMOVE_DOOR":1,
				"ACTION_REMOVE_JAR":1,
				"ACTION_KILL_PLAYER":0,
				"ACTION_ENERGY":1,
				"ACTION_SET_TIMER":1,
				"ACTION_WAIT_TIMER_SET":0,
				"ACTION_WAIT_TIMER_GONE":0,
				"ACTION_RESTART_SCRIPT":0,
				"ACTION_WAIT_CONTACT":0,
				"ACTION_MOVE_STILE": 5,
				"ACTION_CHANGE_OBJECT":1,
				"ACTION_WAIT_PICKUP":0,
				"ACTION_IDLE":0,
				"ACTION_ADD_INVENTORY": 1,
                "ACTION_ADD_ENERGY": 1,
				"ACTION_CHECK_OBJECT_IN_INVENTORY": 1, 
				"ACTION_REMOVE_OBJECT_FROM_INVENTORY": 1, 
				"ACTION_CHECKPOINT": 0,
				"ACTION_FINISH_LEVEL": 1,
				"ACTION_ADD_WEAPON": 1,
				"ACTION_WAIT_CROSS_DOOR": 0,
				"ACTION_CHANGE_STILE": 3,
				"ACTION_CHANGE_HARDNESS": 3,
				"ACTION_SET_OBJECT_STATE": 2,
                "ACTION_WAIT_OBJECT_STATE": 2,
                "ACTION_NOP": 0,
				"ACTION_WAIT_CONTACT_EXT": 4,
				"ACTION_TELEPORT_EXT": 4,
				"ACTION_TELEPORT_ENEMY": 2,
				"ACTION_MOVE_OBJECT": 4, 
				"ACTION_WAIT_PICKUP_INVENTORY":0,
				"ACTION_FX": 1,
		}

	script_function = {	"ACTION_NONE": 		action_none,
				"ACTION_JOYSTICK":	action_joystick,
				"ACTION_PLAYER":	script_player,
				"ACTION_PATROL":	action_patrol,
				"ACTION_FIGHT":		action_fight,
				"ACTION_DESTROY":	action_destroy,
				"ACTION_STRING":	action_string,
				"ACTION_WAIT":		action_wait,
				"ACTION_MOVE":		action_move,
				"ACTION_WAIT_SWITCH_ON":action_wait_switch_on,
				"ACTION_WAIT_DEAD":	action_wait_switch_on,
				"ACTION_WAIT_DESTROYED":action_wait_switch_on,
				"ACTION_WAIT_SWITCH_OFF":action_wait_switch_off,
				"ACTION_TOGGLE_SWITCH_ON":action_toggle_switch_on,
				"ACTION_TOGGLE_SWITCH_OFF":action_toggle_switch_off,
				"ACTION_OPEN_DOOR":	action_open_door,
				"ACTION_CLOSE_DOOR":	action_close_door,
				"ACTION_REMOVE_BOXES":	action_remove_boxes,
				"ACTION_RETURN_SUBSCRIPT":action_return_subscript,	
				"ACTION_TELEPORT":	action_teleport,
				"ACTION_REMOVE_DOOR": action_remove_door,
				"ACTION_REMOVE_JAR": 	action_remove_jar,
				"ACTION_KILL_PLAYER": action_kill_player,
				"ACTION_ENERGY":	action_energy,
				"ACTION_SET_TIMER":	action_set_timer,
				"ACTION_WAIT_TIMER_SET": action_wait_timer_set,
				"ACTION_WAIT_TIMER_GONE": action_wait_timer_gone,
				"ACTION_RESTART_SCRIPT": action_restart_script,
				"ACTION_WAIT_CONTACT": action_wait_contact,
				"ACTION_MOVE_STILE": action_move_stile,
				"ACTION_CHANGE_OBJECT": action_change_object,
				"ACTION_WAIT_PICKUP": action_wait_pickup,
				"ACTION_IDLE": action_idle,
				"ACTION_ADD_INVENTORY": action_add_inventory,
                "ACTION_ADD_ENERGY": action_add_energy,
				"ACTION_CHECK_OBJECT_IN_INVENTORY": action_check_object_in_inventory, 
				"ACTION_REMOVE_OBJECT_FROM_INVENTORY": action_remove_object_from_inventory, 
				"ACTION_CHECKPOINT": action_checkpoint,
				"ACTION_FINISH_LEVEL": action_finish_level,
				"ACTION_ADD_WEAPON": action_add_weapon,
				"ACTION_WAIT_CROSS_DOOR": action_wait_cross_door,
				"ACTION_CHANGE_STILE": action_change_stile,
				"ACTION_CHANGE_HARDNESS": action_change_hardness,
				"ACTION_SET_OBJECT_STATE": action_set_object_state,
                "ACTION_WAIT_OBJECT_STATE": action_wait_object_state,
                "ACTION_NOP": action_nop,
				"ACTION_WAIT_CONTACT_EXT": action_wait_contact_ext,
				"ACTION_TELEPORT_EXT": action_teleport_ext,
				"ACTION_TELEPORT_ENEMY": action_teleport_enemy,
				"ACTION_MOVE_OBJECT": action_move_object,
				"ACTION_WAIT_PICKUP_INVENTORY": action_wait_pickup_inventory,
				"ACTION_FX": action_fx,
		}

	scripts_per_pickable_object = { "OBJECT_KEY_GREEN": "ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_GREEN,ACTION_NONE",
					"OBJECT_KEY_BLUE": "ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_BLUE,ACTION_NONE",
					"OBJECT_KEY_YELLOW": "ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_YELLOW,ACTION_NONE",
					"OBJECT_KEY_RED": "ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_RED,ACTION_NONE",
					"OBJECT_KEY_WHITE": "ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_WHITE,ACTION_NONE",
					"OBJECT_KEY_PURPLE": "ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_KEY_PURPLE,ACTION_NONE",
					"OBJECT_BREAD": "ACTION_WAIT_PICKUP,ACTION_REMOVE_JAR,255,ACTION_ADD_ENERGY, 20, ACTION_NONE",
					"OBJECT_MEAT": "ACTION_WAIT_PICKUP,ACTION_REMOVE_JAR,255,ACTION_ADD_ENERGY, 50, ACTION_NONE",
					"OBJECT_HEALTH": "ACTION_WAIT_PICKUP_INVENTORY,ACTION_REMOVE_JAR,255,ACTION_ADD_INVENTORY,OBJECT_HEALTH,ACTION_NONE",
		}

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
