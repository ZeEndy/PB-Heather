extends Sprite2D

class_name Elevator


@onready var node2d=get_node("Node2d")
@onready var black_out=get_node("Node2d/ColorRect")
@onready var area_check=get_node("Area2d") as Area2D

@onready var top_check=get_node("TopCheck") as RayCast2D
@onready var bottom_check=get_node("BottomCheck") as RayCast2D
@onready var top_anim=get_node("TopAnim") as AnimationPlayer
@onready var bottom_anim=get_node("BottomAnim") as AnimationPlayer
@export var targets=[]
var selected_floor=-1

@export var elevator_time=0.0
var timer=0.0
var player_in_elevator=false
var wait_for_player_to_leave=false

var camera_shaking=false
var elevator_shake=0.2

func _ready():
	for i in targets.size():
		targets[i]=get_node(targets[i])
		if get_viewport()==targets[i]:
			selected_floor=i
	
	await RenderingServer.frame_pre_draw
	if top_check.is_colliding()==false:
		door_animation(top_anim,"Open")
	else:
		door_animation(top_anim,"Close")
	
	
	if bottom_check.is_colliding()==false:
		door_animation(bottom_anim,"Open")
	else:
		door_animation(bottom_anim,"Close")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	node2d.global_position=-get_viewport_transform().origin/get_viewport_transform().get_scale()
	black_out.size=get_viewport_rect().size
	node2d.z_index=z_index-6
	if timer>0:
		timer-=delta
		if z_index!=8:
			for i in area_check.get_overlapping_bodies():
				var parent_obj=i.get_parent()
				if parent_obj is PED:
					player_in_elevator=true
					wait_for_player_to_leave=true
					parent_obj.z_index+=6
					
				else:
					z_index+=6
			
			z_index=8
		
		if timer<elevator_time*0.10+delta && get_parent() != targets[selected_floor]:
			stoping_sound()
		
		if timer<elevator_time*0.10:
			if get_parent() != targets[selected_floor]:
				var floor=targets[selected_floor]
				for i in area_check.get_overlapping_bodies():
					var parent_obj=i.get_parent()
					if parent_obj is PED:
						var saved_node=parent_obj
						get_viewport().remove_child(saved_node)
						floor.add_child(saved_node)
					else:
						var saved_node=i
						get_viewport().remove_child(saved_node)
						floor.add_child(saved_node)
				get_parent().remove_child(self)
				floor.add_child(self)
			if player_in_elevator==true:
				node2d.modulate.a=lerp(node2d.modulate.a,0.0,5*delta)
		else:
			if player_in_elevator==true:
				node2d.modulate.a=lerp(node2d.modulate.a,1.0,5*delta)
			
		if timer<=0:
			arrive()
#			get_node(targets[selected_floor][1]).emit_my_signal()
			if z_index!=2:
				for i in area_check.get_overlapping_bodies():
					if i.get_parent() is PED:
						player_in_elevator=true
						i.get_parent().z_index-=6
					else:
						z_index-=6
				z_index=2
	else:
		if player_in_elevator==true:
			node2d.modulate.a=lerp(node2d.modulate.a,0.0,5*delta)
			if node2d.modulate.a==0.0:
				player_in_elevator=false
		var ar_check=area_check.get_overlapping_bodies()
		for i in area_check.get_overlapping_bodies():
			if i.get_parent() is Player:
				if wait_for_player_to_leave==false:
					next_floor()
		if ar_check.size()==0:
			wait_for_player_to_leave=false



func door_animation(obj,requested:String):
	if obj.assigned_animation!=requested:
		if obj.current_animation=="":
			obj.play(requested)
		else:
			var saved_time=obj.current_animation_length-obj.current_animation_position
			obj.play(requested)
			obj.seek(saved_time,true)
	


func _on_button_interacted(obj):
	obj.anim_disapear()




func next_floor():
	selected_floor+=1
	if selected_floor>targets.size()-1:
		selected_floor=0
	for i in get_children():
		if "Anim" in i.name:
			if i.assigned_animation=="Open":
				door_animation(i,"Close")
	timer=elevator_time

func arrive():
	get_node("Ding").play()
	await get_tree().create_timer(0.69).timeout
	if top_check.is_colliding()==false:
		door_animation(top_anim,"Open")
	if bottom_check.is_colliding()==false:
		door_animation(bottom_anim,"Open")

func stoping_sound():
	get_node("Arrive").play()
	await get_tree().create_timer(0.775).timeout
	camera_shaking=false
	await get_tree().create_timer(0.775).timeout
	get_node("Moving").stop()
	



func moving_sound():
	if timer>0:
		get_node("Departure").play()
		await get_tree().create_timer(0.71).timeout
		camera_shaking=true
		elevator_shake=0.6
		await get_tree().create_timer(0.71).timeout
		get_node("Moving").play()

