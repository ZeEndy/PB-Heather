extends HSlider

@export var var_change=""

# Called when the node enters the scene tree for the first time.
func _ready():
	value_changed.connect(click)
	value=GAME.get(var_change)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func click(value):
	GUI.s_slider.play()
	GAME.set_deferred(var_change,value)
