extends Node3D

@export var point : Node3D
@export var honk : bool

func _physics_process(delta: float) -> void:
	global_position = point.global_position

func _process(delta: float) -> void:
	honk = Input.is_action_pressed("gp_action")
	if honk:
		$Sound.stream_paused = false
	else:
		$Sound.stream_paused = true

func _ready() -> void:
	$Sound.play()
	$Sound.stream_paused = true
