extends Control

func _ready():
	var playButton = $Button
	playButton.connect("pressed", _on_PlayButton_pressed)
	$Music.play()

func _on_PlayButton_pressed():
	#var gameScene = preload("res://Scenes/MainLevel.tscn")
	$ButtonSound.play()
	OS.delay_msec(171)
	get_tree().change_scene_to_file("res://Scenes/MainLevel.tscn")
	
