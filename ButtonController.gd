extends Button
class_name BasicButton

var value: String
var uses: int

func _init(_name, _value, _uses := 0):
	name = _name
	text = _value
	value = _value
	uses = _uses
