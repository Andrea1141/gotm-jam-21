extends Control



func _ready():
	get_tree().paused = true


func _on_Main_Menu_pressed():
	$AudioStreamPlayer.play()
	Game.change_scene("res://scenes/menu/menu.tscn", {
		'show_progress_bar': false
	})
