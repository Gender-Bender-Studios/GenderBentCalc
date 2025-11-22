extends Node

func _on_pressed():
	var res = Expr.operation(Expr.ADD, [Expr.value(12.3), Expr.value(12.6)])
	print("Result: " + str(res.evaluate()))
