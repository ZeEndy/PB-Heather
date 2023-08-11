extends Node

var glob_delta=0
var glob_phys_delta=0

#	This weapon DB is a lite version of DK weapon system
#mostly lite because DK has an advanced weapon cycle and modification system
#as well as a bullet system which this doesn't as to not overcomplicate it here atleast.

#saying this wont bite me in the ass later lol

#	The weapons are split into 2 categories to make finding them easier
#as well as firearms and melee behaving way differently compared to default PB
#this version might get implemented into PB

const weapon_database={
	"Melee":{
		"Unarmed":{
			#id for hud
			"id":"Unarmed",
			
			"Type":"Melee",
			# ammount of attack sprites counting from 0
			"attack_count":0,
			# which attack is used depending on the count
			"attack_index":0,
			#random on attack
			"random_sprite":false,
			"attack_sound":null,
			
			
			"droppable":false,
			#types:melee"
			"attack_type":"downing",
			
			#trigger
			"trigger_pressed":false,
			"trigger_reset":0.1,},
		"Knife":{
			#id for hud
			"id":"Knife",
			#ammo of the gun
			"max_ammo":6,
			# wad sprites
			"attack_count":0,
			"attack_index":0,
			#random on attack
			"random_sprite":false,
			"attack_sound":"",
			
			
			"kill_sprite":"DeadSlash",
			"kill_lean_sprite":"DeadLeanMelee",
			
			"recoil":8,
			
			"droppable":true,
			#types:melee,burst,semi,auto
			"type":"melee",
			#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
			"attack_type":"",
			
			
			"execution_sprite":"Knife",
			"ground_sprite":"DieKnife",
			"gun_length":0,
			"screen_shake":1,
			
			#trigger
			"trigger_reset":0.1,
			"trigger_pressed":false,},
		"Bat":{
			#id for hud
			"id":"Bat",
			# wad sprites
			"walk_sprite":"Walk",
			"attack_sprite":["Attack"],
			"attack_index":0,
			#random on attack
			"random_sprite":false,
			"attack_sound":"",
			
			
			"kill_sprite":"DeadSlash",
			"kill_lean_sprite":"DeadLeanMelee",
			
			"recoil":8,
			
			"droppable":true,
			#types:melee,burst,semi,auto
			"type":"melee",
			#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
			"attack_type":"",
			
			
			"execution_sprite":"Bat",
			"ground_sprite":"DieBat",
			"gun_length":0,
			"screen_shake":1,
			
			#trigger
			"trigger_reset":0.1,
			"trigger_pressed":false,},
	},
	"Firearm":{
		"1911":{
			"ID":"1911",
			"Type":"Firearm",
			"Mode":"Semi",
			
			"Bullet":"FMJ",
			#ammo of the gun
			"Ammo":8,
			"Max ammo":7,
			"Reserve":14,
			# using the just an int because a magazine system doesn't fit this project 
			
			"Attack index":0,
			"Attack ammount":1,
			"Random sprite":false,
			
			"Damage":100,
			
			"Added recoil":0.2,
			"Recoil":4,
			
			
			"hearing_radius":220, # its a radius
			#so that means if an enemy is in a 220 range between the player he will hear the gunshot
			
			"droppable":true,
			
			#trigger
			"trigger_pressed":false,
			"trigger_bullets":0,
			"trigger_reset":0.1,
			"trigger_shot":0,
			"shoot_bullets":1},
		"PB":{
			"id":"PB",
			#ammo of the gun
			"Type":"Firearm",
			"Mode":"Semi",
			
			"Bullet":"FMJ",
			#ammo of the gun
			"Ammo":9,
			"Max ammo":8,
			"Reserve":16,
			# using the just an int because a magazine system doesn't fit this project 
			
			"Attack index":0,
			"Attack ammount":1,
			"Random sprite":false,
			
			"Damage":100,
			
			"Added recoil":0.2,
			"Recoil":4,
			
			
			"hearing_radius":220, # its a radius
			#so that means if an enemy is in a 220 range between the player he will hear the gunshot
			
			"droppable":true,
			
			#trigger
			"trigger_pressed":false,
			"trigger_bullets":0,
			"trigger_reset":0.1,
			"trigger_shot":0,
			"shoot_bullets":1},
		"MAC-10":{
			"id":"MAC-10",
			#ammo of the gun
			"Type":"Firearm",
			"Mode":"Semi",
			
			"Bullet":"FMJ",
			#ammo of the gun
			"Ammo":9,
			"Max ammo":8,
			"Reserve":16,
			# using the just an int because a magazine system doesn't fit this project 
			
			"Attack index":0,
			"Attack ammount":1,
			"Random sprite":false,
			
			"Damage":100,
			
			"Added recoil":0.2,
			"Recoil":4,
			
			
			"hearing_radius":220, # its a radius
			#so that means if an enemy is in a 220 range between the player he will hear the gunshot
			
			"droppable":true,
			
			#trigger
			"trigger_pressed":false,
			"trigger_bullets":0,
			"trigger_reset":0.1,
			"trigger_shot":0,
			"shoot_bullets":1},
		"AR-15":{
			#id for hud
			"id":"AR-15",
			#ammo of the gun
			"ammo":30,
			"max_ammo":30,
			"reserve":[30,30,30],
			# wad sprites
			"walk_sprite":"Walk",
			"attack_sprite":["Attack"],
			"attack_index":0,
			#random on attack
			"random_sprite":false,
			"attack_sound":"res://Data/Sounds/Vector/Fire.wav",
			"dry_fire":"PED_SPRITES/Body/Sound Library/AR-57/Trigger Pressed",
			
			"damage":100,
			"added_recoil":0.1,
			"recoil":4,
			
			
			"kill_sprite":"DeadMachinegun",
			"kill_lean_sprite":"DeadLeanMachinegun",
			
			
			"ring_ammount":0.2,
			"hearing_radius":160,
			
			
			"droppable":true,
			#types:melee,burst,semi,auto
			"type":"auto",
			#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
			"attack_type":"armor",
			
			
			"execution_sprite":"",
			"ground_sprite":"",
			"screen_shake":1,
			
			
			#trigger
			"trigger_pressed":false,
			"trigger_bullets":0,
			"trigger_reset":0.0705882352941176,
			"trigger_shot":0,
			"shoot_bullets":1},
		"AK-74U":{
			#id for hud
			"id":"AK-74U",
			#ammo of the gun
			"ammo":31,
			"max_ammo":30,
			"reserve":[30],
			# wad sprites
			"walk_sprite":"Walk",
			"attack_sprite":["Attack"],
			"attack_index":0,
			#random on attack
			"random_sprite":false,
			"attack_sound":"res://Data/Sounds/Vector/Fire.wav",
			"dry_fire":"PED_SPRITES/Body/Sound Library/AR-57/Trigger Pressed",
			
			"damage":100,
			"added_recoil":0.1,
			"recoil":4,
			
			
			"kill_sprite":"DeadMachinegun",
			"kill_lean_sprite":"DeadLeanMachinegun",
			
			
			"ring_ammount":0.2,
			"hearing_radius":160,
			
			
			"droppable":true,
			#types:melee,burst,semi,auto
			"type":"auto",
			#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
			"attack_type":"armor",
			
			
			"execution_sprite":"",
			"ground_sprite":"",
			"screen_shake":1,
			
			
			#trigger
			"trigger_pressed":false,
			"trigger_bullets":0,
			"trigger_reset":0.0705882352941176,
			"trigger_shot":0,
			"shoot_bullets":1},
		"OverUnder":{
			#id for hud
			"id":"M16",
			#ammo of the gun
			"ammo":30,
			"max_ammo":30,
			"reserve":[30,30,30],
			# wad sprites
			"walk_sprite":"Walk",
			"attack_sprite":["Attack"],
			"attack_index":0,
			#random on attack
			"random_sprite":false,
			"attack_sound":"res://Data/Sounds/Vector/Fire.wav",
			"dry_fire":"PED_SPRITES/Body/Sound Library/AR-57/Trigger Pressed",
			
			"damage":100,
			"added_recoil":0.1,
			"recoil":4,
			
			
			"kill_sprite":"DeadMachinegun",
			"kill_lean_sprite":"DeadLeanMachinegun",
			
			
			"ring_ammount":0.2,
			"hearing_radius":160,
			
			
			"droppable":true,
			#types:melee,burst,semi,auto
			"type":"auto",
			#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
			"attack_type":"armor",
			
			
			"execution_sprite":"",
			"ground_sprite":"",
			"screen_shake":1,
			
			
			#trigger
			"trigger_pressed":false,
			"trigger_bullets":0,
			"trigger_reset":0.0705882352941176,
			"trigger_shot":0,
			"shoot_bullets":1},
		"Shotgun":{
			#id for hud
			"id":"Shotgun",
			#ammo of the gun
			"ammo":7,
			"max_ammo":6,
			# wad sprites
			"walk_sprite":"Walk",
			"attack_sprite":["Attack"],
			"attack_index":0,
			#random on attack
			"random_sprite":false,
			"damage":75,
			
			
			"kill_sprite":"DeadShotgun",
			"kill_lean_sprite":"DeadLeanShotgun",
			
			"recoil":8,
			
			"droppable":true,
			#types:melee,burst,semi,auto
			"type":"semi",
			#attack_type:| shotgun, normal, armor, grenade,lethal, non-lethal,downing
			"attack_type":"armor",
			
			
			"execution_sprite":"Execute",
			"ground_sprite":"DieShotgun",
			"gun_length":0,
			"screen_shake":1,
			
			#trigger
			"trigger_pressed":false,
			"trigger_bullets":0,
			"trigger_reset":0.8,
			"trigger_shot":0,
			"shoot_bullets":8}
	}
}

var execution_db={
	"Unarmed":{
		"execution_sprite":"Execute", # determine the player's animation
		"ground_sprite":"Stomp", # determine the enemy's animation
		"lock_rotation":true # determine w
	}
}

#used
var death_db={
	
	"1911":{
		"kill_sprite":"DeadMachinegun",
		"kill_lean_sprite":"DeadLeanMachinegun",
	}
}

func get_wep(type,input_weapon):
	return weapon_database[type][input_weapon].duplicate(true)

#	The get function is used on the execution database as it has 2nd variant variable
#which can be assigned to anything as so we call the execution db and ask for the unarmed
#this a heavy function but since its used once in a while it shouldn't have a significatn impact
#on performance
func get_execution(input_id):
	return execution_db.get(input_id,execution_db["Unarmed"])


func _process(delta):
	glob_delta=delta#I have no idea what I used this for

func _physics_process(delta):
	glob_phys_delta=delta#same with this lol
