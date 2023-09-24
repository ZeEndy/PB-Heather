extends PED

class_name Enemy



#reference variables
@onready var visibilty_check=get_node("PED_COL/visibilty_check")
@onready var movement_check=get_node("PED_COL/movement_check")
@onready var s_entry=get_node("PED_SPRITES/Legs/Sound/Blood Impact/Bullet Enter")
@onready var s_exit=get_node("PED_SPRITES/Legs/Sound/Blood Impact/Bullet Exit")
@onready var vis_query = PhysicsShapeQueryParameters2D.new()
@onready var vis_shape = RectangleShape2D.new()
@onready var pat_query = PhysicsShapeQueryParameters2D.new()
@onready var pat_shape = RectangleShape2D.new()
@onready var space = get_world_2d().direct_space_state

@onready var blood_fuck=get_node("PED_SPRITES/Legs/BLOODMANAGER")

#states
enum Enemy_t {
	RANDOM,
	PATROL,
	STATIONARY,
}

enum enemy_s {
	neutral,
	charging,
	chasing,
	scared}

@export var enemy_type:Enemy_t
@export var enemy_state = enemy_s.neutral


#alert stuff
enum alert_s{
	normal,
	alert,
	ready}

@export var alert_state=alert_s.normal
@export var alert_timer=-1
var random_timer = 0
var player_vis=false
#misc
var spawn_timer=0.1
var target_point=Vector2.ZERO
var direction=0
var focused_player=null
var focused_direction=0.0
func _ready():
	super()
#	get_node("pathline").global_position=Vector2(0,0)
#	get_node("pathline").global_rotation=0
	if alert_timer==-1:
		alert_timer=alert_time()
	collision_body.set_collision_layer_value(1,true)
	pat_query.exclude.append(collision_body.get_rid())
	enemy_state=-1
	blood_fuck.clear()

func _process(_delta):
	super(_delta)

func _physics_process(delta):
	super(delta)
	#fuck you Juan and your fucking quircky engine
	if spawn_timer>-1: 
		spawn_timer-=delta 
		if spawn_timer<0:
			enemy_state=enemy_s.neutral
			spawn_timer=-1
	var delta_time=delta*60
	var player_exists=GAME.player_count>0
	if player_exists:
		if focused_player==null:
			focused_player=GAME.player_group[0]
		else:
			
			visibilty_check.target_position=focused_player.global_position-collision_body.global_position
			movement_check.target_position=focused_player.global_position-collision_body.global_position
			focused_direction=visibilty_check.target_position.normalized().angle()
	var len_check=movement_check.target_position.length()
	var axis_angle=axis.angle()
	if state==ped_states.alive:
		col_shape.disabled=false
		if player_exists:
			player_vis=player_visibilty()
		if weapon["ID"]=="Unarmed":
			enemy_state=enemy_s.scared
		if enemy_state==enemy_s.neutral:
			if player_vis:
				if alert_timer<0:
					enemy_state=enemy_s.charging
					alert_timer=alert_time()
					alert_state=alert_s.ready
				else:
					alert_timer-=1*delta_time
			else:
				alert_timer=alert_time()
			if enemy_type==Enemy_t.PATROL:
				movement(null,delta)
				axis=Vector2(0.35,0).rotated(direction)
				#get_node("PED_SPRITES/Label").text=str(rad_to_deg(direction))
				direction=fmod(direction,PI*2.0)
				body_direction=lerp_angle(body_direction,axis_angle,0.15)
				var v = Vector2(my_velocity.length()*0.35,0).rotated(direction)
				pat_shape.extents=Vector2(v.length(),col_shape.shape.radius)
				pat_query.set_shape(pat_shape)
				pat_query.collision_mask=32
				pat_query.set_transform(Transform2D(direction,collision_body.global_position+Vector2(pat_shape.extents.x/2,0).rotated(direction)))
				if space.intersect_shape(pat_query,1).size()>0:
					direction -= deg_to_rad(10.0) * delta_time - delta
				else:
					var dif = fmod(direction, deg_to_rad(90.0))
					if abs(dif) > deg_to_rad(10.0):
						direction -= deg_to_rad(10.0) * delta_time - delta
					else:
						direction -= dif
			elif enemy_type==Enemy_t.RANDOM:
				body_direction=lerp_angle(body_direction,deg_to_rad(direction),0.15)
				movement(null,delta)
				random_timer -= 1 * delta_time
				if (random_timer <= 0):
					direction = randi() % 360
					axis=Vector2((randi() % 2)*0.25,0).rotated(deg_to_rad(direction)) 
					#print(axis)
					random_timer = 60 + (randi() % 61)
				var v = Vector2(12,0).rotated(deg_to_rad(direction))
				var c = collision_body.move_and_collide(v, true, true, true)
				if c:
					v = v.bounce(c.get_normal())
					direction = rad_to_deg(v.angle())
					axis=Vector2(axis.length(),0).rotated(deg_to_rad(direction)) 
				return
			elif enemy_type==Enemy_t.STATIONARY:
				movement(Vector2(0,0),delta)
				return
		elif enemy_state==enemy_s.scared:
			var found=weapon_finder(100*100)
			if found!=null:
				move_to_point(found.global_position,1.0)
				body_direction=lerp(body_direction,axis_angle,clamp(10*delta,0,1))
				if collision_body.global_position.distance_to(found.global_position)<5:
					switch_weapon()
					enemy_state=enemy_s.neutral
			else:
				axis=Vector2.ZERO
				if len_check<50:
					axis=Vector2(0.5,0).rotated(focused_direction-PI)
					body_direction=lerp(body_direction,axis_angle+PI,clamp(10*delta,0,1))
				movement(null,delta)
		else:
			if player_exists:
				if enemy_state==enemy_s.charging:
					if player_vis:
						if weapon["Type"]=="Firearm":
							var clamped_rotation_speed=clamp(len_check*0.02,0.15,0.25)
							body_direction=lerp_angle(body_direction,focused_direction,clamped_rotation_speed*60*delta)
							if alert_timer>0:
								alert_timer-=1*delta_time
							if len_check<280:
								if alert_timer<=0:
									attack()
								movement(null,delta)
								if len_check<50:
									axis=Vector2(1.0,0).rotated(focused_direction-PI)
								else:
									axis=Vector2(0,0)
							else:
								move_to_point(focused_player.global_position,1.0)
						elif weapon["Type"]=="Melee":
							if len_check<24:
								body_direction=lerp_angle(body_direction,focused_direction,0.25)
								attack()
								if focused_player.get_parent().state==ped_states.down:
									do_execution()
							if len_check>10:
								move_to_point(focused_player.global_position,1.0)
							else:
								axis=lerp(axis,Vector2.ZERO,1.0)
								movement(null,delta)
					else:
						enemy_state=enemy_s.chasing
						alert_state=alert_s.ready
						target_point=focused_player.global_position
						alert_timer=alert_time()
				elif enemy_state==enemy_s.chasing:
					body_direction=lerp_angle(body_direction,axis_angle,0.25)
					move_to_point(target_point,0.95)
					if player_vis:
						if alert_timer<0:
							enemy_state=enemy_s.charging
							alert_state=alert_s.ready
							alert_timer=alert_time()
							return
						else:
							alert_timer-=1*delta_time
					if path.size()<=1 && collision_body.global_position.distance_to(target_point)<10:
						axis=Vector2()
						enemy_state=enemy_s.neutral
						alert_state=alert_s.alert
						alert_timer=alert_time()
						path=[]
			else:
				enemy_state=enemy_s.neutral
		
	elif state==ped_states.execute:
		if execute_click==true:
			sprite_body.speed_scale=1
