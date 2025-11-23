extends Button
class_name BasicButton

var buttonText: String
var value: String
var uses: int
var price: int
var inshop: bool

func _init(_text, _value, _uses := 0, _price := 0):
	buttonText = _text
	value = _value
	uses = _uses
	price = _price
