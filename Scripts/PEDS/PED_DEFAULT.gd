extends Node2D

class_name PED
#preloads
@onready var def_bullet_ent=preload("res://Data/DEFAULT/ENTS/ENT_BULLET.tscn")
@onready var def_grenade_ent=preload("res://Data/DEFAULT/ENTS/ENT_GRENADE.tscn")


#reference variables
@onready var sprites = get_node("PED_SPRITES")
@onready var sprite_body = get_node("PED_SPRITES/Body")
@onready var sprite_body_anim = get_node("PED_SPRITES/Body/AnimationPlayer")
@onready var sprite_legs = get_node("PED_SPRITES/Legs")
@onready var sprite_legs_anim = get_node("PED_SPRITES/Legs/AnimationPlayer")
@onready var collision_body = get_node("PED_COL")
@onready var col_shape = get_node("PED_COL/CollsionCircle")

var groups
var col_groups

#variables are oragnized by specification aka what state they are used the most in
enum ped_states{
	alive,
	abilty,
	execute,
	down,
	dead
}
@export_category("Base variables")
@export var state = ped_states.alive
#ALIVE STATE VARIABLES
@export var health=100.0
@export var armour=0
@export var start_with_weapon=false


# Movement variables
const MAX_SPEED = 125
const ACCELERATION = 6.0
const DECEL_MULTIP = 9.0
@export var my_velocity=Vector2()
var friction_multip = 1
var axis = Vector2()
var motion_multiplier=1
var path=[]


#WEAPON VARIABLES
@onready var default_weapon = Database.get_wep("Unarmed")
@export_enum("Unarmed","PB","1911","AR-15","MAC-10","AK-74U") var desired_weapon="Unarmed"
@onready var weapon = Database.get_wep("Unarmed")

var delay=0
var bAttack=false

var given_height=0
var added_recoil = 0.0 #multiply this shit in the attack if needed
var closest_weapon = null


#DOWNED STATE/EXECUTION STATE
@export_category("Downed or execute state")
@export var MAX_GET_UP_TIME=8
@export var down_timer=8
@export var copy_time=false
var in_distance_to_execute=false
var execute_target=null
@export var execute_click=false
var can_get_up=true


#VISUALS AND MISC
@export_category("Visuals and misc")
@export var shake_screen=false
var change_sprite_value=false
var change_leg_sprite_value=false
# Sprite variables
@export var sprite_index = ""
@export var sprite_based_on_export=false
@export var leg_index = "Walk/Start"
@export var body_direction = 0





func _ready():
	if groups==null:
		groups=get_groups().duplicate(true)
		col_groups=collision_body.get_groups().duplicate(true)
	col_shape.shape
	body_direction=global_rotation
	global_rotation=0
	default_weapon=Database.get_wep("Unarmed")
	weapon=default_weapon.duplicate()
	if desired_weapon!="Unarmed":
		weapon=Database.get_wep(desired_weapon)
	if sprite_based_on_export==false:
		_play_animation("Walk")
	else:
		_play_animation(sprite_index)
	sprite_legs.play(leg_index)
	



func reset_groups():
	print(groups)
	for i in groups:
		add_to_group(i)
	for i in col_groups:
		collision_body.add_to_group(i)

# Finds the first visible pickupable weapon dropped within 40 units of the player that isn't behind a wall 
func weapon_finder():
	var dropped_weapons = get_tree().get_nodes_in_group("Weapon")
	var pickup_dist = 40*40
	
	for weapon in dropped_weapons:
		# filter weapons that cannot be picked up
		if weapon.pick_up == true && weapon.visible == true:
			# filter weapons within certain distance
			if weapon.global_position.distance_squared_to(sprites.global_position) < pickup_dist:
				# filter weapons behind walls
				get_node("PED_COL/weapon_find").target_position = weapon.global_position - sprites.global_position
				if !get_node("PED_COL/weapon_find").is_colliding():
					closest_weapon = weapon
					return weapon
	return null


