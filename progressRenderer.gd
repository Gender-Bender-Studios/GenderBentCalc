extends Node2D

@onready var progressContainer =  $".."
@onready var bar = $"."
@onready var lbl = $"../../DisplayContainer/Display2D/Equation"
@onready var rootNode = $"../.."


var scalePositions:Array


const barHeight:int = 50

func _ready() -> void:
	
	scalePositions = progressContainer.relativePositions
	
	

func _draw() -> void:
	var bars:Array = []
	for i in range(len(scalePositions)/2):
		var positon:Vector2 = Vector2(scalePositions[i],0)
		var length:Vector2 = Vector2((scalePositions[-i-1]-scalePositions[i]),barHeight)
		bars.append(Rect2(positon,length))
		

	
	#print(bars)
	
		
	for i in range(len(bars)):
		
		var red:float = 255 - 255/(len(bars)-1) * (i)
		var green:float = 255/(len(bars)-1) * (i)
		
		#print("red: ",red,"\ngreen: ",green)
		var rectangle:Rect2 = bars[i]
		var c:Color = Color(red/255,green/255,0)
		draw_rect(rectangle,c)
		
	var tgt:float = progressContainer.target
	var cnt:float = float(rootNode.eval_safe(lbl.text))
	#print(cnt)
	var rel:Array = progressContainer.mirror(progressContainer.relativeValues)
	
	
	
	
	var top:float = cnt - tgt * (sign(tgt) *rel.min()+1)
	var bottom:float = abs(tgt)* (2 * rel.max())
	var x:float = 750 * (top/bottom)
	
	#print("top: ",top,"\nbottom: ",bottom,"\nx: ",x,"\nvalues: ",rel)
	

	
	if x > 750:
		x = 750
	if x < 0:
		x = 0
	if(sign(cnt*tgt) == -1):
		750+x
	#print(x)

	
	var pointerLength:Vector2 = Vector2(5,barHeight)
	var pointerPosition:Vector2 = Vector2(x,0)
	var pointer = Rect2(pointerPosition,pointerLength)
	draw_rect(pointer,Color.BLACK)
	#print(pointerPosition)
	
	

	pass
