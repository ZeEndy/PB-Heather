extends Sprite2D

class_name BULLET

@onready var ray_check=get_node("RayCast2D") as RayCast2D
@onready var shape = RectangleShape2D.new()
@onready var query = PhysicsShapeQueryParameters2D.new()
@onready var space = get_world_2d().direct_space_state
@onready var glass_shit=preload("res://Data/Scenes/VFX/GlassShit.tscn")
@onready var smoke_hit=preload("res://Data/Scenes/VFX/VFX_smokehit.tscn")

@onready var imp_sounds={
	"Brick":get_node("Brick"),
	"Plaster":get_node("Plaster"),
	"Glass":get_node("Glass"),
}

var bullet
var paused=false
var speed = (1000+randf_range(-150,150))
@export var velocity = Vector2()
@export var size = Vector2(8,1)
@export var force=0
var get_destroyed=true
var penetrate=false
var last_position=Vector2()
var spawn_position=null
var damage=1
signal bullet_signal
var ground_hole=""
var exclusion=[]
var collision_array : Array =[] 
var g_pdelta=0.0

var bullet_height=20
var death_sprite=""
var death_lean_sprite=""

func _ready():
	for sound in imp_sounds:
		imp_sounds[sound].finished.connect(queue_free)
	if spawn_position!=null:
		var collision=[]
		var len=(spawn_position-global_position).length()
		ray_check.target_position=Vector2(len,0.0)
		for i in exclusion:
			ray_check.add_exception_rid(i)
		ray_check.force_raycast_update()
		if ray_check.is_colliding()==true:
			collision.append({
			"collider": ray_check.get_collider()
			})
			collision.append({
			"normal":ray_check.get_collision_normal(),
			"point":ray_check.get_collision_point()
			})
		if collision.size()>0:
			collision_array.append(collision)
	#	collision=check_collision(g_pdelta)
	speed = speed

func _process(delta):
	region_rect.size.x=lerp(region_rect.size.x,14.0,clamp(15*delta,0,1))
	region_rect.position.x=lerp(region_rect.position.x,2.0,clamp(15*delta,0,1))


func _physics_process(delta):
	if ray_check!=null:
		var last_pos=global_position
		for collision in collision_array:
			if collision[0].collider.get_parent().has_method("do_remove_health"):
				var col_parent=collision[0].collider.get_parent()
				if penetrate==true || col_parent.health==0:
					get_destroyed=false
				else:
					get_destroyed=false
					queue_free()
				if !(collision[0].collider in exclusion) && col_parent.health>0:
					if "Lean" in col_parent.sprite_legs.animation:
						col_parent.do_remove_health(damage,death_lean_sprite,collision[0].collider.get_parent().sprites.get_node("Legs").global_rotation)
						exclusion.append(collision[0].collider.get_rid())
					else:
						col_parent.do_remove_health(damage,death_sprite,global_rotation-PI,"rand")
						exclusion.append(collision[0].collider.get_rid())
			elif collision[0].collider is TileMap:
				collision[0].collider as TileMap
				var store_pos=collision[0].collider.local_to_map(collision[1].point-collision[1].normal)
				var data : TileData = collision[0].collider.get_cell_tile_data(1,store_pos)
				if data!=null:
					if data.get_custom_data_by_layer_id(1)==true && data.get_custom_data_by_layer_id(2)==false:
						var original_pos=collision[0].collider.get_cell_atlas_coords(1,store_pos)
						
						collision[0].collider.set_cell(1,
							store_pos,
							collision[0].collider.get_cell_source_id(1,store_pos),
							original_pos+Vector2i(3,0))
						for i in randi_range(10,17):
							var fuck=glass_shit.instantiate()
							fuck.global_position=collision[1].point-collision[1].normal
							fuck.velocity=Vector2(160+600*randf(),0).rotated(collision[1].normal.angle()-PI).rotated(randf_range(-PI*0.05,PI*0.05))
							fuck.rotation=randf()*PI
							get_parent().add_child(fuck)
						for i in randi_range(7,10):
							var fuck=glass_shit.instantiate()
							fuck.global_position=collision[1].point-collision[1].normal
							fuck.velocity=Vector2(160+100*randf(),0).rotated(collision[1].normal.angle()).rotated(randf_range(-PI*0.05,PI*0.05))
							fuck.rotation=randf()*PI
							get_parent().add_child(fuck)
						
						var sound_obj=imp_sounds[data.get_custom_data_by_layer_id(4)]
						sound_obj.reparent(get_parent())
						sound_obj.play()
						for i in sound_obj.get_children():
							i.play()
						sound_obj.global_position=collision[1].point-collision[1].normal
						get_destroyed=false
					
					
				else:
					var data2: TileData = collision[0].collider.get_cell_tile_data(0,store_pos)
					if data2!=null:
						var sound_obj=imp_sounds[data2.get_custom_data_by_layer_id(4)]
						sound_obj.reparent(get_parent())
						sound_obj.play()
						sound_obj.global_position=collision[1].point-collision[1].normal
					
					for i in randi_range(4,6):
						var fuck=smoke_hit.instantiate()
						fuck.global_position=collision[1].point+collision[1].normal
						var ang=collision[1].normal.angle()-PI
						fuck.velocity=Vector2(160+100*randf(),0).rotated(ang)
						fuck.rotation=ang
						fuck.speed_scale=0.6+0.2*randf()
						get_parent().add_child(fuck)
					destroy()
				
			else:
				destroy()
		if (bullet_height<0):
			queue_free()
			return
		bullet_height-=delta
		modulate = Color.WHITE.lerp(Color.YELLOW, randf())
		velocity = Vector2(speed, 0).rotated(rotation)
		global_position+=(velocity*delta)
		check_collision(delta)
#	get_node("Sprite_Bullet").scale.x=lerp(get_node("Sprite_Bullet").scale.x,1,0.3*delta*60)
	


func destroy():
#	spawn_smoke(hit_rotation,hit_point,Color.whitesmoke,1)
#	for i in 4+rand_range(0,6):
#		spawn_spark(rad2deg(hit_rotation),hit_point)
	queue_free()



func check_collision(delta):
	var collision_objects=[]
	shape.extents=Vector2(abs(speed)*delta,3)
	query.set_shape(shape)
	query.collision_mask=ray_check.collision_mask
	query.set_transform(Transform2D(global_rotation,global_position+Vector2(speed*delta*2,0).rotated(global_rotation)))
	query.exclude=exclusion
	
	ray_check.target_position=Vector2(speed*delta,0.0)
	ray_check.force_raycast_update()
	if ray_check.is_colliding()==true:
		collision_objects.append({
		"collider": ray_check.get_collider()
		})
		collision_objects.append({
		"normal":ray_check.get_collision_normal(),
		"point":ray_check.get_collision_point()
		})
		collision_array.append(collision_objects)
	var piss=space.intersect_shape(query,5)
	if piss.size()>0:
		collision_array.append([piss[0],space.get_rest_info(query)])





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
