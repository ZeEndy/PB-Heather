extends Sprite2D

@onready var viewp=get_viewport()
@onready var root=owner

@onready var door_col=get_node("StaticBody2D/Door") as CollisionPolygon2D
@onready var door_sprite=get_node("Door") as Sprite2D
@onready var door_area=get_node("DoorCheck") as Area2D
var rot_target=0.0
@onready var pullin=get_node("PullIn") as Area2D


@onready var s_open=get_node("DoorOpen") as AudioStreamPlayer2D
var bopen=false
@onready var s_close=get_node("DoorClose") as AudioStreamPlayer2D
var bclose=false
@onready var s_engine=get_node("EngineStart") as AudioStreamPlayer
var bengine=false



@export var next_level = ""
@export var next_scene = ""



# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request("res://Data/Scenes/VFX/ENT_Transition.tscn")
	s_engine.finished.connect(switch_level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if root.combat_level==false || root.level_complete==true:
		door_col.disabled=true
		var area_check=door_area.get_overlapping_bodies()
		if area_check.size()>0:
			rot_target=80.0
			if bopen==false:
				s_open.play()
				bopen=true
				bclose=false
		else:
			rot_target=0.0
		
		var next_step=move_toward(door_sprite.rotation_degrees,rot_target,clamp(100.0*delta,0.0,10.0))
		if rot_target==0 && next_step==0:
			if bclose==false:
				s_close.play()
				bclose=true
				bopen=false
		
		
		for i in pullin.get_overlapping_bodies():
			var par=i.get_parent()
			if par is Player:
				par.override_input=true
				par.axis=i.global_position.direction_to(pullin.global_position)*0.25
				par.body_direction=lerp_angle(par.body_direction,global_rotation,clamp(10*delta,0,1))
				par.movement(null,delta)
				if i.global_position.distance_to(pullin.global_position)<1 && door_sprite.rotation_degrees==0:
					if bengine==false:
						s_engine.play()
						bengine=true
						GAME.fade=true
	
	door_sprite.rotation_degrees=move_toward(door_sprite.rotation_degrees,rot_target,clamp(200.0*delta,0.0,15.0))
func switch_level():
	if next_level!="":
		GAME.fade=false
		GAME.fade_color=0
		var scene=ResourceLoader.load_threaded_get("res://Data/Scenes/VFX/ENT_Transition.tscn").instantiate()
		scene.next_level=next_level
		get_tree().root.add_child(scene)
		owner.queue_free()
	else:
		get_tree().change_scene_to_file(next_scene)
