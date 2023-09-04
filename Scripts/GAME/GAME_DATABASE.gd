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


#FOR FIREARMS
#if you want to recreate a weapon for example the MP9
#and you want the gun to fire at about the same rate it would IRL
#what you need to do is search up the gun's firerate/cycle rate
#take 60 and devide it by that number
#for example:
#60.0/900 //use ctrl+shift+e to convert it
#and in the end you will have 0.0666667

const weapon_database={
	"Melee":{
		"Unarmed":{
			#id for hud and anims
			"ID":"Unarmed",
			
			"Type":"Melee",
			# ammount of attack sprites counting from 0
			"Attack ammount":2,
			# which attack is used depending on the count
			"Attack index":0,
			#random on attack
			"Random sprite":false,
			
			
			"droppable":false,
			
			"Swing time":0.3889,
			"Swing timer":0.0
			},
		"Bat":{
			#id for hud
			"ID":"Bat",
			
			"Type":"Melee",
			# ammount of attack sprites counting from 0
			"Attack ammount":2,
			# which attack is used depending on the count
			"Attack index":0,
			#random on attack
			"Random sprite":false,
			
			
			"droppable":true,
			
			"Swing time":0.3889,
			"Swing timer":0.0
			},
			"Knife":{
			#id for hud
			"ID":"Knife",
			
			"Type":"Melee",
			# ammount of attack sprites counting from 0
			"Attack ammount":2,
			# which attack is used depending on the count
			"Attack index":0,
			#random on attack
			"Random sprite":false,
			
			
			"droppable":true,
			
			"Swing time":0.3889,
			"Swing timer":0.0
			},
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
			"Cycle Rate":0.0666667,
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
			"Cycle rate":0.109091,
			"Cycle":0.0,
			"Trigger shot":0,
			"Splits":1},
		
		"MAC-10":{
			"ID":"MAC-10",
			#ammo of the weapon
			"Type":"Firearm",
			"Mode":"Auto",
			
			"Bullet":"FMJ",
			#ammo of the weapon
			"Ammo":30,
			"Max ammo":30,
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
			"Cycle rate":0.1,
			"Cycle":0.0550459,
			"Trigger shot":0,
			"Splits":1},
		
		"AR-15":{
			#id
			"ID":"AR-15",
			#ammo of the weapon
			"Type":"Firearm",
			"Mode":"Semi",
			
			"Bullet":"FMJ",
			#ammo of the weapon
			"Ammo":21,
			"Max ammo":20,
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
			"Cycle rate":0.0867143,
			"Cycle":0.0,
			"Splits":1},
		
		"AK-74U":{
			#id
			"ID":"AK-74U",
			#ammo of the weapon
			"Type":"Firearm",
			"Mode":"Auto",
			
			"Bullet":"FMJ",
			#ammo of the weapon
			"Ammo":31,
			"Max ammo":30,
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
			"Cycle rate":0.0779221,
			"Cycle":0.0,
			#How many "Bullets" need to spawn
			"Splits":1},
		
		"OU-DB":{
			#id for hud
			"ID":"OU-DB",
			#ammo of the weapon
			"Type":"Firearm",
			"Mode":"Semi",
			#ammo of the weapon
			"Ammo":2,
			"Max ammo":2,
			
			"Attack index":0,
			"Attack count":0,
			"Random index":false,
			
			"dry_fire":"PED_SPRITES/Body/Sound Library/AR-57/Trigger Pressed",
			
			"damage":75,
			"added_recoil":0.1,
			"recoil":4,
			
			
			"ring_ammount":0.2,
			"hearing_radius":160,
			
			
			"droppable":true,
			
			"screen_shake":1,
			
			
			#trigger
			"trigger_pressed":false,
			"Cycle rate":0.01,
			"Cycle":0.0,
			"Splits":8},
	}
}

var execution_db={
	"Unarmed":{
		"ID":"Unarmed",
		"Executioner":"Execute", # determine the player's animation
		"Victim":"Stomp", # determine the enemy's animation
		"lock_rotation":true # determine w
	}
}

#used
var death_db={
	"PB":{
		"kill_sprite":"Dead/Machinegun",
		"kill_lean_sprite":"Dead/Machinegun",
	},
	"1911":{
		"kill_sprite":"Dead/Machinegun",
		"kill_lean_sprite":"Dead/Machinegun",
	},
	"AK-74U":{
		"kill_sprite":"Dead/Machinegun",
		"kill_lean_sprite":"Dead/Machinegun",
	},
	"AR-15":{
		"kill_sprite":"Dead/Machinegun",
		"kill_lean_sprite":"Dead/Machinegun",
	},
}

func get_wep(input_weapon):
	for i in weapon_database:
		if weapon_database[i].has(input_weapon):
			print(weapon_database[i][input_weapon]["ID"])
			return weapon_database[i][input_weapon].duplicate(true)

func get_exec(exec) -> Dictionary:
	var ret=execution_db["Unarmed"]
	if execution_db.has(exec):
		return execution_db[exec].duplicate(true)
	return ret

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
