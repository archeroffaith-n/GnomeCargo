extends RigidBody3D


@export var SPEED = 10.0
@export var JUMP_VELOCITY = 4.5
@export var TURN_SPEED = 0.03
@export var ACCELERATION = 0.5
@export var DECELERATION = 0.5

@export var shapeCasts : Array[ShapeCast3D]
@export var maxDistanceToFloor : float
@export var criticalSlope: float

@export var frontWheels : Array[Node3D]

var is_on_floor : bool
var contactPointNormals : Array[Vector3]
var floorNormal : Vector3

var minVolume = -10.5
var maxVolume = -5.5

func get_child_ShapeCast3D(node: Node3D) -> ShapeCast3D:
	for child in node.get_children():
		if child is ShapeCast3D:
			return child
	return null
	
func _ready() -> void:
	assert(len(shapeCasts) == 4)
	assert(len(frontWheels) > 0)
	$EngineSound.play()
	$EngineSound.volume_db = minVolume

func recalc_floor() -> void:
	contactPointNormals = []
	for shapeCast in shapeCasts:
		var lowestContactNormal = null
		var lowestContactPoint = null
		for i in range(shapeCast.get_collision_count()):
			var point = shapeCast.get_collision_point(i)
			#and (shapeCast.global_position - point).length() < maxDistanceToFloor
			if (shapeCast.global_position - point).y > cos(deg_to_rad(criticalSlope)) * maxDistanceToFloor:
				#print(shapeCast.get_collider(i).name, ' ', shapeCast.get_collider(i).get_parent().name)
				if !lowestContactNormal or lowestContactPoint.y < point.y:
					lowestContactNormal = shapeCast.get_collision_normal(i)
					lowestContactPoint = point
		if lowestContactNormal:
			contactPointNormals.append(lowestContactNormal)
		
	if len(contactPointNormals) >= 2:
		is_on_floor = true
	else:
		is_on_floor = false
		
	floorNormal = Vector3.UP
	if is_on_floor:
		var meanNormal = Vector3.ZERO
		for normal in contactPointNormals:
			meanNormal += normal / len(contactPointNormals)
		meanNormal = meanNormal.normalized()
		floorNormal = meanNormal

func _physics_process(delta: float) -> void:
	recalc_floor()

	# Get the input direction
	var input_dir := Input.get_vector("gp_left", "gp_right", "gp_forward", "gp_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# Update direction
	if direction:
		var old_transform = global_transform
		global_transform = global_transform.interpolate_with(global_transform.looking_at(global_position + direction, global_transform.basis.y), TURN_SPEED)
		
		#for wheel in frontWheels:
			#wheel.transform = wheel.transform.looking_at(-(global_transform.basis.z - old_transform.basis.z) + wheel.position, wheel.transform.basis.y)
	#else:
		#for wheel in frontWheels:
			#wheel.transform = wheel.transform.looking_at(wheel.position + wheel.transform.basis.z, wheel.transform.basis.y)
	
	# Handle the speed/deceleration
	var floor_velocity = linear_velocity - linear_velocity.dot(floorNormal) * floorNormal
	if is_on_floor:
		if direction.length() > 0:
			var target_velocity = linear_velocity - floor_velocity - global_transform.basis.z * SPEED
			linear_velocity.x = move_toward(linear_velocity.x, target_velocity.x, ACCELERATION)
			linear_velocity.y = move_toward(linear_velocity.y, target_velocity.y, ACCELERATION)
			linear_velocity.z = move_toward(linear_velocity.z, target_velocity.z, ACCELERATION)
			$EngineSound.volume_db = lerp($EngineSound.volume_db, maxVolume, ACCELERATION)
				
			#var ground_z = transform.basis.z - transform.basis.z.dot(floorNormal) * floorNormal
			#if abs(linear_velocity.dot(ground_z)) < SPEED:
				#linear_velocity = linear_velocity + (sign(input_dir.y) * SPEED - linear_velocity.dot(ground_z)) * ground_z
		else:
			if floor_velocity.length() > 0:
				var target_velocity = linear_velocity - floor_velocity
				linear_velocity.x = move_toward(linear_velocity.x, target_velocity.x, DECELERATION)
				linear_velocity.z = move_toward(linear_velocity.y, target_velocity.y, DECELERATION)
				linear_velocity.z = move_toward(linear_velocity.z, target_velocity.z, DECELERATION)
				$EngineSound.volume_db = lerp($EngineSound.volume_db, minVolume, ACCELERATION)
	
	if direction.length() > 0:
		$EngineSound.volume_db = lerp($EngineSound.volume_db, maxVolume, ACCELERATION)
	else:
		$EngineSound.volume_db = lerp($EngineSound.volume_db, minVolume, ACCELERATION)
				
	# Handle jump.
	if Input.is_action_just_pressed("gp_jump") and is_on_floor:
		linear_velocity += floorNormal * JUMP_VELOCITY
