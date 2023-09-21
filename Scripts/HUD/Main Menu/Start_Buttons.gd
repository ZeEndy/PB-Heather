extends Button

@export var start_focus=false
@onready var saved_text=text


# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request("res://Data/Scenes/VFX/ENT_Transition.tscn")
	text="  "+saved_text
	if start_focus==true:
		grab_focus()
		text=" >"+saved_text
	pressed.connect(button_action)


func _process(delta):
	if is_hovered() || button_pressed:
		if text!=" >"+saved_text:
			GUI.s_hover.play()
		text=" >"+saved_text
	else:
		text="  "+saved_text

func button_action():
	GUI.s_click.play()
	if name=="PLAY":
			GUI.s_click.play()
			var scene=ResourceLoader.load_threaded_get("res://Data/Scenes/VFX/ENT_Transition.tscn").instantiate()
			scene.next_level="res://Data/Scenes/Levels/PanicRoom.tscn"
			get_tree().root.add_child(scene)
			owner.queue_free()
			GUI.grab_mouse_back()
	elif name=="CHAPTERS":
		get_node("../../Recordings").visible=!get_node("../../Recordings").visible
		get_node("../../Options").visible=false
		get_node("../OPTIONS").button_pressed=false
	elif name=="OPTIONS":
		get_node("../../Recordings").visible=false
		get_node("../../Options").visible=!get_node("../../Options").visible
		get_node("../CHAPTERS").button_pressed=false
	elif name=="EXIT":
		get_tree().quit()



#func _on_mouse_entered():
#	grab_focus()

#
#func _on_mouse_exited():
#	pass # Replace with function body.


#func _on_focus_entered():
#	text=" >"+saved_text
#
#
#func _on_focus_exited():
#	text="  "+saved_text
