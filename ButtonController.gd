extends Button
class_name BasicButton

var value: String
var uses: int
var price: int
var exe: String

func _init(_name, _value,_exe, _uses := 0, _price := 0):
	name = _name
	text = _value
	value = _value
	exe = _exe
	uses = _uses
	price = _price
