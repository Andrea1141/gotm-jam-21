extends Node2D

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
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
	var new_dialog = Dialogic.start('Timeline')
	new_dialog.pause_mode = Node.PAUSE_MODE_PROCESS
	new_dialog.connect("timeline_end", self, "on_timeline_end")
	add_child(new_dialog)


func on_timeline_end(timeline_name):
	get_tree().paused = false


