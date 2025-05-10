extends Control
class_name MainMenu

@onready var margin_container: MarginContainer = $MarginContainer
@onready var v_box_container: VBoxContainer = $MarginContainer/VBoxContainer

signal continue_sig
signal new_game_sig
signal quit_sig

func _ready() -> void:
	var view_size: Vector2 = get_viewport_rect().size
	margin_container.size = view_size / Globals.CameraZoom # need to check how size works
	scale /= Globals.CameraZoom
	margin_container.position = (view_size - margin_container.size) / 2

func _on_continue_pressed() -> void:
	continue_sig.emit()

func _on_new_game_pressed() -> void:
	new_game_sig.emit()

func _on_quit_pressed() -> void:
	quit_sig.emit()
	
