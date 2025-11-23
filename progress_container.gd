extends Container

@onready var rootNode = $".."
@onready var progressContainer = $"."
@onready var targetLabel = $targetLabel
@onready var PointsLabel = $PointsLabel
@onready var targetBar = $progressBar
@onready var Eqn = $"../DisplayContainer/Display2D/Equation"
@onready var Ans = $"../DisplayContainer/Display2D/Ans"
@onready var BossContainer = $"../BossFrame"
@onready var Location = $Location

#var currentValue: float = randi_range(-100,100)
var routeEnemies:Array = [
	["Denise","Normal","Normal","Normal","Normal","Boss"],
	["Normal","Normal","Normal","Normal","Normal","Boss"],
	["Normal","Normal","Denise","Normal","Normal","Boss"],
	["Normal","Normal","Normal","Normal","Normal","Boss"],
	["Tsundere Denise"]
]

var target:float
var currenemy:String = ""



var relativeValues = [0.01,0.3,0.75]
var relativePositions = generateFucksGiven(relativeValues,750)

const barHeight:int = 50



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Location.size = Vector2(800,100)
	Location.position = Vector2(progressContainer.size.x/2-Location.size.x/2,progressContainer.size.y-50)
	Location.text = "Area: " + str(rootNode.area) + "       Round: " + str(rootNode.round)
	Location.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	target  = _targetGen()
	#Eqn.text = str(currentValue)
	targetBar.position = Vector2(0,barHeight)
	
	createLabels(target)
		
		
	targetBar.queue_redraw()
	

	
func generateFucksGiven(arr:Array,size:int) -> Array:

	var temp:Array = mirror(arr)
	temp = (temp).map(func(e:float):return e + temp.max())
	#print(temp)
	temp = temp.map(func(e:float):return size*e/temp.max())
	#print(temp)
	return temp
	#[0.0, 0.16666666666667, 0.36666666666667, 0.49333333333333, 0.50666666666667, 0.63333333333333, 0.83333333333333, 1.0]
func mirror(arr:Array) -> Array:
	var temp:Array = []
	for i in range(len(arr)-1,-1,-1):
		temp.append(-arr[i])
	temp = temp + arr
	return temp

func _targetGen():
	var area:int = rootNode.area
	var round:int = rootNode.round
	currenemy = routeEnemies[area-1][round-1]
	
	print("Area: ",area,"\nRound: ",round,"\nCurrent Enemy: ",currenemy)
	if currenemy == "Denise":
		# Target type: Big numbers
		return randi() % (10**(area+3)-10**(area+2)) + 10**(area+2)
	else:
		if area == 1:
			# Target type: Square numbers
			return (randi_range(1,16))**2
		elif area == 2:
			# Target type: Fib numbers
			var x: int = randi() % 17 + 4
			return F(x)
		elif area == 3:
			# Target type: Small numbers
			return 1/(2)
		else:
			# Target type: Constants
			if randi() % 1 == 1:
				return (randi() % 99 + 1)*2.71828
			else:
				return (randi() % 99 + 1)*3.14159
	
func F(a):
	if a == 1 or a == 2:
		return 1
	else:
		return F(a-1) + F(a-2)

func createLabels(target):
	targetLabel.size = Vector2(100,50)
	targetLabel.position = Vector2(progressContainer.size.x/2-targetLabel.size.x/2,0) 
	targetLabel.text = str(target)

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
		clone.name = str(mirror(relativeValues)[idx]) + "_Marker"
		clone.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		clone.position.x = (pos-clone.size.x/2)
		clone.position.y = 0
		clone.visible = abs(mirror(relativeValues)[idx]) >=0.1
	

func resetCalc(hardReset:bool = false) -> void:
	var threshLables:Array = progressContainer.get_children()
	for node in threshLables:
		if node is Label && !(node.name in ["targetLabel","Location"]):
			progressContainer.remove_child(node)
	if hardReset:
		pass
	else:
		target = _targetGen()
		createLabels(target)
	Eqn.text = ""
	Ans.text = "="
	#print(target)
