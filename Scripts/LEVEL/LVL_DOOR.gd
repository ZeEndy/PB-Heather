extends Node2D

class_name Door

#reference variables
@onready var door_anc=get_node("DOOR_ANCHER") as Node2D
@onready var sprite=get_node("Sprite") as Sprite2D
@onready var e_knocker=get_node("DOOR_ANCHER/Enemy Knocker") as Area2D

var player_turn=false
var desired_rot=0
var process=false
var count_down=0.1


var door_size=Vector2(34,10)
@export var PED_SCALE=8

@export var easing : Curve
@export var locked = false
@export var unlock_on_level_end=false
@export var spring_return=false

@export var door_flip=1

@export_range(0.0,135.0) var left
@export_range(0.0,135.0) var right

@onready var door_rots=[-left,0,right]
var next_rot=1


var _wad=null

var door_rot=0.0
var prev_rot=0.0
var door_timer=1.0

func _ready():
	process=false
	count_down=0.05

func _physics_process(delta):
	if process==true && locked==false:
		var p_col_check=player_collision_checker()
		var e_col_check=enemy_collision_checker()
		var dir=0
		if p_col_check[0]!=0:
			dir=p_col_check[0]
		else:
			dir=e_col_check[0]
		
		p_col_check.remove_at(0)
		e_col_check.remove_at(0)
		
#		if active == false:
		if door_timer>0.4 || player_turn==false:
			for i in p_col_check:
				if i[0] is Player:
					if dir!=0: # i cba to do full error prevention
						player_turn=true
						prev_rot=door_anc.rotation
						
						next_rot=clamp(next_rot+dir,0,2)
						
						door_rot=deg_to_rad(door_rots[next_rot])
						
						door_rot=clamp(door_rot,deg_to_rad(-right),deg_to_rad(left))
						door_timer=0.0
			if player_turn==false:
				for i in e_col_check:
					if i[0] is Enemy && (i[0].state==0 || ((i[0].state == 4 || i[0].state == 3) && i[0].my_velocity.length()>50.0)):
						if dir!=0: # i cba to do full error prevention
							prev_rot=door_anc.rotation
							
							next_rot=clamp(next_rot+dir,0,2)
							door_rot=deg_to_rad(door_rots[next_rot])
							
							door_rot=clamp(door_rot,deg_to_rad(-right),deg_to_rad(left))
							door_timer=0.0
		elif door_timer<0.6 && player_turn==true:
			for i in e_knocker.get_overlapping_bodies():
				var par=i.get_parent()
				if par is Enemy && par.state==0:
					var door_org=door_anc.global_position+Vector2(door_size.x*0.5,0).rotated(door_anc.global_rotation)
					par.go_down(door_org.direction_to(i.global_position).angle())
					par.my_velocity=door_org.direction_to(i.global_position)*300.0
					
		
		door_timer=clamp(door_timer+delta,0,1.0)
		
		door_anc.rotation=lerp(prev_rot,door_rot,easing.sample(door_timer))
		if door_timer>0.6:
			player_turn=false


func _process(delta):
	if process==false:
		door_anc.rotation=door_rot
		count_down=clamp(count_down-delta,0,1)
		if count_down==0.0:
			process=true
			
	else:
		sprite.global_rotation=lerp_angle(sprite.global_rotation,door_anc.global_rotation,10*delta)


func player_collision_checker():
	var mask=0b0000000000000000100
	var collision_objects=[]
	var shape = RectangleShape2D.new()
	shape.extents=door_size
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	get_node("DOOR_ANCHER/Sprite2D").set_transform(Transform2D(door_anc.global_rotation, door_anc.global_position+Vector2(door_size.x*0.5-1,0).rotated(door_anc.global_rotation)))
	get_node("DOOR_ANCHER/Sprite2D").scale=door_size
	query.collision_mask=mask
	var space = get_world_2d().direct_space_state
	query.set_transform(Transform2D(door_anc.global_rotation, door_anc.global_position+Vector2(door_size.x*0.5-1,0).rotated(door_anc.global_rotation)))
	collision_objects+=space.intersect_shape(query,5)
#	if collision_objects.size()>0:
#		print(collision_objects)
	var return_array=[]
	var test=0
	var raycast=PhysicsRayQueryParameters2D.new()
	raycast.from=door_anc.global_position
	raycast.collision_mask=mask
	raycast.hit_from_inside=true
	
	for i in collision_objects:
		if (i.collider.get_parent() is PED && (i.collider.get_parent().my_velocity.length()>10) ):
			var rots=[30,25,20,15,10,5,-5,-10,-15,-20,-25,-30]
			for rot in rots:
				for y in int(door_size.y*0.5):
					raycast.to=door_anc.global_position+Vector2(door_size.x,y*2-(door_size.y*0.5)).rotated(door_anc.global_rotation+deg_to_rad(rot))
					if space.intersect_ray(raycast)!={}:
						test-=rot
			return_array.append([i.collider.get_parent(),i.collider.global_position])
	if test!=0:
		test/=abs(test)
	return_array.push_front(test)
	return return_array


func enemy_collision_checker():
	var mask=0b0000000000000000001
	var collision_objects=[]
	var shape = RectangleShape2D.new()
	shape.extents=door_size
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	get_node("DOOR_ANCHER/Sprite2D").set_transform(Transform2D(door_anc.global_rotation, door_anc.global_position+Vector2(door_size.x*0.5-1,0).rotated(door_anc.global_rotation)))
	get_node("DOOR_ANCHER/Sprite2D").scale=door_size
	query.collision_mask=mask
	var space = get_world_2d().direct_space_state
	query.set_transform(Transform2D(door_anc.global_rotation, door_anc.global_position+Vector2(door_size.x*0.5-1,0).rotated(door_anc.global_rotation)))
	collision_objects+=space.intersect_shape(query,5)
#	if collision_objects.size()>0:
#		print(collision_objects)
	var return_array=[]
	var test=0
	var raycast=PhysicsRayQueryParameters2D.new()
	raycast.from=door_anc.global_position
	raycast.collision_mask=mask
	raycast.hit_from_inside=true
	
	for i in collision_objects:
		if (i.collider.get_parent() is PED && (i.collider.get_parent().my_velocity.length()>10) ):
			var rots=[30,25,20,15,10,5,-5,-10,-15,-20,-25,-30]
			for rot in rots:
				for y in int(door_size.y*0.5):
					raycast.to=door_anc.global_position+Vector2(door_size.x,y*2-(door_size.y*0.5)).rotated(door_anc.global_rotation+deg_to_rad(rot))
					if space.intersect_ray(raycast)!={}:
						test-=rot
			return_array.append([i.collider.get_parent(),i.collider.global_position])
	if test!=0:
		test/=abs(test)
	return_array.push_front(test)
	return return_array

static func angle_difference(from, to):
	return fposmod(to-from + PI, PI*2) - PI
