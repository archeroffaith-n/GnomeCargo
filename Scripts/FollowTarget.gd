extends Node3D

@export var maxDistanceFrac : float
@export var constantShift : Vector3
var target : Node3D
var distanceObject : Node3D
var defaultPosition : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = get_node("../TruckBase")
	distanceObject = get_node("Camera3D")
	defaultPosition = distanceObject.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = global_position.lerp(target.global_transform.basis * constantShift + target.global_position, 0.2)
	distanceObject.position = distanceObject.position.lerp(
		defaultPosition * (1 + min(1.0, target.linear_velocity.length() / target.SPEED) * (maxDistanceFrac - 1)), 
		0.03)
