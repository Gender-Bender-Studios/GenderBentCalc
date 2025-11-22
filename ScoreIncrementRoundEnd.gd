extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
var TotalPoints = 0 #PLACEHOLDER, We will store and init the total score at boot
var TargetScore = 1 #PlACEHOLDER, need to write function to calculate round targets

func _ScoreMultplierCondense(room_no: int,FullStop = false) -> float:#unfinished, first bool is FullStop's condition
	var FullStopScoreMult = 1
	if FullStop:
		FullStopScoreMult = 1.5
	return 1 * FullStopScoreMult

func _TransGainedScoreToPoints(Target: float,Score: float,room_no: int,ScoreMult: float) -> int:
	if Target == Score:
		return roundi(40*ScoreMult)
	var Upper = TargetScore*1.25
	var Lower = TargetScore*0.75
	var upper = TargetScore*1.1
	var lower = TargetScore*0.9
	if Lower < Score and Score < Upper:
		if lower < Score and Score < upper:
			return roundi(20*ScoreMult)
		return roundi(10*ScoreMult)
	return 0

var BossesDict = {1:"Pythagoras",2:"Aristotle",3:"Euclid",4:"Fibonacci",5:"Sherlock?!",6:"Euler, The Creator",7:"Guass, The Eliminator",8:"Big Albert the Einstien"}
var rivalrooms = [3,15,27,39,50]


func WhatBossAmI(room_no: int) -> int:
	return room_no/6 
	
	
func WhatDaTargetDoing(room_no: int) -> float: #Currently ignores special cases ( POW, bosses and rivals ), Also this will be main point of balance issues
	var rng = RandomNumberGenerator.new()
	var MAINAREASCALE = 2.5 #Balancing
	var SUBAREASCALE = 0.25 #Balancing, maybe not exponent multi for this
	var MainArea = ((room_no-1)/6) + 1
	var SubArea = (room_no-1)%6
	var SEEDMIN = 1
	var SEEDMAX = 100
	var SeedFloorRise = 100*MainArea
	var SeedCeilingRise = 50*MainArea
	return(rng.randi_range(SEEDMIN+SeedFloorRise,SEEDMAX+SeedCeilingRise)*(MAINAREASCALE*MainArea)*(SUBAREASCALE*SubArea))
	
func  PointTotalInrease(TotalPoints: int,GainedPoints: int) -> int
	return TotalPoints+GainedPoints
	
	

	
 
