extends Node2D

@onready var DisplayContainer =  $".."

func _draw() -> void:
	var ind: int = 0
	
	draw_rect(Rect2(ind,ind,DisplayContainer.size.x - 2*ind,DisplayContainer.size.y - 2*ind),Color.DARK_GRAY)
