extends KinematicBody2D

var velocity = Vector2(0, 0)
var speed = 300

func _physics_process(delta):
	var collision = move_and_collide(velocity.normalized() * delta * speed)


func _on_VisibilityNotifier2D_screen_exited():
	pass
	queue_free()


func _on_Area2D_body_entered(body):
	body.queue_free()
	queue_free()