func _process(delta):
	if state==ped_states.alive:
		#pisss
		if delay>0:
			delay-=delta
			delay=clamp(delay,0,999)
		
		#use this shit idkgfdsfhbsdh
		if added_recoil>0:
			added_recoil=clamp(added_recoil,0,1.4)
			added_recoil-=delta
		else:
			added_recoil=0
		
		
		leg_sprites(delta)
		var walking = ("Walk" in sprite_index)
		
		if walking:
			sprite_body.speed_scale = (abs(collision_body.velocity.length()/125))
		else:
			if weapon["Type"]=="Melee" && ("Attack" in sprite_index):
				sprite_body.speed_scale=motion_multiplier
			elif !("Attack" in sprite_index):
				sprite_body.speed_scale=motion_multiplier
			else:
				sprite_body.speed_scale=1.0
		
		if sprite_legs.animation!=leg_index:
			sprite_legs.play(leg_index)
		
		if sprite_index=="":
			if weapon["Type"]!="Melee" && weapon["Ammo"]==0:
				_play_animation("Walk Empty")
			else:
				_play_animation("Walk")
		
		if !(sprite_index in sprite_body_anim.current_animation):
			await RenderingServer.frame_post_draw
			if !(sprite_index in sprite_body_anim.current_animation):
				_play_animation(sprite_index,0,true)
		
		
	elif state==ped_states.execute:
		if copy_time==true:
			execute_target.sprite_legs.seek(sprite_body.frame,true)

func _physics_process(delta):
	weapon_logic(delta)
	collision_body.global_rotation=0
	col_shape.shape.radius=lerp(col_shape.shape.radius,8.0,10*delta)
	col_shape.shape.height=lerp(col_shape.shape.height,16.0,10*delta)
	if weapon is Dictionary:
		if weapon!={}:
			if bAttack==true:
				self.attack()
	if state == ped_states.down:
		movement(null,delta)
#		axis=lerp(axis,Vector2.ZERO,0.1)
		if my_velocity.length()>0.1:
			axis=axis.lerp(Vector2.ZERO,clamp(10*delta,0,1))
			var test_motion=collision_body.move_and_collide(Vector2(16,0).rotated(my_velocity.angle()),true)
			if test_motion:
				my_velocity=Vector2.ZERO
				axis=Vector2.ZERO
				sprite_legs.play("GetUpLean")
				sprite_legs.global_rotation=test_motion.get_normal().angle()
				sprite_legs.speed_scale=0
				collision_body.global_position=test_motion.get_position()
		if my_velocity.length()<5:
			sprite_body.global_rotation=sprite_legs.global_rotation
			if can_get_up==true:
				down_timer-=delta
				if down_timer<0:
					sprite_legs.speed_scale=1
	
	
	elif state == ped_states.dead:
#		get_node("PED_COL/CollsionCircle").disabled=true
		my_velocity=lerp(my_velocity,Vector2.ZERO,5.0*delta)
		collision_body.velocity=my_velocity
		col_shape.shape.radius=lerp(col_shape.shape.radius,11.0,10*delta)
		col_shape.shape.height=lerp(col_shape.shape.height,56.0,10*delta)
		col_shape.global_rotation=sprite_legs.global_rotation+PI*0.5
#		56
#		10

#		8
#		16
		collision_body.move_and_slide()
		if get_groups().size()>0:
			for i in get_groups():
				remove_from_group(i)
		if collision_body.get_groups().size()>0:
			for i in collision_body.get_groups():
				collision_body.remove_from_group(i)
		

func movement(new_motion=null,delta=null):
	if new_motion==null:
		#normal movement code
		if axis.length() > 0:
			my_velocity=my_velocity.lerp(axis*MAX_SPEED,clamp(ACCELERATION*delta*motion_multiplier,0,1))
			my_velocity= my_velocity.limit_length(MAX_SPEED*motion_multiplier)
		else:
			pass
			my_velocity=my_velocity.lerp(Vector2(0,0),clamp(DECEL_MULTIP*delta*motion_multiplier,0,1))
	else:
		my_velocity=new_motion
	collision_body.velocity=my_velocity*motion_multiplier
	collision_body.move_and_slide()





