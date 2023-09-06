extends CanvasLayer

@onready var tracking=get_node("Aspect/Tracking/Label/anim")
@onready var white_flash=get_node("ColorRect")
@onready var l_name=get_node("Aspect/Name")
@onready var l_song=get_node("Aspect/Song")
@onready var l_tape=get_node("Aspect/Tape")


var next_level="res://Data/Scenes/Levels/Level_Intern.tscn"
var transition_time=3.0
var level_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	tracking.play("Loading")
	GUI.aspect.visible=false
	level_scene=load(next_level).instantiate()
	if level_scene.song!=null:
		AudioManager.play_song(level_scene.song)
	l_name.text=level_scene.n_level
	l_song.text=level_scene.n_song
	AudioManager.play_amb("res://Data/Sounds/UI/Menu/levletitle.wav")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	GUI.health=clamp(clamp(transition_time,0.0,0.5)+0.5,0.0,1.0)
	transition_time=clamp(transition_time-delta,0.0,3.0)
	if transition_time<2.85:
		white_flash.visible=false
	if transition_time==0.0:
		get_tree().root.add_child(level_scene)
		GUI.aspect.visible=true
		queue_free()
