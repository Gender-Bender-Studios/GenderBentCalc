extends Control

@onready var Calc = $".."
@onready var ScoreLabel = $Node2D/ScoreLabel

func _process(delta: float) -> void:
	ScoreLabel.text = str(Calc.TotalPoints)
