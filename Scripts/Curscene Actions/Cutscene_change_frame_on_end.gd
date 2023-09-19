extends Node

class_name action_change_frame_on_end

var actor=null
var obj=null
var frame=0
var desired_anim=""

# Called when the node enters the scene tree for the first time.
func _ready():
	if actor!=null:
		actor.sprite_body_anim.animation_finished.connect(die)


func die(anim):
	obj.frame=frame
	queue_free()
