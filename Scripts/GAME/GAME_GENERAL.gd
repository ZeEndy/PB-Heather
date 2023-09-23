extends Node


#onready var resource_queue=get_node("root/resource_queue")

var saved = false

var load_=false



#var restart_scene
#var checkpoint


var time=1.0


#config stuff









var rend_method="mobile"
var display_mode=0
var curr_display_mode=-1
var resolution=Vector2(1920,1080)
var cur_resolution=Vector2(-1,-1)
var particle_quality=0
var light_quality=0
#0 no particles
#1 minimal particles
#3 all particles
var music_volume=0
var sfx_volume=0
var mas_volume=0

var cursor_sens=1.0
var cursor_method=Input.MOUSE_MODE_CAPTURED

var _saving=false

var new_room

var cursor_position=null

var configfile


var discord_rich 


var paused=false


var fade=false
var fade_color = 1


@onready var viewp=get_viewport()


var given_track
var target_volume=0

signal fade_out
var fade_out_emitted=false
signal fade_in
var fade_in_emitted=false

#@onready var music=get_node("Music") 
@onready var glob_fade=get_node("CanvasLayer/Fade")
var player_group=[]
var player_count=0
var enemy_group=[]
var enemy_count=0

func _enter_tree():
	discord_rich==true

func _init():
	print(DisplayServer.window_get_vsync_mode())
	Engine.max_fps = DisplayServer.screen_get_refresh_rate()
	configfile = ConfigFile.new()
	OS.low_processor_usage_mode=true
	if configfile.load("res://config.cfg") == OK:
		
		resolution=configfile.get_value("VIDEO","resolution",Vector2(1920,1080))
		display_mode=configfile.get_value("VIDEO","display_mode",0)
		particle_quality=configfile.get_value("VIDEO","particle_quality",0)
		light_quality=configfile.get_value("VIDEO","light_quality",0)
		
		music_volume=configfile.get_value("AUDIO","Music",1.0)
		sfx_volume=configfile.get_value("AUDIO","SFX",1.0)
		mas_volume=configfile.get_value("AUDIO","Master",0.5)
		
		
		cursor_method=configfile.get_value("CURSOR","cursor_method",2)
		cursor_sens=configfile.get_value("CURSOR","cursor_sens",1.0)
	else:
		resolution=Vector2(1920,1080)
		display_mode=0
		particle_quality=0
		light_quality=0
		
		mas_volume=0.4
		music_volume=0.7
		sfx_volume=0.6
		
		cursor_method=2
		cursor_sens=1.0
		save_config()
		
	var ovrd = ConfigFile.new()
	if ovrd.load("res://override.cfg") == OK:
		rend_method=ovrd.get_value("rendering","renderer/rendering_method","mobile")
	else:
		ovrd.set_value("rendering","renderer/rendering_method","mobile")
		ovrd.save("res://override.cfg")
#	InputMap
#	await RenderingServer.frame_post_draw
#	activate_discord()



func save_config():
	var config=ConfigFile.new()
	config.set_value("VIDEO","display_mode",display_mode)
	config.set_value("VIDEO","resolution",resolution)
	config.set_value("VIDEO","particle_quality",particle_quality)
	config.set_value("VIDEO","light_quality",light_quality)
	
	config.set_value("AUDIO","Master",mas_volume)
	config.set_value("AUDIO","Music",music_volume)
	config.set_value("AUDIO","SFX",sfx_volume)
	
	config.set_value("CURSOR","cursor_sens",cursor_sens)
	config.set_value("CURSOR","cursor_method",cursor_method)
	
	config.save("res://config.cfg")
	var ovrd=ConfigFile.new()
	ovrd.set_value("rendering","renderer/rendering_method",rend_method)
	ovrd.save("res://override.cfg")
	



func _process(delta):
	if curr_display_mode!=display_mode:
		match display_mode:
			0:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			1:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
			2:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,true)
			3:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
				DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,false)
		curr_display_mode=display_mode
	
	if cur_resolution!=resolution:
		print(resolution)
		DisplayServer.window_set_size(resolution)
		cur_resolution=resolution
	
	var t_delta=delta/Engine.time_scale
	if Input.is_action_just_pressed("Pause"):
		paused=!paused
	if paused==true:
		Engine.time_scale=lerp(Engine.time_scale,0.00005,10*t_delta)
	else:
		Engine.time_scale=lerp(float(time),1.0,10*t_delta)
	
	player_group=get_tree().get_nodes_in_group("Player")
	player_count=player_group.size()
	enemy_group=get_tree().get_nodes_in_group("Enemy")
	enemy_count=enemy_group.size()
	
	if Input.is_action_just_pressed("Debug_exit"):
		get_tree().quit()




	if Input.is_action_just_pressed("DEV_SAVE"):
		save_node_state("checkpoint",get_tree().get_nodes_in_group("Level")[0])


#	get_node("CanvasLayer/Noise").material.set_shader_param("giv_time",delta*randf_range(0.767845,1.697665))
	#fade
	glob_fade.scale=Vector2(viewp.size.y*2,viewp.size.x*2)

	if fade==false: 
		if fade_color>0:
			fade_in_emitted=false
			fade_out_emitted=false
			fade_color-=delta*5 
		else:
			fade_color=0
			if fade_out_emitted==false:
				emit_signal("fade_out")
				fade_out_emitted=true
	else:
		if fade_color<1:
			fade_in_emitted=false
			fade_out_emitted=false
			fade_color+=delta*5
		else:
			fade_color=1
			if fade_in_emitted==false:
				emit_signal("fade_in")
				fade_in_emitted=true
	glob_fade.modulate.a=fade_color
	get_node(
		"CanvasLayer2/DEBUG_TEXT"	).text="Build version :"+str(Engine.get_version_info().string)+"\n"+"FPS:"+str(Performance.get_monitor(0))+"\n"+"Texture Memory used:"+str(Performance.get_monitor(21)/10000000)+"\n"+"Process time:"+str(Performance.get_monitor(1))+"\n"+"Physics process time:"+str(Performance.get_monitor(2))+"\n"+"Draw calls:"+str(Performance.get_monitor(19))+"\n"+"Objects in game"+str(Performance.get_monitor(8))
		
#saves nodes and shit in the node tree
func save_node_state(_file_name,node):
	_saving=true
	var saved_scene
	
	var root_node=node
	
	var packed_scene = PackedScene.new()
	
	_set_owner(root_node,root_node)
	packed_scene.pack(node)
	saved_scene=ResourceSaver.save(packed_scene,"user://"+_file_name+".scn")
	
	_saving=false
	print("saved on file: "+_file_name)
	return saved_scene


func quit_level():
	get_tree().quit()

func _set_owner(node, root):
	if node is SubViewport && node in get_tree().get_nodes_in_group("Surface"):
		node.save_surface()
	if node != root:
		node.owner = root
		if node.scene_file_path!="":
			node.scene_file_path=""
	for child in node.get_children():
		_set_owner(child, root)



func exit_game():
	fade=true
	await fade_in==true
	get_tree().quit(0)


#objects can call this function to either switch to a level or menu or something idk
func switch_scene(file):
	if _saving==false:
		fade=true
		await fade_in==true
		if fade_color==1:
			get_tree().call_deferred("change_scene_to_file",file)
			fade=false





func _on_GAME_fade_in():
	return true


func _on_GAME_fade_out():
	return true
