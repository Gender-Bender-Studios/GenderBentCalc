extends ColorRect

@onready var BossContainer = $"."
@onready var BossName = $BossName/BossLabel
@onready var BossBar = $BossHP/BossHPBar
@onready var BossSprite = $BossSprite
@onready var BossDesc = $BossDescription/DescLabel
@onready var Calc = $".."

var areabosses: Array = ["Pythagoras", "Fibonacci", "Sherlock", "Einstein"]

var area: int = 1
var room: int = 1
var currenemy: String = "NB"

func _ready() -> void:
	room = Calc.round 
	area = Calc.area

func _process(delta: float) -> void:
	room = Calc.round 
	area = Calc.area
	
	if room == 2:
		_killBoss()
	
	if currenemy == "NB":
		if room == 6:
			_spawnAreaBoss()
			currenemy = areabosses[area]
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
		else:
			_killBoss()

func _spawnAreaBoss():
	currenemy = areabosses[area]
	BossBar.max_value = 100 + 40*area
	BossBar.value = 100 + 40*area
	
	_spawnGenBoss()

func _spawnDenise():
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
		BossSprite.texture = load("res://Assets/Denice_beloved.png")
	elif currenemy == "Pythagoras":
		BossDesc.text = "Pythagorean theorem: Any square numbers are removed from your equation"
		BossSprite.texture = load("res://Assets/triangles-4-01.webp")
	elif currenemy == "Fibonacci":
		BossDesc.text = "Spiral of life: At the end of every round, a random button loses all of it's uses"
		BossSprite.texture = load("res://Assets/Placeholders/Spectrum3.webp")
	elif currenemy == "Sherlock":
		BossSprite.texture = load("res://Assets/vintage-female-sherlock-holmes-detective-smoking-a-pipe-and-wearing-CT6BAP.jpg")
		BossDesc.text = "Pedantry: Acceptable range for answers decreased & upper limit put on key presses / function"
	elif currenemy == "Einstein":
		BossSprite.texture = load("res://Assets/Screenshot_2025-11-23_at_15.51.35.png")
		BossDesc.text = "Theory of relativity: Randomises the position and uses of your regular buttons each round"
	elif currenemy == "Tsundere Denise":
		BossDesc.text = "Pressure: Buttons take 2 uses per press, not one /n Presence: She jumps in front of some of your buttons each round to make sure you're paying attention to her"
		BossSprite.texture = load("res://Assets/Denice_beloved.png")

func _killBoss():
	BossBar.value = 0
	
	BossContainer.visible = false
	
	area += 1
	room = 1
	
	currenemy = "NB"
	BossDesc.text = ""

func _victoryscreen():
	pass
