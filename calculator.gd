extends Control

const BasicButtons = ["7","8","9","+","4","5","6","-","1","2","3","*",".","0","()","/"]
const MenuButtons = ["Start","Quit","Cont","Save"]
const ControlButtons = ["Left","Right","Enter"]
const PowerButtons = ["Miku","MIKU","Milk","Sun Tzu"]

const fibPos:Array = [0,1,2,3]
var fibIdx:int = 0

# Storage if you want access to the BasicButton data later
var basic_button_data : Array = []
var menu_button_data : Array = []
var control_button_data : Array = []
var power_button_data : Array = []
var TotalPoints: int = 10
var inShop: bool = false
var currentValue: float 

var area: int = 3
var round: int = 6
var Enemy: String = ""

# Button swapping variables
var buttSwap: bool = false
var buttToSwap: String = "" # The text that will go on the button
var buttType: String = "" # REG / POW 


@onready var whitebutton = load("res://Textures/white buttons.tres")
@onready var orangebutton = load("res://Textures/orange buttons.tres")
@onready var bluebutton = load("res://Textures/blue buttons.tres")
@onready var calcsprite = $Sprite2D

@onready var ButtonTemplate = $BasicPanel/ButtonTemplate
@onready var LifePanel = $LifePanel
@onready var BasicPanel = $BasicPanel
@onready var MenuPanel = $MenuPanel
@onready var PowerPanel = $PowerPanel
@onready var ControlPanel = $ControlPanel
@onready var Eqn = $DisplayContainer/Display2D/Equation
@onready var Ans = $DisplayContainer/Display2D/Ans

# DANGERA
@onready var lbl = $BasicPanel/ButtonTemplate/Uses/Label
@onready var USES = $BasicPanel/ButtonTemplate/Uses
@onready var lblprices = $BasicPanel/ButtonTemplate/Prices/Label
@onready var progressContainer = $ProgressContainer
@onready var targetLabel = $ProgressContainer/targetLabel
@onready var bar = $ProgressContainer/progressBar
@onready var lives = $LifePanel
@onready var Location = $ProgressContainer/Location
@onready var ButtonTraderB = $ButtonTrader/ButtonTraderButton


func _ready() -> void:
	_create_buttons(BasicButtons, BasicPanel, basic_button_data, whitebutton)
	_create_buttons(MenuButtons, MenuPanel, menu_button_data, orangebutton, -2)
	_create_buttons(PowerButtons, PowerPanel, power_button_data, bluebutton)
	_create_buttons(ControlButtons, ControlPanel, control_button_data, orangebutton, -2)
	Enemy = progressContainer.currenemy
	
	

func _create_buttons(list: Array, panel: Control, storage_array: Array, texture, _uses := 3) -> void:
	
	
	var _price: int = 1
	var labelvis = true
	if _uses == -2:
		labelvis = false
		
		
	# Use label set up
	lbl.text = str(_uses)
	lbl.visible = true
	lbl.get_parent().visible = labelvis
	
	# Price Label setup
	lblprices.text = str(_price)
	lblprices.visible = true
	lblprices.get_parent().visible = false
	
	
	
	for label in list:

		var val
		if (list == ControlButtons || list == MenuButtons) && label not in ["Enter","Quit"]:
			val = "skip"
			_price = 0
		else:
			val = label
		var data = BasicButton.new(label, val, _uses,_price)
		storage_array.append(data)

		var clone = ButtonTemplate.duplicate()

		clone.visible = true
		panel.add_child(clone)

		clone.name = "button_" + data.buttonText
		clone.text = data.buttonText
		clone.theme = texture

		# Set initial enabled/disabled state
		clone.disabled = data.uses == 0

		clone.set_meta("basic_button", data)
		clone.pressed.connect(_on_button_pressed.bind(clone))

func _round_to_shop():




	var BasArra = BasicPanel.get_children()
	BasArra.remove_at(0)
	var PowArra = PowerPanel.get_children()
	inShop = true
	for button in BasArra:
		button.disabled = false
		button.get_children()[1].visible = true
	for button in PowArra:
		button.disabled = false
		button.get_children()[1].visible = true
		
	ButtonTraderB.visible = true
		


