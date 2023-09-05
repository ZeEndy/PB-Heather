extends RigidBody2D
class_name WEAPON


@onready var def_bullet_ent=preload("res://Data/DEFAULT/ENTS/ENT_BULLET.tscn")

var pick_up=false
var wait_pickup=0.001

@onready var sprite=get_node("SPRITE")
@onready var col=get_node("CollisionShape2D")

@export var weapon={
			"ID":"PB",
			#ammo of the weapon
			"Type":"Firearm",
			"Mode":"Semi",
			
			"Bullet":"FMJ",
			#ammo of the weapon
			"Ammo":9,
			"Max ammo":8,
			# using the just an int because a magazine system doesn't fit this project 
			
			"Attack index":0,
			"Attack ammount":0,
			"Random sprite":true,
			
			"Damage":100,
			
			"Added recoil":0.2,
			"Recoil":4,
			
			
			"HR":220, # its a radius
			#so that means if an enemy is in a 220 range between the player he will hear the weaponshot
			
			"droppable":true,
			
			#trigger
			"Trigger pressed":false,
			"Cycle rate":0.109091,
			"Cycle":0.0,
			"Trigger shot":0,
			"Splits":1}



func _ready():
	sprite.global_rotation=global_rotation
	sprite.animation=weapon["ID"]
	if weapon["Type"]=="Firearm":
		for bullet in weapon["Ammo"]:
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sprite.global_position=global_position
	sprite.global_rotation+=deg_to_rad(linear_velocity.length()*5*delta)
	if wait_pickup>0 && pick_up==false:
		wait_pickup-=delta
	else:
		pick_up=true
	if linear_velocity.length()<50:
		col.disabled=true
		linear_velocity=lerp(linear_velocity,Vector2.ZERO,10*delta)


func _manual_visiblity(input1=true):
	sprite.visible=input1


func _on_ENT_GENERIC_WEAPON_body_entered(body):
	if body in get_tree().get_nodes_in_group("Enemy") && col.disabled==false:
		body.get_parent().go_down(global_position.direction_to(body.global_position).angle())
		linear_velocity*=0.1
		pass


