extends Node2D

class Cursor:
	static var font: Font = load("res://prstartk.ttf")
	static var FONT_SIZE: int = 32
	static var POS_OFFSET = Vector2(0, -2)
	static var SIZE_OFFSET = Vector2(5, 4)

	var canvas: CanvasItem
	var box: RichTextLabel
	var index: int = 0
	var rect: Rect2 = Rect2(0, 0, 0, 0)
	var color: Color

	var frame: int = 0
	var cycle: Array[int] = [20, 30]

	static func create(_canvas: CanvasItem, _box: RichTextLabel, _color: Color = Color.from_rgba8(24, 193, 27)):
		var s = Cursor.new()
		s.canvas = _canvas
		s.box = _box
		s.color = _color
		s.recalculate_rect()
		return s

	func recalculate_rect():
		var box_width = box.size.x
		if box.text.is_empty():
			self.rect = Rect2(Vector2(box.size.x / 2 - 3, box.size.y / 2 - 18), Vector2(5, 36))
			print(self.rect)
			return
		
		
		var line: int = box.get_character_line(maxi(self.index - 1, 0))
		var char_y: float = box.size.y / 2 - 18 + box.get_line_offset(line)
		
		var line_height: int = box.get_line_height(line)
		print("Index: ", self.index, " Line Index: ", line, " Char: ", char_y, " Line Height: ", line_height)
		var line_width = box.get_line_width(line)
		var line_x_offset: float = (box_width - line_width) / 2
		var line_range = box.get_line_range(line)
		print("Line Range: ", line_range)
		var line_txt = box.text.substr(line_range.x, self.index)
		print("Line Segment: '", line_txt, "'")
		var line_segment_size: Vector2 = font.get_string_size(line_txt, HORIZONTAL_ALIGNMENT_LEFT, line_width, FONT_SIZE, TextServer.JUSTIFICATION_NONE, TextServer.DIRECTION_LTR, TextServer.ORIENTATION_HORIZONTAL)
		
		var char_x = line_x_offset + line_segment_size.x
		
		var cursor_rect = Rect2(Vector2(char_x, char_y) + POS_OFFSET, Vector2(0, line_height) + SIZE_OFFSET)
		self.rect = cursor_rect
		print("Rect: ", self.rect)

	func move(rel_idx: int):
		self.index += rel_idx
		self.recalculate_rect()

	func draw() -> void:
		if box == null: return
		if self.frame < self.cycle[0]:
			canvas.draw_rect(self.rect, self.color, true)
			pass
			
		self.frame = (self.frame + 1) % self.cycle[-1]


@onready var DisplayContainer = $".."
@onready var Eqn: RichTextLabel = $Equation
@onready var Ans = $Ans

var cursor: Cursor
var current_val: float = NAN

func _ready() -> void:
	Eqn.size = DisplayContainer.size
	Eqn.position = Vector2(0, 0)
	Ans.size.x = DisplayContainer.size.x / 2
	Ans.size.y = DisplayContainer.size.y / 4
	
	Ans.position = Vector2(DisplayContainer.size.x / 2, DisplayContainer.size.y - DisplayContainer.size.y / 4)
	Ans.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	Ans.text = "="
	
	cursor = Cursor.create(self, Eqn)
	
func reset() -> void:
	Ans.text = "="
	Eqn.text = ""
	cursor.index = 0

func move(rel: int) -> void:
	print("MOVING ", rel)
	self.cursor.move(rel)

static func eval_safe(equation: String) -> String:
	var expr := Expression.new()
	if expr.parse("float(" + equation.replace("*", ")*float(").replace("/", ")/float(") + ")") != OK:
		return "ERROR"

	var result = expr.execute()
	if expr.has_execute_failed():
		return "ERROR"

	return str(result)

func insert(ch: String) -> void:
	print("Insert ", ch)
	Eqn.text = Eqn.text.substr(0, self.cursor.index) + ch + Eqn.text.substr(self.cursor.index)
	self.cursor.move(ch.length())
	
	var raw_val = eval_safe(Eqn.text)
	if raw_val != "ERROR":
		print("RAW VALUE: ", float(raw_val))
		self.current_val = float(raw_val)
		
	Ans.text = "= " + raw_val
	
func value() -> float:
	return self.current_val

func _process(delta: float) -> void:
	self.queue_redraw()

func _draw() -> void:
	self.draw_rect(Eqn.get_rect(), Color.TRANSPARENT, true)
	self.cursor.draw()
