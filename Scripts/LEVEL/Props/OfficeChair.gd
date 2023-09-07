extends Sprite2D

@onready var legs=get_node("Legs")
# Called when the node enters the scene tree for the first time.
func _ready():
	legs.rotation=randf()*PI*2.0
	rotation=rotation+randf_range(-PI*0.25,PI*0.25)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
