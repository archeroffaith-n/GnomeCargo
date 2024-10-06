extends RigidBody3D


const SPEED = 5.0
const JUMP_FORCE = 45
const TURN_SPEED = 0.07

@export var shapeCast : ShapeCast3D
@export var maxDistanceToFloor : float
@export var criticalSlope: float

enum STATES {IDLE, IN_FLIGHT, WAITING_TILL_NEXT_JUMP, HEAR_HONK}
var state : int
var timerInState : float
var timeForCurrentState : float

var direction : Vector3
var gameData : Node
var honkArea : Area3D

var hurt : bool
var timeTillHurt : float

func _ready() -> void:
	update_state(choose_wait_state())
	gameData = get_node("/root/MainLevel/GameData")
	honkArea = gameData.get_node("../Truck/HonkArea")
	direction = draw_random_direction()
	gameData.register_damageable(self, hurt_with_timeout)
	
func hurt_with_timeout() -> bool:
	if hurt and timeTillHurt < 4.0:
		return false
	else:
		#$HardHit.play()
		hurt = true
		timeTillHurt = 0.0
		return true

func is_on_floor() -> bool:
	for i in range(shapeCast.get_collision_count()):
		var point = shapeCast.get_collision_point(i)
		if (shapeCast.global_position - point).y > cos(deg_to_rad(criticalSlope)) * maxDistanceToFloor:
			return true
	return false
	
func draw_time_in_state() -> float:
	if state == STATES.IDLE:
		return randf_range(10.0, 15.0)
	elif state == STATES.WAITING_TILL_NEXT_JUMP:
		return randf_range(1.0, 3.0)
	elif state == STATES.IN_FLIGHT:
		return 0.1
	return 10000000.0
	
func draw_random_direction() -> Vector3:
	var phi = deg_to_rad(randf_range(0.0, 360.0))
	return Vector3(cos(phi), 0, sin(phi)).normalized()
	
func update_state(state : int) -> void:
	self.state = state
	timerInState = 0.0
	timeForCurrentState = draw_time_in_state()
	
func choose_wait_state() -> int:
	var random_float = randf()
	if random_float < 0.8:
		return STATES.WAITING_TILL_NEXT_JUMP
	else:
		return STATES.IDLE
	
func _physics_process(delta: float) -> void:
	timerInState += delta
	if hurt:
		timeTillHurt += delta
	
	if timerInState > timeForCurrentState and state == STATES.IN_FLIGHT and is_on_floor():
		if honkArea.overlaps_body(self) and honkArea.honk:
			update_state(STATES.HEAR_HONK)
		else:
			update_state(choose_wait_state())
	elif state != STATES.IN_FLIGHT:
		if honkArea.overlaps_body(self) and honkArea.honk:
			update_state(STATES.HEAR_HONK)
	
	
	if timerInState > timeForCurrentState and (state == STATES.IDLE or state == STATES.WAITING_TILL_NEXT_JUMP) or state == STATES.HEAR_HONK:
		if not is_on_floor():
			return
		if state == STATES.HEAR_HONK:
			direction = global_position - honkArea.global_position
			direction.y = 0
			direction = direction.normalized()
		else:
			direction = draw_random_direction()
		apply_impulse((Vector3.UP + direction * 0.5) * JUMP_FORCE, Vector3(0, 0, 0))
		update_state(STATES.IN_FLIGHT)
		$Jump.play()
			
	transform = transform.interpolate_with(transform.looking_at(position - direction, transform.basis.y), TURN_SPEED)
