extends Button

var hover=false
@export var next_level=""
@export var level_name=""
@export var next_song=""
#var transition=

# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request("res://Data/Scenes/VFX/ENT_Transition.tscn")
	pressed.connect(switch_level)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hover==false && is_hovered():
		GUI.s_hover.play()
		hover=true
	if !is_hovered():
		hover=false

func switch_level():
	GUI.s_click.play()
	var scene=ResourceLoader.load_threaded_get("res://Data/Scenes/VFX/ENT_Transition.tscn").instantiate()
	scene.next_level=next_level
	get_tree().root.add_child(scene)
	owner.queue_free()
	GUI.grab_mouse_back()
