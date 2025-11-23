extends ColorRect

@onready var BossContainer = $"."
@onready var BossName = $BossName/BossLabel
@onready var BossBar = $BossHP/BossHPBar
@onready var BossSprite = $BossSprite
@onready var BossDesc = $BossDescription/DescLabel

var areabosses: Array = ["Pythagoras", "Fibonacci", "Sherlock", "Einstein"]

var area: int = 1
var room: int = 1
var currenemy: String = "NB"

func _process(delta: float) -> void:
	if currenemy == "NB":
		if room == 6:
			_spawnAreaBoss()
			currenemy = areabosses[area-1]
			BossBar.max_value = 100 + 40*area
		elif area == 1 and room == 1:
			_spawnDenise()
		elif area == 3 and room == 3:
			_spawnDenise()
		elif area == 5 and room == 1:
			_spawnDenise()
	
	if BossBar.value <= 0:
		if BossName.text == "Tsundere Denise":
			_victoryscreen()
		elif currenemy == "NB":
			pass
		else:
			_killBoss()

func _spawnAreaBoss():
	currenemy = areabosses[area-1]
	BossBar.max_value = 100 + 40*area
	BossBar.value = 100 + 40*area
	
	_spawnGenBoss()

func _spawnDenise():
	print("A")
	if area == 5:
		currenemy = "Tsundere Denise"
	else:
		currenemy = "Denise"
		
	BossBar.max_value = 50 + 50*area
	BossBar.value = 50 + 50*area
	
	_spawnGenBoss()

func _spawnGenBoss():
	BossName.text = currenemy
	BossContainer.visible = true
	
	if currenemy == "Denise":
		BossDesc.text = "Pressure: Buttons take 2 uses per press, not one"
	elif currenemy == "Pythagoras":
		BossDesc.text = "Pythagorean theorem: Any square numbers are removed from your equation"
	elif currenemy == "Fibonacci":
		BossDesc.text = "Spiral of life: Every round you lose all of the uses of a button"
	elif currenemy == "Sherlock":
		BossDesc.text = "Pedantry: Acceptable range for answers decreased & upper limit put on key presses / function"
	elif currenemy == "Einstein":
		BossDesc.text = "Theory of relativity: Randomises the position and uses of your regular buttons each round"
	elif currenemy == "Tsundere Denise":
		BossDesc.text = "Pressure: Buttons take 2 uses per press, not one /n Presence: She jumps in front of some of your buttons each round to make sure you're paying attention to her"

func _killBoss():
	print("we did it")
	BossBar.value = 0
	
	
	BossContainer.visible = false
	
	if room == 6:
		area += 1
		room = 1
	else:
		room += 1
	
	currenemy = "NB"
	BossDesc.text = ""

func _victoryscreen():
	pass
