extends Panel

@onready var LifePanel = $"."
@onready var LifeTemplate = $LifeTemplate

var spacing: int = 40

var initlives: int = 3
var numlives: int = initlives
var maxlives: int = 7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawnlives(0,initlives)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if numlives > maxlives:
		numlives = maxlives
	
	# If gained lives, spawn new lives
	if !LifePanel.has_node("life_" + str(numlives)):
		for n in range(numlives):
			if !LifePanel.has_node("life_" + str(n)):
				_spawnlives(n,numlives)
				break
	
	# If lost lives, destroy lives
	if LifePanel.has_node("life_" + str(numlives)):
		for n in range(numlives,maxlives):
			if !LifePanel.has_node("life_" + str(n)):
				for m in range(numlives, n):
					LifePanel.get_node("life_" + str(m)).queue_free()
				break
		
	if numlives <= 0:
		# Die
		pass

func _spawnlives(startlives,lives) -> void:
	for n in range(startlives,lives):
		var clone: Sprite2D = LifeTemplate.duplicate()
		clone.visible = true
		clone.name = "life_" + str(n)
		LifePanel.add_child(clone)
		clone.position = Vector2(18 + n*spacing,25)
