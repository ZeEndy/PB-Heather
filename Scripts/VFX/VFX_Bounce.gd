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
@export_node_path("AudioStreamPlayer","AudioStreamPlayer2D") var bounce_path
@onready var bounce=get_node(bounce_path) as AudioStreamPlayer2D

var tilemap

# Called when the node enters the scene tree for the first time.
func _ready():
	tilemap=get_viewport().get_node("Tiles")
	for sound in sound_list:
		if sound_list[sound] is String:
			sound_list[sound]=load(sound_list[sound])


func check_sound():
	call_deferred("def_check")


func def_check():
	tilemap as TileMap
	var touch = tilemap.local_to_map(global_position)
	var data = tilemap.get_cell_tile_data(2, touch)
	print(tilemap)
	if data && data.get_custom_data("Sound")!="":
		
		bounce.stream=sound_list[data.get_custom_data("Sound")]
func play():
	def_check()
	bounce.play()
