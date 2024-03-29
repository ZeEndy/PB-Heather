extends Button

@export_node_path("ScrollContainer") var pt_list
@onready var list=get_node(pt_list)
@export_node_path() var parent
@onready var par=get_node(parent)

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(vis_change,0)
	mouse_entered.connect(hover)
	for i in list.get_child(0).get_children():
		if i is Button:
			i.changed.connect(hide_me)
			if i.change=="cursor_method":
				print(str(GAME.get(i.change)))
				print(i.value)
			if str(GAME.get(i.change))==i.value:
				text=i.text+"↓"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if !has_focus():
#		list.visible=false
#	if list.visible==false:
#		button_pressed=false
func hover():
	GUI.s_hover.play()
func vis_change():
	list.visible=!list.visible
	GUI.s_click.play()
func hide_me(value):
	list.visible=false
	text=value+"↓"