func _shop_to_round():
	var BasArra = basic_button_data
	var BasArraFrame = BasicPanel.get_children()
	BasArraFrame.remove_at(0)
	var PowArraFrame = PowerPanel.get_children()
	var PowArra = power_button_data
	inShop = false
	for i in range(0,len(BasArra)):
		if BasArra[i].uses == 0:
			BasArraFrame[i].disabled = true
		BasArraFrame[i].get_children()[1].visible = false
	for i in range(0,len(PowArra)):
		if PowArra[i].uses == 0:
			PowArraFrame[i].disabled = true
		PowArraFrame[i].get_children()[1].visible = false
	Eqn.text = ""
	Ans.text = "="
	
	ButtonTraderB.visible = false

func _on_button_pressed(button: Button):
	
	
	var data: BasicButton = button.get_meta("basic_button")
	var value: String = data.value

	if inShop == false:
		# Decrement uses and disable if it hits 0
		var useCost:int = 1
		if Enemy in ["Denise","Tsundere Denise"]:
			useCost = 2
		else:
			useCost = 1
			
		data.uses -= useCost
		data.uses = max(data.uses,0)
		if data.uses <= 0 && !(data.buttonText in MenuButtons || data.buttonText in ControlButtons): 
			button.disabled = true
		

		# Updating button uses
		button.get_children(true)[0].get_children()[0].text = str(data.uses)
	
		var current = eval_safe(Eqn.text)
		
		
			
		# Handle button action
		match value:
			"Enter":
				var target:float = float(targetLabel.text)

				
				print("Target: ",target,"\nCurrent: ",float(current))
				checkScore(target,float(current))
			"Quit":
				get_tree().quit()
					
			"skip":
				pass
			_:
				
				Eqn.text += value
				current = eval_safe(Eqn.text)
				Ans.text = "= " + str(current)
				
				
				bar.queue_redraw()
		
	if inShop == true:
		match value:
			"Quit":
				_shop_to_round()

			_:
				pass
		if data.price <= TotalPoints:
			TotalPoints -= data.price
			if data.uses >= -1:
				data.uses += 1
			# Updating button uses
			button.get_children(true)[0].get_children()[0].text = str(data.uses)
	

	
func checkScore(target:float,current:float) -> void:
	var relScore = 1 - current/target
	print(relScore)
	var safe:bool = false
	var points:float = 0
	for idx in range(len(progressContainer.relativeValues)-1):
		var limit:float = progressContainer.relativeValues[idx]
		#print("\nchecking ",relScore," against ", limit)
		if abs(relScore) <= limit:
			safe = abs(relScore) <= limit
			
			
			points = round(50*(1-limit))
			TotalPoints += points 
			print("Points Earned: ",points)
			round += 1
			
			if round == 6:
				pass
				#runBoss()			
			if round == 7:
				area+=1
				round = 1
			break
			

	#print(safe)
	#		
	if !safe:
		lives.numlives-=1

				
	print("\nCurrent Round: ",area,"-",round)
	progressContainer.resetCalc()
	Location.text = "Area: " + str(area) + "       Round: " + str(round)

	if round == 4:
		_round_to_shop()
		Eqn.text = "Scuff Sals\n\nClick Buttons to Spend Points"
		Ans.text = ""
	
	Enemy = progressContainer.currenemy

func eval_safe(equation: String) -> String:
	var expr := Expression.new()
	if expr.parse("float(" + equation.replace("*", ")*float(").replace("/", ")/float(") + ")") != OK:
		return "ERROR"

	var result = expr.execute()
	if expr.has_execute_failed():
		return "ERROR"

	return str(result)



func force_floats(eq: String) -> String:
	var r = RegEx.new()
	r.compile(r"(?<!\d)\d+(?!\.\d)")
	return r.sub(eq, "$0.0", true)
