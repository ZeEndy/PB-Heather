extends PED

class_name Player

var glob_delta=0
var glob_phys_delta=0

var interact_target={}

signal interact_anim_finish()
signal interact_pos_reached()

# Typing in a abilty for the player character lets know what abilty to use i.e. rolldoge, killing punches, tony punches, ect 
@export var ability = ""
@export var saved_ability_variable=[]
@export var ability_active=""
@export var override_input=false
var cursor_pos = Vector2(0,0)
@export var camera_obj=0
@export var axis_multiplier=1.0
var rotation_multip=1.0


@export var in_combat=true



var bullet_container=[]


var after_image_reset=0.0




@onready var CAMERA=get_tree().get_nodes_in_group("Glob_Camera_pos")[0]
@onready var cam_track=get_node("PED_SPRITES/Body/CameraTrack")
#@onready var turn_angle=sprite_body.global_rotation
#@export var cursor=null
#
func print_test():
	print("test")

func _ready():
	super()
	CAMERA.target=cam_track


func _physics_process(delta):
	super(delta)
	glob_phys_delta=delta
#	if Input.is_action_just_pressed("weapon_swap"):
#		holster_weapon()
#	if Input.is_action_just_pressed("ui_accept"):
#		sprite_index="MaskOn"
	collision_body.global_rotation = 0
	if state == ped_states.alive:
		if in_combat==true && override_input==false:
			if Input.is_action_just_pressed("interact"):
				switch_weapon()
		if in_combat==true && Input.is_action_just_pressed("execute"):
			do_execution()
		
		if interact_target=={}:
			axis = Vector2(Input.get_action_strength("right")-Input.get_action_strength("left"),Input.get_action_strength("down")-Input.get_action_strength("up"))*axis_multiplier
		else:
			print(rad_to_deg(interact_target.pos.angle_to_point(collision_body.global_position)))
			axis = Vector2(1,0).rotated(collision_body.global_position.angle_to_point(interact_target.pos))
			print(collision_body.global_position.distance_to(interact_target.pos))
			override_input=true
			body_direction=lerp_angle(body_direction,interact_target.rot,clamp(15*delta,0,1))
				
		if override_input==false:
			movement(null,delta)


#		if Input.is_action_just_pressed("switch_mode") && weapon.trigger_pressed==false:
#			if weapon.type=="semi":
#				weapon.type="burst"
#			else:
#				weapon.type="semi"
		
		
		
		if override_input==false && in_combat==true:
			if weapon!={}:
				if Input.is_action_pressed("attack"):
					bAttack=true
				else:
					bAttack=false


func attack():
	if weapon["Type"]=="Firearm":
		get_tree().call_group("Enemy_Parent","investigate_gunshot",weapon["HR"])
	super()

func _process(delta):
	glob_delta=delta
	super(delta)
#	if weapon.has("Ammo"):
#		GUI.ammo=weapon.ammo
#		GUI.max_ammo=weapon.max_ammo
#		get_node("PED_COL/Label").text=str(weapon["Ammo"])+"/"+str(weapon["Max ammo"])
	
	if OS.is_debug_build():
		Engine.time_scale=1-0.85*float(Input.is_action_pressed("DEBUG_ABILTY"))
		debug_rand_weapon()
	
	
	GUI.health=clamp(health,0,100)/100.0
	if state == ped_states.alive:
		cursor_pos=GUI.mouse
		GUI.p_pos=sprite_body.get_screen_transform().origin
		
		if cursor_pos != null:
			if override_input==false:
				body_direction = lerp_angle(body_direction,-cursor_pos.angle_to(Vector2(1,0)),clamp(40*rotation_multip*delta,0,1))
				rotation_multip=lerp(rotation_multip,1.0,clamp(25*delta,0,1))
				given_height = cursor_pos.length()*0.0018
				if CAMERA!=null:
					cam_track.position=Vector2(32+given_height*70,0)
			else:
				if CAMERA!=null:
					cam_track.position=Vector2(0,0)
		
		sprite_body.global_rotation = body_direction
		if weapon["Type"]=="Firearm":
			GUI.ammo=weapon["Ammo"]
			GUI.max_ammo=weapon["Max ammo"]
		else:
			GUI.ammo=-1
			GUI.max_ammo=-1
		GUI.in_combat=in_combat
	elif state == ped_states.execute:
		if CAMERA!=null:
			cam_track.position=Vector2(0,0)
		if execute_click==true:
			if Input.is_action_just_pressed("attack"):
				execute_do_click()
			

