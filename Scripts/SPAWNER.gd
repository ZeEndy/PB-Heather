extends Node2D
#
#
## Declare member variables here. Examples:
## var a = 2
## var b = "text"
#var random_timer=rand_range(0,1)
#
#
#
## Called when the node enters the scene tree for the first time.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta):
##	random_timer-=delta
##	if random_timer<0:
##		spawn_eneny()
#
#
#func spawn_eneny():
#	var eneny=load("res://Data/DEFAULT/ENTS/PED_ENEMY.tscn").instantiate()
#	get_parent().add_child(eneny)
#	eneny.global_position=global_position
#	eneny.get_node('PED_SPRITES').teleport()
#	var weapon=debug_rand_weapon()
#	eneny.weapon=weapon
#	eneny.sprite_index=weapon.walk_sprite
#	random_timer=rand_range(10,15)
#
#func debug_rand_weapon():
#			var random_weapon=int(round(rand_range(0,3)))
#			var weapon
#			match random_weapon:
#				0:#M16
#					var transfer_weapon={
#						#id for hud
#						"id":"M9",
#						#ammo of the weapon
#						"ammo":12,
#						"max_ammo":12,
#						# wad sprites
#						"walk_sprite":"WalkM9",
#						"attack_sprite":["AttackM9"],
#						"attack_index":0,
#						#random on attack
#						"random_sprite":false,
#						"attack_sound":"res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_M9.wav",
#
#
#						"kill_sprite":"DeadMachineweapon",
#						"kill_lean_sprite":"DeadLeanMachineweapon",
#
#						"recoil":4,
#
#						"droppable":true,
#						#types:melee,burst,semi,auto
#						"type":"semi",
#						#attack_type:| shotweapon, normal, armor, grenade,lethal, non-lethal,downing
#						"attack_type":"normal",
#
#
#						"execution_sprite":"ExecuteM9",
#						"ground_sprite":"DieShot",
#						"weapon_length":0,
#						"screen_shake":1,
#
#						#trigger
#						"trigger_pressed":false,
#						"trigger_bullets":0,
#						"trigger_reset":0.1,
#						"trigger_shot":0,
#						"shoot_bullets":1
#					}
#					weapon=dupe_dict(transfer_weapon)
#				1:#AK
#					var transfer_weapon={
#						#id for hud
#						"id":"AK",
#						#ammo of the weapon
#						"ammo":31,
#						"max_ammo":30,
#						# wad sprites
#						"walk_sprite":"WalkAK",
#						"attack_sprite":["AttackAK"],
#						"attack_index":0,
#						#random on attack
#						"random_sprite":false,
#						"attack_sound":"res://Data/DEFAULT/SOUNDS/GAMEPLAY/sndAK.wav",
#
#
#						"kill_sprite":"DeadMachineweapon",
#						"kill_lean_sprite":"DeadLeanMachineweapon",
#
#						"recoil":4,
#
#						"droppable":true,
#						#types:melee,burst,semi,auto
#						"type":"auto",
#						#attack_type:| shotweapon, normal, armor, grenade,lethal, non-lethal,downing
#						"attack_type":"armor",
#
#
#						"execution_sprite":"",
#						"ground_sprite":"",
#						"weapon_length":0,
#						"screen_shake":1,
#
#						#trigger
#						"trigger_pressed":false,
#						"trigger_bullets":0,
#						"trigger_reset":0.1,
#						"trigger_shot":0,
#						"shoot_bullets":1
#					}
#					weapon=dupe_dict(transfer_weapon)
#				2:#UZI
#					var transfer_weapon={
#						#id for hud
#						"id":"M16",
#						#ammo of the weapon
#						"ammo":21,
#						"max_ammo":20,
#						# wad sprites
#						"walk_sprite":"WalkM16",
#						"attack_sprite":["AttackM16"],
#						"attack_index":0,
#						#random on attack
#						"random_sprite":false,
#						"attack_sound":"res://Data/DEFAULT/SOUNDS/GAMEPLAY/sndM16.wav",
#
#
#						"kill_sprite":"DeadMachineweapon",
#						"kill_lean_sprite":"DeadLeanMachineweapon",
#
#						"recoil":4,
#
#						"droppable":true,
#						#types:melee,burst,semi,auto
#						"type":"burst",
#						#attack_type:| shotweapon, normal, armor, grenade,lethal, non-lethal,downing
#						"attack_type":"armor",
#
#
#						"execution_sprite":"",
#						"ground_sprite":"",
#						"weapon_length":0,
#						"screen_shake":1,
#
#						#trigger
#						"trigger_pressed":false,
#						"trigger_bullets":3,
#						"trigger_reset":0.1,
#						"trigger_shot":0,
#						"shoot_bullets":1
#					}
#					weapon=dupe_dict(transfer_weapon)
#				3:#SHOTweapon
#					var transfer_weapon={
#						#id for hud
#						"id":"Shotweapon",
#						#ammo of the weapon
#						"ammo":7,
#						"max_ammo":6,
#						# wad sprites
#						"walk_sprite":"WalkShotweapon",
#						"attack_sprite":["AttackShotweapon"],
#						"attack_index":0,
#						#random on attack
#						"random_sprite":false,
#						"attack_sound":"res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_Shotweapon.wav",
#
#
#						"kill_sprite":"DeadShotweapon",
#						"kill_lean_sprite":"DeadLeanShotweapon",
#
#						"recoil":8,
#
#						"droppable":true,
#						#types:melee,burst,semi,auto
#						"type":"semi",
#						#attack_type:| shotweapon, normal, armor, grenade,lethal, non-lethal,downing
#						"attack_type":"armor",
#
#
#						"execution_sprite":"ExecuteShotweapon",
#						"ground_sprite":"DieShotweapon",
#						"weapon_length":0,
#						"screen_shake":1,
#
#						#trigger
#						"trigger_pressed":false,
#						"trigger_bullets":0,
#						"trigger_reset":0.8,
#						"trigger_shot":0,
#						"shoot_bullets":8
#					}
#					weapon=dupe_dict(transfer_weapon)
#				4:#Knife
#					var transfer_weapon={
#						#id for hud
#						"id":"Knife",
#						#ammo of the weapon
#						"ammo":7,
#						"max_ammo":6,
#						# wad sprites
#						"walk_sprite":"WalkKnife",
#						"attack_sprite":["AttackKnife"],
#						"attack_index":0,
#						#random on attack
#						"random_sprite":false,
#						"attack_sound":"",
#
#
#						"kill_sprite":"DeadSlash",
#						"kill_lean_sprite":"DeadLeanMelee",
#
#						"recoil":8,
#
#						"droppable":true,
#						#types:melee,burst,semi,auto
#						"type":"melee",
#						#attack_type:| shotweapon, normal, armor, grenade,lethal, non-lethal,downing
#						"attack_type":"",
#
#
#						"execution_sprite":"ExecuteKnife",
#						"ground_sprite":"DieKnife",
#						"weapon_length":0,
#						"screen_shake":1,
#
#						#trigger
#						"trigger_pressed":false,
#						"trigger_bullets":0,
#						"trigger_reset":0,
#						"trigger_shot":0,
#						"shoot_bullets":0
#					}
#					weapon=dupe_dict(transfer_weapon)
#				5:#Bat
#					var transfer_weapon={
#						#id for hud
#						"id":"Bat",
#						#ammo of the weapon
#						"ammo":7,
#						"max_ammo":6,
#						# wad sprites
#						"walk_sprite":"WalkBat",
#						"attack_sprite":["AttackBat"],
#						"attack_index":0,
#						#random on attack
#						"random_sprite":false,
#						"attack_sound":"",
#
#
#						"kill_sprite":"DeadBlunt",
#						"kill_lean_sprite":"DeadLeanMelee",
#
#						"recoil":8,
#
#						"droppable":true,
#						#types:melee,burst,semi,auto
#						"type":"melee",
#						#attack_type:| shotweapon, normal, armor, grenade,lethal, non-lethal,downing
#						"attack_type":"",
#
#
#						"execution_sprite":"ExecuteBat",
#						"ground_sprite":"DieBlunt",
#						"weapon_length":0,
#						"screen_shake":1,
#
#						#trigger
#						"trigger_pressed":false,
#						"trigger_bullets":0,
#						"trigger_reset":0.8,
#						"trigger_shot":0,
#						"shoot_bullets":0
#					}
#					weapon=dupe_dict(transfer_weapon)
#			return weapon
#
#
#func dupe_dict(fromdict):
#	var todict=fromdict.duplicate(true)
#	return todict
