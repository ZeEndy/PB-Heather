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

func _ready():
	super()
#	get_node("pathline").global_position=Vector2(0,0)
#	get_node("pathline").global_rotation=0
	if alert_timer==-1:
		alert_timer=alert_time()
	collision_body.set_collision_layer_value(1,true)
	pat_query.exclude.append(collision_body.get_rid())
	enemy_state=-1

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

	if state==ped_states.alive:
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
				body_direction=lerp_angle(body_direction,axis.angle(),0.15)
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
				if collision_body.global_position.distance_to(found.global_position)<5:
					switch_weapon()
					enemy_state=enemy_s.neutral
			else:
				axis=Vector2.ZERO
				movement(null,delta)
		else:
			if player_exists:
				if enemy_state==enemy_s.charging:
					if player_vis:
						if weapon["Type"]!="Melee":
							var clamped_rotation_speed=clamp(movement_check.target_position.length()*0.02,0.15,0.25)
							body_direction=lerp_angle(body_direction,movement_check.target_position.angle(),clamped_rotation_speed*60*delta)
							if alert_timer>0:
								alert_timer-=1*delta_time
							if movement_check.target_position.length()<280:
								if alert_timer<=0:
									attack()
								axis=Vector2(0,0)
								movement(null,delta)
							else:
								move_to_point(focused_player.global_position,1.0)
						elif weapon["Type"]=="Melee":
							if movement_check.target_position.length()<24:
								body_direction=lerp_angle(body_direction,collision_body.global_position.direction_to(focused_player.global_position).angle(),0.25)
								attack()
								if focused_player.get_parent().state==ped_states.down:
									do_execution()
							if movement_check.target_position.length()>10:
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
					body_direction=lerp_angle(body_direction,axis.angle(),0.25)
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

func get_up():
	collision_body.set_collision_layer_value(1,true)
	super()

func go_down(down_dir=randi(),spd=MAX_SPEED):
	if state == ped_states.alive:
		collision_body.set_collision_layer_value(1,false)
	super(down_dir,spd)

func kys(damage,killsprite:String="DeadBlunt",rot:float=randf()*180,frame="rand",body_speed=2,_bleed=false):
	do_remove_health(damage,killsprite,rot,frame,body_speed,_bleed)

func do_remove_health(damage,killsprite:String="DeadBlunt",rot:float=randf()*180,frame="rand",body_speed=2,_bleed=false):
	owner.add_kill()
	if "gun" in killsprite:
		s_entry.play()
		if randi()%6>4:
			s_exit.play()
	super(damage,killsprite,rot,frame,body_speed,_bleed)

func player_visibilty(mode=0):
	var seen=true
	if focused_player!=null && focused_player.get_viewport()==get_viewport():
		if mode==0:
			vis_shape.extents=Vector2(collision_body.global_position.distance_to(focused_player.global_position)/2,4)
			vis_query.set_shape(vis_shape)
			vis_query.collision_mask=16
			
			var angle=collision_body.global_position.direction_to(focused_player.global_position).angle()
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
			return 10
		alert_s.alert:
			return 7.5
		alert_s.ready:
			return 5





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


