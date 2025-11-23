extends Container

@onready var DisplayContainer = $"."
@onready var Eqn = $Display2D/Equation
@onready var Ans = $Display2D/Ans



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Eqn.size = DisplayContainer.size
	Eqn.position = Vector2(0,0)
	Ans.size.x = DisplayContainer.size.x/2
	Ans.size.y = DisplayContainer.size.y/4
	
	Ans.position = Vector2(DisplayContainer.size.x/2,DisplayContainer.size.y-DisplayContainer.size.y/4)
	Ans.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	Ans.text = "="