func leg_sprites(delta):
	if (abs(collision_body.velocity.length()))<30:
			if sprite_legs.speed_scale!=0:
				sprite_legs_anim.seek(0)
				sprite_legs.speed_scale=0
				leg_index="Walk/Start"

	else:
		sprite_legs.rotation=lerp_angle(sprite_legs.rotation,atan2(collision_body.velocity.y,collision_body.velocity.x),clamp(50*delta,0,1))
		sprite_legs.speed_scale = (abs(collision_body.get_real_velocity().length()/125))


#This script functions by reading through the poperty list of the weapon variable and spawning
#a bullet depending on what the parameters are
#as well as doing melee initalization
func attack(sound_pos=sprite_body.global_position):
	
	if weapon["Type"]=="Melee":
		# animation decision tree
		var chosen_attack_sprite = "Attack_"+str(weapon["Attack index"])
		if weapon["Swing timer"]==0.0:
			if weapon["Random sprite"] == false:
				weapon["Attack index"] = (weapon["Attack index"] + 1) % weapon["Attack ammount"]
			else:
				weapon["Attack index"]=randi_range(0,weapon["Attack ammount"])
			weapon["Swing timer"]=weapon["Swing time"]
			_play_animation(chosen_attack_sprite)
	elif weapon["Type"]=="Firearm":
		if weapon["Mode"]=="Auto" && weapon["Cycle"]==0.0:
			if weapon["Ammo"]>0:
				if weapon["Ammo"]-1==0:
					weapon["Attack index"]=-1
				var chosen_attack_sprite = "Attack_"+str(weapon["Attack index"])
				
				if weapon["Random sprite"] == false:
					weapon["Attack index"] = (weapon["Attack index"] + 1) % weapon["Attack ammount"]
				else:
					weapon["Attack index"]=randi_range(0,weapon["Attack ammount"])
				_play_animation(chosen_attack_sprite)
				weapon["Cycle"]=weapon["Cycle rate"]
				spawn_bullet(weapon["Splits"])
		elif weapon["Mode"]=="Semi" && weapon["Cycle"]==0.0:
			if weapon["Ammo"]-1==0:
				weapon["Attack index"]=-1
			if weapon["Ammo"]>0 && weapon["Trigger pressed"]==false:
				var chosen_attack_sprite = "Attack_"+str(weapon["Attack index"])
				if weapon["Random sprite"] == false:
					weapon["Attack index"] = (weapon["Attack index"] + 1) % weapon["Attack ammount"]
				else:
					weapon["Attack index"]=randi_range(0,weapon["Attack ammount"])
				_play_animation(chosen_attack_sprite)
				weapon["Cycle"]=weapon["Cycle rate"]
				spawn_bullet(weapon["Splits"])
		
		weapon["Trigger pressed"]=true
#		var chosen_attack_sprite = "Attack_"+str(weapon["attack_index"])
#		if weapon["Swing timer"]==0.0:
#			if weapon["random_sprite"] == false:
#				weapon["attack_index"] = (weapon["attack_index"] + 1) % weapon["attack_count"]
#			else:
#				weapon["attack_index"]=randi_range(0,weapon["attack_count"])
#			_play_animation(chosen_attack_sprite)
#		if weapon.get("jammed",false)==true:
#			return
#		spawn_bullet(weapon["shoot_bullets"])
#		# animation decision tree
#		var chosen_attack_sprite = weapon[attack_sprite][weapon["attack_index"]]
#		if !(sprite_index in [weapon.get("turn_right"),weapon.get("turn_left")]):
#			_play_animation(chosen_attack_sprite)
#		else:
#			if weapon["ammo"]!=0:
#				sprite_body.get_node("anim/BARREL").play(weapon["id"])
#			else:
#				sprite_body.get_node("anim/BARREL").play(weapon["id"]+str("Empty"))
#		if weapon["random_sprite"] == false:
#			weapon["attack_index"] = (weapon["attack_index"] + 1) % weapon[attack_sprite].size()
#		else:
#			weapon["attack_index"]=randi_range(0,weapon[attack_sprite].size()-1)
#		delay=weapon["trigger_reset"]
#		weapon["trigger_pressed"]=false
	
	
#
#
#	elif weapon["type"]=="auto" && delay==0 && weapon.ammo>0:
#		if weapon.get("jammed",false)==true:
#			return
#		spawn_bullet(weapon["shoot_bullets"])
#		# animation decision tree
#		var chosen_attack_sprite = weapon[attack_sprite][weapon["attack_index"]]
#		if !(sprite_index in [weapon.get("turn_right"),weapon.get("turn_left")]):
#			_play_animation(chosen_attack_sprite)
#		else:
#			if weapon["ammo"]!=0:
#				sprite_body.get_node("anim/BARREL").play(weapon["id"])
#			else:
#				sprite_body.get_node("anim/BARREL").play(weapon["id"]+str("Empty"))
#		if weapon["random_sprite"] == false:
#			weapon["attack_index"] = (weapon["attack_index"] + 1) % weapon[attack_sprite].size()
#		else:
#			weapon["attack_index"]=randi_range(0,weapon[attack_sprite].size()-1)
#		delay=weapon["trigger_reset"]

	
	
	
	
