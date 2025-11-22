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

@onready var ButtonTemplate = $BasicPanel/ButtonTemplate
@onready var BasicPanel = $BasicPanel
@onready var MenuPanel = $MenuPanel
@onready var PowerPanel = $PowerPanel
@onready var ControlPanel = $ControlPanel
@onready var DisplayLabel = $DisplayContainer/Display2D/Display

# DANGERA
@onready var lbl = $BasicPanel/ButtonTemplate/Uses/Label


func _ready() -> void:
	_create_buttons(BasicButtons, BasicPanel, basic_button_data)
	_create_buttons(MenuButtons, MenuPanel, menu_button_data)
	_create_buttons(PowerButtons, PowerPanel, power_button_data)
	_create_buttons(ControlButtons, ControlPanel, control_button_data)


func _create_buttons(list: Array, panel: Control, storage_array: Array) -> void:
	var _uses: int = 3
	
	# Use label set up
	lbl.text = str(_uses)
	lbl.visible = true
	lbl.get_parent().visible = true
	
	for label in list:
		
		var data = BasicButton.new(label, label, _uses)  # start with 3 uses
		storage_array.append(data)

		var clone = ButtonTemplate.duplicate()
		clone.visible = true
		panel.add_child(clone)

		clone.name = "button_" + data.name
		clone.text = data.value

		# Set initial enabled/disabled state
		clone.disabled = data.uses == 0

		clone.set_meta("basic_button", data)
		clone.pressed.connect(_on_button_pressed.bind(clone))



func _on_button_pressed(button: Button):
	var data: BasicButton = button.get_meta("basic_button")
	var value: String = data.value

	# Decrement uses and disable if it hits 0
	data.uses -= 1
	if data.uses <= 0:
		button.disabled = true
		
	# Updating button uses
	button.get_children(true)[0].get_children()[0].text = str(data.uses)

	# Handle button action
	match value:
		_:
			DisplayLabel.text += value
