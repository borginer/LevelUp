extends Weapon
class_name BulletGun

@export var shoot_origin: Marker2D

@onready var bullet_cd: Timer = $bullet_cd

@onready var bullet = load("res://Scenes/bullet.tscn")
@onready var player = get_tree().get_root().get_node("GameManager/Level1/Player")

var can_shoot: bool = true

var base_bullet_cd: float = 1
var bullet_targets: int = 1

func _process(_delta: float) -> void:
	handle_shooting()

func handle_shooting() -> void:
	if not can_shoot:
		return 
		
	var enemies = get_tree().get_nodes_in_group("enemies") \
	.filter(Mob.is_alive).filter(
		func(a: Mob): return GF.in_range(player.position, a.position, 280)
	)
	enemies.sort_custom(
		func(a: Mob, b: Mob): 
			return (player.position - a.position).length() < (player.position - b.position).length()
	)
	
	if enemies.size() > 0:
		create_bullet(enemies[0].position)
	else:
		return
		
	can_shoot = false
	bullet_cd.start()
	
	
func create_bullet(to: Vector2):
	var bullet_speed = 280
	var from = player.position + shoot_origin.position
	var damage = base_damage * damage_mult		
	var dir = (to - from).normalized()
	var new_bullet: Bullet = bullet.instantiate()
	var hits_left = bullet_targets
	
	new_bullet.create_bullet(bullet_speed, dir, damage, from, hits_left)
	player.get_parent().add_child.call_deferred(new_bullet)

func update() -> void:
	bullet_cd.wait_time = base_bullet_cd * weapon_speed_mult

func _on_bullet_cd_timeout() -> void:
	can_shoot = true
