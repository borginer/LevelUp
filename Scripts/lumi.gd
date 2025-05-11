extends Weapon
class_name Lumi

@onready var lumi_cd: Timer = $lumi_cd
@onready var lumi_delay_cd: Timer = $lumi_delay_cd

@onready var player = get_tree().get_root().get_node("GameManager/Level1/Player")
@onready var lazer = load("res://Scenes/lazer.tscn")

var can_lumi: bool = true

var base_lumi_cd: float = 2
var lazer_targets: int = 2

signal lumi_sig

func _ready() -> void:
	lumi_sig.connect(_on_lumi_signal)
	
func _process(_delta: float) -> void:
	handle_lumi()
	
func create_lazer(from: Vector2, to: Vector2):
	var new_lazer :Node2D = lazer.instantiate()
	new_lazer.position = to
	new_lazer.x_len = (from - to).length()
	new_lazer.rotation = (from - to).angle()
	player.get_parent().add_child.call_deferred(new_lazer)

func handle_lumi():
	if not can_lumi:
		return
	lumi_sig.emit()
	
# returns the next point to shoot a lazer from
func hit_enemy(e: Mob, from: Vector2) -> Vector2:
	if not e or e.is_dead:
		return from
	e.deal_damage(base_damage * damage_mult)
	create_lazer(from, e.position)
	return e.position
	
func _on_lumi_signal():
	var enemies = get_tree().get_nodes_in_group("enemies") \
		.filter(
			func(a: Mob): return GF.in_range(player.position, a.position, 280) \
		).filter(Mob.is_alive)
	
	var last_e_pos: Vector2 = player.position
	if enemies.size() > 0:
		can_lumi = false
		lumi_cd.start()
		last_e_pos = hit_enemy(enemies[0], last_e_pos)
		enemies.remove_at(0)
		enemies.shuffle()
		lumi_delay_cd.start()
		await lumi_delay_cd.timeout
	else:
		return
	
	for i in range(0, min(enemies.size(), lazer_targets - 1), 1):
		if not enemies[i]:
			continue
		var cur_e: Mob = enemies[i]
		last_e_pos = hit_enemy(cur_e, last_e_pos)
		lumi_delay_cd.start()
		await lumi_delay_cd.timeout
		
func update() -> void:
	lumi_cd.wait_time = base_lumi_cd * weapon_speed_mult
	
func _on_lumi_cd_timeout() -> void:
	can_lumi = true