#	elif state==ped_states.down:
#
func get_up():
	collision_body.set_collision_layer_value(1,true)
	super()

func go_down(down_dir=randi(),spd=MAX_SPEED):
	if state == ped_states.alive:
		collision_body.set_collision_layer_value(1,false)
		collision_body.set_collision_layer_value(4,false)
	super(down_dir,spd)

func weapon_finder(pickup_dist=40*40):
	var dropped_weapons = get_tree().get_nodes_in_group("Weapon")
	
	for weapon in dropped_weapons:
		# filter weapons that cannot be picked up
		if weapon.pick_up == true && weapon.viewp==viewp && weapon.linear_velocity.length()<200:
			# filter weapons within certain distance
			if weapon.global_position.distance_squared_to(sprites.global_position) < pickup_dist:
				# filter weapons behind walls
				wep_check.target_position = weapon.global_position - sprites.global_position
				if !wep_check.is_colliding():
					closest_weapon = weapon
					return weapon
	return null

func kys(damage,killsprite:String="DeadBlunt",rot:float=randf()*180,frame="rand",body_speed=2,_bleed=false):
	sprite_legs.speed_scale=0
	health=0
	sprite_body.visible=false
	state=ped_states.dead
	axis=Vector2.ZERO
	my_velocity=Vector2(0.0,0.0)

func do_remove_health(damage,killsprite:String="DeadBlunt",rot:float=randf()*180,frame="rand",body_speed=2,_bleed=false):
	super(damage,killsprite,rot,frame,body_speed,_bleed)
	if "gun" in killsprite && health==0 && state==ped_states.dead:
		owner.add_kill()
		s_entry.play()
		if randi()%6>4:
			s_exit.play()
		blood_fuck.spawn_blood("Splat",0.0,200.0,Vector2.ZERO,randi_range(5,12))
		blood_fuck.spawn_blood("Squirt",0.0,600.0,Vector2.ZERO,randi_range(4,8))
		blood_fuck.spawn_blood("Speck",0.0,800.0,Vector2.ZERO,randi_range(12,25))
		collision_body.set_collision_layer_value(1,false)
	

func player_visibilty(mode=0):
	var seen=true
	if focused_player!=null && focused_player.get_viewport()==get_viewport():
		if mode==0:
			vis_shape.extents=Vector2(collision_body.global_position.distance_to(focused_player.global_position)/2,4)
			vis_query.set_shape(vis_shape)
			vis_query.collision_mask=16
			
			var angle=focused_direction
			vis_query.set_transform(Transform2D(angle,collision_body.global_position+Vector2(vis_shape.extents.x,0).rotated(angle)))
			if space.intersect_shape(vis_query,1).size()>0:
				seen=false
		#add other modes like cone and shit here
	else:
		seen=false
	return seen



func alert_time():
	match alert_state:
		alert_s.normal:
			return 15
		alert_s.alert:
			return 10
		alert_s.ready:
			return 7.5





func investigate_gunshot(distance):
	if collision_body.global_position.distance_to(focused_player.global_position)<distance && focused_player.get_viewport() == get_viewport() && enemy_state!=enemy_s.charging:
		enemy_state=enemy_s.chasing
		target_point=focused_player.global_position


func _on_VisibilityNotifier2D_viewport_entered(_viewport):
	sprites.visible=true
	sprites.set_enabled(true)
	sprites.teleport()


func _on_VisibilityNotifier2D_viewport_exited(_viewport):
	sprites.visible=false
	sprites.set_enabled(false)

func get_classd():
	return "Enemy"


