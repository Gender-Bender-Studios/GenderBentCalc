extends Container

@onready var DisplayContainer = $"."
@onready var Display = $Display2D/Display



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Display.size = DisplayContainer.size
	Display.position = Vector2(0,0)
