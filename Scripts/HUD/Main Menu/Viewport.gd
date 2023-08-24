extends SubViewport


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
#	size=get_parent().get_viewport().size
	next_frame()

func next_frame():
	await RenderingServer.frame_pre_draw
	await RenderingServer.frame_pre_draw
	render_target_update_mode=SubViewport.UPDATE_ONCE
