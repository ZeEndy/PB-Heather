extends Sprite2D


@onready var cunt=get_node("Button/CanvasLayer/Container/Control/ColorRect/GridContainer")
@onready var node2d=get_node("Node2d")
@onready var area_check=get_node("Area2d")

@export var targets=[]
var selected_floor=-1

@export var elevator_time=0.0
var timer=0.0
var player_in_elevator=false

func _ready():
	
	for i in targets.size():
		var id=targets[i]
		targets[i][0]=get_node(id[0])
		targets[i][1]=get_node(id[1])
		if get_viewport()==id[0]:
			selected_floor=i
			id[1].play("Open")
		
#	get_node("Button/CanvasLayer/Container/Control/ColorRect").size.y=100.0*(ceil(float(cunt_count)*0.5))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	node2d.global_position=-get_viewport_transform().origin/get_viewport_transform().get_scale()
	get_node("Node2d/ColorRect").size=get_viewport_rect().size
	node2d.z_index=z_index-6
	if timer>0:
		timer-=delta
		if z_index!=8:
			for i in area_check.get_overlapping_bodies():
				var parent_obj=i.get_parent()
				if parent_obj is PED:
					player_in_elevator=true
					parent_obj.z_index+=6
				else:
					z_index+=6
			z_index=8
		
		
		
		if timer<elevator_time*0.10:
			if get_parent() != targets[selected_floor][0]:
				var floor=targets[selected_floor][0]
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
			get_node(targets[selected_floor][1]).emit_my_signal()
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



func door_animation(obj,requested:String):
	var obj_anim_player=obj.get_node("Animation")
	if obj_anim_player.assigned_animation!=requested:
		if obj_anim_player.current_animation=="":
			obj_anim_player.play(requested)
		else:
			var saved_time=obj_anim_player.current_animation_length-obj_anim_player.current_animation_position
			obj_anim_player.play(requested)
			obj_anim_player.seek(saved_time,true)
	


func _on_button_interacted(obj):
	obj.anim_disapear()




func select_floor(floor):
	if selected_floor!=floor:
		selected_floor=floor
		for i in get_children():
			if "Door" in i.name:
				if i.get_node("Animation").assigned_animation=="Open":
					door_animation(i,"Close")
		timer=elevator_time


