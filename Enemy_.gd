extends KinematicBody

export var jump_height =20.0
export var speed = 80.0
export var wait_time = 0.1
export var fall_acceleration = 159

onready var target = $"../Player"
onready var animation = $Animation

var displacement = Vector3.LEFT
var snap = Vector3.DOWN
var velocity = Vector3.ZERO

func _ready():
	animation.play("idle")
	if target == null:
		velocity = Vector3.LEFT*speed

func _physics_process(delta):	
	if target != null:
		displacement = (
			(global_translation*Vector3(1,0,1)).direction_to(
			target.global_translation*Vector3(1,0,1))
		)
	
	
	velocity = Vector3(
		displacement.x*speed,
		velocity.y - fall_acceleration*delta,
		displacement.z*speed
	)

	velocity = move_and_slide(velocity,Vector3.UP)
