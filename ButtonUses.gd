extends Node2D

@onready var template = $".."
@onready var lbl = $Label
# Called when the node enters the scene tree for the first time.
func _draw() -> void:
	var size: int = template.size.x
	var radius: int = 15
	var txtsz: float = 0.8
	var ind: Vector2 = Vector2(-3, 3)
	
	draw_circle(Vector2(size, 0) + ind, radius, Color.DIM_GRAY)
	draw_circle(Vector2(size, 0) + ind, 0.9*radius, Color.WHITE)
	
	lbl.position = Vector2(size-txtsz*radius,-txtsz*radius) + ind
	lbl.size = Vector2(2*txtsz*radius, 2*txtsz*radius)
