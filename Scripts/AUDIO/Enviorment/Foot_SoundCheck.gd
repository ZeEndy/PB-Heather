extends Marker2D


@export var sound_list={
	"Blood":"",
	"Broken Glass":"",
	"Carpet":"",
	"Tile":"",
	"Wood":"",
	"Concrete Road":"",
	"Concrete":"",
}
@export_node_path("AudioStreamPlayer","AudioStreamPlayer2D") var foot_player_path
@onready var foot=get_node(foot_player_path) as AudioStreamPlayer
@export_node_path("AudioStreamPlayer","AudioStreamPlayer2D") var foot_overlay_player_path
@onready var foot_overlay=get_node(foot_overlay_player_path) as AudioStreamPlayer

var tilemap

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap=get_viewport().get_node("Tiles")
	for sound in sound_list:
		if sound_list[sound] is String:
			sound_list[sound]=load(sound_list[sound])
	

func _process(delta):
	foot.volume_db=lerp(foot.volume_db,0.0-10.0*float(foot_overlay.stream!=null),10*delta)
	foot_overlay.volume_db=lerp(foot_overlay.volume_db,0.0+5.0*float(foot_overlay.stream!=null),10*delta)

func _enter_tree():
	tilemap=get_viewport().get_node("Tiles")

func check_sound():
	tilemap as TileMap
	var touch = tilemap.local_to_map(global_position)
	var data = tilemap.get_cell_tile_data(3, touch)
	var data_2 =tilemap.get_cell_tile_data(2, touch)
	if data:
		foot.stream=sound_list[data.get_custom_data("Sound")]
		print(data.get_custom_data("Sound"))
	else:
		print("nothing")
	if data_2:
		foot_overlay.stream=sound_list[data_2.get_custom_data("Sound")]
		print(data_2.get_custom_data("Sound"))
	else:
		foot_overlay.stream=null
		print("nothing")

