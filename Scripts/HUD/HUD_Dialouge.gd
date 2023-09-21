extends CanvasLayer


@onready var text=get_node("Control/Text")
@onready var texture=get_node("Control/Spritepoint/Texture")
 

var change_delay=0.0

var bounce=0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	visible=false




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if change_delay==0:
		text.visible=true
	else:
		change_delay=clamp(change_delay-delta,0.0,1.0)
		text.visible=false
	bounce=clamp(bounce-delta,0.0,0.1)
	texture.scale=Vector2(1+bounce,1+bounce)

func change_text(new_text:String):
	change_delay=0.1
	text.visible=false
	text.text=new_text
	bounce=0.1

func show_dialouge():
	visible=true
	bounce=0.1
func hide_dialouge():
	visible=false
