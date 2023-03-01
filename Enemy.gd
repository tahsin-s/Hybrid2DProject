extends KinematicBody

export var jump_height =20.0
export var speed = 20.0
export var wait_time = 0.1
export var fall_acceleration = 156

onready var target = $"../Player"
onready var animation = $Animation

var snap = Vector3.DOWN
var velocity = Vector3.ZERO


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	animation.play("idle")
	if target == null:
		velocity = Vector3.LEFT*speed
	
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var displacement = global_translation.direction_to(target.global_translation)
	velocity = velocity.linear_interpolate(displacement*speed,1)
	velocity.y -= fall_acceleration*delta
	move_and_slide_with_snap(velocity,snap)
