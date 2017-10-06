import constants
from sev_sprite import * 
import traceback

"""
Generic entity class
"""
class IannaEntity():
	def __init__ (self):
		self.posx=0
		self.posy=0
		self.script=None
		self.script_pos=0
		self.energy=2
		self.objid=0

"""
Ianna Character class
 
Used for the barbarian and enemies
 
package: ianna
"""
class IannaCharacter(IannaEntity):
	""" Ianna Character """
	# Sprites
	sp_idle=[]
	sp_turn=[]
	sp_walk=[]
	sp_fall=[]
	sp_crouch=[]
	sp_unsheathe=[]
	sp_idle_sword=[]
	sp_walk_sword=[]
	sp_high_sword=[]
	sp_forw_sword=[]
	sp_combo1_sword=[]
	sp_low_sword=[]
	sp_back_sword=[]	
	sp_block_sword=[]
	sp_ouch_sword=[]
	sp_die=[]


	# The following sprites only apply to the barbarian
	sp_ouch=[]
	sp_jump_up=[]
	sp_shortjump=[]
	sp_longjump=[]
	sp_run=[]
	sp_brake=[]
	sp_braketurn=[]
	sp_switch=[]
	sp_grab=[]

	
	def __init__ (self, name , currentmap, entity_array, scorearea, player_weapons, player=False):
	  """ 
	  Initialize. Params:
	  name: character name (barbaro,esqueleto, etc).
	  player: boolean. If True, load additional main player animations 
	  """
	  IannaEntity.__init__(self)
	  self.reset_values()

	  self.sp_idle = SevSprite("sprites/"+name+"/"+name+"_idle.sev")
	  self.sp_turn = SevSprite("sprites/"+name+"/"+name+"_gira.sev")
	  self.sp_walk = SevSprite("sprites/"+name+"/"+name+"_camina.sev")
	  self.sp_fall = SevSprite("sprites/"+name+"/"+name+"_cae.sev")
	  self.sp_crouch = SevSprite("sprites/"+name+"/"+name+"_agacha.sev")
	  self.sp_unsheathe = SevSprite("sprites/"+name+"/"+name+"_saca_espada.sev")
	  self.sp_idle_sword = SevSprite("sprites/"+name+"/"+name+"_idle_espada.sev")
	  self.sp_walk_sword = SevSprite("sprites/"+name+"/"+name+"_camina_espada.sev")
	  self.sp_high_sword = SevSprite("sprites/"+name+"/"+name+"_espada_golpealto.sev")
	  self.sp_forw_sword = SevSprite("sprites/"+name+"/"+name+"_espada_golpeadelante.sev")
	  self.sp_combo1_sword = SevSprite("sprites/"+name+"/"+name+"_espada_comboadelante.sev")
	  self.sp_low_sword = SevSprite("sprites/"+name+"/"+name+"_espada_golpebajo.sev")
	  try:
		  self.sp_back_sword = SevSprite("sprites/"+name+"/"+name+"_espada_golpeatras.sev")	
	  except IOError:
		  self.sp_back_sword = SevSprite("sprites/"+name+"/"+name+"_espada_golpeadelante.sev")	
		  self.sp_back_sword.name = name+"_espada_golpeatras.sev"
	  self.sp_block_sword = SevSprite("sprites/"+name+"/"+name+"_espada_bloquea.sev")
	  self.sp_ouch_sword = SevSprite("sprites/"+name+"/"+name+"_espada_ouch.sev")
	  self.sp_die = SevSprite("sprites/"+name+"/"+name+"_muere.sev")
	  self.sp_idle.flip()
  	  self.sp_turn.flip()
	  self.sp_walk.flip()
	  self.sp_fall.flip()
	  self.sp_crouch.flip()
	  self.sp_unsheathe.flip()
	  self.sp_idle_sword.flip()
	  self.sp_walk_sword.flip()
	  self.sp_high_sword.flip()
	  self.sp_forw_sword.flip()
	  self.sp_combo1_sword.flip()
	  self.sp_low_sword.flip()
	  self.sp_back_sword.flip()
	  self.sp_block_sword.flip()
	  self.sp_ouch_sword.flip()
	  self.sp_die.flip()
	  self.current_anim = self.sp_idle
	  self.player = player
	  self.map = currentmap
	  self.game_entities = entity_array
	  self.scorearea = scorearea
	  self.keyboard=None
	  self.weapon= constants.WEAPON_SWORD
	  self.player_weapons = player_weapons

	  if (player==True):
		# Load additional animations, only meant for player
		self.sp_ouch=SevSprite("sprites/"+name+"/"+name+"_ouch.sev")
		self.sp_jump_up=SevSprite("sprites/"+name+"/"+name+"_salta.sev")
		self.sp_shortjump=SevSprite("sprites/"+name+"/"+name+"_salto_corto.sev")
		self.sp_longjump=SevSprite("sprites/"+name+"/"+name+"_salto_largo.sev")
		self.sp_run=SevSprite("sprites/"+name+"/"+name+"_corre.sev")
		self.sp_brake=SevSprite("sprites/"+name+"/"+name+"_frena.sev")
		self.sp_braketurn=SevSprite("sprites/"+name+"/"+name+"_frena_gira.sev")
		self.sp_switch=SevSprite("sprites/"+name+"/"+name+"_palanca.sev")
		self.sp_grab=SevSprite("sprites/"+name+"/"+name+"_cuelga.sev")		
		self.sp_ouch.flip()
		self.sp_jump_up.flip()
		self.sp_shortjump.flip()
		self.sp_longjump.flip()
		self.sp_run.flip()
		self.sp_brake.flip()
		self.sp_braketurn.flip()
		self.sp_switch.flip()
		self.sp_grab.flip()
		self.inventory = []
		self.current_object = 0
		self.experience = 0

	def reset_values(self):
		self.posx=0
		self.posy=0
		self.script=None
		self.script_pos=0
		self.energy=2
		self.state=constants.STATE_IDLE_LEFT
		self.current_anim = self.sp_idle
		self.anim_pos=1
		self.last_move=0
		self.level=5
		self.enemy_type=0	
		self.anim_wait=0	
		self.extra_sprite=None
		self.objid=0
		self.previous_script_pos=[]

	def dump_entity(self):
		print "Entity state dump for "+str(self)
		print "Sp_Idle: "+str(self.sp_idle)
		print "Map: "+str(self.map)
		print "game_entities: "+str(self.game_entities)
		print "Score area: "+str(self.scorearea)
		print "Keyboard: "+str(self.keyboard)
		print "Weapon: "+str(self.weapon)
		if self.sp_run:
			print "Sp_run: "+str(self.sp_run)
			print "Inventory: "+str(self.inventory)
			print "Current obj: "+str(self.current_object)
		print "Position: "+str(self.posx)+","+str(self.posy)
		print "Script: ",
		print self.script.script
		print "Position in script: "+str(self.script_pos)
		print "Energy: "+str(self.energy)
		print "State: "+str(self.state)
		print "Current anim: "+str(self.current_anim)
		print "Anim pos: "+str(self.anim_pos)
		print "Last move: "+str(self.last_move)
		print "Level: "+str(self.level)
		print "Enemy type: "+str(self.enemy_type)
		print "Anim wait: "+str(self.anim_wait)
		print "Extra sprite: "+str(self.extra_sprite)
		print "Objid: "+str(self.objid)
		print "-----------------------------------"
		print ""

	def load_weapon(self):
		weapon_name = self.weapon_names[self.weapon]
		self.sp_idle_sword = SevSprite("sprites/barbaro/barbaro_idle_"+weapon_name+".sev")
		self.sp_walk_sword = SevSprite("sprites/barbaro/barbaro_camina_"+weapon_name+".sev")
		self.sp_high_sword = SevSprite("sprites/barbaro/barbaro_"+weapon_name+"_golpealto.sev")
		self.sp_forw_sword = SevSprite("sprites/barbaro/barbaro_"+weapon_name+"_golpeadelante.sev")
		self.sp_combo1_sword = SevSprite("sprites/barbaro/barbaro_"+weapon_name+"_comboadelante.sev")
		self.sp_low_sword = SevSprite("sprites/barbaro/barbaro_"+weapon_name+"_golpebajo.sev")
		self.sp_back_sword = SevSprite("sprites/barbaro/barbaro_"+weapon_name+"_golpeatras.sev")	
		self.sp_block_sword = SevSprite("sprites/barbaro/barbaro_"+weapon_name+"_bloquea.sev")
		self.sp_ouch_sword = SevSprite("sprites/barbaro/barbaro_"+weapon_name+"_ouch.sev")

		self.sp_idle_sword.flip()
		self.sp_walk_sword.flip()
		self.sp_high_sword.flip()
		self.sp_forw_sword.flip()
		self.sp_combo1_sword.flip()
		self.sp_low_sword.flip()
		self.sp_back_sword.flip()
		self.sp_block_sword.flip()
		self.sp_ouch_sword.flip()


	def process_state(self,keyboard):
		self.entity_functions[self.state](self,keyboard)
		return

	def entity_idle(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right

		if keyboard[5] == 1:	# Action pressed, unsheathe sword
			self.state = constants.STATE_UNSHEATHE_LEFT + direction
			self.current_anim = self.sp_unsheathe
			self.anim_pos = self.current_anim.nframes * (1-direction)
			return
		if keyboard[4] == 1:	# Fire pressed
			if keyboard[0] == 1: # Left+Fire pressed, run left
				if direction == 0: 	# already looking left, start running
					if self.player == True:
						self.state = constants.STATE_RUN_LEFT
						self.current_anim = self.sp_run
						self.anim_pos = self.current_anim.nframes
					else:
						print "WARNING: a non-player is trying to run!"
						self.dump_entity()
				else:			# looking right, turn around
					self.state = constants.STATE_TURNING_LEFT
					self.current_anim = self.sp_turn
					self.anim_pos =  self.current_anim.nframes
				return
			elif keyboard[1] == 1: # right+fire pressed, run right
				if direction == 1: 	# already looking right, start running
					if self.player == True:
						self.state = constants.STATE_RUN_RIGHT
						self.current_anim = self.sp_run
						self.anim_pos = 0
					else:
						print "WARNING: a non-player is trying to run!"
						self.dump_entity()
				else:			# looking left, turn around
					self.state = constants.STATE_TURNING_RIGHT
					self.current_anim = self.sp_turn 
					self.anim_pos = 0
				return
			elif keyboard[2] == 1: # fire+up pressed, unsheathe	
				self.state = constants.STATE_UNSHEATHE_LEFT + direction
				self.current_anim = self.sp_unsheathe
				self.anim_pos = self.current_anim.nframes * (1-direction)
				return	
			else:  # Just fire pressed, should check for a switch
				switch, objid = self.check_switch(direction)
				if switch == True:
					self.map.objects[objid*2] = 1 # the switch is toggling
					self.state = constants.STATE_SWITCH_LEFT + direction
					self.current_anim = self.sp_switch
					self.anim_pos = self.current_anim.nframes * (1-direction)
					self.anim_wait = 0
				return
		elif keyboard[0] == 1: # LEFT
			# if we are a rock, we should do something special
			if self.enemy_type == 'OBJECT_ENEMY_ROCK':
				self.state = constants.STATE_ROCK_LEFT
				self.current_anim = self.sp_walk
				self.anim_pos = self.current_anim.nframes
				self.anim_wait = 0
				return

			if direction == 1: # looking right, turn around
				self.state = constants.STATE_TURNING_LEFT
				self.current_anim = self.sp_turn
				self.anim_pos = self.current_anim.nframes
			else:
				if keyboard[2] == 1: # UP+LEFT, short jump
					if self.player == True:
						self.state = constants.STATE_JUMP_LEFT
						self.current_anim = self.sp_shortjump
						self.anim_pos = self.current_anim.nframes		
					else:
						print "WARNING: a non-player is trying to jump left!"
						self.dump_entity()
				else: 	# already looking left, start walking
					self.state = constants.STATE_WALK_LEFT
					self.current_anim = self.sp_walk
					self.anim_pos = self.current_anim.nframes
			return
		elif keyboard[1] == 1: # RIGHT
			# if we are a rock, we should do something special
			if self.enemy_type == 'OBJECT_ENEMY_ROCK':
				self.state = constants.STATE_ROCK_RIGHT
				self.current_anim = self.sp_walk
				self.anim_pos = self.current_anim.nframes
				self.anim_wait = 0
				return

			if direction == 0: # looking left, turn around
				self.state = constants.STATE_TURNING_RIGHT
				self.current_anim = self.sp_turn
				self.anim_pos = 0
			else:
				if keyboard[2] == 1: # UP+RIGHT, short jump
					if self.player == True:
						self.state = constants.STATE_JUMP_RIGHT
						self.current_anim = self.sp_shortjump
						self.anim_pos = 0
					else:
						print "WARNING: a non-player is trying to jump right!"
						self.dump_entity()
				else:# already looking right, start walking
					self.state = constants.STATE_WALK_RIGHT
					self.current_anim = self.sp_walk
					self.anim_pos = 0
			return

		elif keyboard[2] == 1: # UP
			# First, check for a teleport
			if self.check_teleport(direction):
				print "TELEPORTING"
				self.state = constants.STATE_DOOR_LEFT + direction
				self.current_anim = self.sp_turn
				self.anim_pos =  self.current_anim.nframes
				self.anim_wait = 0
				return				

			if direction == 0: 	# looking left
				deltax = 0
			else:			# looking right
				deltax = 16		
			if self.entity_canhang_up(deltax,-16) == 0:  # can hang
				self.state = constants.STATE_JUMP_UP_LOOK_LEFT + direction
				self.current_anim = self.sp_jump_up
				self.anim_pos = self.current_anim.nframes * (1-direction)				
				return
			else:
				if self.posx >= 8:
					self.posx = self.posx - 8
					if self.entity_canhang_up(deltax,-16) == 0:  # can hang, and needs to move 8 pixels left
						self.state = constants.STATE_JUMP_UP_LOOK_LEFT + direction
						self.current_anim = self.sp_jump_up
						self.anim_pos = self.current_anim.nframes * (1-direction)			
						return
				if self.posx + 8 < 255:
					self.posx = self.posx + 16
					if self.entity_canhang_up(deltax,-16) == 0:  # can hang, and needs to move 8 pixels right
						self.state = constants.STATE_JUMP_UP_LOOK_LEFT + direction
						self.current_anim = self.sp_jump_up
						self.anim_pos = self.current_anim.nframes * (1-direction)			
					else:  # cannot hang anyway, so lets just jump up
						self.posx = self.posx - 8
						self.state = constants.STATE_JUMP_UP_LOOK_LEFT + direction
						self.current_anim = self.sp_jump_up
						self.anim_pos = self.current_anim.nframes * (1-direction)
				return	

		elif keyboard[3] == 1: # DOWN, now crouch
			if self.cango_down(direction): # Can move down
				self.state = constants.STATE_DOWN_LOOK_LEFT + direction
				self.current_anim = self.sp_jump_up
				self.anim_pos = self.current_anim.nframes * (1-direction)+7
				self.anim_wait = 0
			else: #just crouch
				self.state = constants.STATE_CROUCH_LEFT + direction
				self.current_anim = self.sp_crouch
				self.anim_pos = self.current_anim.nframes * (1-direction)
				self.anim_wait = 0							
			return
		return

	def entity_walk(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if keyboard[5] == 1:	# Action pressed, unsheathe sword
			self.state = constants.STATE_UNSHEATHE_LEFT + direction
			self.current_anim = self.sp_unsheathe
			self.anim_pos = self.current_anim.nframes * (1-direction)
			return
		if keyboard[4] == 1:	# Fire pressed
			if keyboard[0] == 1: # Left+Fire pressed, run left
				if direction == 0: 	# already looking left, start running
					if self.player == True:
						self.state = constants.STATE_RUN_LEFT
						self.current_anim = self.sp_run
						self.anim_pos = self.current_anim.nframes
					else:
						print "WARNING: a non-player is trying to run!"
						self.dump_entity()
				else:			# looking right, turn around
					self.state = constants.STATE_TURNING_LEFT
					self.current_anim = self.sp_turn
					self.anim_pos =  self.current_anim.nframes
			elif keyboard[1] == 1: # right+fire pressed, run right
				if direction == 1: 	# already looking right, start running
					if self.player == True:
						self.state = constants.STATE_RUN_RIGHT
						self.current_anim = self.sp_run
						self.anim_pos = 0
					else:
						print "WARNING: a non-player is trying to run!"
						self.dump_entity()
				else:			# looking left, turn around
					self.state = constants.STATE_TURNING_RIGHT
					self.current_anim = self.sp_turn 
					self.anim_pos = 0
			elif keyboard[2] == 1: # fire+up pressed, unsheathe	
				self.state = constants.STATE_UNSHEATHE_LEFT + direction
				self.current_anim = self.sp_unsheathe
				self.anim_pos = self.current_anim.nframes * (1-direction)

			else:  # Just fire pressed, should check for a switch
				switch, objid = self.check_switch(direction)
				if switch == True:
					self.map.objects[objid*2] = 1 # the switch is toggling
					self.state = constants.STATE_SWITCH_LEFT + direction
					self.current_anim = self.sp_switch
					self.anim_pos = self.current_anim.nframes * (1-direction)
					self.anim_wait = 0
			return
		if keyboard[2] == 1: # UP, jump
			if self.player == True:
				self.state = constants.STATE_JUMP_LEFT + direction
				self.current_anim = self.sp_shortjump
				self.anim_pos = self.current_anim.nframes * (1-direction)
			else:
				print "WARNING: a non-player is trying to jump!"
				self.dump_entity()
			return
		if keyboard[0] == 1: # left
			if direction == 1:
				self.keepon_moving(direction)		# Do nothing if moving right
			else:	# keep on moving left
				self.anim_pos = self.anim_pos+1
				if self.anim_pos == self.current_anim.nframes * 2: # restart animation
					self.anim_pos = self.current_anim.nframes
				if (self.anim_pos & 1) == 0:
					if self.move(-8,0) == False: # we are hitting something
						self.entity_setidle(direction)		
			return
		if keyboard[1] == 1: # right
			if direction == 0:
				self.keepon_moving(direction)		# Do nothing if moving left
			else:	# keep on moving left
				self.anim_pos = self.anim_pos+1
				if self.anim_pos == self.current_anim.nframes: # restart animation
					self.anim_pos = 0
				if (self.anim_pos & 1) == 0:
					if self.move(8,0) == False: # we are hitting something
						self.entity_setidle(direction)			
			return

		self.keepon_moving(direction)
		return

	def keepon_moving(self,direction):
		self.anim_pos = self.anim_pos+1	

		if direction == 0: # moving left
			if self.anim_pos == self.current_anim.nframes * 2 or self.anim_pos == (self.current_anim.nframes + self.current_anim.nframes/2) : # stop animation
				self.entity_setidle(direction)	
				return
			if (self.anim_pos & 1) == 0:
				if self.move(-8,0) == False: # we are hitting something
					self.entity_setidle(direction)			
		else: # moving right
			if self.anim_pos == self.current_anim.nframes or self.anim_pos == self.current_anim.nframes/2: # stop animation
				self.entity_setidle(direction)
				return
			if (self.anim_pos & 1) == 0:
				if self.move(8,0) == False: # we are hitting something
					self.entity_setidle(direction)			

	def keepon_running(self,direction):
		self.anim_pos = self.anim_pos+1	

		if direction == 0: # moving left
			if self.anim_pos == self.current_anim.nframes * 2: # stop animation
				self.anim_pos = self.current_anim.nframes
			if self.move(-8,0) == False: # we are hitting something
				self.state = constants.STATE_OUCH_LEFT + direction
				self.current_anim = self.sp_ouch
				self.anim_pos = self.current_anim.nframes * (1-direction)
				self.anim_wait = 0
		else: # moving right
			if self.anim_pos == self.current_anim.nframes: # stop animation
				self.anim_pos = 0
			if self.move(8,0) == False: # we are hitting something
				self.state = constants.STATE_OUCH_LEFT + direction
				self.current_anim = self.sp_ouch
				self.anim_pos = self.current_anim.nframes * (1-direction)
				self.anim_wait = 0

	def entity_run(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if keyboard[2] == 1:	# UP, so longjump
			self.state = constants.STATE_LONGJUMP_LEFT + direction
			self.current_anim = self.sp_longjump
			self.anim_pos = self.current_anim.nframes * (1-direction)
			self.anim_wait=0
			return
		if keyboard[0] == 1: # left
			if direction == 0:	# keep on running
				self.keepon_running(direction)
			else:	# brake+turn right
				self.state = constants.STATE_BRAKE_TURN_RIGHT
				self.current_anim = self.sp_braketurn
				self.anim_pos = 0
				self.anim_wait = 0

		elif keyboard[1] == 1: # right
			if direction == 1:	# keep on running
				self.keepon_running(direction)
			else:	# brake+turn left
				self.state = constants.STATE_BRAKE_TURN_LEFT
				self.current_anim = self.sp_braketurn
				self.anim_pos = self.current_anim.nframes
				self.anim_wait = 0
		else: #brake
			self.state = constants.STATE_BRAKE_LEFT + direction
			self.current_anim = self.sp_brake
			self.anim_pos = self.current_anim.nframes * (1-direction)
			self.anim_wait = 0
		return



	def entity_jump_up(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if keyboard[2] == 1:	# still pressing UP, will skip the "hang" animation if needed
			anim_increment = 3
		else:	
			anim_increment = 2
		if (self.anim_pos == 1) or (self.anim_pos == self.current_anim.nframes+1): # check if we can hang, otherwise go idle
			if direction == 0:
				movex = 0
			else:
				movex = 16
			if self.entity_canhang_up(movex,0) == 0:
				if anim_increment == 2:
					self.state = constants.STATE_HANG_LEFT + direction
				else:
					self.state = constants.STATE_CLIMB_LEFT + direction		
				self.current_anim = self.sp_jump_up
				self.anim_pos = self.current_anim.nframes * (1-direction) + anim_increment
				self.posy = self.posy - 8
			else: # go idle
				self.entity_setidle(direction)	
		else: # just change animation
			self.anim_pos = self.anim_pos + 1
			self.posy = self.posy - 8
		return

	def entity_shortjump(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right

		if direction == 0:		# -1 to move left, 1 to move right
			deltax = -1
		else:
			deltax = 1

		self.anim_pos = self.anim_pos + 1
		if self.anim_pos > self.current_anim.nframes:
			state = self.anim_pos - self.current_anim.nframes
		else:
			state = self.anim_pos

		if state == 1:
			if self.move(16*deltax,-8,checkstair=False) == False:
				self.entity_setidle(direction)
		elif state == 4:
			if self.move(16*deltax,8,checkstair=False) == False:
				self.entity_setidle(direction)
			if self.WhereDidILand(direction):
				self.move(0,-8)
		elif state == 5:
			self.entity_setidle(direction)
		else: # state is 2 or 3
			if self.move(8*deltax,0,checkstair=False) == False:
				self.entity_setidle(direction)
		return

	def entity_movedown(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		self.anim_pos = self.anim_pos - 1
		curanimpos = self.anim_pos - (self.current_anim.nframes * (1-direction))
		if curanimpos == 2: # hang
			self.state = constants.STATE_HANG_LEFT + direction
			self.move(0,8)
		elif curanimpos == 3 or curanimpos == 5:
			return
		elif curanimpos == 4: # move down 2 chars
			self.move(0,16)
		else:
			self.move(0,8)
		return

	def entity_fall(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		self.anim_wait = self.anim_wait + 1

		if self.enemy_type == 'OBJECT_ENEMY_ROCK':
			self.check_rock_kills_entity()
		elif self.enemy_type == 0: # only the player can hang!
			canhang, delta = self.entity_canhang(direction)
			if canhang:
				self.state = constants.STATE_GRAB_LEFT + direction
				self.current_anim = self.sp_grab
				self.anim_pos = self.current_anim.nframes * (1-direction)
				self.posy = (self.posy & 240) + delta
				self.anim_wait = 0

		return

	def entity_finishfall(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right

		if self.enemy_type == 'OBJECT_ENEMY_ROCK':
			self.state = constants.STATE_DYING_LEFT
			self.current_anim = self.sp_die
			self.anim_pos = 0
			self.anim_wait = 0	
			self.map.objects[self.objid*2] = 1
			return
		if self.anim_wait >= 3: # if we have fallen for more than two frames, crouch
			self.state = constants.STATE_CROUCH_LEFT + direction
			self.current_anim = self.sp_crouch
			self.anim_pos = self.current_anim.nframes * (1-direction)		
			# Falling from a high area means damage. Falling for more than 8 frames means death
			if self.anim_wait > 8:
				self.energy = 0
				print "Falling from too high! -> Die!!"
			elif self.anim_wait > 5:
				print "Falling from high, reducing energy in "+str(self.anim_wait - 5)
				self.energy = self.energy - self.anim_wait + 5
			if self.energy <= 0 and self.state != constants.STATE_DYING_LEFT and self.state != constants.STATE_DYING_RIGHT and self.state != constants.STATE_DEAD: # should now die
				direction = self.state & 1	# 0 is left, 1 is right		
				self.state = constants.STATE_DYING_LEFT + direction
				self.current_anim = self.sp_die
				self.anim_pos = self.current_anim.nframes * (1-direction)	
				self.anim_wait = 0
				self.map.objects[self.objid*2] = 1

			self.anim_wait = 0
		else:
			self.entity_setidle(direction)			
		return

	def entity_crouch(self,keyboard):
		if self.anim_wait == 0:
			self.anim_wait = self.anim_wait + 1
			self.anim_pos = self.anim_pos + 1
		elif self.anim_wait == 1:
			if keyboard[3] == 1: # DOWN
				return
			else: # down released, stand up
				self.anim_wait = self.anim_wait + 1
				self.anim_pos = self.anim_pos + 1
		else: #stand up
			direction = self.state & 1	# 0 is left, 1 is right		
			self.entity_setidle(direction)
		return

	def entity_teleport(self,keyboard):
		self.anim_wait = self.anim_wait + 1
		self.anim_pos = self.anim_pos + 1
		return		
	
	def entity_teleport_2(self,keyboard):
		self.anim_wait = self.anim_wait + 1
		self.anim_pos = self.anim_pos - 1
		return

	def entity_turn(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if direction == 0: # looking left
			if keyboard[0] == 1: # LEFT
				self.state = constants.STATE_WALK_LEFT
				self.current_anim = self.sp_walk
				self.anim_pos = self.current_anim.nframes
			else:
				self.state = constants.STATE_IDLE_LEFT + direction
				self.current_anim = self.sp_idle
				self.anim_pos = self.current_anim.nframes * (1-direction)
		else: # looking right:
			if keyboard[1] == 1: # RIGHT
				self.state = constants.STATE_WALK_RIGHT
				self.current_anim = self.sp_walk
				self.anim_pos = 0
			else:
				self.state = constants.STATE_IDLE_LEFT + direction
				self.current_anim = self.sp_idle
				self.anim_pos = self.current_anim.nframes * (1-direction)
		return

	def entity_switch(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if direction == 0:
			deltax = -16
		else: 
			deltax = 16
		if self.anim_wait == 3:
			self.entity_setidle(direction)

		if self.anim_wait == 0:
			self.anim_pos = self.anim_pos + 1
		elif self.anim_wait == 1:
			self.anim_pos = self.anim_pos - 1
			deltax = -deltax
		else: # 2
			self.current_anim = self.sp_walk
			self.anim_pos = self.current_anim.nframes * (1-direction)	
			deltax = 0	

		self.anim_wait = self.anim_wait + 1
		self.move(deltax,0,force=True)


		return

	def entity_hang(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if keyboard[2] == 1:	# UP
			self.state = constants.STATE_CLIMB_LEFT + direction
			self.anim_pos = self.anim_pos + 1	
		elif keyboard[3] == 1: # down
			self.state = constants.STATE_IDLE_LEFT + direction
			self.current_anim = self.sp_idle
			self.anim_pos = self.current_anim.nframes * (1-direction)
		return

	def entity_climb(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		self.anim_pos = self.anim_pos + 1
		curanimpos = self.anim_pos - (self.current_anim.nframes * (1-direction))
		if curanimpos == 4:
			self.move(0,-8)
		elif curanimpos == 5:
			self.move(0,-16)
		elif curanimpos == 6:
			self.move(0,0)
		elif curanimpos == 7:
			self.move(0,-8)
		else:  # curanimpos == 8
			self.entity_setidle(direction)			
		return

	def entity_brake(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if direction == 0:		# -1 to move left, 1 to move right
			deltax = -1
		else:
			deltax = 1

		self.anim_wait = self.anim_wait + 1
		if self.anim_wait == 3:
			self.entity_setidle(direction)
		else:
			self.move(8*deltax,0)		
		return

	def entity_brake_turn(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if direction == 0:		# -1 to move left, 1 to move right
			deltax = -1
		else:
			deltax = 1

		self.anim_wait = self.anim_wait + 1
		if self.anim_wait == 4:
			self.state = constants.STATE_RUN_LEFT + (1-direction)
			self.current_anim = self.sp_run
			self.anim_pos = self.current_anim.nframes * (direction)
		else:
			if self.anim_wait == 3:
				self.anim_pos = self.anim_pos + 1
			self.move(8*deltax,0)	
		return

	def entity_longjump(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right

		if direction == 0:		# -1 to move left, 1 to move right
			deltax = -1
		else:
			deltax = 1

		self.anim_wait = self.anim_wait + 1
		if self.anim_wait == 1:
			self.anim_pos = self.anim_pos + 1
			if self.move(8*deltax,-8,checkstair=False) == False:
				self.entity_setidle(direction)
				print "Jump fail 1"
		elif self.anim_wait == 2:
			self.anim_pos = self.anim_pos + 1
			if self.move(16*deltax,-8,checkstair=False) == False:
				# If we cannot move 16 pixels, maybe we can move 8 :)
				print "Jump fail 2.1"
				if self.move(8*deltax,-8,checkstair=False) == False:
					self.entity_setidle(direction)
					print "Jump fail 2.2"
		elif self.anim_wait == 3:
			self.anim_pos = self.anim_pos + 1
			if self.move(8*deltax,0,checkstair=False) == False:
				self.entity_setidle(direction)
				print "Jump fail 3"
		elif self.anim_wait == 4:
			if self.move(8*deltax,0,checkstair=False) == False:
				self.entity_setidle(direction)
				print "Jump fail 4"
		elif self.anim_wait == 5:
			self.anim_pos = self.anim_pos + 1
			if self.move(16*deltax,8,checkstair=False) == False:
				self.entity_setidle(direction)
				print "Jump fail 5.1"
				if self.move(8*deltax,8,checkstair=False) == False:
					self.entity_setidle(direction)
					print "Jump fail 5.2"
		elif self.anim_wait == 6:
			if direction == 0: # looking left
				self.anim_pos = self.current_anim.nframes
			else: # right
				self.anim_pos = 0
			if self.move(8*deltax,8,checkstair=False) == False:
				self.entity_setidle(direction)
				print "Jump fail 6"
			if self.WhereDidILand(direction):
				self.move(0,-8)
		else:
			self.state = constants.STATE_RUN_LEFT + direction
			self.current_anim = self.sp_run
			self.anim_pos = self.current_anim.nframes * (1-direction)
		return

	def entity_ouch(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right		
		self.anim_wait = self.anim_wait + 1
		if self.anim_wait == 2:
			if self.energy > 0:
				self.entity_setidle(direction)
			else: # the entity is dying
				self.state = constants.STATE_DYING_LEFT + direction
				self.current_anim = self.sp_die
				self.anim_pos = self.current_anim.nframes * (1-direction)	
				self.anim_wait = 0	
				self.map.objects[self.objid*2] = 1
		else:	
			if direction == 0: #looking left, so go right
				self.move(8,0)
			else:
				self.move(-8,0)		
		return

	def entity_unsheathe(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right		
		self.state = constants.STATE_IDLE_SWORD_LEFT + direction
		self.current_anim = self.sp_idle_sword
		self.anim_pos = self.current_anim.nframes * (1-direction)
		return

	def entity_sheathe(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right		
		self.entity_setidle(direction)
		return

	def entity_idle_sword(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if keyboard[5] == 1:	# Action pressed, sheathe sword
			self.state = constants.STATE_SHEATHE_LEFT + direction
			self.current_anim = self.sp_unsheathe
			self.anim_pos = self.current_anim.nframes * (1-direction)
			return
		if keyboard[4] == 1:	# Fire pressed, Now check combinations of fire + direction
			if keyboard[2] == 1: # UP
				if self.last_move != constants.STATE_SWORD_HIGHSLASH_LEFT:
					self.last_move = constants.STATE_SWORD_HIGHSLASH_LEFT
					self.state = constants.STATE_SWORD_HIGHSLASH_LEFT + direction
					self.current_anim = self.sp_high_sword
					self.anim_pos = self.current_anim.nframes * (1-direction)
					self.anim_wait = 0
				return		
			if keyboard[3] == 1: # DOWN
				if self.last_move != constants.STATE_SWORD_LOWSLASH_LEFT:
					self.last_move = constants.STATE_SWORD_LOWSLASH_LEFT
					self.state = constants.STATE_SWORD_LOWSLASH_LEFT + direction
					self.current_anim = self.sp_low_sword
					self.anim_pos = self.current_anim.nframes * (1-direction)
					self.anim_wait = 0
				return
			if keyboard[0] == 1: # LEFT
				if direction == 0: # forward slash
					if self.last_move != constants.STATE_SWORD_MEDSLASH_LEFT:
						self.last_move = constants.STATE_SWORD_MEDSLASH_LEFT
						self.state = constants.STATE_SWORD_MEDSLASH_LEFT + direction
						self.current_anim = self.sp_forw_sword
						self.anim_pos = self.current_anim.nframes * (1-direction)
						self.anim_wait = 0
					return	
				else: # back slash
					if self.last_move != constants.STATE_SWORD_BACKSLASH_LEFT:
						self.last_move = constants.STATE_SWORD_BACKSLASH_LEFT
						self.state = constants.STATE_SWORD_BACKSLASH_LEFT + direction
						self.current_anim = self.sp_back_sword
						self.anim_pos = self.current_anim.nframes * (1-direction)
						self.anim_wait = 0
					return	
			if keyboard[1] == 1: # RIGHT
				if direction == 1: # forward slash
					if self.last_move != constants.STATE_SWORD_MEDSLASH_LEFT:
						self.last_move = constants.STATE_SWORD_MEDSLASH_LEFT
						self.state = constants.STATE_SWORD_MEDSLASH_LEFT + direction
						self.current_anim = self.sp_forw_sword
						self.anim_pos = self.current_anim.nframes * (1-direction)
						self.anim_wait = 0
					return	
				else: # back slash
					if self.last_move != constants.STATE_SWORD_BACKSLASH_LEFT:
						self.last_move = constants.STATE_SWORD_BACKSLASH_LEFT
						self.state = constants.STATE_SWORD_BACKSLASH_LEFT + direction
						self.current_anim = self.sp_back_sword
						self.anim_pos = self.current_anim.nframes * (1-direction)
						self.anim_wait = 0
					return	
		if keyboard[0] == 1 or keyboard[1] == 1: # LEFT / RIGHT
			self.last_move = constants.STATE_WALK_SWORD_LEFT
			self.state = constants.STATE_WALK_SWORD_LEFT + direction
			self.current_anim = self.sp_idle_sword
			self.anim_pos = self.current_anim.nframes * (1-direction)
			self.anim_wait = 0
			return
		if keyboard[2] == 1: # UP, block
			if self.last_move != constants.STATE_SWORD_BLOCK_LEFT:
				self.last_move = constants.STATE_SWORD_BLOCK_LEFT
				self.state = constants.STATE_SWORD_BLOCK_LEFT + direction
				self.current_anim = self.sp_block_sword
				self.anim_pos = self.current_anim.nframes * (1-direction)
				self.anim_wait = 0
			return
		self.last_move = 0
		return

	def entity_walk_sword(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		if keyboard[5] == 1:	# Action pressed, sheathe sword
			self.state = constants.STATE_SHEATHE_LEFT + direction
			self.current_anim = self.sp_unsheathe
			self.anim_pos = self.current_anim.nframes * (1-direction)
			return
		if keyboard[4] == 1:	# Fire pressed, Now check combinations of fire + direction
			if keyboard[2] == 1: # UP
				if self.last_move != constants.STATE_SWORD_HIGHSLASH_LEFT:
					self.last_move = constants.STATE_SWORD_HIGHSLASH_LEFT
					self.state = constants.STATE_SWORD_HIGHSLASH_LEFT + direction
					self.current_anim = self.sp_high_sword
					self.anim_pos = self.current_anim.nframes * (1-direction)
					self.anim_wait = 0
				return		
			if keyboard[3] == 1: # DOWN
				if self.last_move != constants.STATE_SWORD_LOWSLASH_LEFT:
					self.last_move = constants.STATE_SWORD_LOWSLASH_LEFT
					self.state = constants.STATE_SWORD_LOWSLASH_LEFT + direction
					self.current_anim = self.sp_low_sword
					self.anim_pos = self.current_anim.nframes * (1-direction)
					self.anim_wait = 0
				return
			if keyboard[0] == 1: # LEFT
				if direction == 0: # forward slash
					if self.last_move != constants.STATE_SWORD_MEDSLASH_LEFT:
						self.last_move = constants.STATE_SWORD_MEDSLASH_LEFT
						self.state = constants.STATE_SWORD_MEDSLASH_LEFT + direction
						self.current_anim = self.sp_forw_sword
						self.anim_pos = self.current_anim.nframes * (1-direction)
						self.anim_wait = 0
					return	
				else: # back slash
					if self.last_move != constants.STATE_SWORD_BACKSLASH_LEFT:
						self.last_move = constants.STATE_SWORD_BACKSLASH_LEFT
						self.state = constants.STATE_SWORD_BACKSLASH_LEFT + direction
						self.current_anim = self.sp_back_sword
						self.anim_pos = self.current_anim.nframes * (1-direction)
						self.anim_wait = 0
					return	
			if keyboard[1] == 1: # RIGHT
				if direction == 1: # forward slash
					if self.last_move != constants.STATE_SWORD_MEDSLASH_LEFT:
						self.last_move = constants.STATE_SWORD_MEDSLASH_LEFT
						self.state = constants.STATE_SWORD_MEDSLASH_LEFT + direction
						self.current_anim = self.sp_forw_sword
						self.anim_pos = self.current_anim.nframes * (1-direction)
						self.anim_wait = 0
					return	
				else: # back slash
					if self.last_move != constants.STATE_SWORD_BACKSLASH_LEFT:
						self.last_move = constants.STATE_SWORD_BACKSLASH_LEFT
						self.state = constants.STATE_SWORD_BACKSLASH_LEFT + direction
						self.current_anim = self.sp_back_sword
						self.anim_pos = self.current_anim.nframes * (1-direction)
						self.anim_wait = 0
					return	
		if keyboard[0] == 1: # LEFT 
			if direction == 0: # moving forward
				self.anim_wait = (self.anim_wait + 1) % 4
				if self.anim_wait == 0:
					self.current_anim = self.sp_idle_sword
					self.anim_pos = self.current_anim.nframes * (1-direction)
				else:
					self.current_anim = self.sp_walk_sword
					self.anim_pos = self.anim_wait - 1 + (self.current_anim.nframes * (1-direction))
					if self.anim_wait == 3:	
						if self.move(-8,0) == False:
							self.entity_setidle_sword(direction)
			else: # moving backwards
				if self.anim_wait > 0:
					self.anim_wait = self.anim_wait - 1
				else:
					self.anim_wait = 3
				if self.anim_wait == 0:
					self.current_anim = self.sp_idle_sword
					self.anim_pos = self.current_anim.nframes * (1-direction)
				else:
					self.current_anim = self.sp_walk_sword
					self.anim_pos = self.anim_wait - 1 + (self.current_anim.nframes * (1-direction))
					if self.anim_wait == 2:	
						if self.move(-8,0) == False:
							self.entity_setidle_sword(direction)
			return
		elif keyboard[1] == 1: # RIGHT 
			if direction == 1: # moving forward
				self.anim_wait = (self.anim_wait + 1) % 4
				if self.anim_wait == 0:
					self.current_anim = self.sp_idle_sword
					self.anim_pos = self.current_anim.nframes * (1-direction)
				else:
					self.current_anim = self.sp_walk_sword
					self.anim_pos = self.anim_wait - 1 + (self.current_anim.nframes * (1-direction))
					if self.anim_wait == 3:	
						if self.move(8,0) == False:
							self.entity_setidle_sword(direction)
			else: # moving backwards
				if self.anim_wait > 0:
					self.anim_wait = self.anim_wait - 1
				else:
					self.anim_wait = 3
				if self.anim_wait == 0:
					self.current_anim = self.sp_idle_sword
					self.anim_pos = self.current_anim.nframes * (1-direction)
				else:
					self.current_anim = self.sp_walk_sword
					self.anim_pos = self.anim_wait - 1 + (self.current_anim.nframes * (1-direction))
					if self.anim_wait == 2:	
						if self.move(8,0) == False:
							self.entity_setidle_sword(direction)
			return
		else: # continue animation
			self.entity_setidle_sword(direction)
			return


	def entity_swordhigh(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		self.anim_wait = self.anim_wait + 1
		if self.anim_wait == 1:
			return
		elif self.anim_wait == 2:
			self.anim_pos = self.anim_pos + 1
			self.extra_sprite = self.current_anim.frames[self.anim_pos + 1]
			# Now check if we hit something
			self.slashchecks(direction)
		elif self.anim_wait == 3:
			self.extra_sprite = None
			self.anim_pos = self.anim_pos + 2
		elif self.anim_wait == 4:
			# check for a combo only if doing a forward slash
			if self.state == constants.STATE_SWORD_MEDSLASH_LEFT or self.state == constants.STATE_SWORD_MEDSLASH_RIGHT:
				if direction == 0: # left
					if keyboard[1] == 1: # RIGHT, so combo
						return
					else:
						self.entity_setidle_sword(direction)
				else:				
					if keyboard[0] == 1: # LEFT, so combo
						return
					else:
						self.entity_setidle_sword(direction)
			else:
				self.entity_setidle_sword(direction)
		elif self.anim_wait == 5:
			return
		elif self.anim_wait == 6:
			self.anim_pos = self.anim_pos - 2
			self.extra_sprite = self.current_anim.frames[self.anim_pos + 1]			
			if direction == 0: # left
				self.move(-8,0)
			else:
				self.move(8,0)
			# Now check if we hit something
			self.slashchecks(direction)

		else:	
			self.extra_sprite = None
			self.entity_setidle_sword(direction)
		return



	def entity_swordlow(self,keyboard):
		self.entity_swordhigh(keyboard)
		return

	def entity_swordmed(self,keyboard):
		self.entity_swordhigh(keyboard)
		return

	def entity_swordback(self,keyboard):
		self.entity_swordhigh(keyboard)
		return

	def entity_swordblock(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right
		self.anim_wait = self.anim_wait + 1
		if self.anim_wait == 6:
			self.entity_setidle_sword(direction)
		return

	def entity_swordouch(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right		
		self.anim_wait = self.anim_wait + 1
		if self.anim_wait == 2:
			if self.energy > 0:
				self.entity_setidle_sword(direction)
			else: # the entity is dying
				self.state = constants.STATE_DYING_LEFT + direction
				self.current_anim = self.sp_die
				self.anim_pos = self.current_anim.nframes * (1-direction)	
				self.anim_wait = 0	
				self.map.objects[self.objid*2] = 1
		else:	
			if direction == 0: #looking left, so go right
				self.move(8,0)
			else:
				self.move(-8,0)		
		return

	def entity_die(self,keyboard):
		if self.anim_wait < 3:
			self.anim_pos = self.anim_pos + 1
			self.anim_wait = self.anim_wait + 1
		else:
			self.state = constants.STATE_DEAD
			if self.player == False:
				self.increase_player_exp()
		return
	
	def entity_nothing(self,keyboard):
		return

	def entity_setidle(self,direction):
		self.state = constants.STATE_IDLE_LEFT + direction
		self.current_anim = self.sp_idle
		self.anim_pos = self.current_anim.nframes * (1-direction)
		return

	def entity_setidle_sword(self,direction):
		self.state = constants.STATE_IDLE_SWORD_LEFT + direction
		self.current_anim = self.sp_idle_sword
		self.anim_pos = self.current_anim.nframes * (1-direction)
		return	

	def check_break_object(self,stilex,stiley):
		for entity in [self.game_entities[3],self.game_entities[4],self.game_entities[5],self.game_entities[6],self.game_entities[7]]:
			if entity:
				#print stilex, stiley, entity.posx/16, entity.posy/16
				if entity.posx / 16 == stilex and entity.posy / 16 == stiley: # we got it
					entity.energy = 0
					entity.map.objects[entity.objid*2] = 1 # entity is missing now
					return

	def entity_grab(self,keyboard):
		direction = self.state & 1	# 0 is left, 1 is right		
		self.state = constants.STATE_HANG_LEFT + direction
		self.current_anim = self.sp_jump_up
		self.anim_pos = self.current_anim.nframes * (1-direction) + 2
		self.anim_wait = 0
		if direction == 0:
			self.posx = self.posx - 8
		else:
			self.posx = self.posx + 8
		return


	def entity_rock(self,keyboard):
		self.anim_pos = self.anim_pos+1	
		if self.anim_pos == self.current_anim.nframes * 2:
			self.anim_pos = self.current_anim.nframes
		elif self.anim_pos == self.current_anim.nframes:
			self.anim_pos = 0

		if keyboard[0] == 1: # LEFT
			if self.move(-8,0) == False:
				self.state = constants.STATE_DYING_LEFT
				self.current_anim = self.sp_die
				self.anim_pos = 0
				self.anim_wait = 0	
				self.map.objects[self.objid*2] = 1
				return
		elif keyboard[1] == 1: # RIGHT
			if self.move(8,0) == False:
				self.state = constants.STATE_DYING_LEFT
				self.current_anim = self.sp_die
				self.anim_pos = 0
				self.anim_wait = 0	
				self.map.objects[self.objid*2] = 1
				return

		self.check_rock_kills_entity()
		return

	def entity_door(self,keyboard):
		self.anim_wait = self.anim_wait + 1
		if self.anim_wait == 4:
			direction = self.state & 1	# 0 is left, 1 is right		
			self.entity_setidle(direction)
		return


	# Return animation depending on primary entity animation
	def primary_animation(self,entity):
		if entity.current_anim == entity.sp_idle:
			return self.sp_idle
		elif entity.current_anim == entity.sp_turn:
			return self.sp_turn
		elif entity.current_anim == entity.sp_walk:
			return self.sp_walk
		elif entity.current_anim == entity.sp_fall:
			return self.sp_fall
		elif entity.current_anim == entity.sp_crouch:
			return self.sp_crouch
		elif entity.current_anim == entity.sp_unsheathe:
			return self.sp_unsheathe
		elif entity.current_anim == entity.sp_idle_sword:
			return self.sp_idle_sword
		elif entity.current_anim == entity.sp_walk_sword:
			return self.sp_walk_sword
		elif entity.current_anim == entity.sp_high_sword:
			return self.sp_high_sword
		elif entity.current_anim == entity.sp_forw_sword:
			return self.sp_forw_sword
		elif entity.current_anim == entity.sp_combo1_sword:
			return self.sp_combo1_sword
		elif entity.current_anim == entity.sp_low_sword:
			return self.sp_low_sword
		elif entity.current_anim == entity.sp_back_sword:
			return self.sp_back_sword
		elif entity.current_anim == entity.sp_block_sword:
			return self.sp_block_sword
		elif entity.current_anim == entity.sp_ouch_sword:
			return self.sp_ouch_sword
		elif entity.current_anim == entity.sp_die:
			return self.sp_die

	# A secondary entity will always mimic what the primary is doing
	def entity_secondary(self,keyboard):
		entity = self.game_entities[1]
		if entity:
			self.posx = entity.posx
			self.posy = entity.posy-32
		  	self.current_anim = self.primary_animation(entity)
		  	self.anim_pos = entity.anim_pos
			if entity.extra_sprite:
				self.extra_sprite = self.current_anim.frames[self.anim_pos + 1]
			else:
				self.extra_sprite = None
			direction = entity.state & 1	# 0 is left, 1 is right
			if direction == 0:
				self.state = constants.STATE_SECONDARY_LEFT
			else:
				self.state = constants.STATE_SECONDARY_RIGHT
		return


	def check_rock_kills_entity(self):
		# check if we are touching any entity. If so, kill it!!!!
		currentRect = pygame.Rect(self.posx,self.posy,self.current_anim.sizex, self.current_anim.sizey)
		for entity in (self.game_entities[0],self.game_entities[1],self.game_entities[2]):
			if entity and entity != self:
				otherRect = pygame.Rect(entity.posx,entity.posy,entity.current_anim.sizex, entity.current_anim.sizey)
				if currentRect.colliderect(otherRect):
					if entity.state != constants.STATE_DYING_LEFT and entity.state != constants.STATE_DYING_RIGHT and entity.state != constants.STATE_DEAD:
						direction = entity.state & 1	# 0 is left, 1 is right
						entity.state = constants.STATE_DYING_LEFT + direction
						entity.current_anim = entity.sp_die
						entity.anim_pos = entity.current_anim.nframes * (1-direction)	
						entity.anim_wait = 0	
						entity.map.objects[entity.objid*2] = 1
						entity.energy = 0
		return


	def slashchecks(self,direction):
		'''
		Do checks related to a sword slash
		OUTPUT: True if no issues, false if we should hide the extra sprite
		'''
		# Check if hitting background
		hitting, stilex, stiley = self.slash_hits_bkg(direction)
		if hitting:
			# are we hitting a breakable object?
			self.check_break_object(stilex,stiley)
		else: # not hitting background or object, check if hitting an enemy
			entity = self.check_slash_hits_entity(direction)
			if entity: #someone was really hit
				if entity.state == constants.STATE_SWORD_BLOCK_LEFT or entity.state == constants.STATE_SWORD_BLOCK_RIGHT: # the other entity is blocking, so _we_ should be ouching
					self.extra_sprite=None
					self.state = constants.STATE_SWORD_OUCH_LEFT + direction
					self.current_anim = self.sp_ouch_sword 
					self.anim_pos = self.current_anim.nframes * (1-direction)
					self.anim_wait = 0
				else:
					newdirection = (self.state & 1) ^ 1
					if entity.energy > 0:
						entity.energy = entity.energy - self.get_entity_attack_damage(entity)
						if entity.energy < 0:
							entity.energy = 0
						entity.extra_sprite=None
						entity.current_anim = entity.sp_ouch_sword 
						entity.anim_pos = entity.current_anim.nframes * (1-newdirection)
						entity.anim_wait = 0
						if entity.state >= constants.STATE_IDLE_SWORD_LEFT: # the other entity is using its sword
							entity.state = constants.STATE_SWORD_OUCH_LEFT + newdirection
						else:
							entity.state = constants.STATE_OUCH_LEFT + newdirection
		return True

	def check_slash_hits_entity(self,direction):
		'''
		Check if the entity slash is hitting either the player or an enemy
		OUTPUT: None if no entity is hit, the pointer to the entity if it is hit
		'''		
		if direction == 0: # looking left
			currentRect = pygame.Rect(self.posx-24,self.posy,self.current_anim.sizex, self.current_anim.sizey)
		else: # looking right
			currentRect = pygame.Rect(self.posx+24,self.posy,self.current_anim.sizex, self.current_anim.sizey)

		for entity in (self.game_entities[0],self.game_entities[1],self.game_entities[2]):
			if entity:
				if entity.state not in [constants.STATE_TELEPORT_PHASE1_LEFT, constants.STATE_TELEPORT_PHASE1_RIGHT, constants.STATE_TELEPORT_PHASE2_LEFT, constants.STATE_TELEPORT_PHASE2_RIGHT]:
					otherRect = pygame.Rect(entity.posx,entity.posy,entity.current_anim.sizex, entity.current_anim.sizey)
					if currentRect.colliderect(otherRect):
						if entity.energy > 0:
							return entity
		return None								


	def slash_hits_bkg(self,direction):
		'''
		Check if we are hitting the background
		OUTPUT: 
			- If hitting: True, X stilecoord, Y stilecoord
			- If not: False, 0, 0
		'''
		if direction == 0: # looking left
			if self.posx < 16:
				return False, 0, 0
			value = self.map.GetHardness((self.posx-8)/16,self.posy/16)
			if value != 0:
				return True, (self.posx-8)/16, self.posy/16

			value = self.map.GetHardness((self.posx-8)/16,self.posy/16+1)
			if value != 0:
				return True, (self.posx-8)/16, self.posy/16+1

			value = self.map.GetHardness((self.posx-24)/16,self.posy/16)
			if value != 0:
				return True, (self.posx-24)/16, self.posy/16

			value = self.map.GetHardness((self.posx-24)/16,self.posy/16+1)
			if value != 0:
				return True, (self.posx-24)/16, self.posy/16+1	
			else:
				return False, 0, 0
		else: #looking right
			if self.posx > 216:
				return False, 0, 0
			value = self.map.GetHardness((self.posx+24)/16,self.posy/16)
			if value != 0:
				return True, (self.posx+24)/16, self.posy/16

			value = self.map.GetHardness((self.posx+24)/16,self.posy/16+1)
			if value != 0:
				return True, (self.posx+24)/16, self.posy/16+1

			value = self.map.GetHardness((self.posx+40)/16,self.posy/16)
			if value != 0:
				return True, (self.posx+40)/16, self.posy/16

			value = self.map.GetHardness((self.posx+40)/16,self.posy/16+1)
			if value != 0:
				return True, (self.posx+40)/16, self.posy/16+1	
			else:
				return False, 0, 0			
			

	def entity_canmovehor(self, deltax, deltay):
		'''
		Check if entity can move left or right
		OUTPUT: 
			- reason:0 it can move, 
				 1: Hit something
				 2: Going to the screen on the left
				 3: Going to the screen on the right
				 4: Going to the screen above
				 5: Going to the screen below
			- stairy: to specify if it is necessary to go up/down a stair
		'''
		direction = self.state & 1	# 0 is left, 1 is right
		if direction == 1:
			adjustx = 16
		else:
			adjustx = 0

		if self.posx + deltax < 0: # going left
			return 2, 0 
		elif self.posx + deltax > 232: # going right
			print "Change screen right, posx is ",self.posx," and deltax is ",deltax
			return 3, 0

		posx = self.posx+deltax
		posy = self.posy+deltay

		hardness = self.map.thisscreen.dureza[posy/16][(posx+adjustx)/16]

		#print "posx: "+str(posx)+" posy: "+str(posy)+" adjustx: "+str(adjustx)+" hardness: "+str(hardness)

		if hardness != 0:	# hitting something with the head
			# But if the hardness is 2 and the player Y AND $0F is 8, it is actually going below some ceiling
			if hardness != 2 or ((posy & 15) != 8):
				return 1, 0
		#print "hardness2: "+str(self.map.thisscreen.dureza[posy/16+1][(posx+adjustx)/16])

		if self.map.thisscreen.dureza[posy/16+1][(posx+adjustx)/16] != 0:	# hitting something with the knee
			# if deltay != 0 
			if self.state == constants.STATE_JUMP_LEFT or self.state == constants.STATE_JUMP_RIGHT or self.state == constants.STATE_LONGJUMP_LEFT or self.state == constants.STATE_LONGJUMP_RIGHT:
				return 1, 0
		ycur = posy/8 + 4
		yleft = self.map.HighYBelow(posx,(posy+31))
		yright= self.map.HighYBelow((posx+16),(posy+31))

		#print ycur,yleft, yright

		ynew = min(yleft,yright)
		if ynew == ycur: # can move, no stair
			return 0, 0
		elif (ynew > ycur):
			if (ynew-ycur < 2): # can move, stair down
				return  0,8
			else: # can move, will fall
				return 0,0
		elif (ycur > ynew) and (ycur-ynew < 2): # can move, stair up
			return 0, -8
		else: # cannot move
			return 1,0
		
	def entity_canmovevert(self,deltay):
		'''
		Check if entity can move up or down
		OUTPUT: 
			- reason:0 it can move, 
				 1: Hit something
				 2: Going to the screen on the left
				 3: Going to the screen on the right
				 4: Going to the screen above
				 5: Going to the screen below
		'''
		if self.posy + deltay < 0: # going up
			return 4
		elif self.posy + deltay + self.current_anim.sizey/8 >= 160: # going down
			return 5
		return 0

	def entity_canhang (self,direction):
		'''
		Check if the entity can hang left or right
		OUTPUT: True, 0/8 if can hang, 0 if upper half, 8 if lower half
			False, 0 if cannot hang
		'''	
		if direction == 0: # looking left
			deltaadd = 8
			deltax = -8
		else: # looking right
			deltaadd =  -8
			deltax = 24
		value = self.map.GetHardness((self.posx+deltax)/16,self.posy/16)

		# print("Canhang value: %s" % value)

		if value == 0 or value == 1:	# cannot hang
			return False, 0
		elif value == 3: 
			half = 8
		else:
			half = 0

		# Just to make sure, lets check there is nothing just on top of that stile
		if self.posx < 16:
			return False, 0 # safety check, do not try below 0!
		if self.map.GetHardness((self.posx+deltax)/16,(self.posy-16)/16) != 0:
			return False, 0
		# and finally, lets check we cannot hang 1 char to the left/right 
		if self.map.GetHardness((self.posx+deltax+deltaadd)/16,(self.posy)/16) != 0:
			return False, 0
		else:
			return True, half
		



	def entity_canhang_up(self,x,y):
		'''
		Check if the entity can hang up
		OUTPUT:
			- 0: can do
			- 1: cannot
		'''	
		posx = self.posx+x
		posy = self.posy+y

		value = self.map.GetHardness(posx/16,posy/16)
		if value == 0 or value == 1:	# cannot hang
			return 1 # no way
		# second check: the stile *above* should be empty!
		posx = self.posx+x
		posy = self.posy+y-16
		if posy >= 0:
			if self.map.GetHardness(posx/16,posy/16) != 0:	# hitting something with the head
				return 1 # no way
		# third check: make sure we do not hit with the head half-way through the tile
		posx = self.posx+8
		posy = self.posy+y
		if self.map.GetHardness(posx/16,posy/16) != 0:	# hitting something with the head
			return 1 # no way
		else:

			return 0 # yes!




	
	def cango_down(self,direction):
		'''
		Check if the entity can move down
		Return: True if possible, False if not possible
		'''
		if direction == 0: #left
			deltax=16
			deltax2=0
		else:
			deltax=0
			deltax2=16

#		print self.posx, deltax, self.posy

		if self.map.GetHardness((self.posx+deltax)/16,(self.posy+32)/16) != 0:
			return False
		if self.map.GetHardness((self.posx+deltax2)/16,(self.posy+32)/16) != 2:
			return False
		if self.posy+48 >= 160:
			return True
		if self.map.GetHardness(self.posx/16,(self.posy+48)/16) != 0:
			return False
		if self.posy+64 >= 160:
			return True		
		if self.map.GetHardness(self.posx/16,(self.posy+64)/16) != 0:
			return False
		else:
			return True

	def WouldFall_IfMoved(self,direction,pixels):
		''' 
		Check if the entity would fall if it moved this number of pixels in this direction
		Returns True if it would fall, False if it would not
		'''
		if direction == 0:
			pixels = -pixels

		if self.posx+pixels < 0:
			return True
		elif self.posx+pixels > 224:
			return True

		ycur = self.posy/8 + 4
		yleft = self.map.HighYBelow(self.posx+pixels,(self.posy+31))
		yright= self.map.HighYBelow((self.posx+pixels+16),(self.posy+31))
		ynew = min(yleft,yright)
		if (ynew > ycur):
			if (ynew-ycur > 1):
				return True
			else:
				return False
		else:
			return False




	def WhereDidILand(self,direction):
		'''
		Check the landing position
		Returns True if clashing with the background, False if not
		'''
		if direction == 0: #left
			deltax = 0
		else:
			deltax = 16

		value = self.map.GetHardness((self.posx+deltax)/16,(self.posy+24)/16)

		if value == 0:
			return False
		elif value == 3: #this is the low one. We are clashing if Y AND 8 is 0
			if self.posy & 8:
				return False
			else:
				return True
		else: # his is the high one. We are clashing if Y AND 8 is 8
			if self.posy & 8:
				return True
			else:
				return False

	def move(self,deltax,deltay,checkstair=True,force=False):
		''' 
		Return True if a movement was possible, False if not
		'''
		if deltax != 0:
			# Here, we should check if the movement is possible.
			canmove, stairy = self.entity_canmovehor(deltax,deltay)
			if canmove == 0:  # Just move, then
				self.posx = self.posx + deltax
				if checkstair == True:
					self.posy = self.posy + deltay + stairy
				else:
					self.posy = self.posy + deltay
			elif canmove == 1: # hitting something
				if force == True:
					self.posx = self.posx + deltax
					if checkstair == True:
						self.posy = self.posy + deltay + stairy
					else:
						self.posy = self.posy + deltay
					return True					
				return False
			elif canmove == 2: # Going to the left
				if self.player == False: # not the player, so dont move
					return False
				else:
					if self.map.current_x == 0:
						return False # cannot go further to the left
					else:
						self.map.current_x = self.map.current_x - 1
						self.posx = 232
						self.map.set_screen(self.map.current_x,self.map.current_y,self.game_entities,self.scorearea)
						return True
			elif canmove == 3: # Going to the right
				if self.player == False: # not the player, so dont move				
					return False
				else:
					if self.map.current_x + 1 >= self.map.map.width:
						return False # cannot go further to the left
					else:
						self.map.current_x = self.map.current_x + 1
						self.posx = 0
						self.map.set_screen(self.map.current_x,self.map.current_y,self.game_entities,self.scorearea)
						return True
		elif deltay != 0:
			canmove = self.entity_canmovevert(deltay)
			if canmove == 0: # just move, then
				self.posy = self.posy + deltay
			elif canmove == 4: # going above
					if self.map.current_y  == 0:
						return False # cannot go further up
					else:
						if self.player == True: # only change screen if this is the player
							self.map.current_y = self.map.current_y - 1
							self.posy = 136
							self.map.set_screen(self.map.current_x,self.map.current_y,self.game_entities,self.scorearea)
							return True
						else: # kill the entity
							direction = self.state & 1	# 0 is left, 1 is right
							self.state = constants.STATE_DEAD
							self.current_anim = self.sp_die
							self.anim_pos = self.current_anim.nframes * (1-direction) + 3
							self.map.objects[self.objid*2] = 1
			elif canmove == 5: # going below
					if self.map.current_y + 1 >= self.map.map.height:
						return False # cannot go further down
					else:
						if self.player == True: # only change screen if this is the player
							self.map.current_y = self.map.current_y + 1
							self.posy = 0
							self.map.set_screen(self.map.current_x,self.map.current_y,self.game_entities,self.scorearea)
							return True
						else: # kill the entity
							print('Die die die!!!!!')
							direction = self.state & 1	# 0 is left, 1 is right
							self.state = constants.STATE_DEAD
							self.current_anim = self.sp_die
							self.anim_pos = self.current_anim.nframes * (1-direction) + 3
							self.map.objects[self.objid*2] = 1

			else:
				return False
		return True		

	def check_gravity(self):
		'''
		Check if gravity should affect to this entity
		Returns True if it should, False if it should not
		'''
		if self.enemy_type == 'OBJECT_ENEMY_SECONDARY':
			# This is a special case, since gravity is checked after scripts
			self.posy = self.game_entities[1].posy - 32
			return False
		ycur = self.posy/8 + 4
		yleft = self.map.HighYBelow(self.posx,(self.posy+31))
		yright= self.map.HighYBelow((self.posx+16),(self.posy+31))
		ynew = min(yleft,yright)
		if (ynew > ycur):
			return True
		else:
			return False

	def check_switch(self,direction):
		'''
		Check if a switch is next to the entity
		Returns True, objid if there is a switch, False, 0 if not
		'''
		if direction == 0: #left
			x = (self.posx-8) / 16
		else:
			x = (self.posx+24) / 16
		y = self.posy / 16
		
		# loop through objects
		for entity in [self.game_entities[3],self.game_entities[4],self.game_entities[5],self.game_entities[6],self.game_entities[7]]:
			if entity:
				if (entity.posx / 16 == x) and (entity.posy / 16 == y):
					if entity.object_type == "OBJECT_SWITCH":
						if constants.DEBUG:
							print "It is a switch!", entity.objid
						return True, entity.objid

		return False, 0


	def check_teleport(self,direction):
		'''
		Check if the entity is touching a teleporter
		Returns True if the entity is touching a teleporter, False if not
		'''

		for entity in [self.game_entities[3],self.game_entities[4],self.game_entities[5],self.game_entities[6],self.game_entities[7]]:
			if entity and entity.object_type == "OBJECT_TELEPORTER":
				playerRect = pygame.Rect(self.posx,self.posy,self.current_anim.sizex, self.current_anim.sizey)
				entityRect = pygame.Rect(entity.posx,entity.posy, 16, 16)
				if playerRect.colliderect(entityRect):
					return True
		return False

	def apply_gravity(self):
		'''
		Apply the effect of gravity to this entity
		'''
		if self.state == constants.STATE_JUMP_UP_LOOK_LEFT:
			return
		elif self.state == constants.STATE_JUMP_UP_LOOK_RIGHT:
			return
		elif self.state == constants.STATE_JUMP_LEFT:
			return
		elif self.state == constants.STATE_JUMP_RIGHT:
			return
		elif self.state == constants.STATE_LONGJUMP_LEFT:
			return
		elif self.state == constants.STATE_LONGJUMP_RIGHT:
			return
		elif self.state == constants.STATE_HANG_LEFT:
			return
		elif self.state == constants.STATE_HANG_RIGHT:
			return
		elif self.state == constants.STATE_GRAB_LEFT:
			return
		elif self.state == constants.STATE_GRAB_RIGHT:
			return		
		elif self.state == constants.STATE_CLIMB_LEFT:
			return
		elif self.state == constants.STATE_CLIMB_RIGHT:
			return
		elif self.state == constants.STATE_DOWN_LOOK_LEFT:
			return
		elif self.state == constants.STATE_DOWN_LOOK_RIGHT:
			return
		elif self.state == constants.STATE_DYING_LEFT:
			return
		elif self.state == constants.STATE_DYING_RIGHT:
			return

		if self.state == constants.STATE_FALLING_LOOK_LEFT or self.state == constants.STATE_FALLING_LOOK_RIGHT:
		# already falling
			for i in range (0,self.anim_wait/2+1):
				if self.check_gravity(): # continue falling
					self.move(0,8)
				else: # finish falling
					self.entity_finishfall([0,0,0,0,0,0])
					return
		elif self.state == constants.STATE_DEAD:
			if self.check_gravity():
				if self.posy <= 136:
					print ("Dead man falling")
					self.move(0,8)
		else:
			if self.check_gravity(): # will start falling now
				direction = self.state & 1	# 0 is left, 1 is right
				self.state = constants.STATE_FALLING_LOOK_LEFT + direction
				self.current_anim = self.sp_fall
				self.anim_pos = self.current_anim.nframes * (1-direction)
				self.anim_wait = 0
				self.extra_sprite = None # if we fall while hitting, just remove the extra sprite
				return

	def get_entity_attack_damage(self, receiving_entity):
		'''
		Get the attack damage for this entity
		Returns a number with the damage, in terms of: level, weapon and state of receiving entity
		'''
		if self.player == True:
			return self.damage_per_weapon[self.weapon-1] + self.level + 1
		else:
			damage = self.level + 1
			if receiving_entity.state < constants.STATE_UNSHEATHE_LEFT:
				damage = damage*2
			return damage

	def get_player_max_exp(self):
		'''
		Get max player experience for the current level
		'''
		return self.barbarian_level_exp[self.level]

	def get_entity_max_energy(self):
		'''
		Get max entity energy for the current level
		'''
		if self.player:
			return self.barbarian_energy[self.level]
		else:
			return self.enemy_energy[self.enemy_type][self.level]

	def increase_player_exp(self):
		'''
		Increase player experience while dying
		'''
		if self.enemy_type == "OBJECT_ENEMY_ROCK":
			return # do nothing
		
		player = self.game_entities[0]
		player.experience = player.experience + self.level + 1
		if player.experience >= player.get_player_max_exp():
			player.experience = 0
			player.level = player.level + 1
			player.energy = player.get_entity_max_energy()


	weapon_names  = { constants.WEAPON_SWORD: "espada",
			  constants.WEAPON_ECLIPSE: "eclipse",
			  constants.WEAPON_AXE: "hacha",
			  constants.WEAPON_BLADE: "blade",
			}			

	# Barbarian energy, per level
	barbarian_energy = [6, 10, 18, 32,  48,  64,  80,  99]

	# Experience required to reach the next level, per level
	barbarian_level_exp = [16, 64, 96, 128, 160, 192, 240, 255]

	# Attack damage per weapon
	damage_per_weapon = [0,1,2,4]

	# Enemy energy, per level
	enemy_energy = { "OBJECT_ENEMY_SKELETON": [2,  7,  14,  25,  35,  50, 65],
			 'OBJECT_ENEMY_ORC': [2,  7,  14,  25,  35,  50,  65],
			 'OBJECT_ENEMY_MUMMY': [2,  5,  10,  20,  35,  50,  70],
			 'OBJECT_ENEMY_TROLL': [5,  10,  20,  35,  45,  60,  80],
			 'OBJECT_ENEMY_ROCK': [255,  255,  255,  255,  255,  255,  255],
			 'OBJECT_ENEMY_KNIGHT': [7,  12,  20,  30,  45,  55,  70],
			 'OBJECT_ENEMY_GOLEM': [10,  20,  35,  50,  65,  80,  99],
			 'OBJECT_ENEMY_OGRE': [10,  20,  35,  50,  65,  80,  99],
			 'OBJECT_ENEMY_MINOTAUR': [10,  20,  35,  50,  65,  80,  99],
			 'OBJECT_ENEMY_DEMON': [10,  20,  35,  48,  60,  80,  99],
			 'OBJECT_ENEMY_DALGURAK': [99,  99,  99,  99,  99,  99, 1],
			}
	# Enemy probability of long-range attack, per level
	enemy_prob_longrange = {"OBJECT_ENEMY_SKELETON": [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_ORC': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_MUMMY': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_TROLL': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_ROCK': [0,  0,  0,  0,  0,  0,  0],
			 'OBJECT_ENEMY_KNIGHT': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_GOLEM': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_OGRE': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_MINOTAUR': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_DEMON': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_DALGURAK': [80,  80,  80, 80, 80, 80, 80],
			}
	# Enemy probability of short-range attack, per level
	enemy_prob_shortrange = {"OBJECT_ENEMY_SKELETON": [40,  75, 100, 140, 180, 215, 235],
			 'OBJECT_ENEMY_ORC': [40,  75, 100, 140, 180, 215, 235],
			 'OBJECT_ENEMY_MUMMY': [40,  75, 100, 140, 180, 215, 235],
			 'OBJECT_ENEMY_TROLL': [40,  75, 100, 140, 180, 215, 235],
			 'OBJECT_ENEMY_ROCK': [0,  0,  0,  0,  0,  0,  0],
			 'OBJECT_ENEMY_KNIGHT': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_GOLEM': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_OGRE': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_MINOTAUR': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_DEMON': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_DALGURAK': [40,  75, 100, 140, 180, 215, 235],
			}
	# Enemy probability of blocking, per level
	enemy_prob_block = {"OBJECT_ENEMY_SKELETON": [20,  40,  80, 100, 125, 150, 175],
			 'OBJECT_ENEMY_ORC': [20,  40,  80, 100, 125, 150, 175],
			 'OBJECT_ENEMY_MUMMY': [20,  40,  80, 100, 125, 150, 175],
			 'OBJECT_ENEMY_TROLL': [20,  40,  80, 100, 125, 150, 175],
			 'OBJECT_ENEMY_ROCK': [0,  0,  0,  0,  0,  0,  0],
			 'OBJECT_ENEMY_KNIGHT': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_GOLEM': [40,  80,  120, 160, 200, 220, 240],
			 'OBJECT_ENEMY_OGRE': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_MINOTAUR': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_DEMON': [20,  40,  80, 120, 160, 200, 220],
			 'OBJECT_ENEMY_DALGURAK': [20,  40,  80, 120, 160, 200, 220],
			}
	# Enemy attack patterns: far attack, short1, short2
	enemy_attack_patterns = {"OBJECT_ENEMY_SKELETON": [
			"ACTION_MOVE, 80, 1, ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 3, ACTION_MOVE, 17, 1, ACTION_WAIT, 20, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 18, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT"
			],

			"OBJECT_ENEMY_ORC": [
			"ACTION_MOVE, 64, 12, ACTION_MOVE, 17, 1, ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 144, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT"
			],

			"OBJECT_ENEMY_MUMMY": [
			"ACTION_MOVE, 80, 1, ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 17, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 18, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT"
			],

			"OBJECT_ENEMY_TROLL": [
			"ACTION_MOVE, 64, 8, ACTION_MOVE, 17, 1, ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 144, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT"
			],

			"OBJECT_ENEMY_ROCK": [
			"ACTION_MOVE, 80, 1,  ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1,  ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1,  ACTION_RETURN_SUBSCRIPT",
			],

			"OBJECT_ENEMY_KNIGHT": [
			"ACTION_MOVE, 64, 8,  ACTION_MOVE, 17, 1, ACTION_WAIT, 4, ACTION_MOVE, 128, 6,  ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1,  ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 5,  ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 18, 1,  ACTION_WAIT, 2, ACTION_RETURN_SUBSCRIPT",
			],

			"OBJECT_ENEMY_GOLEM": [
			"ACTION_MOVE, 64, 8, ACTION_MOVE, 17, 1, ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 144, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1, ACTION_WAIT, 6, ACTION_RETURN_SUBSCRIPT",
			],

			"OBJECT_ENEMY_OGRE": [
			"ACTION_MOVE, 80, 1,  ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 12,  ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1,  ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 17, 1,  ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT",
			],

			"OBJECT_ENEMY_MINOTAUR": [
			"ACTION_MOVE, 80, 1,  ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 12,  ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 17, 1,  ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1,  ACTION_WAIT, 10, ACTION_RETURN_SUBSCRIPT",
			],

			"OBJECT_ENEMY_DEMON": [
			"ACTION_MOVE, 64, 8, ACTION_MOVE, 17, 1, ACTION_WAIT, 2, ACTION_MOVE, 128, 5, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1,  ACTION_WAIT, 3, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1,  ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 12,  ACTION_RETURN_SUBSCRIPT",
			],

			"OBJECT_ENEMY_DALGURAK": [
			"ACTION_TELEPORT_ENEMY, 112, 64, ACTION_WAIT, 8, ACTION_MOVE, 8, 2, ACTION_WAIT, 2, ACTION_MOVE, 32, 1, ACTION_WAIT, 2, ACTION_MOVE, 17, 1, ACTION_MOVE_OBJECT, 105, 5, 0, 1, ACTION_MOVE_OBJECT, 105, 1, 1, 6, ACTION_MOVE_OBJECT, 105, -1, 0, 12, ACTION_MOVE_OBJECT, 105, 1, -1, 6, ACTION_MOVE_OBJECT, 105, -5, 0, 1, ACTION_CHANGE_STILE, 8, 2, 92, ACTION_TELEPORT_ENEMY, 16, 112, ACTION_WAIT, 8, ACTION_MOVE, 8, 2, ACTION_WAIT, 2, ACTION_MOVE, 32, 1, ACTION_RETURN_SUBSCRIPT",
			"ACTION_MOVE, 80, 1, ACTION_WAIT, 3, ACTION_MOVE, 144, 1, ACTION_WAIT, 3, ACTION_MOVE, 17, 1, ACTION_WAIT, 20, ACTION_RETURN_SUBSCRIPT",
			"ACTION_TELEPORT_ENEMY, 16, 112, ACTION_WAIT, 8, ACTION_MOVE, 8, 2, ACTION_WAIT, 2, ACTION_MOVE, 32, 1, ACTION_WAIT, 2, ACTION_MOVE, 17, 1, ACTION_MOVE_OBJECT, 105, 0, 5, 1, ACTION_MOVE_OBJECT, 105, 1, 0, 8,  ACTION_MOVE_OBJECT, 105, -1, 0, 9, ACTION_MOVE_OBJECT, 105, 1, -5, 1, ACTION_RETURN_SUBSCRIPT",
			],

			}

	entity_functions = { constants.STATE_IDLE_LEFT: 	entity_idle,
				constants.STATE_IDLE_RIGHT: 	entity_idle,
				constants.STATE_WALK_LEFT:	entity_walk,		
				constants.STATE_WALK_RIGHT:	entity_walk,
				constants.STATE_RUN_LEFT: 	entity_run,
				constants.STATE_RUN_RIGHT:	entity_run,
				constants.STATE_JUMP_UP_LOOK_LEFT:	entity_jump_up,
				constants.STATE_JUMP_UP_LOOK_RIGHT:	entity_jump_up,
				constants.STATE_JUMP_LEFT:	entity_shortjump,
				constants.STATE_JUMP_RIGHT:	entity_shortjump,
				constants.STATE_DOWN_LOOK_LEFT:	entity_movedown,
				constants.STATE_DOWN_LOOK_RIGHT:	entity_movedown,
				constants.STATE_FALLING_LOOK_LEFT:	entity_fall,
				constants.STATE_FALLING_LOOK_RIGHT:	entity_fall,
				constants.STATE_FINISHFALL_LOOK_LEFT:	entity_finishfall,
				constants.STATE_FINISHFALL_LOOK_RIGHT:	entity_finishfall,
				constants.STATE_CROUCH_LEFT:	entity_crouch,
				constants.STATE_CROUCH_RIGHT:	entity_crouch,
				constants.STATE_TURNING_LEFT:	entity_turn,
				constants.STATE_TURNING_RIGHT:	entity_turn,
				constants.STATE_SWITCH_LEFT:	entity_switch,
				constants.STATE_SWITCH_RIGHT:	entity_switch,
				constants.STATE_HANG_LEFT:	entity_hang,
				constants.STATE_HANG_RIGHT:	entity_hang,
				constants.STATE_CLIMB_LEFT:	entity_climb,
				constants.STATE_CLIMB_RIGHT:	entity_climb,
				constants.STATE_BRAKE_LEFT:	entity_brake,
				constants.STATE_BRAKE_RIGHT:	entity_brake,
				constants.STATE_BRAKE_TURN_LEFT:	entity_brake_turn,
				constants.STATE_BRAKE_TURN_RIGHT:	entity_brake_turn,
				constants.STATE_LONGJUMP_LEFT:	entity_longjump,
				constants.STATE_LONGJUMP_RIGHT:	entity_longjump,
				constants.STATE_OUCH_LEFT:	entity_ouch,
				constants.STATE_OUCH_RIGHT:	entity_ouch,
				constants.STATE_UNSHEATHE_LEFT:	entity_unsheathe,
				constants.STATE_UNSHEATHE_RIGHT:	entity_unsheathe,
				constants.STATE_SHEATHE_LEFT:	entity_sheathe,
				constants.STATE_SHEATHE_RIGHT:	entity_sheathe,
				constants.STATE_IDLE_SWORD_LEFT:	entity_idle_sword,
				constants.STATE_IDLE_SWORD_RIGHT:	entity_idle_sword,
				constants.STATE_WALK_SWORD_LEFT:	entity_walk_sword,
				constants.STATE_WALK_SWORD_RIGHT:	entity_walk_sword,
				constants.STATE_SWORD_HIGHSLASH_LEFT:	entity_swordhigh,
				constants.STATE_SWORD_HIGHSLASH_RIGHT:	entity_swordhigh,
				constants.STATE_SWORD_LOWSLASH_LEFT:	entity_swordlow,
				constants.STATE_SWORD_LOWSLASH_RIGHT:	entity_swordlow,
				constants.STATE_SWORD_MEDSLASH_LEFT:	entity_swordmed,
				constants.STATE_SWORD_MEDSLASH_RIGHT:	entity_swordmed,
				constants.STATE_SWORD_BACKSLASH_LEFT:	entity_swordback,
				constants.STATE_SWORD_BACKSLASH_RIGHT:	entity_swordback,
				constants.STATE_SWORD_BLOCK_LEFT:	entity_swordblock,
				constants.STATE_SWORD_BLOCK_RIGHT:	entity_swordblock,
				constants.STATE_SWORD_OUCH_LEFT:	entity_swordouch,
				constants.STATE_SWORD_OUCH_RIGHT:	entity_swordouch,
				constants.STATE_DYING_LEFT:		entity_die,
				constants.STATE_DYING_RIGHT:	entity_die,
				constants.STATE_GRAB_LEFT:		entity_grab,
				constants.STATE_GRAB_RIGHT:		entity_grab,
				constants.STATE_ROCK_LEFT:		entity_rock,
				constants.STATE_ROCK_RIGHT:		entity_rock,
				constants.STATE_SECONDARY_LEFT:	entity_secondary,
				constants.STATE_SECONDARY_RIGHT:entity_secondary,
				constants.STATE_DOOR_LEFT:		entity_door,
				constants.STATE_DOOR_RIGHT:		entity_door,
				constants.STATE_TELEPORT_PHASE1_LEFT:	entity_teleport,
				constants.STATE_TELEPORT_PHASE1_RIGHT: entity_teleport,
				constants.STATE_TELEPORT_PHASE2_LEFT:	entity_teleport_2,
				constants.STATE_TELEPORT_PHASE2_RIGHT: entity_teleport_2,
				constants.STATE_DEAD:			entity_nothing,
			}

"""
Object class
"""
class IannaObject(IannaEntity):
	def __init__ (self, currentmap, entity_array, scorearea):
		IannaEntity.__init__(self)
		self.object_type = None
		self.map = currentmap
		self.game_entities = entity_array	
		self.scorearea = scorearea

	def dump_entity(self):
		print "Entity state dump for "+str(self)
		print "Position: "+str(self.posx)+","+str(self.posy)
		if self.script:
			print ("Script: %s" % self.script.script)
		else:
			print ("Object is inactive, no script")
		print "Position in script: "+str(self.script_pos)
		print "Energy: "+str(self.energy)
		print "Object type: "+str(self.object_type)
		print "Objid: "+str(self.objid)
		print "-----------------------------------"
		print ""


	def object_switch_inactive(self):
		# now update supertiles in map
		y1 = self.posy / 16
		x1 = self.posx / 16
		tile1 =  self.map.thisscreen.screenmap[y1][x1]
		tile1 = tile1 + 2
		self.map.thisscreen.screenmap[y1][x1] = tile1
		tile2 = self.map.thisscreen.screenmap[y1+1][x1]
		tile2 = tile2 + 2
		self.map.thisscreen.screenmap[y1+1][x1] = tile2
		# As a last step, we should place the script offset accordingly. 
		# For switches, it will ALWAYS be 2, since their script must be: 
		# wait for condition, associated condition, turn switch, switch id
		self.script_pos=2


	def object_door_inactive(self):
		for step in range(0,3):
			y1 = self.posy / 16
			x1 = self.posx / 16		
			self.map.thisscreen.screenmap[y1+2-step][x1] = self.map.thisscreen.screenmap[y1+3-step][x1]
			self.map.thisscreen.screenmap[y1+3-step][x1] = 0
			self.map.SetHardness(x1,y1+3-step,0)
		# As a last step, we should place the script offset accordingly. 
		# For door, it will ALWAYS be 2, since their script must be: 
		# wait for condition, associated condition, open door, door id
		self.script_pos=2

	def object_box_right_inactive(self):
		y1 = self.posy / 16
		x1 = self.posx / 16	
		self.map.thisscreen.screenmap[y1][x1] = 0
		self.map.thisscreen.screenmap[y1+1][x1] = 0
		self.map.thisscreen.screenmap[y1][x1-1] = 0
		self.map.thisscreen.screenmap[y1+1][x1-1] = 0
		self.map.SetHardness(x1,y1,0)
		self.map.SetHardness(x1-1,y1,0)
		self.map.SetHardness(x1,y1+1,0)
		self.map.SetHardness(x1-1,y1+1,0)
		# Once a jar is destroyed, there is no point in running its script anymore
		self.script=None		
		self.script_pos=0


	def object_box_left_inactive(self):
		y1 = self.posy / 16
		x1 = self.posx / 16	
		self.map.thisscreen.screenmap[y1][x1] = 0
		self.map.thisscreen.screenmap[y1+1][x1] = 0
		self.map.thisscreen.screenmap[y1][x1+1] = 0
		self.map.thisscreen.screenmap[y1+1][x1+1] = 0
		self.map.SetHardness(x1,y1,0)
		self.map.SetHardness(x1+1,y1,0)
		self.map.SetHardness(x1,y1+1,0)
		self.map.SetHardness(x1+1,y1+1,0)
		# Once a jar is destroyed, there is no point in running its script anymore
		self.script=None		
		self.script_pos=0


	def object_wall_inactive(self):
		print "object_wall_inactive NOT IMPLEMENTED"

	def object_floor_inactive(self):
		print "object_floor_inactive NOT IMPLEMENTED"

	def object_teleporter_inactive(self):
		return

	def object_door_destroy_inactive(self):
		y1 = self.posy / 16
		x1 = self.posx / 16	
		self.map.thisscreen.screenmap[y1][x1] = 0
		self.map.thisscreen.screenmap[y1+1][x1] = 0
		self.map.thisscreen.screenmap[y1-1][x1] = 0
		self.map.SetHardness(x1,y1,0)
		self.map.SetHardness(x1,y1+1,0)
		self.map.SetHardness(x1,y1-1,0)
		# Once a door is destroyed, there is no point in running its script anymore
		self.script=None		
		self.script_pos=0
		return

	def object_jar_inactive(self):
		y1 = self.posy / 16
		x1 = self.posx / 16	
		self.map.thisscreen.screenmap[y1][x1] = 0
		self.map.SetHardness(x1,y1,0)
		# Once a jar is destroyed, there is no point in running its script anymore
		self.script=None		
		self.script_pos=0
		return

	inactive_object_functions = {
			'OBJECT_SWITCH':		object_switch_inactive,
			'OBJECT_DOOR':			object_door_inactive,
			'OBJECT_DOOR_DESTROY':		object_door_destroy_inactive,
			'OBJECT_WALL_DESTROY':		object_wall_inactive,
			'OBJECT_FLOOR_DESTROY':		object_floor_inactive,
			'OBJECT_BOX_LEFT':		object_box_left_inactive,
			'OBJECT_BOX_RIGHT':		object_box_right_inactive,
			'OBJECT_JAR':			object_jar_inactive,
			'OBJECT_TELEPORTER':		object_teleporter_inactive,    # Teleporters will always be active?
		}
