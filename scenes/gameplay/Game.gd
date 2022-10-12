extends Node2D


onready var player = $Player

func pre_start(params):
	var cur_scene: Node = get_tree().current_scene
	print("Current scene is: ", cur_scene.name, " (", cur_scene.filename, ")")
	print("gameplay.gd: pre_start() called with params = ")
	if params:
		for key in params:
			var val = params[key]
			printt("", key, val)
	print("Processing...")
	yield(get_tree().create_timer(2), "timeout")
	print("Done")

func _ready():
	get_tree().paused = true

# `start()` is called when the graphic transition ends.
func start():
	print("gameplay.gd: start() called")
	$AudioStreamPlayer.play()
	var new_dialog = Dialogic.start('Timeline')
	new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	new_dialog.connect("timeline_end", self, "on_timeline_end")
	add_child(new_dialog)
	player.connect("gun_taken", self, "on_gun_taken")
	player.connect("items_found", self, "on_items_found")
	


func on_timeline_end(_timeline_name):
	yield(get_tree().create_timer(.1), "timeout")
	get_tree().paused = false

func on_gun_taken():
	var new_dialog = Dialogic.start('Gun')
	new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	new_dialog.connect("timeline_end", self, "on_timeline_end")
	add_child(new_dialog)
	get_tree().paused = true

func on_items_found():
	var new_dialog = Dialogic.start('Items')
	new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	new_dialog.connect("timeline_end", self, "on_timeline_end")
	add_child(new_dialog)
	get_tree().paused = true


