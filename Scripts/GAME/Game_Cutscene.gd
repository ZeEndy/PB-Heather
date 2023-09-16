extends AnimationPlayer

var current_actions=[]
var instance_count_down=0.01
var active=false

# Called when the node enters the scene tree for the first time.
func _ready():
	speed_scale=0.0

func activate():
	active=true
	play("Cutscene")
	speed_scale=0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if active==true:
		if get_children().size()==0:
			speed_scale=1.0
#			print(current_animation_position)
		else:
			speed_scale=0.0

func actor_move_to_point(actor:NodePath,spd:float,position:Vector2):
	var action=action_move_to_point.new()
	var n_actor=get_node(actor)
	action.actor=n_actor
	action.position=position
	action.speed=spd
	add_child(action)

func actor_play_anim(actor:NodePath,desired_anim:String,next_anim:String):
	var action=action_ped_anim.new()
	var n_actor=get_node(actor)
	action.actor=n_actor
	action.desired_anim=desired_anim
	action.next_anim=next_anim
	add_child(action)

func actor_rotate_body(actor:NodePath,rotation:float,spd:float):
	var action=action_rotate_body.new()
	var n_actor=get_node(actor)
	action.actor=n_actor
	action.rotation=deg_to_rad(rotation)
	action.rotation_speed=spd
	add_child(action)

func free_player(actor:NodePath):
	get_node(actor).override_input=false

func end_cutscene():
	active=false
func await_input():
	var action=action_input.new()
	add_child(action)

func show_dialouge(initial_text : String =""):
	Dialouge.show_dialouge()
	Dialouge.change_text(initial_text)

func hide_dialouge():
	Dialouge.hide_dialouge()

func change_dialouge(text):
	Dialouge.change_text(text)
