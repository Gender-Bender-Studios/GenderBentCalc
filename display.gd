class_name CalcDisplay
extends Control

const TEXT_COLOR: Color = Color.WHITE
const BACKGROUND_COLOR: Color = Color.DIM_GRAY
const FONT_SIZE: int = 52

static var ExprHelper = preload("res://expr/ExprHelper.cs")
static var font: Font = load("res://prstartk.ttf")

var expr_helper
@onready 
var DisplayContainer = $'..'


func _ready() -> void:
	self.expr_helper = ExprHelper.create(self, font, FONT_SIZE, TEXT_COLOR, BACKGROUND_COLOR,
		Rect2(Vector2.ZERO, DisplayContainer.size), Vector2(20.0, 10.0)
	)
	

func _draw():
	self.expr_helper.Draw()
	

func _process(_delta: float) -> void:
	self.queue_redraw()
	
func button_press(key: String) -> void:
	print("God-willing: ", key)
	self.expr_helper.BtnPress(key)
