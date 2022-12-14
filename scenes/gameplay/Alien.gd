class_name Alien
extends KinematicBody2D


export var speed = Vector2(75.0, 350.0)
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_NORMAL = Vector2.UP

var _velocity = Vector2.ZERO

enum State {
	WALKING,
	DEAD,
}

var _state = State.WALKING
var life_points = 100
var damage = 15

onready var platform_detector = $PlatformDetector
onready var floor_detector_left = $FloorDetectorLeft
onready var floor_detector_right = $FloorDetectorRight
onready var sprite = $AnimatedSprite
onready var animation_player = $AnimationPlayer

func _ready():
	_velocity.x = -speed.x
	randomize()


func _physics_process(delta):
	_velocity.y += gravity * delta
	# If the enemy encounters a wall or an edge, the horizontal velocity is flipped.
	if not floor_detector_left.is_colliding():
		_velocity.x = speed.x
	elif not floor_detector_right.is_colliding():
		_velocity.x = -speed.x

	if is_on_wall():
		_velocity.x *= -1

	# We only update the y value of _velocity as we want to handle the horizontal movement ourselves.
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y

	# We flip the Sprite depending on which way the enemy is moving.
	if _velocity.x > 0:
		sprite.scale.x = -.02
	elif _velocity.x == 0:
		pass
	else:
		sprite.scale.x = .02

	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)
	
	if life_points <= 0: 
		destroy()
		$TextureProgress.value = 0
	else:
		$TextureProgress.value = life_points


func destroy():
	_state = State.DEAD
	_velocity = Vector2.ZERO
	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func get_new_animation():
	var animation_new = ""
	if _state == State.WALKING:
		if _velocity.x == 0:
			animation_new = "idle"
		else:
			animation_new = "walk"
	else:
		animation_new = "destroy"
	return animation_new

func get_damage():
	life_points = max(life_points - 50, 0)
	get_node("Hit").play()
