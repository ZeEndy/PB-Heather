extends AnimatedSprite2D

var velocity=Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_finished.connect(queue_free)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity=lerp(velocity,Vector2.ZERO,15*delta)
