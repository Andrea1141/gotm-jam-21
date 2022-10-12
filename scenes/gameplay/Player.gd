extends KinematicBody2D

export (int) var speed = 200
export (int) var jump_speed = -250
export (int) var gravity = 200
export (float, 0, 1.0) var friction = 0.1
export (float, 0, 1.0) var acceleration = 0.25

var velocity = Vector2.ZERO
var mouse_pos
var items = ["Water", "Wrench", "Fuel", "Oxygen", "Hammer"]
var has_gun = false
var life_points = 100
var bullets = 6
var items_found = 0

var bullet_scene = preload("res://scenes/gameplay/Bullet.tscn")

onready var game = get_parent()
onready var sprite = $AnimatedSprite
onready var gun = $Gun
onready var gun_position2D = $Gun/Position2D

signal gun_taken
signal items_found

func _ready():
	$UI/TextureProgress.value = 100

func get_input():
	var dir = 0
	
	if Input.is_action_pressed("ui_right"):
		dir += 1
		sprite.flip_h = false
		gun.offset = Vector2(410, 5)
		gun.position = Vector2(25, 1)
		gun.flip_h = false
		gun_position2D.position = Vector2(910, -110)
	if Input.is_action_pressed("ui_left"):
		dir -= 1
		sprite.flip_h = true
		gun.offset = Vector2(-410, 5)
		gun.position = Vector2(-25, 1)
		gun.flip_h = true
		gun_position2D.position = Vector2(-910, -110)
	
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
		sprite.animation = "run"
	else:
		velocity.x = lerp(velocity.x, 0, friction)
		sprite.animation = "stand"
	
	if !is_on_floor():
		sprite.animation = "jump"
	
	if Input.is_action_just_pressed("ui_accept") and has_gun and bullets > 0 and ((!sprite.flip_h and get_global_mouse_position()[0] > gun.global_position[0]) or (sprite.flip_h and get_global_mouse_position()[0] < gun.global_position[0])):
		shoot()
		$AudioStreamPlayer.play()
		get_node("UI/Bullets/Bullet" + str(bullets)).visible = false
		bullets -= 1
	
	$UI/RichTextLabel.bbcode_text = "TIME        :     " + str(round($Timer.time_left)) + " s"

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_speed
			sprite.animation = "jump"
			$Jump.play(0.15)
	if !sprite.flip_h: #if the player is going right
		mouse_pos = Vector2(clamp(get_global_mouse_position()[0], gun.global_position[0], get_global_mouse_position()[0]), get_global_mouse_position()[1])
		gun.rotation_degrees = rad2deg(get_angle_to(mouse_pos))
	else:
		mouse_pos = Vector2(clamp(get_global_mouse_position()[0], get_global_mouse_position()[0], gun.global_position[0]), get_global_mouse_position()[1])
		gun.rotation_degrees = rad2deg(get_angle_to(mouse_pos)) - 180
	

func shoot(): 
	var bullet = bullet_scene.instance()
	bullet.global_position = gun_position2D.global_position
	bullet.global_rotation = gun.global_rotation
	bullet.velocity = mouse_pos - gun_position2D.global_position
	game.add_child(bullet)


func _on_Area2D_body_entered(body):
	if body is Enemy or body is Alien:
		life_points = max(life_points - body.damage, 0)
		$UI/TextureProgress.value = life_points
		$InvulnerabilityTimer.start()
		$Hurt.play()
		
		if life_points <= 0:
			get_tree().paused = true
			$UI/GameOver.visible = true
	
	elif body.is_in_group("Navicella"):
		if items_found == 5:
			get_tree().paused = true
			$UI/Win.visible = true
	
	else:
		if body.index == 5: #gun
			gun.visible = true
			has_gun = true
			$UI/Bullets.visible = true
			emit_signal("gun_taken")
			$Pickup.play()
			body.queue_free()
		
		elif body.index == 6: #bullets
			bullets = min(bullets + 2, 6)
			get_node("UI/Bullets/Bullet" + str(bullets-1)).visible = true
			get_node("UI/Bullets/Bullet" + str(bullets)).visible = true
			$Pickup.play()
			body.queue_free()
		
		elif body.index == 7:
			life_points = min(life_points + 25, 100)
			$UI/TextureProgress.value = life_points
			$Pickup.play()
			body.queue_free()
		
		elif body.index == 8:
			life_points = min(life_points + 10, 100)
			$UI/TextureProgress.value = life_points
			$Pickup.play()
			body.queue_free()
		
		elif body.index == 9:
			body.explode()
			life_points = max(life_points - 35, 0)
			$UI/TextureProgress.value = life_points
			$Hurt.play()
			
			if life_points <= 0:
				get_tree().paused = true
				$UI/GameOver.visible = true
		
		else: #item
			get_node("UI/Items/" + items[body.index]).visible = true
			items_found += 1
			if items_found == 5:
				$UI/Items.visible = false
				$UI/RichTextLabel.visible = true
				emit_signal("items_found")
				$Timer.start()
			$Pickup.play()
			body.queue_free()
		
		



func _on_Timer_timeout():
	get_tree().paused = true
	$UI/GameOver.visible = true


func _on_InvulnerabilityTimer_timeout():
	if $Area2D.get_overlapping_bodies() != null:
		for body in $Area2D.get_overlapping_bodies():
			if body is Enemy or body is Alien:
				life_points -= body.damage
				$UI/TextureProgress.value = life_points
				$InvulnerabilityTimer.start()
				$Hurt.play()
				
				if life_points <= 0:
					get_tree().paused = true
					$UI/GameOver.visible = true
