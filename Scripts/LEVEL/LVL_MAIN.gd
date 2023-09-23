extends Node2D

@onready var weapon_preload=preload("res://Data/DEFAULT/ENTS/ENT_GENERIC_WEAPON.tscn")

var points=0
var held_points=0
var combo=0
var combo_timer=0.0
var time=0.0
@export var point_stuff=[]
@export var saved=false
@export var level_complete=false
@export var combat_level=true
@export var n_level="Intern"
@export var n_song="Health - Blue Monday"
@export var n_tape=""
var checkpoint=[]
var restart=[]

@export var song:AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	GUI.play_timer=1.0
	if saved==false:
		saved=true
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		checkpoint=save_level()
		restart=save_level()
	if level_complete==false && song!=null:
		AudioManager.play_song(song)

func _process(delta):
	if Input.is_action_just_pressed("DEBUG_SAVE"):
		_save_checkpoint()
	
	if Input.is_action_just_pressed("reload") && GUI.health_iterp>0.9:
		GAME.cursor_position=GUI.real_mouse
		if Input.is_action_pressed("far_look"):
			load_level(restart)
		else:
			load_level(checkpoint)
	if GAME.enemy_count==0 && level_complete==false:
		level_complete=true
		if combat_level==true:
			AudioManager.play_song("res://Data/Music/mu_Videodrome.ogg")
	if level_complete==false:
		time+=delta
	combo_timer=clamp(combo_timer-delta,0,6)
	if combo_timer==0 && held_points!=0:
		points+=held_points*combo
		combo=0
		held_points=0
	GUI.combo=combo
	GUI.desired_points=points
	GUI.level_time=time


func _save_checkpoint():
#	GAME.save_node_state("checkpoint",self)
	checkpoint=save_level()

func save_level():
	var save_array=[]
	for x in get_children(true):
		if x is SubViewportContainer:
			for i in x.get_child(0).get_children():
				if i is PED:
					var dict={
						"id":i,
						"parent_id":i.get_parent(),
						"variables":{
						"state":i.state,
						"sprite_index":i.sprite_index,
						"leg_index":i.leg_index,
						"body_direction":i.body_direction,
						"add_to_surface":i.add_to_surface,
						"weapon":i.weapon.duplicate(true),
						"health":i.health,
						"bAttack":i.bAttack,
						"global_position":i.collision_body.global_position,
						"delay":i.delay,
						"groups":i.groups,
						"col_groups":i.col_groups,
						"path":i.path,
						"path_index":i.path_index,
						}
					}
					if i is Player:
						dict["variables"].merge({
						"override_input":i.override_input,
						})
					if i is Enemy:
						dict["variables"].merge({
						"enemy_state":i.enemy_state,
						"direction":i.direction,
						"target_point":i.target_point,
						"alert_timer":i.alert_timer,
						"spawn_timer":0.01
						})
					save_array.append(dict)
				if i is WEAPON:
					save_array.append({
						"id":"Weapon",
						"parent_id":i.get_parent(),
						"global_position":i.global_position,
						"rotation":i.rotation,
						"weapon":i.weapon
					})
				if i is goresurf:
					save_array.append({
						"id":i,
						"surf_data":i.surface_data.duplicate(true),
						"avalible_sprites":i.avalible_sprites.duplicate(true)
					})
				if i is Door:
					save_array.append({
						"id":i,
						"door_rot":i.door_rot,
						"player_turn":i.player_turn,
						"next_rot":i.next_rot,
						"door_timer":i.door_timer
#						"swingspeed":i.swingspeed
					})
				if i is Door:
					save_array.append({
						"id":i,
						"door_rot":i.door_rot,
						"player_turn":i.player_turn,
						"next_rot":i.next_rot,
						"door_timer":i.door_timer
					})
				if i is Elevator:
					save_array.append({
						"id":i,
						"parent_id":i.get_parent(),
						"selected_floor":i.selected_floor,
						"timer":i.timer,
					})
				if i.name=="Tiles":
					i as TileMap
					var used_cells=i.get_used_cells(1)
					var atlas_pos=[]
					for t in used_cells.size()-1:
						atlas_pos.append(i.get_cell_atlas_coords(1,used_cells[t]))
					save_array.append({"id":i,"positions":used_cells,"atlas_pos":atlas_pos})
	save_array.append({
		"id":self,
		"combo_timer":combo_timer,
		"combo":combo,
		"held_points":held_points,
		"points":points
	})
	return save_array


func set_child(child,property,value):
	child.set_deferred(property,value)

func get_group(strg):
	var return_array=[]
	if get_tree().get_nodes_in_group(strg)!=null:
		return_array=get_tree().get_nodes_in_group(strg)
	return return_array

func load_level(array):
#	print("fuck")
#	print(save_CUNT)
	GUI.play_timer=3.0
	for i in get_group("Weapon")+get_group("Particles"):
		i.queue_free()
	for i in array:
		var id = i["id"]
		if id is String:
			if id=="Weapon":
				var wep=weapon_preload.instantiate()
				i["parent_id"].add_child(wep)
				wep.global_position=i["global_position"]
				wep.global_rotation=i["rotation"]
				wep.weapon=i["weapon"]
		else:
			if id is PED:
				id._ready()
				id.reparent(i["parent_id"])
				for x in i["variables"]:
					if i["variables"][x] is Dictionary || i["variables"][x] is Array:
						id.set_deferred(x,i["variables"][x].duplicate(true))
					else:
						id.set(x,i["variables"][x])
						if x == "global_position":
							id.collision_body.position=Vector2(0.0,0.0)
				id.reset_groups()
			if id is goresurf:
				id.surface_data=i["surf_data"].duplicate(true)
				id.avalible_sprites=i["avalible_sprites"].duplicate(true)
				id._ready()
			if id is Door:
				id.door_rot=i["door_rot"]
				id.player_turn=i["player_turn"]
				id.door_timer=i["door_timer"]
				id.next_rot=i["next_rot"]
				id._ready()
			if id is TileMap:
				for x in i["positions"].size()-1:
					id.set_cell(1,i["positions"][x],
					id.get_cell_source_id(1,i["positions"][x]),
					i["atlas_pos"][x])
			if id==self:
				combo_timer=i["combo_timer"]
				held_points=i["held_points"]
				points=i["points"]
				combo=i["combo"]

func add_kill():
	combo+=1
	combo_timer=5.0
	held_points+=100
