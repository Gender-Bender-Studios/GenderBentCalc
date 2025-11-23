extends Node2D

@onready var template = $".."
@onready var lblprices = $Label
# Called when the node enters the scene tree for the first time.
func _draw() -> void:
	var size: int = template.size.x
	var radius: int = 15
	var txtsz: float = 0.8
	var ind: Vector2 = Vector2(3, 3)

	draw_circle(Vector2(0, 0) + ind, radius, Color.DIM_GRAY)
	draw_circle(Vector2(0, 0) + ind, 0.9*radius, Color.WHITE)
	
	lblprices.position = Vector2(-txtsz*radius,-txtsz*radius) + ind + Vector2(6,0)
	lblprices.size = Vector2(2*txtsz*radius, 2*txtsz*radius)
