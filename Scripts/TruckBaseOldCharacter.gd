extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var wheels : Array[Node3D]
var shapeCasts : Array[ShapeCast3D]

func get_child_ShapeCast3D(node: Node3D) -> ShapeCast3D:
	for child in node.get_children():
		if child is ShapeCast3D:
			return child
	return null
	
func _ready() -> void:
	assert(len(wheels) == 4)
	for wheel in wheels:
		shapeCasts.append(get_child_ShapeCast3D(wheel))

func _physics_process(delta: float) -> void:
	# Smoothly rotate so, that as much wheels as possible are on the ground
	#var contactPoints
	#if is_on_floor():
		#for shapeCast in shapeCasts:
			#for i in range(shapeCast.get_collision_count()):
				#shapeCast.get_collision_point(i)
		#pass
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("gp_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("gp_left", "gp_right", "gp_forward", "gp_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
