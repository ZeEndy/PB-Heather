extends CanvasLayer

@onready var tracking=get_node("Aspect/Tracking/Label/anim")
@onready var white_flash=get_node("ColorRect")
var next_level="res://Data/Scenes/Levels/Level_Intern.tscn"
var next_level_song="res://Data/Music/mu_BlueMonday.ogg"
var transition_time=3.0


# Called when the node enters the scene tree for the first time.
func _ready():
	tracking.play("Loading")
	GUI.aspect.visible=false
	ResourceLoader.load_threaded_request(next_level)
	AudioManager.play_song(load(next_level_song))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	GUI.health=clamp(clamp(transition_time,0.0,0.5)+0.5,0.0,1.0)
	transition_time=clamp(transition_time-delta,0.0,3.0)
	if transition_time<2.85:
		white_flash.visible=false
	if transition_time==0.0:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(next_level))
		GUI.aspect.visible=true