func do_remove_health(damage,killsprite:String="DeadBlunt",rot:float=randf()*180,frame="rand",body_speed=2,_bleed=false):
	get_tree().get_nodes_in_group("Glob_Camera_pos")[0].add_shake(damage/10,true)
	body_direction+=randf_range(deg_to_rad(10),deg_to_rad(20))* ([-1,1][randi_range(0,1)])
	rotation_multip=0.2
	super(damage,killsprite,rot,frame,body_speed,_bleed)

func leave_execution():
	super()




func do_execution():
	super()

#func _unhandled_input(event):
#	if state==ped_states.alive:
#		if event.is_action_pressed("scroll_up") or event.is_action_pressed("scroll_down"):
#			holster_weapon()


#func holster_weapon():
#	if (weapon.walk_sprite in sprite_index):
#		if holster==null:
#			if weapon.id!=default_weapon.id:
#				print("holster_empty")
#				var holst=weapon.get("holster")
#				var empty_holst=weapon.get("holster_empty")
#				var cur_sprite_index=""
#				if weapon.ammo>0:
#					if holst!=null:
#						cur_sprite_index=holst
#					else:
#						cur_sprite_index=empty_holst
#				else:
#					if empty_holst!=null:
#						cur_sprite_index=empty_holst
#					else:
#						cur_sprite_index=holst
#				if cur_sprite_index!="" && cur_sprite_index!=null:
#					sprite_body.play(cur_sprite_index,false)
#					sprite_index=cur_sprite_index
#
#		if holster!=null:
#			drop_weapon()
#			print("holster_full")
#			var holst=holster.get("unholster")
#			var empty_holst=holster.get("unholster_empty")
#			var cur_sprite_index=""
#			if holster.ammo>0:
#				if holst!=null:
#					cur_sprite_index=holst
#				else:
#					cur_sprite_index=empty_holst
#			else:
#				if empty_holst!=null:
#					cur_sprite_index=empty_holst
#				else:
#					cur_sprite_index=holst
#			if cur_sprite_index!="":
#				sprite_body.play(cur_sprite_index,false)
#				sprite_index=cur_sprite_index
#



#func drop_weapon(throw_speed=1,dir=null):
#	sprite_body.get_node("anim/BARREL").visible=false
#	super(throw_speed,dir)



func get_classd():
	return "Player"


func debug_rand_weapon():
		if Input.is_action_just_pressed("DEBUG_SPAWN_GUN"):
			var rand_list=["PB","AR-15","AK-74U","OU-DB","1911"]
			var random_select=int(round(randf_range(0,rand_list.size()-1)))
			drop_weapon()
			weapon=Database.get_wep(rand_list[random_select])
			sprite_index = ""




func fuck_around_anim():
#	print("worky")
	pass

func _play_animation(animation:String,frame=0,global=false):
	super(animation,frame,global)


#func _on_animation_player_animation_changed(old_name, new_name):



func _on_animation_player_animation_started(anim_name):
	if  ("Insert_shell" in anim_name) || ("Reload" in anim_name) || ("Clear" in anim_name):
		GUI.show_mag_timer=2.5
		GUI.show_ammo_timer=2.5

func interact_anim_signal():
	interact_anim_finish.emit()
