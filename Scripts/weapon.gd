extends Node2D
class_name Weapon

var damage_mult: float = 1
var base_damage: float = 10
var weapon_speed_mult: float = 1

func set_weapon_speed(new_mult: float):
	weapon_speed_mult = new_mult
	
func set_base_damage(new_base: float):
	base_damage = new_base
	
func set_damage_mult(new_mult: float):
	damage_mult = new_mult
	
# update weapon to reflect the newly set values
func update() -> void:
	return
