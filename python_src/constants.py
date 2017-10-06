# Debug

DEBUG = False
DEBUG_SCRIPT = False
LANGUAGE = 0		# 0: Spanish, 1: English

# State definitions

STATE_IDLE_LEFT		= 0
STATE_IDLE_RIGHT		= 1
STATE_WALK_LEFT		= 2
STATE_WALK_RIGHT		= 3
STATE_RUN_LEFT			= 4
STATE_RUN_RIGHT		= 5
STATE_JUMP_UP_LOOK_LEFT	= 6
STATE_JUMP_UP_LOOK_RIGHT	= 7
STATE_JUMP_LEFT		= 8
STATE_JUMP_RIGHT		= 9
STATE_DOWN_LOOK_LEFT		= 10
STATE_DOWN_LOOK_RIGHT		= 11
STATE_FALLING_LOOK_LEFT	= 12
STATE_FALLING_LOOK_RIGHT	= 13
STATE_FINISHFALL_LOOK_LEFT	= 14
STATE_FINISHFALL_LOOK_RIGHT	= 15
STATE_CROUCH_LEFT		= 16
STATE_CROUCH_RIGHT		= 17
STATE_TURNING_LEFT		= 18
STATE_TURNING_RIGHT		= 19
STATE_SWITCH_LEFT		= 20	
STATE_SWITCH_RIGHT		= 21
STATE_HANG_LEFT		= 22
STATE_HANG_RIGHT		= 23
STATE_CLIMB_LEFT		= 24
STATE_CLIMB_RIGHT		= 25
STATE_BRAKE_LEFT		= 26
STATE_BRAKE_RIGHT		= 27
STATE_BRAKE_TURN_LEFT		= 28
STATE_BRAKE_TURN_RIGHT		= 29
STATE_LONGJUMP_LEFT		= 30
STATE_LONGJUMP_RIGHT		= 31
STATE_OUCH_LEFT			= 32
STATE_OUCH_RIGHT		= 33
STATE_UNSHEATHE_LEFT		= 34
STATE_UNSHEATHE_RIGHT		= 35
STATE_SHEATHE_LEFT		= 36
STATE_SHEATHE_RIGHT		= 37
STATE_IDLE_SWORD_LEFT		= 38
STATE_IDLE_SWORD_RIGHT		= 39
STATE_WALK_SWORD_LEFT		= 40
STATE_WALK_SWORD_RIGHT		= 41
STATE_SWORD_HIGHSLASH_LEFT	= 42
STATE_SWORD_HIGHSLASH_RIGHT	= 43
STATE_SWORD_LOWSLASH_LEFT	= 44
STATE_SWORD_LOWSLASH_RIGHT	= 45
STATE_SWORD_MEDSLASH_LEFT	= 46
STATE_SWORD_MEDSLASH_RIGHT	= 47
STATE_SWORD_BACKSLASH_LEFT	= 48
STATE_SWORD_BACKSLASH_RIGHT	= 49
STATE_SWORD_BLOCK_LEFT		= 50
STATE_SWORD_BLOCK_RIGHT		= 51
STATE_SWORD_OUCH_LEFT		= 52
STATE_SWORD_OUCH_RIGHT		= 53
STATE_DYING_LEFT		= 54
STATE_DYING_RIGHT		= 55
STATE_GRAB_LEFT			= 56
STATE_GRAB_RIGHT		= 57
STATE_ROCK_LEFT			= 58
STATE_ROCK_RIGHT		= 59
STATE_SECONDARY_LEFT	= 60
STATE_SECONDARY_RIGHT	= 61
STATE_DOOR_LEFT		= 62
STATE_DOOR_RIGHT    = 63
STATE_TELEPORT_PHASE1_LEFT = 64
STATE_TELEPORT_PHASE1_RIGHT = 65
STATE_TELEPORT_PHASE2_LEFT = 64
STATE_TELEPORT_PHASE2_RIGHT = 65
STATE_DEAD			= 256 # Only useful for the Python version

# Action definitions

ACTION_NONE 		= 0	# do nothing, no parameters
ACTION_JOYSTICK 	= 1	# control position/animation with joystick, no parameters
ACTION_PLAYER 		= 2	# player control
ACTION_PATROL		= 3	# move left-right in the area, waiting until the player is in its view area. One parameter: flags
ACTION_FIGHT		= 4	# Fight. One parameter: flags
ACTION_DESTROY		= 5	# remove entity, no parameters
ACTION_STRING		= 6	# print a string in the notification area, useful for cutscenes. One parameter (db): string id
ACTION_WAIT		= 7	# do nothing for a number of game frames. One parameter (db): number of frames
ACTION_MOVE		= 8	# move for a number of game frames. Two parameter (db): direction, number of frames
ACTION_WAIT_SWITCH_ON	= 9	# wait for a switch to be changed from 0 to 1 or 2. One parameter (db): object id
ACTION_WAIT_DEAD	= 9	# wair for an enemy to be dead (its parameter is 1). One parameter (db): object id
ACTION_WAIT_DESTROYED	= 9	# wair for an object to be destroyed (its parameter is 1). One parameter (db): object id
ACTION_WAIT_SWITCH_OFF	= 10	# wait for a switch to be changed from 1/2 to 0. One parameter (db): object id
ACTION_TOGGLE_SWITCH_ON	= 11	# toggle a switch. It will change the switch from 1 to 2, and also update the tiles. One parameter (db): object id
ACTION_TOGGLE_SWITCH_OFF= 12	# toggle a switch. It will change the switch from 2 to 0, and also update the tiles. One parameter (db): object id
ACTION_OPEN_DOOR	= 13	# open a door. It will change the object value from 0 to 1, then to 2 when done, and update the tiles. One parameter (db): object id
ACTION_CLOSE_DOOR	= 14	# close a door. It will change the object value from 2 to 1, then to 0 when done, and update the tiles. One parameter (db): object id 
ACTION_REMOVE_BOXES	= 15	# remove a group of boxes. One parameter (db): object id
ACTION_RETURN_SUBSCRIPT	= 16  # return from a subscript

# Flags for actions, will be used as parameters to functions
FLAG_PATROL_NONE	= 0
FLAG_PATROL_NOFALL	= 1	# do not jump blindly on platforms
FLAG_FIGHT_NONE		= 0
FLAG_FIGHT_NOFALL	= 1	# do not jump blindly when fighting

# Constants for movement
MOVE_UP 		= 1
MOVE_DOWN		= 2
MOVE_LEFT		= 4
MOVE_RIGHT		= 8
MOVE_FIRE		= 16
MOVE_SELECT		= 32
MOVE_FORWARD		= 64
MOVE_BACKWARD		= 128

# Distances to player
PLAYER_MAX_DIST		= 64
PLAYER_MED_DIST		= 40
PLAYER_MIN_DIST		= 32

# Weapon types
WEAPON_SWORD		= 1
WEAPON_ECLIPSE		= 2
WEAPON_AXE		= 3
WEAPON_BLADE		= 4
