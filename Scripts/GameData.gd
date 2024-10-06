extends Node

@export var truckCatch : Node3D
var playerColliders : Array[Node]
var arrow : Node3D
var arrowHidden = false

var start : Node3D
var finish : Node3D
var startPositions : Array[Node]
var finishPositions : Array[Node]
var selectedStart : Node3D
var selectedFinish : Node3D

@export var money: int
@export var potentialMoney : int
@export var hasStarted : bool
@export var startCreated : bool
var hideValue = Vector3(0, -1000, 0)

var lastPotentialMoney : int
var timeTillMoneyChanged : float

var timeInState : float
var timeToWait : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	truckCatch = get_node("../Truck/CatchArea")
	arrow = get_node("../Truck/TruckBase/Arrow")
	playerColliders = get_node("../Truck").get_children(true)
	finish = $Finish
	start = $Start
	
	startPositions = $StartPositions.get_children()
	finishPositions = $FinishPositions.get_children()
	
	money = 0
	potentialMoney = 0
	lastPotentialMoney = 0
	timeTillMoneyChanged = 0.0
	hasStarted = false
	startCreated = false
	timeInState = 0
	timeToWait = 0
	hide_finish()
	hide_start()
	hide_arrow()
	
func finished() -> bool:
	return finish.get_node("Area3D").overlaps_area(truckCatch)
	
func started() -> bool:
	return start.get_node("Area3D").overlaps_area(truckCatch)
	
func draw_potential_money() -> int:
	return randi_range(10, 101)
	
func transfer_money() -> void:
	if potentialMoney != 0:
		$MoneySound.play()
		money += potentialMoney
		potentialMoney = 0
	
func draw_time_to_start() -> float:
	return randf_range(3.0, 10.0)
	
func create_start() -> void:
	var startPosition = startPositions[randi() % startPositions.size()]
	while startPosition == selectedStart:
		startPosition = startPositions[randi() % startPositions.size()]
	selectedStart = startPosition
	start.transform = selectedStart.transform
	
func hide_start() -> void:
	start.position += hideValue
	
func create_finish() -> void:
	var finishPosition = finishPositions[randi() % finishPositions.size()]
	while finishPosition == selectedFinish and (selectedStart.global_position - finishPosition.global_position).length() < 40.0:
		finishPosition = finishPositions[randi() % finishPositions.size()]
	selectedFinish = finishPosition
	finish.transform = selectedFinish.transform
	
func hide_finish() -> void:
	finish.position += hideValue
	
func register_damageable(body: RigidBody3D, destroy_call: Callable) -> void:
	body.contact_monitor = true
	body.max_contacts_reported = 20
	var local_callback = func (collisionBody):
		if not is_instance_valid(body):
			return
		_damage_callback(body, collisionBody, destroy_call)
		
	body.body_entered.connect(local_callback)
	
func _damage_callback(body: RigidBody3D, collisionBody: Node, destroy_call: Callable) -> void:
	if collisionBody in playerColliders:
		if collisionBody.linear_velocity.length() > 4.0:
			if destroy_call.call():
				potentialMoney -= randi_range(5, 16)
				$HardHit.play()
		else:
			$SoftHit.play()

func hide_arrow() -> void:
	if not arrowHidden:
		arrowHidden = true
		arrow.position += hideValue
		
func show_arrow() -> void:
	if arrowHidden:
		arrowHidden = false
		arrow.position -= hideValue
		
func update_arrow_to_target(target: Node3D) -> void:
	show_arrow()
	arrow.global_transform = arrow.global_transform.looking_at(target.position, Vector3.UP)

func _process(delta: float) -> void:
	timeInState += delta
	timeTillMoneyChanged += delta
	
	if not startCreated and timeInState >= timeToWait:
		create_start()
		startCreated = true
	
	if not hasStarted and potentialMoney != 0:
		if lastPotentialMoney != potentialMoney:
			lastPotentialMoney = potentialMoney
			timeTillMoneyChanged = 0.0
		elif timeTillMoneyChanged > 2.0:
			transfer_money()

	if started() and not hasStarted:
		transfer_money()
		hasStarted = true
		hide_start()
		create_finish()
		potentialMoney = draw_potential_money()
		
	if finished() and hasStarted:
		hasStarted = false
		startCreated = false
		hide_finish()
		transfer_money()
		timeInState = 0
		timeToWait = draw_time_to_start()
		
	if startCreated and not hasStarted:
		update_arrow_to_target(start)
	elif hasStarted:
		update_arrow_to_target(finish)
	else:
		hide_arrow()
	
