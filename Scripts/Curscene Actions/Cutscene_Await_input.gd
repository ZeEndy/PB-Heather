extends Node

class_name action_input


# Called when the node enters the scene tree for the first time.
#func _ready():
#	actor.reached_point.connect(die)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("attack"):
		queue_free()
