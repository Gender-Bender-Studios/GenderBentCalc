extends Control

const BasicButtons = ["7","8","9","+","4","5","6","-","1","2","3","*",".","0","()","/"]
const BasicEXEs = ["7","8","9","+","4","5","6","-","1","2","3","*",".","0","()",")/float("]
const MenuButtons = ["Start","Quit","Cont","Save"]
const MenuEXEs = ["","","",""]
const ControlButtons = ["Left","Right","Enter"]
const ControlEXEs = ["","",""]
const PowerButtons = ["Miku","MIKU","Milk","Sun Tzu"]
const PowerEXEs = ["","","",""]

# Storage if you want access to the BasicButton data later
var basic_button_data : Array = []
var menu_button_data : Array = []
var control_button_data : Array = []
var power_button_data : Array = []
var TotalPoints: int = 0
var inShop: bool = false
var EXEstring = "float("

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
@onready var DisplayLabel = $DisplayContainer/Display2D/Display
@onready var BossFrame = $BossFrame
@onready var ProgressContainer = $ProgressContainer
@onready var ScoreLogic = $"ScoreLogic(idk_how_to_reference_scripts)"
# DANGERA
@onready var lbl = $BasicPanel/ButtonTemplate/Uses/Label
@onready var USES = $BasicPanel/ButtonTemplate/Uses
@onready var lblprices = $BasicPanel/ButtonTemplate/Prices/Label

func _ready() -> void:
	_create_buttons(BasicButtons,BasicEXEs, BasicPanel, basic_button_data, whitebutton)
	_create_buttons(MenuButtons,MenuEXEs, MenuPanel, menu_button_data, orangebutton, -2)
	_create_buttons(PowerButtons,PowerEXEs, PowerPanel, power_button_data, bluebutton)
	_create_buttons(ControlButtons,ControlEXEs, ControlPanel, control_button_data, orangebutton, -2)
	print("Starting Stats: "+str(ProgressContainer.target)+"  "+str(ProgressContainer.currentValue)+"  "+str(BossFrame.room)+"  "+str(BossFrame.area))


func _create_buttons(list: Array,listEXE: Array, panel: Control, storage_array: Array, texture, _uses := 3) -> void:
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
	
	for i in range(0,len(list)):
		
		var data = BasicButton.new(list[i], list[i],listEXE[i], _uses,_price)  # start with 3 uses
		storage_array.append(data)
		var clone = ButtonTemplate.duplicate()

		clone.visible = true
		panel.add_child(clone)

		clone.name = "button_" + data.name
		clone.text = data.value
		clone.theme = texture

		# Set initial enabled/disabled state
		clone.disabled = data.uses == 0

		clone.set_meta("basic_button", data)
		clone.pressed.connect(_on_button_pressed.bind(clone))

func _TransGainedScoreToPoints(Target: float,current:) -> int:
	if Target == current:
		return roundi(40)
	var relative = abs((current/Target)-1)
	if relative <= 0.3:
		if relative <= 0.1:
			return roundi(20)
		return roundi(10)
	return 0
	
func _battle_end():
	print("Before: "+str(BossFrame.room)+ "   " + BossFrame.currenemy)
	ProgressContainer.currentValue = ScoreLogic.TempScoreCalc(EXEstring+")")
	print(ProgressContainer.currentValue)
	print(ProgressContainer.target)
	if BossFrame.currenemy == "NB":
		var points_to_add = _TransGainedScoreToPoints(ProgressContainer.target,ProgressContainer.currentValue)
		if points_to_add == 0:
			#DieDieDie
			LifePanel.numlives -= 1
			print("life down!")
		TotalPoints += points_to_add
		BossFrame.room += 1
	else:
		#Same as reg but also decrease health
		var points_to_add = _TransGainedScoreToPoints(ProgressContainer.target,ProgressContainer.currentValue)
		if points_to_add == 0:
			#DieDieDie
			LifePanel.numlives -= 1
		TotalPoints += points_to_add
		BossFrame.BossBar.value -= points_to_add
		if BossFrame.BossBar.value <= 0:
			BossFrame._killBoss()
	if BossFrame.room%3 == 1 and (BossFrame.currenemy != "Denise"):
		if BossFrame.currenemy != "Tsundere Denise":
			_round_to_shop()
	print("After: "+str(BossFrame.room)+ "   " + BossFrame.currenemy)

func _round_init():
	ProgressContainer.target = ProgressContainer._targetGen()
	ProgressContainer.currentValue = 0

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

func _on_button_pressed(button: Button):
	var data: BasicButton = button.get_meta("basic_button")
	var value: String = data.value
	var EXE: String = data.exe

	if inShop == false:
		# Decrement uses and disable if it hits 0
		data.uses -= 1
		if data.uses == 0 or data.uses==-1:
			button.disabled = true
		
		# Updating button uses
		button.get_children(true)[0].get_children()[0].text = str(data.uses)
		# Handle button action
		match value:
			"Left":
				if ScoreLogic.Cursor > 0:
					ScoreLogic.Cursor -= 1
			"Right":
				if ScoreLogic.Cursor < len(DisplayLabel.text):
					ScoreLogic.Cursor += 1
			_:
				DisplayLabel.text += value
				EXEstring += EXE
				print(EXEstring)
				
	
	if inShop == true:
		if data.price <= TotalPoints:
			TotalPoints -= data.price
			if data.uses >= -1:
				data.uses += 1
			# Updating button uses
			button.get_children(true)[0].get_children()[0].text = str(data.uses)
	
	#Logic for ending a round, enter submits the score and handles if you go to shop or not
	#if you don't go shop or leave shop, it will load data
	if data.value == "Enter":
		var flag = false
		if inShop == true:
			flag = true
		else:
			_battle_end()
		DisplayLabel.text = ""
		EXEstring = "float("
		if flag == true:
			_shop_to_round()
		if not inShop:
			_round_init()
		
		
			
		
		
	
	
