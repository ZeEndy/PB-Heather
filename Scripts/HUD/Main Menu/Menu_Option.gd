extends Button

@export var change=""
@export var value=""
@export var is_str=false
signal changed(value)
# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(val_change)




func val_change():
	var temp_val=value
	if is_str==false:
		temp_val=str_to_var(value)
	print(temp_val)
	GAME.set_deferred(change,temp_val)
	print(GAME.get(change))
	changed.emit(text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):

