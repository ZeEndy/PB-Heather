extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var z_ready=false
@onready var saved_z=z_index
var change_z=0.15
var bounce_speed=0.6+randf()*1.4
@onready var audio = get_node("Bounce")
var bounce_timer=0.2


func _ready():
	if get_node_or_null("CPUParticles2D")!=null:
		if round(randf_range(0,3))==2 && GAME.particle_quality<=1:
			get_node("CPUParticles2D").emitting=true
#		ready=true
#		z_index=-2


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
#	if get_node_or_null("CPUParticles2D")!=null:
#		get_node("CPUParticles2D").emitting=true
	angular_velocity=(linear_velocity.length())*5
	if change_z>0:
		change_z-=delta
	else:
		z_ready=true
#		print(z_index)
		z_index=saved_z-2
	
	
	if bounce_timer>0:
		bounce_timer-=delta*bounce_speed
	else:
		if bounce_speed>0.5:
			audio.play()
		bounce_speed*=0.5
		bounce_timer=0.2
	if linear_velocity.length()<10:
		if get_node_or_null("CPUParticles2D"):
			get_node("CPUParticles2D").emitting=false
	if linear_velocity.length()<0.001 && z_ready==true:
		var sprite = get_node("Sprite")
		remove_child(sprite)
		var c=PhysicsPointQueryParameters2D.new()
		c.position=global_position
		c.collision_mask=128
		c.collide_with_bodies=false
		c.collide_with_areas=true
		var viewp=get_viewport()
		var cunt=get_world_2d().direct_space_state.intersect_point(c,1)
		if cunt!=[]:
			cunt[0].collider.target.call_deferred("add_to_surface",sprite,global_position,global_rotation)
		elif viewp.my_surface!=null:
			viewp.my_surface.call_deferred("add_to_surface",sprite,global_position,global_rotation)
		if get_node_or_null("Sprite")==null:
			queue_free()
