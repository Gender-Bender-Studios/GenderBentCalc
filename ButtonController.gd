extends Button
class_name BasicButton

var value: String
var uses: int
var price: int
var inshop: bool

func _init(_name, _value, _uses := 0, _price := 0):
	name = _name
	text = _value
	value = _value
	uses = _uses
	price = _price
