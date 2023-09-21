extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	await RenderingServer.frame_post_draw
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GUI.aspect.visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#



func _on_play_button_up():
	print("Test")
