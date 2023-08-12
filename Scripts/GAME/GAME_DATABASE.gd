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
			"ID":"Unarmed",
			
			"Type":"Melee",
			# ammount of attack sprites counting from 0
			"attack_count":1,
			# which attack is used depending on the count
			"attack_index":0,
			#random on attack
			"random_sprite":false,
			
			
			"droppable":false,
			#types:melee"
			"attack_type":"downing",
			
			"Swing time":0.3889,
			"Swing timer":0.0
			},
		"Knife":{
			#id for hud
			"id":"Knife",
			#ammo of the weapon
			"max_ammo":6,
			# wad sprites
			"attack_count":1,
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
			#attack_type:| shotweapon, normal, armor, grenade,lethal, non-lethal,downing
			"attack_type":"",
			
			
			"execution_sprite":"Knife",
			"ground_sprite":"DieKnife",
			"weapon_length":0,
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
			#attack_type:| shotweapon, normal, armor, grenade,lethal, non-lethal,downing
			"attack_type":"",
			
			
			"execution_sprite":"Bat",
			"ground_sprite":"DieBat",
			"weapon_length":0,
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
			
			"Bullet":"AP",
			#ammo of the weapon
			"Ammo":8,
			"Max ammo":7,
			"Reserve":14,
			# using the just an int because a magazine system doesn't fit this project 
			
			"Attack index":0,
			"Attack ammount":1,
			"Random sprite":true,
			
			"Damage":100,
			
			"Added recoil":0.2,
			"Recoil":4,
			
			
			"Hearing radius":220, # its a radius
			#so that means if an enemy is in a 220 range between the player he will hear the weaponshot
			
			"Droppable":true,
			
			#trigger
			"Trigger pressed":false,
			"Trigger bullets":0,
			"Firerate":0.1,
			"Splits":1},
		
		"PB":{
			"ID":"PB",
			#ammo of the weapon
			"Type":"Firearm",
			"Mode":"Semi",
			
			"Bullet":"FMJ",
			#ammo of the weapon
			"Ammo":9,
			"Max ammo":8,
			"Reserve":16,
			# using the just an int because a magazine system doesn't fit this project 
			
			"Attack index":0,
			"Attack ammount":1,
			"Random sprite":true,
			
			"Damage":100,
			
			"Added recoil":0.2,
			"Recoil":4,
			
			
			"hearing_radius":220, # its a radius
			#so that means if an enemy is in a 220 range between the player he will hear the weaponshot
			
			"droppable":true,
			
			#trigger
			"Trigger pressed":false,
			"Trigger bullets":0,
			"Trigger reset":0.1,
			"Trigger shot":0,
			"Splits":1},
		
		"MAC-10":{
			"ID":"MAC-10",
			#ammo of the weapon
			"Type":"Firearm",
			"Mode":"Full",
			
			"Bullet":"FMJ",
			#ammo of the weapon
			"Ammo":31,
			"Max ammo":30,
			"Reserve":30,
			# using the just an int because a magazine system doesn't fit this project 
			
			"Attack index":0,
			"Attack ammount":0,
			"Random sprite":true,
			
			"Damage":100,
			
			"Added recoil":0.2,
			"Recoil":4,
			
			
			"hearing_radius":220, # its a radius
			#so that means if an enemy is in a 220 range between the player he will hear the weaponshot
			
			"droppable":true,
			
			#trigger
			"Trigger pressed":false,
			"Trigger bullets":0,
			"Trigger reset":0.1,
			"Trigger shot":0,
			"Splits":1},
		
		"AR-15":{
			#id
			"ID":"AR-15",
			#ammo of the weapon
			"Type":"Firearm",
			"Mode":"Full",
			
			"Bullet":"FMJ",
			#ammo of the weapon
			"Ammo":31,
			"Max ammo":30,
			"Reserve":30,
			# using the just an int because a magazine system doesn't fit this project 
			
			"Attack index":0,
			"Attack ammount":0,
			"Random sprite":true,
			
			"Damage":100,
			
			"Added recoil":0.2,
			"Recoil":4,
			
			
			"hearing_radius":220, # its a radius
			#so that means if an enemy is in a 220 range between the player he will hear the weaponshot
			
			"droppable":true,
			
			#trigger
			"Trigger pressed":false,
			"Trigger bullets":0,
			"Trigger reset":0.1,
			"Trigger shot":0,
			"Splits":1},
		
		"AK-74U":{
			#id
			"ID":"AK-74U",
			#ammo of the weapon
			"Type":"Firearm",
			"Mode":"Full",
			
			"Bullet":"FMJ",
			#ammo of the weapon
			"Ammo":31,
			"Max ammo":30,
			"Reserve":30,
			# using the just an int because a magazine system doesn't fit this project 
			
			"Attack index":0,
			"Attack ammount":0,
			"Random sprite":true,
			
			"Damage":100,
			
			"Added recoil":0.2,
			"Recoil":4,
			
			"hearing_radius":220, # its a radius
			#so that means if an enemy is in a 220 range between the player he will hear the weaponshot
			
			"droppable":true,
			
			#trigger
			"Trigger pressed":false,
			"Trigger bullets":0,
			"Trigger reset":0.1,
			"Trigger shot":0,
			#How many "Bullets" need to spawn
			"Splits":1},
		
		"OverUnder":{
			#id for hud
			"ID":"OverUnder",
			#ammo of the weapon
			"Ammo":2,
			"Max_ammo":1,
			"Reserve":4,
			
			"Attack index":0,
			"Attack count":0,
			"Random index":false,
			
			"dry_fire":"PED_SPRITES/Body/Sound Library/AR-57/Trigger Pressed",
			
			"damage":100,
			"added_recoil":0.1,
			"recoil":4,
			
			
			"ring_ammount":0.2,
			"hearing_radius":160,
			
			
			"droppable":true,
			#types:melee,burst,semi,auto
			"type":"auto",
			#attack_type:| shotweapon, normal, armor, grenade,lethal, non-lethal,downing
			"attack_type":"armor",
			
			
			"execution_sprite":"",
			"ground_sprite":"",
			"screen_shake":1,
			
			
			#trigger
			"trigger_pressed":false,
			"trigger_bullets":0,
			"Firerate":0.0705882352941176,
			"trigger_shot":0,
			"Splits":8},
	}
}

var execution_db={
	"Unarmed":{
		"Executioner":"Execute", # determine the player's animation
		"Victim":"Stomp", # determine the enemy's animation
		"lock_rotation":true # determine w
	}
}

#used
var death_db={
	
	"1911":{
		"kill_sprite":"DeadMachineweapon",
		"kill_lean_sprite":"DeadLeanMachineweapon",
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