#	elif weapon["type"]=="burst" && weapon["ammo"]>0:
#		if weapon.get("jammed",false)==true:
#			return
#		if weapon["trigger_shot"]==0:
#			weapon["trigger_shot"]=weapon["trigger_bullets"]
#		for i in weapon["trigger_shot"]:
#			if delay==0 && weapon["ammo"]>0:
#				spawn_bullet(weapon["shoot_bullets"])
#				# animation decision tree
#				var chosen_attack_sprite = weapon[attack_sprite][weapon["attack_index"]]
#				if !(sprite_index in [weapon.get("turn_right"),weapon.get("turn_left")]):
#					_play_animation(chosen_attack_sprite)
#				else:
#					if weapon["ammo"]!=0:
#						sprite_body.get_node("anim/BARREL").play(weapon["id"])
#					else:
#						sprite_body.get_node("anim/BARREL").play(weapon["id"]+str("Empty"))
#				if weapon["random_sprite"] == false:
#					weapon["attack_index"] = (weapon["attack_index"] + 1) % weapon[attack_sprite].size()
#				else:
#					weapon["attack_index"]=randi_range(0,weapon[attack_sprite].size()-1)
#				weapon["trigger_shot"]-=1
#				delay=weapon["trigger_reset"]
#
#				if weapon["trigger_shot"]==0 || weapon["trigger_pressed"]==false:
#					weapon["trigger_pressed"]=false
#					delay=weapon["trigger_reset"]*3.5
#					weapon["trigger_shot"]=0


func weapon_logic(delta):
	if weapon["Type"]=="Melee":
		weapon["Swing timer"] = (weapon["Swing timer"]-delta)*float(weapon["Swing timer"]>0)
#		print(weapon["Swing timer"])
	elif weapon["Type"]=="Firearm":
		weapon["Cycle"] = (weapon["Cycle"]-delta)*float(weapon["Cycle"]>0)
		if bAttack==false:
			weapon["Trigger pressed"]=false


func switch_weapon():
	if !"Attack" in sprite_index:
		drop_weapon()
		closest_weapon = weapon_finder()
		if closest_weapon != null:
			var sound_pos=collision_body.global_position
			if get_class()=="Player":
				sound_pos=null
			AudioManager.play_audio("res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_PickupWeapon.wav",sound_pos,true,1,0,"Master")
			weapon=dupe_dict(closest_weapon.weapon)
			closest_weapon.call_deferred("queue_free")
#			play_sample("res://Assets/Sounds/Weapons/Pick up/Pick_up.wav",0)
		sprite_index=""

#weapon transfer script
func dupe_dict(fromdict):
	var todict=fromdict.duplicate(true)
	return todict


func drop_weapon(throw_speed=1,dir=body_direction):
	if weapon["droppable"]==true:
		var load_weapon=load("res://Data/DEFAULT/ENTS/ENT_GENERIC_WEAPON.tscn")
		var inst_weapon=load_weapon.instantiate()
		inst_weapon.linear_velocity=(Vector2(600,0).rotated(dir))*throw_speed
		inst_weapon.global_position=collision_body.global_position+Vector2(15,0).rotated(dir)
		inst_weapon.weapon=dupe_dict(weapon)
		get_parent().call_deferred("add_child",inst_weapon)
		weapon=dupe_dict(default_weapon)
