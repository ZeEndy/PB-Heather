extends AnimatedSprite2D

@export var input=""
@export var pool_size=25
var input_map={
	"Big Splat":["Big Splat 1","Big Splat 2"],
	"Brains":["Brains"],
	"Pool":["Pool"],
	"Splat":["Splat 1","Splat 2","Splat 3","Splat 4"],
	"Speck":["Speck"],
	"Squirt":["Squirt 1","Squirt 2"]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	animation=input_map[input][randi_range(0,input_map[input].size()-1)]
	animation_finished.connect(end_sprite)
	visibility_changed.connect(start)

func start():
	if visible==true:
		frame=0
		play(animation)
		speed_scale=1
	else:
		frame=0
		stop()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if "Pool" in animation && frame>=pool_size && is_playing():
		end_sprite()

func end_sprite():
	add_to_surf()
	speed_scale=0

func add_to_surf():
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
