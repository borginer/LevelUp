extends Node
# global functions

func in_range(p1: Vector2, p2: Vector2, _range: float):
	return (p1 - p2).length() < _range
	