#		get_node("PED_SPRITES/Body/anim/Bullet_Spawn/CPUParticles2D").emitting=false
		var sound_pos=collision_body.global_position
		if get_class()=="Player":
			sound_pos=null
#		AudioManager.play_audio("res://Data/DEFAULT/SOUNDS/GAMEPLAY/snd_Throw.wav",sound_pos,true,1,0,"SFX")


func spawn_bullet(amoumt:int):
	if shake_screen==true:
		get_tree().get_nodes_in_group("Camera")[0].shake=weapon.screen_shake
	weapon["Ammo"]-=1
	for i in amoumt:
		var sus_bullet=def_bullet_ent.instantiate()
		#add da weapon spawn bullet
		sus_bullet.global_position=sprite_body.get_node("anim/Bullet_Spawn").global_position
		var spawn_recoil_add=sprite_body.get_node("anim/Bullet_Spawn").global_rotation
		#add recoil
		if weapon.has("Recoil"):
			spawn_recoil_add+=deg_to_rad(randf_range(-weapon["Recoil"],weapon["Recoil"]))
		sus_bullet.global_rotation=spawn_recoil_add
		#check if AP ammo 
		get_parent().add_child(sus_bullet)
		sus_bullet.damage=weapon["Damage"]













func move_to_point(delta,point,speed=0.7):
	get_node("PED_COL/movement_check").target_position=point-collision_body.global_position
	if get_node("PED_COL/movement_check").is_colliding()==false:
		#cum calculation piss =focused_player.global_position+Vector2(25,0).rotated(focused_player.global_position.direction_to(collision_body.global_position).angle())
		axis=axis.lerp(Vector2(speed,0).rotated(collision_body.global_position.direction_to(point).angle()),clamp(50*delta,0,1))
		body_direction=lerp_angle(body_direction,axis.angle(),0.15)
		path=[]
		movement(null,delta)
	else:
		movement(null,delta)
		var temp_dir=Vector2(0,0)
		if path.size()>2 && path[-1].distance_to(point)<16.0:
			if collision_body.global_position.distance_to(path[0])<8.0:
#				print(path)
				path.remove_at(0)
#				print(path)
			temp_dir=collision_body.global_position.direction_to(path[0])
		else:
			path=get_viewport()._astar._get_path(collision_body.global_position,point)
		axis=temp_dir*speed
#		get_node("Line2d").global_position=Vector2(0,0)
#		get_node("Line2d").points=path
	




func _on_Legs_animation_finished():
	change_leg_sprite_value=true

func _play_animation(animation:String,frame=0,global=false):
#	print(animation)
	var id=weapon["ID"]+"/"
	if global==true:
		id=""
	sprite_index = id+animation
	sprite_body.play(id+animation)



func do_remove_health(damage,killsprite:String="DeadBlunt",rot:float=randf()*PI,frame="rand",body_speed=2,_bleed=false):
	var damage_output : float
	if damage is Array:
		damage_output=randf_range(damage[0],damage[1])
	else:
		damage_output=damage
	if armour>0 && armour-damage_output>0:
		armour=clamp(armour-damage_output,0,300)
	else:
		var changed_value=damage_output-armour
		armour=0
		health=clamp(health-changed_value,0,300)
	if state==ped_states.alive or (state == ped_states.down && "Lean" in sprite_legs.animation):
		if health<=0:
			drop_weapon()
			sprite_legs.play(killsprite)
			if frame=="rand":
				sprite_legs.seek(randf_range(0,sprite_legs_anim.current_animation_length))
			else:
				sprite_legs.seek(frame)
			sprite_legs.global_rotation=rot
			my_velocity=Vector2(damage,0).rotated(sprite_legs.global_rotation-PI)
			sprite_legs.speed_scale=0
			sprite_body.visible=false
			state=ped_states.dead

