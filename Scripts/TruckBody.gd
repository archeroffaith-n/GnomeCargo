extends RigidBody3D

@export var anchor : RigidBody3D 
@export var targetPosition : Node3D 
@export var attachPosition : Node3D 
@export var trickBody : Node3D

@export_group("Frequency")
@export var linearFrequency : float
@export var linearDamping : float
@export var angularFrequency : float
@export var angularDamping : float
@export var thirdDamping : float
@export var minDistFrac : float
@export var maxDistFrac : float

var targetPositionOriginal : Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(anchor and targetPosition and attachPosition)
	trickBody.rotate_object_local(Vector3(1, 0, 0), deg_to_rad(-90))
	targetPositionOriginal = targetPosition.position
	
func _physics_process(delta: float) -> void:
	var targetLinear = targetPosition.global_position - attachPosition.global_position
	var currentLinear = global_position - attachPosition.global_position
	
	if currentLinear.length() < minDistFrac * targetLinear.length():
		global_position = attachPosition.global_position + currentLinear.normalized() * minDistFrac * targetLinear.length()
		currentLinear = global_position - attachPosition.global_position
		
	if currentLinear.length() > maxDistFrac * targetLinear.length():
		global_position = attachPosition.global_position + currentLinear.normalized() * maxDistFrac * targetLinear.length()
		currentLinear = global_position - attachPosition.global_position
	
	var dx = currentLinear.length() - targetLinear.length()
	var forceLinear = -dx * currentLinear.normalized() / linearFrequency
	
	var dphi = currentLinear.angle_to(targetLinear)
	var angularDirection = currentLinear - targetLinear - (currentLinear - targetLinear).dot(currentLinear.normalized()) * currentLinear
	var forceAngular = -dphi * angularDirection.normalized() / angularFrequency
	
	apply_central_impulse(forceLinear + forceAngular)

	var relativeSpeed = linear_velocity - anchor.linear_velocity
	var dampingForceLinear = -linearDamping * relativeSpeed.dot(currentLinear.normalized()) * currentLinear.normalized()
	var dampingForceAngular = -angularDamping * relativeSpeed.dot(angularDirection.normalized()) * angularDirection.normalized()
	var dampingForceThird = -thirdDamping * relativeSpeed

	apply_central_impulse(dampingForceLinear + dampingForceAngular + dampingForceThird)
	
	transform = transform.interpolate_with(transform.looking_at(transform.origin + currentLinear, anchor.transform.basis.z), 0.5)
