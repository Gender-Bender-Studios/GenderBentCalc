extends Node2D

@onready var template = $".."
@onready var lbl = $Label
# Called when the node enters the scene tree for the first time.
func _draw() -> void:
	var size: int = template.size.y
	var radius: int = 15
	var txtsz: float = 0.8
	var ind: Vector2 = Vector2(8, 8)
	
	draw_circle(Vector2(0, size-18) + ind, radius, Color.DIM_GRAY)
	draw_circle(Vector2(0, size-18) + ind, 0.9*radius, Color.WEB_GRAY)
	
	lbl.position = Vector2(txtsz*radius-8,size -txtsz*radius - 10)
	lbl.size = Vector2(2*txtsz*radius, 2*txtsz*radius)
