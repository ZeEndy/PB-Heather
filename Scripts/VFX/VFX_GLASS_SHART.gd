extends AnimatedSprite2D

var velocity=Vector2()
@onready var viewp=get_parent()
func _ready():
	frame=randi_range(0,8)


func _process(delta):
	velocity=lerp(velocity,Vector2.ZERO,10*delta)
	global_position+=velocity*delta
	rotation+=velocity.length()*delta
	if velocity.length()<0.001:
		var new_sprite=AnimatedSprite2D.new()
		new_sprite.sprite_frames=sprite_frames
		new_sprite.animation=animation
		new_sprite.frame=frame
		var c=PhysicsPointQueryParameters2D.new()
		c.position=global_position
		c.collision_mask=128
		c.collide_with_bodies=false
		c.collide_with_areas=true
		var viewp=get_viewport()
		var cunt=get_world_2d().direct_space_state.intersect_point(c,1)
		if cunt!=[]:
			cunt[0].collider.target.call_deferred("add_to_surface",new_sprite,global_position,global_rotation)
		elif viewp.my_surface!=null:
			viewp.my_surface.call_deferred("add_to_surface",new_sprite,global_position,global_rotation)
		queue_free()
