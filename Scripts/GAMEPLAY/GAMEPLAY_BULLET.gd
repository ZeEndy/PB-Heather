extends Sprite2D

class_name BULLET

@onready var ray_check=get_node("RayCast2D") as RayCast2D

var bullet
var paused=false
var speed = 3750
@export var velocity = Vector2()
@export var size = Vector2(8,1)
@export var force=0
var get_destroyed=true
var penetrate=true
var last_position=Vector2()
var hit_point=Vector2()
var hit_rotation =0 
var _wad=null
var damage=1
var signal_=""
signal bullet_signal
var ground_hole=""
var exclusion=[]


var bullet_height=20
var death_sprite=""
var death_lean_sprite=""

func _ready():
	speed = 1000+randf_range(-150,150)

func _process(delta):
	region_rect.size.x=lerp(region_rect.size.x,14.0,clamp(15*delta,0,1))
	region_rect.position.x=lerp(region_rect.position.x,2.0,clamp(15*delta,0,1))


func _physics_process(delta):
	var last_pos=global_position
	global_position+=(velocity*delta)
	var collision = check_collision(delta)
	if collision.size()>0:
		if collision[0].collider.get_parent().has_method("do_remove_health"):
#			spawn_smoke(collision.normal.angle(),collision.position,Color.red,0)
			if penetrate==true:
#				var exit_wound_pos = collision[0].collider.global_position+(Vector2(collision.collider.global_position.distance_to(collision[0].position),0).rotated((collision.collider.global_position-collision.position).angle()))
#				spawn_smoke(-collision.normal.angle(),exit_wound_pos,Color.red,0)
				get_destroyed=false
			else:
				get_destroyed=false
				queue_free()
			if !(collision[0].collider in exclusion):
				if "Lean" in collision[0].collider.get_parent().sprites.get_node("Legs").animation:
					if signal_!="":
						emit_signal("bullet_signal")
					collision[0].collider.get_parent().do_remove_health(damage,death_sprite,collision[0].collider.get_parent().sprites.get_node("Legs").global_rotation)
					exclusion.append(collision[0].collider)
				else:
					if signal_!="":
						emit_signal("bullet_signal")
#					if collision[0].collider.get_parent().armour>0:
#						if GAME.particle_quality<2:
#							for i in randi_range(4,8):
#								spawn_armour_imp(collision[1].normal.angle(),collision[1].point)
#						destroy()
					collision[0].collider.get_parent().do_remove_health(damage,death_sprite,global_rotation-PI,"rand")
					exclusion.append(collision[0].collider)
		elif collision[0].collider is TileMap:
			collision[0].collider as TileMap
			var store_pos=collision[0].collider.local_to_map(collision[1].point+Vector2(0.1,0.0).rotated(rotation))
			var data : TileData = collision[0].collider.get_cell_tile_data(1,store_pos)
			if data!=null && data.get_custom_data_by_layer_id(1)==true:
				if data.get_custom_data_by_layer_id(2)==false:
					var original_pos=collision[0].collider.get_cell_atlas_coords(1,store_pos)
					collision[0].collider.set_cell(1,
						store_pos,
						collision[0].collider.get_cell_source_id(1,store_pos),
						original_pos+Vector2i(3,0))
				get_destroyed=false
			else:
#				collision[0].collider.get_cell_source_id()
				if data!=null:
					print(data)
				destroy()
			
		else:
			destroy()
	else:
		get_destroyed=true
	if (bullet_height<0):
		if ground_hole!="":
			var frames=SpriteFrames.new()
			var sprite=AnimatedSprite2D.new()
			frames.add_frame("default",load(ground_hole))
			sprite.frames=frames
			add_child(sprite)
			if GAME.particle_quality<2:
				get_parent().get_node_or_null(get_parent().my_surface).add_to_surface(sprite,global_position,deg_to_rad(randf_range(-180,180)))
		queue_free()
		return
	bullet_height-=delta
	modulate = Color.WHITE.lerp(Color.YELLOW, randf())
	velocity = Vector2(speed, 0).rotated(rotation)
#	get_node("Sprite_Bullet").scale.x=lerp(get_node("Sprite_Bullet").scale.x,1,0.3*delta*60)
	global_position+=(velocity*delta)


func destroy():
#	spawn_smoke(hit_rotation,hit_point,Color.whitesmoke,1)
#	for i in 4+rand_range(0,6):
#		spawn_spark(rad2deg(hit_rotation),hit_point)
	queue_free()



func check_collision(delta):
	var collision_objects=[]
	var shape = RectangleShape2D.new()
	shape.extents=Vector2(7.5,1)
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	query.collision_mask=get_node("RayCast2D").collision_mask
	
	var space = get_world_2d().direct_space_state
	query.set_transform(Transform2D(global_rotation,global_position+Vector2(shape.extents.x*2,0).rotated(global_rotation)))
	ray_check.target_position=Vector2(speed*delta,0.0)
	if ray_check.is_colliding()==true:
		collision_objects.append({
		"collider": ray_check.get_collider()
		})
		collision_objects.append({
		"normal":ray_check.get_collision_normal(),
		"point":ray_check.get_collision_point()
		})
	else:
		var piss=space.intersect_shape(query,5)
		if piss.size()>0:
			collision_objects=[piss[0],space.get_rest_info(query)]
	return collision_objects





func play_sample(given_sample,affected_time=true,true_pitch=1,random_pitch=0,bus="Master"):
#	print(given_sample)
#	if (given_sample is String):
#		var audio_player := AudioStreamPlayer.new()
#		audio_player.stream = _wad.audio_stream(given_sample+".wav",true)
#		#gonna add this script later but gonna need to probably rethink about that
#		audio_player.set_script(load("res://Scripts/AUDIO/AUDIO_STREAM_SOUND.gd"))
#		audio_player.affected_time=affected_time
#		get_parent().get_parent().call_deferred("add_child",audio_player)
#		audio_player.current_pitch=true_pitch+rand_range(-random_pitch,random_pitch)
#		audio_player.autoplay = true
#		audio_player.set_bus(bus) 
#	elif given_sample is Array:
#		if (typeof(given_sample[0])==1 && given_sample[0]==false):
#			print("type of is 1")
#			play_sample(given_sample[rand_range(1,given_sample.size()-1)],affected_time,true_pitch,random_pitch,bus)
#		else:
#			for i in given_sample:
#				play_sample(i,affected_time,true_pitch,random_pitch,bus)
	return true
