extends Node

class_name action_ped_anim

var actor=null
var desired_anim=""
var next_anim=""

# Called when the node enters the scene tree for the first time.
func _ready():
	if actor!=null:
		actor.sprite_body_anim.animation_finished.connect(die)
		actor.sprite_index=desired_anim


func die(anim):
	if desired_anim==anim:
		get_parent().advance(0.1)
		await RenderingServer.frame_pre_draw
		actor.sprite_index=next_anim
		queue_free()
