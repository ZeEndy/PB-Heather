extends Control

#@onready var click=get_node("Click")
#@onready var hover=get_node("Hover")
#@onready var slider=get_node("Slider")
# Called when the node enters the scene tree for the first time.
func _ready():
	await RenderingServer.frame_post_draw
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
#	GUI.get_node("Cursor").visible=false
	GUI.aspect.visible=false
	print(clamp(linear_to_db(0.0),-80,0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#



func _on_play_button_up():
	print("Test")
