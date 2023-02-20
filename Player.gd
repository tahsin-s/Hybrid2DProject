extends KinematicBody

onready var aniP = $SpriteAnimation
onready var dash_timer = $DashTimer
onready var sword_hitbox = $SpriteAnimation/Sword_HitBox

export var speed = 173
export var fall_acceleration = 156
export var jump_impulse = 40
export var dash_impulse = 48
export var jump_release = float(0.5)
export var min_speed = 0.05
export var frict = 15
export var hangtime = 0.2
export var time_dash = 0.1
export var STEP_UP_HEIGHT = 0.5

var ani_thres = 0.25
var velocity = Vector3.ZERO
var snap = Vector3.DOWN
var dash_ready = false
var direction = Vector3.ZERO
var d_last = Vector3.ZERO
var anim_state = "walking"

## Movement
func dash():
	if dash_ready == false:
		return
	dash_ready = false
	
	velocity = d_last*dash_impulse
	dash_timer.start()
	snap = Vector3.ZERO

func _on_DashTimer_timeout():
	dash_timer.stop()
	dash_timer.set_wait_time(time_dash)

func jump():
	if is_on_floor():
		snap = Vector3.ZERO
		velocity.y += jump_impulse

func crouch():
	if is_on_floor():
		pass
	else:
		velocity = Vector3.ZERO
		velocity.y = -jump_impulse

func fall():
	if velocity.y > 0:
		velocity.y = velocity.y*jump_release

func attack():
	anim("attack")
	velocity += d_last*dash_impulse*0.2
	
func _input(event): #input polling
	#print(moves)
	#jump cases
	if event.is_action_pressed("jump"):
		jump()
	elif event.is_action_released("jump"):
		fall()
	if event.is_action_pressed("crouch"):
		crouch()
	if event.is_action_pressed("dash"):
		dash()
	if event.is_action_pressed("attack"):
		attack()
	

## Stepping functions
func lift(var dir,delta):
	#if the bottom hitbox is shorter than what is being collided with,
	#lift the player the height of the collided
	var step_up = move_and_collide((Vector3.UP) * STEP_UP_HEIGHT+dir, false, true, true)
	var go_forth = move_and_collide(direction, false, true, true)
	if go_forth and not step_up:
		snap = Vector3.ZERO
		velocity += 2*fall_acceleration*Vector3.UP*delta

## Animation
func anim(var s: String):
	match s:
		"walking": 
			anim_walk()
		"jump":
			pass
		"climb":
			pass
		"attack": #initializes attack animation
			anim_state = "attacking" #indicates attacking status
			aniP.play("attack")
			pass
	
func anim_walk():
	if direction.is_equal_approx(Vector3.ZERO):
		aniP.play("idle")
		return
	else:
		aniP.play("walk")
		
	var vNorm: Vector3 = velocity.normalized()
	
	if vNorm.x > ani_thres:
		aniP.flip_h = 0
	elif vNorm.x < -ani_thres:
		aniP.flip_h = 1

func _on_SpriteAnimation_animation_finished():
	match anim_state:
		"attacking":
			anim_state = "walking"
			#also end hitbox time
	

## Main
func _ready():
	dash_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	dash_timer.wait_time = time_dash

func _physics_process(delta):
	# We check for each move input and update the direction accordingly.
	direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	direction.z = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
	
	anim(anim_state)
	
	velocity.y -= fall_acceleration * delta 
	velocity.x += (direction.x * speed - velocity.x  * frict) * delta 
	velocity.z += (direction.z * speed - velocity.z  * frict) * delta 
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	lift(direction,delta)
	
	if is_on_floor(): 
		snap = Vector3.DOWN #return snapping
		dash_ready = dash_timer.is_stopped() #recover dash after timer
	
	elif global_translation.y < -80: #OoB
		get_tree().change_scene("res://Game Over Screen.tscn")
	
	if direction != Vector3.ZERO:
		d_last = direction



