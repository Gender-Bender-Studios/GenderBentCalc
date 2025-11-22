class_name Expr

func evaluate() -> float:
	return 0.0

static func value(val: float) -> Expr:
	return ExprValue.create(val) as Expr
	
static func operation(op: Callable, args: Array[Expr]) -> Expr:
	return ExprOperation.create(op, args) as Expr
	
static var ADD = func(a, b): return a + b
static var SUB = func(a, b): return a - b
static var MUL = func(a, b): return a * b
static var DIV = func(a, b): return a / b

class ExprValue extends Expr:
	var _value: float
	
	static func create(val: float) -> ExprValue:
		var v = ExprValue.new()
		v._value = val
		return v
		
	func evaluate() -> float:
		return self._value
	
class ExprOperation extends Expr:
	var _operator: Callable
	var _arguments: Array[Expr]
	
	static func create(op: Callable, arguments: Array[Expr]) -> ExprOperation:
		var oper = ExprOperation.new()
		oper._operator = op
		oper._arguments = arguments
		return oper
	
	func evaluate() -> float:
		return self._operator.callv(self._arguments.map(func(e: Expr): return e.evaluate()))
	
	
class ExprPlaceholder extends Expr:
	var text: String
	
	func evaluate() -> float:
		return NAN
