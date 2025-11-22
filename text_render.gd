extends Control

class UI:
	func draw():
		pass

class ValueUI extends UI:
	var value: String
	var origin: Vector2
	var canvas: CanvasItem
	var font: Font
	var size: int = 52
	
	static func create(origin: Vector2, value: String, canvas: CanvasItem, font: Font) -> ValueUI:
		var s = ValueUI.new()
		s.origin = origin
		s.value = value
		s.canvas = canvas
		s.font = font
		return s
	
	func draw():
		self.canvas.draw_string(self.font, self.origin, self.value, HORIZONTAL_ALIGNMENT_LEFT, -1,  self.size, Color.BLACK)

class CursorUI extends UI:
	var origin: Vector2
	var cycle: Array[int] = [20, 30]
	var i: int = 0
	var canvas: CanvasItem
	
	var cursor_width: int = 6
	var cursor_height: int = 60
	var color: Color

	func draw():

		match i:
			var t when t < self.cycle[0]:
				self.canvas.draw_rect(Rect2i(int(self.origin.x), int(self.origin.y), self.cursor_width, self.cursor_height), self.color)
			_:
				pass
	
		i = (i + 1) % cycle[-1]
	
	static func create(origin: Vector2, canvas: CanvasItem, color: Color = Color.DIM_GRAY) -> CursorUI:
		var s = CursorUI.new()
		s.canvas = canvas
		s.origin = origin
		s.color = color
		return s


static var font: Font = load("res://fonts/prstartk.ttf")
@onready var cursor_canvas: CanvasItem = $Cursor;
@onready var display_canvas: CanvasItem = $Display;


var components: Array[UI]
var cursor_i = 0
var prompt = "abcd1fgh"
var cursor: CursorUI

func _ready():
	self.components = [
		ValueUI.create(Vector2(125.0, 52.0), self.prompt, self, font),
	]
	self.cursor = CursorUI.create(Vector2(125.0, 0.0), self) 

func _draw():
	self.draw_rect(Rect2i(0.0, 0.0, 1200.0, 120.0), Color.WHITE)
	
	for s in self.components:
		s.draw()
	self.cursor.draw()
	

func _on_right_btn_pressed():
	self.cursor_i = mini(self.cursor_i + 1, prompt.length())
	
	self.cursor.origin = calc_cursor_pos(Vector2(125.0, 0.0))
	
	
func _on_left_btn_pressed():
	self.cursor_i = maxi(self.cursor_i - 1, 0)
	self.cursor.origin = calc_cursor_pos(Vector2(125.0, 0.0))
	

func _on_backspace_btn_pressed():
	self.prompt = self.prompt.substr(0, maxi(self.cursor_i-1, 0)) + prompt.substr(self.cursor_i)
	self.components[0].value = self.prompt
	self.cursor_i = mini(max(self.cursor_i-1, 0), self.prompt.length())
	
	self.cursor.origin = calc_cursor_pos(Vector2(125.0, 0.0))
	
func _process(_delta: float) -> void:
	self.queue_redraw()

func calc_cursor_pos(origin: Vector2) -> Vector2:
	var bound = font.get_string_size(self.prompt.substr(0, cursor_i), HORIZONTAL_ALIGNMENT_LEFT, -1, 52, TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_LTR, TextServer.ORIENTATION_HORIZONTAL)
	origin.x += bound.x
	return origin
