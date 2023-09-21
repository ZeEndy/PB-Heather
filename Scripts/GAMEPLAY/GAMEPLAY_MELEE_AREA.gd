extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum at_types{
	downing=0,
	lethal=1
}

@onready var space_state = get_world_2d().direct_space_state
@onready var query= PhysicsRayQueryParameters2D.new()

@onready var collision=get_node("CollisionShape2D")
@onready var ped_parent=get_node("../../../")

@export var attack_type : at_types
@export var hit_sound : NodePath
@export var death_sprite = ""
@export var death_lean_sprite = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if collision.disabled==false && ped_parent.state==0:
		var body = get_overlapping_bodies()
		for i in body:
			if i.get_parent()!=ped_parent:
				var for_ped_parent=i.get_parent()
				
				query.from=ped_parent.collision_body.global_position
				query.to=i.global_position
				query.collision_mask=16
				var sound_node = get_node_or_null(hit_sound)
				var result = space_state.intersect_ray(query)
				if result.size()==0:
					if for_ped_parent.has_method("go_down") && attack_type==at_types.downing:
						if for_ped_parent.state==0:
							for_ped_parent.go_down(ped_parent.collision_body.global_position.direction_to(i.global_position).angle())
							if sound_node!=null:
								sound_node.play()
					if for_ped_parent.has_method("do_remove_health") && attack_type==at_types.lethal:
						if for_ped_parent.state==0 || for_ped_parent.state==3:
							if !("Lean" in for_ped_parent.sprite_legs.animation):
								for_ped_parent.do_remove_health(1,death_sprite,(ped_parent.collision_body.global_position.direction_to(i.global_position).angle())-deg_to_rad(180),"rand",0.8)
								if sound_node!=null:
									sound_node.play()
							else:
								for_ped_parent.do_remove_health(1,death_lean_sprite,for_ped_parent.sprite_legs.global_rotation,"rand",0.8)
								if sound_node!=null:
									sound_node.play()
						break

