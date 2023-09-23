extends SubViewport


@export var floor_clear=false
@export var solid_collisions_list=[]
@export_node_path("goresurf") var path_to_surf
@export_node_path("TileMap") var astar
var _astar=null
var my_surface=null
var viewp
@onready var parent=get_parent()
#@onready var navigation=get_node(navigation_path)


var time_to_reset_navmap=0.1
var reset_navmap=true
var intensity=0
var chromatic=0.1
var death=0;

@export var current=false
var execute_once=true

var constantly_show=false

#
func _ready():
	viewp=get
	if path_to_surf!=null:
		my_surface=get_node_or_null(path_to_surf)
	if astar != null:
		_astar=get_node_or_null(astar)

#func _physics_process(_delta):
#	floor_clear=true
#	for i in get_children():
#		if i in get_tree().get_nodes_in_group("Enemy_Parent"):
#			floor_clear=false

func _process(delta):
	if GAME.player_count>0:
		if GAME.player_group[0].get_parent() in get_children():
			parent.visible=true
			audio_listener_enable_2d=true
			parent.modulate=Color(1,1,1)
		else:
			audio_listener_enable_2d=false
			if constantly_show==true:
				parent.visible=true
				parent.modulate=Color(0.5,0.5,0.5)
				constantly_show=false
			else:
				parent.visible=false
	size=parent.get_viewport_rect().size
	if current==true && OS.get_name()!="HTML5":
		intensity=clamp(intensity+(float(Input.is_action_just_pressed("ui_up"))-float(Input.is_action_just_pressed("ui_down")))*0.1,0,0.545)
func _physics_process(delta):
	floor_clear=true
	for i in get_children():
		if (i is Enemy && i.health!=0):
			floor_clear=false



