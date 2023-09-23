extends Node2D

@onready var blood=preload("res://Data/Scenes/VFX/ENT_blood.tscn")
@onready var viewp=get_viewport()
@onready var pool=get_node("BloodPool/Blood")
var all_blood_despawned=false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_child_count()>1 && pool.speed_scale==0:
		all_blood_despawned=false
	else:
		all_blood_despawned=true

func spawn_blood(type:String,direction:float,speed:float,off_pos:Vector2=Vector2.ZERO,count:int=1):
	for i in count:
		var b_part=blood.instantiate()
		b_part.input=type
		b_part.global_position=global_position+off_pos.rotated(global_rotation-PI*0.5)
		add_child(b_part)
		b_part.global_rotation=rotation-PI+direction+randf_range(-PI*0.5,PI*0.5)
		b_part.velocity=Vector2(speed*randf(),0).rotated(b_part.global_rotation+PI)
		b_part.visible=true
		b_part.play(b_part.animation)
#		b_part.z_index=get_parent().z_index
		b_part.top_level=true
		b_part.start()

func clear():
	for i in get_children():
		if !(i is Marker2D):
			i.queue_free()
#	"Big Splat"
#	"Brains"
#	"Pool"
#	"Splat"
#	"Speck"
#	"Squirt
