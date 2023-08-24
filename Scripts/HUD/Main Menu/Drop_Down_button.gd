extends Button

@export_node_path("ScrollContainer") var pt_list
@onready var list=get_node(pt_list)
@export_node_path() var parent
@onready var par=get_node(parent)

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(vis_change,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !has_focus():
		list.visible=false
	if list.visible==false:
		button_pressed=false



func vis_change():
	list.visible=!list.visible
