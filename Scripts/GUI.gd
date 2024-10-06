extends Control

var gameData : Node
var buttonStats : Dictionary
var buttonLastTime : Dictionary
var buttonTips = {
	"gp_forward" : 
		"Use WASD to control truck", 
	"gp_back" : 
		"Use WASD to control truck", 
	"gp_left" : 
		"Use WASD to control truck", 
	"gp_right" : 
		"Use WASD to control truck", 
	"gp_action" : 
		"Use Shift to honk", 
	"gp_jump" : 
		"Use Space to jump"
}
var tipTime : float
var tipWaiting = 3.0
var currentTime = 0.0

func _ready() -> void:
	gameData = get_node("../GameData")
	tipTime = 0
	for button in buttonTips:
		buttonStats[button] = 0
		buttonLastTime[button] = 0.0

func check_buttons() -> void:
	for button in buttonTips:
		if Input.is_action_just_pressed(button):
			buttonStats[button] += 1
			buttonLastTime[button] = currentTime
	
func _process(delta: float) -> void:
	currentTime += delta
	check_buttons()
	
	$Money.text = "%s$" % gameData.money
	if gameData.potentialMoney != 0 or gameData.hasStarted:
		$PotentialMoney.text = "%s%s$" % ["+" if gameData.potentialMoney >= 0 else "", gameData.potentialMoney]
		$PotentialMoney["theme_override_colors/font_color"] = Color("ffffff") if gameData.potentialMoney >= 0 else Color("f54e4e")
	else:
		$PotentialMoney.text = ""
	
	tipTime += delta
		
	if tipTime > tipWaiting:
		tipTime = 0.0
		if $Tip.text != "":
			$Tip.text = ""
		else:
			for button in buttonTips:
				if (buttonStats[button] == 0 
					or buttonStats[button] <= 3 and (buttonLastTime[button] - currentTime) > 20.0 
					or (buttonLastTime[button] - currentTime) > 60.0):
					$Tip.text = buttonTips[button]
					break
		
