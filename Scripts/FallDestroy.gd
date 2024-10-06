extends RigidBody3D

var gameData : Node
var destroyed : bool

var falling = false
var direction : Vector3

func _ready() -> void:
	gameData = get_node("/root/MainLevel/GameData")
	gameData.register_damageable(self, destroy)

func destroy() -> bool:
	if destroyed:
		return false
	else:
		falling = true
		destroyed = true
		#axis_lock_angular_x = false
		#axis_lock_angular_y = false
		#axis_lock_angular_z = false
		#apply_central_impulse(Vector3(randf(), 0, randf()).normalized() * 30.0)
		direction = Vector3(randf(), 0, randf()).normalized()
		return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if falling and transform.basis.y.dot(Vector3.UP) > 0:
		transform = transform.rotated(direction, 3.0 * delta * (1 - transform.basis.y.dot(Vector3.UP) + 0.1))
	#if falling and transform.basis.y.dot(Vector3.UP) > 0:
		#axis_lock_angular_x = false
		#axis_lock_angular_y = false
		#axis_lock_angular_z = false
	#else:
		#axis_lock_angular_x = true
		#axis_lock_angular_y = true
		#axis_lock_angular_z = true
