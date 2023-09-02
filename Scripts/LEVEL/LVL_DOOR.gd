extends Node2D

class_name Door

#reference variables
@onready var door_anc=get_node("DOOR_ANCHER")


var active=false
var desired_rot=0
var process=false
var count_down=0.1


var door_size=Vector2(32,8)
@export var PED_SCALE=8

@export var easing : Curve
@export var locked = false
@export var unlock_on_level_end=false
@export var spring_return=false

@export var door_flip=1

@export_range(0.0,135.0) var left
@export_range(0.0,135.0) var right

var _wad=null

var door_rot=0.0
var prev_rot=0.0
var door_timer=0.0

func _ready():
	process=false
	count_down=0.05

func _physics_process(delta):
	if process==true:
		var p_col_check=player_collision_checker()
		var dir=p_col_check[0]
		p_col_check.remove_at(0)
		
		if active == false:
			for i in p_col_check:
				if i[0] is Player:
					active=true
					prev_rot=door_anc.rotation
					door_rot+=deg_to_rad(135)*dir
					door_rot=clamp(door_rot,deg_to_rad(-right),deg_to_rad(left))
					door_timer=0.0
		else:
			pass


func _process(delta):
	if process==false:
		door_anc.rotation=door_rot
		count_down=clamp(count_down-delta,0,1)
		if count_down==0.0:
			process=true
			
	else:
		door_timer=clamp(door_timer+delta,0,1.0)
		
		door_anc.rotation=lerp_angle(prev_rot,door_rot,easing.sample(door_timer))
		if door_timer>0.6:
			active=false


func player_collision_checker():
	var mask=0b0000000000000000100
	var collision_objects=[]
	var shape = RectangleShape2D.new()
	shape.extents=door_size
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	get_node("DOOR_ANCHER/Sprite2D").set_transform(Transform2D(door_anc.global_rotation, door_anc.global_position+Vector2(door_size.x*0.5,0).rotated(door_anc.global_rotation)))
	get_node("DOOR_ANCHER/Sprite2D").scale=door_size
	query.collision_mask=mask
	var space = get_world_2d().direct_space_state
	query.set_transform(Transform2D(door_anc.global_rotation, door_anc.global_position+Vector2(door_size.x*0.5,0).rotated(door_anc.global_rotation)))
	collision_objects+=space.intersect_shape(query,5)
	var return_array=[]
	var test=0
	var raycast=PhysicsRayQueryParameters2D.new()
	raycast.from=door_anc.global_position
	raycast.collision_mask=mask
	
	for i in collision_objects:
		if (i.collider.get_parent() is PED && (i.collider.get_parent().my_velocity.length()>10) ):
			var rots=[30,25,20,15,10,5,-5,-10,-15,-20,-25,-30]
			for rot in rots:
				raycast.to=door_anc.global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation+deg_to_rad(rot))
				if space.intersect_ray(raycast)!={}:
					test-=rot
			#cheaper but not better
#			if angle_difference(door_anc.global_rotation,direction)>deg_to_rad(90) && angle_difference(door_anc.global_rotation,direction+deg_to_rad(180)):
#				test-=1
#			else:
#				test+=1
			return_array.append([i.collider.get_parent(),i.collider.global_position])
	if test!=0:
		test=test/abs(test)
	return_array.push_front(test)
	return return_array


func enemy_collision_checker():
	var mask=0b0000000000000000001
	var collision_objects=[]
	var shape = RectangleShape2D.new()
	shape.extents=door_size/2
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	get_node("DOOR_ANCHER/Sprite2D").set_transform(Transform2D(door_anc.global_rotation, door_anc.global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation)))
	get_node("DOOR_ANCHER/Sprite2D").scale=door_size
	query.collision_mask=mask
	var space = get_world_2d().direct_space_state
	query.set_transform(Transform2D(door_anc.global_rotation, door_anc.global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation)))
	collision_objects+=space.intersect_shape(query,5)
#	for ang in range(abs(round(swingspeed))):
#		var space2 = get_world_2d().direct_space_state
#		query.set_transform(Transform2D(door_anc.global_rotation+deg_to_rad(ang*active), global_position+Vector2(door_size.x/2,0).rotated(door_anc.global_rotation+deg_to_rad(ang*active))))
#		collision_objects+=space2.intersect_shape(query,5)
	var return_array=[]
	var test=0
	var raycast=PhysicsRayQueryParameters2D.new()
	raycast.from=door_anc.global_position
	raycast.collision_mask=mask
	
	for i in collision_objects:
		if (i.collider.get_parent() is PED && (i.collider.get_parent().my_velocity.length()>10) ):
			var rots=[30,25,20,15,10,5,-5,-10,-15,-20,-25,-30]
			for rot in rots:
				raycast.to=door_anc.global_position+Vector2(door_size.x,0).rotated(door_anc.global_rotation+deg_to_rad(rot))
#				print(space.intersect_ray(raycast))
				if space.intersect_ray(raycast)!={}:
					test-=rot
#			if angle_difference(door_anc.global_rotation,direction)>deg_to_rad(90) && angle_difference(door_anc.global_rotation,direction+deg_to_rad(180)):
#				test-=1
#			else:
#				test+=1
			return_array.append([i.collider.get_parent(),i.collider.global_position])
	if test!=0:
		test=test/abs(test)
#	test=clamp(test,0.0,1.0)
	return_array.push_front(test)
	return return_array

static func angle_difference(from, to):
	return fposmod(to-from + PI, PI*2) - PI
