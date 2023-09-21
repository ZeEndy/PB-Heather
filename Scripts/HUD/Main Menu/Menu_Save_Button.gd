extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(GAME.save_config)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
