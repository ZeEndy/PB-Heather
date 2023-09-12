extends Node

class_name action_move_to_point

var actor=null
var position=Vector2()
var speed=0

# Called when the node enters the scene tree for the first time.
func _ready():
	actor.reached_point.connect(die)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if actor!=null:
		actor as PED
		actor.move_to_point(position,speed)
		if actor is Player:
			actor.override_input=true

func die():
	actor as PED
	actor.my_velocity=Vector2.ZERO
	actor.axis=Vector2.ZERO
	actor.collision_body.velocity=Vector2.ZERO
	actor.collision_body.global_position=position
	queue_free()
