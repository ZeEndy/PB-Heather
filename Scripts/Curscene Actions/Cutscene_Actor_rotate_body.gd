extends Node

class_name action_rotate_body

var actor=null
var rotation=0
var rotation_speed=0



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if actor!=null:
		actor as PED
		actor.body_direction=lerp_angle(actor.body_direction,rotation,rotation_speed*delta)
		if abs(angle_difference(actor.body_direction,rotation))<0.01:
			actor.body_direction=rotation
			die()

func die():
	queue_free()

static func angle_difference(from, to):
	return fposmod(to-from + PI, PI*2) - PI
