extends Node2D

var game_exists = false
var in_main_menu = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		if not in_main_menu:
			get_tree().paused = true
			in_main_menu = true
			create_menu()
		else:
			in_main_menu = false
			resume_game()
			

func _ready() -> void:
	create_menu()

func _new_game() -> void:
	for child in get_children():
		child.queue_free()
		await child.tree_exited
	var level1 = load("res://Scenes/level1.tscn").instantiate()
	add_child(level1)
	level1.call_deferred("set_name", "Level1")
	game_exists = true
	get_tree().paused = false
	in_main_menu = false
	get_tree().get_root().get_node("GameManager/Level1/Player").leveled_up.connect(_on_player_levelup)

func _quit() -> void:
	get_tree().quit()
	
func _continue() -> void:
	if game_exists:
		resume_game()
	in_main_menu = false
	
func resume_game():
	get_tree().paused = false
	for child in get_children():
		if child is MainMenu or child is UpgradeMenu:
			child.queue_free()

func create_menu() -> void:
	var view_size: Vector2 = get_viewport().size
	var menu: MainMenu = load("res://Scenes/main_menu.tscn").instantiate()
	if game_exists:
		menu.position = get_tree().get_root().get_node("GameManager/Level1/Player").position - view_size / (2 * Globals.CameraZoom)
	else:
		menu.position = Vector2(0, 0)
		
	menu.new_game_sig.connect(_new_game)
	menu.quit_sig.connect(_quit)
	menu.continue_sig.connect(_continue)
	add_child(menu)
	
func create_upgrade_menu() -> void:
	var view_size: Vector2 = get_viewport().size
	var menu: UpgradeMenu = load("res://Scenes/powerup_menu.tscn").instantiate()
	menu.position = get_tree().get_root().get_node("GameManager/Level1/Player").position - view_size / (2 * Globals.CameraZoom)
	
	menu.upgrade_selected.connect(_on_upgrade_selected)
	add_child(menu)

func _on_player_levelup():
	get_tree().paused = true
	create_upgrade_menu()
	
func _on_upgrade_selected(upgrade_type: Globals.PlayerUpgradeTypes):
	get_tree().get_root().get_node("GameManager/Level1/Player").upgrade_player.emit(upgrade_type)
	resume_game()
