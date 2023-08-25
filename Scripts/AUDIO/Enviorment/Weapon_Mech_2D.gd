extends AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if owner.weapon["Type"]=="Firearm":
		volume_db=-40.0*(clamp(float(owner.weapon["Ammo"])/float(owner.weapon["Max ammo"])-0.3,-0.1,1.0))
