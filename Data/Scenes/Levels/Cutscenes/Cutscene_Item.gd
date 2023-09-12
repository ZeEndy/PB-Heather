extends Area2D

@export_node_path("AnimationPlayer") var cutscene_object
@onready var obj=get_node(cutscene_object)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_overlapping_bodies().size()>0 && Input.is_action_just_pressed("interact"):
		obj.activate()
