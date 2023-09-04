extends CanvasLayer

@onready var tracking=get_node("Aspect/Tracking/Label/anim")
var next_level=""
var transition_time=3.0


# Called when the node enters the scene tree for the first time.
func _ready():
	tracking.play("Loading")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
