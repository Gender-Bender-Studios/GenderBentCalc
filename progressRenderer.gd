extends Node2D

@onready var progressContainer =  $".."
@onready var bar = $"."

const barHeight:int = 50

func _draw() -> void:
	var badPosition:Vector2 = Vector2(0,progressContainer.size.y-barHeight*2 -25)
	var goodPosition:Vector2 = Vector2(3*progressContainer.size.x/8,progressContainer.size.y-barHeight*2 -25)
	var pityPosition:Vector2 = Vector2(49*progressContainer.size.x/100,progressContainer.size.y-barHeight*2 -25)
	
	var badSize:Vector2 = Vector2(progressContainer.size.x,barHeight)
	var goodSize:Vector2 = Vector2(progressContainer.size.x/4,barHeight)
	var pitySize:Vector2 = Vector2(2*progressContainer.size.x/100,barHeight)
	
	draw_rect(Rect2(badPosition,badSize),Color.RED)
	draw_rect(Rect2(goodPosition,goodSize),Color.GREEN)
	draw_rect(Rect2(pityPosition,pitySize),Color.DARK_GREEN)
	pass