func go_down(direction=randi()):
	if state == ped_states.alive:
		if sprite_legs.has_animation("GetUp"):
			drop_weapon()
			state = ped_states.down
			sprite_legs.play("GetUp",false,0)
			sprite_legs.speed_scale=0
			sprite_legs.global_rotation=deg_to_rad(direction)+deg_to_rad(180)
			sprite_body.visible=false
			down_timer=8
#			collision_body.set_collision_layer_bit(6,false)
			axis=Vector2(0.8,0).rotated(direction)
#		collision_body.linear_damp=6




func get_up():
	state=ped_states.alive
	sprite_body.visible=true
	get_node("PED_SPRITES/Body/Melee_Area/CollisionShape2D").disabled=true




func do_execution():
	if get_downed_enemies() != null:
		state=ped_states.execute
		axis=Vector2(0,0)
		my_velocity=Vector2(0,0)
		execute_target.my_velocity=Vector2(0,0)
		execute_target.axis=Vector2(0,0)

#		execute_target.get_parent().sprite_legs.get_node("AnimationPlayer").playback_speed=0
		collision_body.global_position=execute_target.collision_body.global_position
		sprite_body.global_rotation=execute_target.sprite_legs.global_rotation-PI
		
		if execute_target.sprite_legs.animation!="GetUpLean":
#			if weapon.execution_sprite!="":
				_play_animation("Execute")
				execute_target.sprite_legs.play("Stomp",false,0)
#			else:
#				drop_weapon()
#				sprite_body.play(default_weapon.id+"/"+default_weapon.execution_sprite)
#				execute_target.sprite_legs.play(default_weapon.ground_sprite,false,0)
#		else:
#				sprite_body.play("ExecuteWall")
#				execute_target.sprite_legs.play("DieLean")
		execute_target.sprite_legs.speed_scale=0	
		sprite_legs.visible=false
		execute_target.can_get_up=false





func get_downed_enemies():
	var ground_enemies = get_tree().get_nodes_in_group("PED")
	in_distance_to_execute = false
	var pickup_dist = 40*40
	
	for enemy in ground_enemies:
		# filter enemies that cannot be executed
		if enemy.get_parent().state == ped_states.down && enemy.visible == true:
			# filter weapons within certain distance
			if enemy.global_position.distance_squared_to(sprites.global_position) < pickup_dist:
				# filter weapons behind walls
				
				get_node("PED_COL/weapon_find").target_position = enemy.global_position - sprites.global_position
				
				if !get_node("PED_COL/weapon_find").is_colliding():
					in_distance_to_execute=true
					execute_target = enemy.get_parent()
					return enemy
	return null




func execute_remove_health(damage,ammo_use=0,animation="",frame="rand",sound=null,_bleed:bool=false):
	if state==ped_states.execute:
		print("test")
		var damage_output
		if damage is Array:
			damage_output=randi_range(damage[0],damage[1])
		else:
			damage_output=damage
		if ammo_use>0:
			var usable_ammo=clamp(weapon["ammo"],1,ammo_use)
			weapon["ammo"]-=1
			damage_output=clamp(execute_target.health,1,999)/usable_ammo
		execute_target.health-=damage_output
		if execute_target.health<=0:
			
#			if sound!=null:
#				AudioManager.play_audio(sound)
			execute_target.state=ped_states.dead
			if animation!="":
				execute_target.sprite_legs.play(animation,false,0)
				if frame=="rand":
					execute_target.sprite_legs.seek(randf_range(0,sprite_legs.get_node("AnimationPlayer").current_animation_length))
				else:
					execute_target.sprite_legs.seek(frame)
			state=ped_states.alive
			sprite_legs.visible=true
			sprite_index=""
			delay=0.1
			return true


#go to the next enemy sprite frame
func execute_e_next_frame(frame_rate:int = 13):
	execute_target.sprite_legs.next_frame(frame_rate)
	return true #output if command was completed



#read the function
func execute_do_click():
	sprite_body.speed_scale=1



func get_classd():
	return "PED"


#used for weapon flipping 
static func angle_difference(from, to):
	return fposmod(to-from + PI, PI*2) - PI
