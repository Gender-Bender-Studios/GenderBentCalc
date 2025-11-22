extends TextureRect

var vPort = SubViewport.new()

var img: Image

func _ready() -> void:
	
	self.texture = ImageTexture.create_from_image(img)
	self.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	self.stretch_mode = TextureRect.STRETCH_SCALE
	
	
const colors = [Color.BLACK, Color.TRANSPARENT]

const BLINK_CYCLE = [60, 80]
const BLINK_WIDTH = 8
const BLINK_HEIGHT = 60



var i = 0
func _process(_delta: float) -> void:

	img.fill_rect(Rect2i(0, 0, 1200, 120), Color.TRANSPARENT) 
	
	self.texture = ImageTexture.create_from_image(img)
	
	
	match i:
		var t when t < BLINK_CYCLE[0]:
			img.fill_rect(Rect2i(40, 0, BLINK_WIDTH, BLINK_HEIGHT), Color.GOLD)
		_:
			img.fill_rect(Rect2i(40, 0, BLINK_WIDTH, BLINK_HEIGHT), Color.TRANSPARENT)
			
	i = (i + 1) % 80
	
