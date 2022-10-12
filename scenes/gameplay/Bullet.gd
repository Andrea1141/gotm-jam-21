extends KinematicBody2D

var velocity = Vector2(0, 0)
var speed = 500
var stop = false

func _physics_process(delta):
	if !stop:
		var _collision = move_and_collide(velocity.normalized() * delta * speed)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Area2D_body_entered(body):
	if body is Enemy or body is Alien:
		body.get_damage()
		
	
	$Sprite.visible = false
	stop = true
	$AnimationPlayer.play("explosion")


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
