extends Container

@onready var progressContainer = $"."
@onready var targetLabel = $targetLabel
@onready var targetBar = $progressBar

var currentValue: float = 100
const relativePositions:Array = [-1,-0.25,0,.25,1]

const barHeight:int = 50



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var target:float = float(randi_range(-100,100))
	
	
	targetLabel.size = Vector2(progressContainer.size.x/2,0)
	targetLabel.position = Vector2(progressContainer.size.x/2,targetLabel.size.y) 
	targetLabel.text = "Target: " + str(target)
	
	targetBar.position = Vector2(0,progressContainer.size.y-barHeight)
	
	CheckScore(currentValue,target)
	
	for pos in relativePositions:
		var clone:Label = targetLabel.duplicate()
		progressContainer.add_child(clone)
		clone.text = str(target+pos*target)
		clone.size = Vector2(100,50)
		clone.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		clone.position.x = progressContainer.size.x/2 -clone.size.x/2 + pos *progressContainer.size.x/2
		clone.position.y = progressContainer.size.y -barHeight * 1.2
		
	targetBar.queue_redraw()
	
func CheckScore(current:float,target:float) -> void:
	var relativeScore:float = 1- current/target
	
	if abs(relativeScore) <= 0.1:
		pass
	elif abs(relativeScore) <= 0.25:
		pass
	elif abs(relativeScore) <= 1:
		pass
	print("Target: ",target,"\nCurrent: ",current,"\nRelative Score: ",relativeScore)
