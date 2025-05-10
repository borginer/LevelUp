extends Node2D

@onready var player: Player = $"../Player"
@onready var background: Sprite2D = $background
@onready var bg_size = background.region_rect.size

var grid : Dictionary[Vector2, bool] = {}

func _ready() -> void:
	grid[Vector2(0, 0)] = true
	
func get_pos_idx_on_grid(pos: Vector2):
	var pos_x = round(pos.x / bg_size.x)
	var pos_y = round(pos.y / bg_size.y)
	return Vector2(pos_x, pos_y)
	
func _process(_delta: float) -> void:
	var pos_on_grid = get_pos_idx_on_grid(player.position)
	var pos: Vector2
	for i in range(-1, 2):
		for j in range(-1, 2):
			pos.x = pos_on_grid.x + j
			pos.y = pos_on_grid.y + i
			if not grid.has(pos):
				add_background(pos)

func add_background(pos_on_grid: Vector2):
	var new_bg = Sprite2D.new()
	new_bg.texture = preload("res://Assets/background.png")
	new_bg.region_enabled = true
	new_bg.region_rect = Rect2(0, 0, bg_size.x, bg_size.y)
	new_bg.position = Vector2(bg_size.x * pos_on_grid.x, bg_size.y * pos_on_grid.y)
	add_child(new_bg)
	grid[pos_on_grid] = true
