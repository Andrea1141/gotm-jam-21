tool
extends StaticBody2D


var images = ["res://assets/sprites/ACQUA.png", "res://assets/sprites/chiave inglese grande.png", 
			  "res://assets/sprites/fuel.png", "res://assets/sprites/OSSIGENO.png", 
			  "res://assets/sprites/martello grande.png", "res://assets/sprites/FUCILE SPAZIALE.png", 
			  "res://assets/sprites/scatola di proiettili (1).png", "res://assets/sprites/cespuglio.png",
			  "res://assets/sprites/frutto della vita.png", "res://assets/sprites/cose tossiche.png"]

export(int, 0, 9) var index = 0


func _ready():
	$TextureRect.texture = load(images[index])
	if index == 9:
		$Particles2D.visible = true

func explode():
	$Particles2D.emitting = true
	$AudioStreamPlayer.play()
	$Timer.start()
	$TextureRect.visible = false



func _on_Timer_timeout():
	queue_free()
