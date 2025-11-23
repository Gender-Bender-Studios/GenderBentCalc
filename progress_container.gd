extends Container

@onready var progressContainer = $"."
@onready var targetLabel = $targetLabel
@onready var targetBar = $progressBar
@onready var display = $"../DisplayContainer/Display2D/Display"

var currentValue: float = randi_range(-100,100)
var target:float = randi_range(-100,100)



var relativeValues = [0.01,0.3,0.75]
var relativePositions = generateFucksGiven(relativeValues,750)

const barHeight:int = 50



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	display.text = str(currentValue)
	
	
	
	
	targetLabel.size = Vector2(100,50)
	targetLabel.position = Vector2(progressContainer.size.x/2-targetLabel.size.x/2,targetLabel.size.y) 
	targetLabel.text = str(target)
	
	targetLabel.add_theme_font_size_override("normal_font_size",32)
	
	targetBar.position = Vector2(0,barHeight)
	
	CheckScore(currentValue,target)
	
	for id in range(len(relativePositions)):
		var idx:int
		if sign(target) == -1:
			idx = -id - 1
		else:
			idx = id
			
		var pos:float = relativePositions[id]
		var clone:Label = targetLabel.duplicate()
		
		progressContainer.add_child(clone)
		
		clone.text = str(target+mirror(relativeValues)[idx]*target)
		clone.size = Vector2(100,50)
		clone.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		clone.position.x = (pos-clone.size.x/2)
		clone.position.y = 0
		clone.visible = abs(mirror(relativeValues)[idx]) >=0.1
		
		
	targetBar.queue_redraw()
	
func CheckScore(current:float,target:float) -> void:
	var relativeScore:float = 1- current/target
	
	if abs(relativeScore) <= 0.1:
		pass
	elif abs(relativeScore) <= 0.25:
		pass
	elif abs(relativeScore) <= 1:
		pass
	#print("Target: ",target,"\nCurrent: ",current,"\nRelative Score: ",relativeScore)
	
func generateFucksGiven(arr:Array,size:int) -> Array:

	var temp:Array = mirror(arr)
	temp = (temp).map(func(e:float):return e + temp.max())
	print(temp)
	temp = temp.map(func(e:float):return size*e/temp.max())
	print(temp)
	return temp
	#[0.0, 0.16666666666667, 0.36666666666667, 0.49333333333333, 0.50666666666667, 0.63333333333333, 0.83333333333333, 1.0]
func mirror(arr:Array) -> Array:
	var temp:Array = []
	for i in range(len(arr)-1,-1,-1):
		temp.append(-arr[i])
	temp = temp + arr
	return temp
	
	
	
	
