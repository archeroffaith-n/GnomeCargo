extends Node3D

@export var point : Node3D

func _physics_process(delta: float) -> void:
	global_position = point.global_position
