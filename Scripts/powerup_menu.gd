extends Control
class_name UpgradeMenu

@onready var button_container: HBoxContainer = $MarginContainer/HBoxContainer
@onready var margin_container: MarginContainer = $MarginContainer

@onready var button_array: Array[Button]

@onready var button_text_dict = { 
	Globals.PlayerUpgradeTypes.WEAP_CD: "+8% weapon speed",
	Globals.PlayerUpgradeTypes.BASE_DAMAGE: "+2 all weapon damage",
	Globals.PlayerUpgradeTypes.BULLET_DAMAGE: "+20% bullet damage",
	Globals.PlayerUpgradeTypes.LAZER_DAMAGE: "+20% lazer damage",
	Globals.PlayerUpgradeTypes.BULLET_TARGETS: "+1 target bullet",
	Globals.PlayerUpgradeTypes.LAZER_TARGETS: "+1 target lazer"
}

var button_type_array: Array[Globals.PlayerUpgradeTypes]

signal upgrade_selected(upgrade_type: Globals.PlayerUpgradeTypes)

func _ready() -> void:
	scale /= Globals.CameraZoom
	set_menu_size_and_position()
	set_button_types()
	set_button_text()
	
# sets the sizes of buttons and container position
func set_menu_size_and_position():
	var viewport_size: Vector2 = get_viewport_rect().size
	
	for button: Button in button_container.get_children():
		button_array.append(button)
		button.set_custom_minimum_size(Vector2(viewport_size.x / 5, viewport_size.y / 2))
		button_type_array.append(-1)
		
	button_container.add_theme_constant_override("separation", int(viewport_size.x / 10))
	# need to call this after size changes
	margin_container.reset_size()
	
	margin_container.position = Vector2(viewport_size - margin_container.size) / 2
	
# rolls random upgrades and saves them
func set_button_types():
	var upgrade_types: Array = Globals.PlayerUpgradeTypes.values()
	for button_idx in button_array.size():
		var type_idx = randi_range(0, upgrade_types.size() - 1)
		button_type_array[button_idx] = upgrade_types[type_idx]
		upgrade_types.remove_at(type_idx)
# sets text acording to upgrade type
func set_button_text():
	for i in button_type_array.size():
		button_array[i].text = button_text_dict[button_type_array[i]]

func set_position_player_relative(player_pos: Vector2):
	position = (player_pos - get_viewport_rect().size) / (2 * Globals.CameraZoom)
	
func _on_option_1_pressed() -> void:
	upgrade_selected.emit(button_type_array[0])

func _on_option_2_pressed() -> void:
	upgrade_selected.emit(button_type_array[1])
	
func _on_option_3_pressed() -> void:
	upgrade_selected.emit(button_type_array[2])
	
