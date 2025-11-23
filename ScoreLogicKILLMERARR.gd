extends Node

"""So here is the idea:
	Player can press button to imput on the calc
	Pressumably they have a cursor to determine where in the equation they type
	So in other words for a button to insert a function i need to somehow need to store each element in a list/array
	Then i can concate the elements in that array into a string and see if that could be executed?
	This approach will work for things like 0-9, +-*/ but the others will be interesting"""
#Apparantly something called Expression exists?
#BUT TRY EXCEPT DOESN'T EXIST KILL ME NOWWW

#Put code for cursor movement

#On ANY (except delete) button press, We will run this and find the specific button
#(the signal will give us which button was pressed) pressed and add it to the index stated
func AddingButtonToPlayerExpression(CurrentExpression: Array,cursor: int,ButtonIndex):
	if cursor > len(CurrentExpression):
		return "Why da cursor so high"
	CurrentExpression.insert(cursor,ButtonIndex)
	return CurrentExpression
		
		

#Special case DELETE one item

#Converting that array to a string, gonna assume we are storing buttons in a dictionary for key + object
#here is a simple dict of the buttons 0-9 and +-*/
var DictForButtonsSimple = {1:"1",2:"2",3:"3",4:"4",5:"4",6:"6",7:"7",8:"8",9:"9",0:"0",10:"+",11:"-",12:"*",13:"/",14:"(",15:")",16:"exp(1)",17:"PI",18:"**2"}
func PlayerArraytoString(PlayerInput: Array,Buttons: Dictionary) -> String: #ISSUE, The string needed to be displayed and for the code are different, 2 different dicts? maybe better as a object
	var ArrayLong = len(PlayerInput)
	var DaCode = ""
	var Block
	for i in range(0,ArrayLong):
		Block = PlayerInput[i]
		Block = Buttons[Block]
		#I do not know if we can store a Button Object in here or just use a string
		#This seg will assume string, we can easily change it or give buttons a string method
		DaCode = DaCode + Block
	return DaCode #this code be optimised so it just adds to an existing string but this works

#Executing the string so we can get a result
func TempScoreCalc(Code: String) -> String:
	var express = Expression.new()
	express.parse(Code)
	var result = express.execute()
	#hmmm the last line always returns null if it fails, That could be the blank state if checked in another function which actually displays the score
	if express.has_execute_failed(): #meaning this line is worthless
		return " You goofy fellow (TempErrorMessage)  " #same here
	return str(result)
# Called when the node enters the scene tree for the first time.
#Guessing the cursor is represented by a index on the text. if it is by mouse we can convert it later
func _ready() -> void:
	var Cursor = 8
	var UserExpressionArr = [1,1,13,4]
	#debug time <3/Example of use
	var ButtonToBeAdded = 1 #If you go back to DictButtonSimple this is the number 1
	UserExpressionArr = AddingButtonToPlayerExpression(UserExpressionArr,Cursor,ButtonToBeAdded)
	var MyString = PlayerArraytoString(UserExpressionArr,DictForButtonsSimple)
	var ThisRoundsScoreGuess = TempScoreCalc(MyString) #When using this if you see null that is a unfinished expression
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


	
