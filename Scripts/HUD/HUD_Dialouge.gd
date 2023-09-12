extends CanvasLayer


@onready var text=get_node("Control/Text")
 

var change_delay=0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if change_delay==0:
		text.visible=true
	else:
		change_delay=clamp(change_delay-delta,0.0,1.0)
		text.visible=false

func change_text(new_text:String):
	change_delay=0.1
	text.text=new_text

func show_dialouge():
	visible=true
func hide_dialouge():
	visible=false
