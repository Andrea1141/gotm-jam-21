extends KinematicBody2D

export (int) var speed = 120
export (int) var jump_speed = -180
export (int) var gravity = 400
export (float, 0, 1.0) var friction = 0.1
export (float, 0, 1.0) var acceleration = 0.25

var velocity = Vector2.ZERO
var mouse_pos

var bullet_scene = preload("res://scenes/gameplay/Bullet.tscn")

onready var game = get_parent()
onready var gun = $Gun
onready var gun_position2D = $Gun/Position2D

func get_input():
	var dir = 0
	if Input.is_action_pressed("ui_right"):
		dir += 1
	if Input.is_action_pressed("ui_left"):
		dir -= 1
	if dir != 0:
		velocity.x = lerp(velocity.x, dir * speed, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)
	
	if Input.is_action_just_pressed("ui_accept"):
		shoot()

func _physics_process(delta):
	get_input()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump_speed
	
	mouse_pos = Vector2(clamp(get_global_mouse_position()[0], gun.global_position[0], get_global_mouse_position()[0]), get_global_mouse_position()[1])
	gun.look_at(mouse_pos)

func shoot(): 
	var bullet = bullet_scene.instance()
	bullet.global_position = gun_position2D.global_position
	bullet.global_rotation = gun.global_rotation
	bullet.velocity = mouse_pos - gun_position2D.global_position
	game.add_child(bullet)
