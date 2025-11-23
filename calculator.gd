extends Control

const BasicButtons = ["7","8","9","+","4","5","6","-","1","2","3","*",".","0","()","/"]
const MenuButtons = ["Start","Quit","Cont","Save"]
const ControlButtons = ["Left","Right","Enter"]
const PowerButtons = ["Miku","MIKU","Milk","Sun Tzu"]

# Storage if you want access to the BasicButton data later
var basic_button_data : Array = []
var menu_button_data : Array = []
var control_button_data : Array = []
var power_button_data : Array = []
var TotalPoints: int = 10
var count: int = 10
var inShop: bool = false

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
@onready var Display: CalcDisplay = $DisplayContainer/Display

# DANGERA
@onready var lbl = $BasicPanel/ButtonTemplate/Uses/Label
@onready var USES = $BasicPanel/ButtonTemplate/Uses
@onready var lblprices = $BasicPanel/ButtonTemplate/Prices/Label

func _ready() -> void:
	_create_buttons(BasicButtons, BasicPanel, basic_button_data, whitebutton)
	_create_buttons(MenuButtons, MenuPanel, menu_button_data, orangebutton, -2)
	_create_buttons(PowerButtons, PowerPanel, power_button_data, bluebutton)
	_create_buttons(ControlButtons, ControlPanel, control_button_data, orangebutton, -2)


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
		
		var data = BasicButton.new(label, label, _uses,_price)  # start with 3 uses
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

	if inShop == false:
		# Decrement uses and disable if it hits 0
		data.uses -= 1
		if data.uses <= 0:
			button.disabled = true
	
		# Updating button uses
		button.get_children(true)[0].get_children()[0].text = str(data.uses)
		count -= 1
		# Handle button action
		match value:
			_:
				Display.button_press(value)
	
	if inShop == true:
		if data.price <= TotalPoints:
			TotalPoints -= data.price
			if data.uses >= -1:
				data.uses += 1
			# Updating button uses
			button.get_children(true)[0].get_children()[0].text = str(data.uses)
	
	if count == 0 and inShop == false:
		_round_to_shop()
		
	if data.uses == 3 and inShop == true:
		_shop_to_round()
		count = 10
	
	
	
