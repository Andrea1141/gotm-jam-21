class_name Enemy
extends KinematicBody2D


export var speed = Vector2(150.0, 100.0)
export var facing_right = false
onready var gravity = ProjectSettings.get("physics/2d/default_gravity")

const FLOOR_NORMAL = Vector2.UP

var velocity = Vector2.ZERO

enum State {
	WALKING,
	DEAD,
}

var _state = State.WALKING
var life_points = 100
var damage = 15

onready var floor_detector = $FloorDetector
onready var roof_detector = $RoofDetector
onready var sprite = $AnimatedSprite
onready var animation_player = $AnimationPlayer


func _ready():
	velocity.y = -speed.y
	$AnimatedSprite.flip_h = facing_right
	randomize()


func _physics_process(delta):
	# If the enemy encounters a wall or an edge, the horizontal velocity is flipped.
	if floor_detector.is_colliding():
		velocity.y = -speed.y
	elif roof_detector.is_colliding():
		velocity.y = speed.y
	
	move_and_slide(velocity)
	
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
	velocity = Vector2.ZERO
	var animation = get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func get_new_animation():
	var animation_new = ""
	if _state == State.WALKING:
		animation_new = "idle"
	else:
		animation_new = "destroy"
	return animation_new


func _on_TalkTimer_timeout():
	var n = randf()
	if n <= .2:
		$Talk.play()

func get_damage():
	life_points = max(life_points - 35, 0)
	get_node("Hit").play()
