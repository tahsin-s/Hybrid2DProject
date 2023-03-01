extends KinematicBody

onready var aniP = $SpriteAnimation
onready var dash_timer = $DashTimer
onready var sword_hitbox = $SpriteAnimation/SwordHitbox

export var accel = 173
export var fall_acceleration = 156
export var jump_impulse = 40
export var dash_impulse = 48
export var jump_release = float(0.5)
export var min_speed = 0.05
export var frict = 15
export var hangtime = 0.2
export var time_dash = 0.1
export var STEP_UP_HEIGHT: float = 1

var hp: int = 3
var ani_thres = 0.5
var velocity = Vector3.ZERO
var snap = Vector3.DOWN
var dash_ready = false
var direction = Vector3.ZERO
var d_last = Vector3.ZERO
var anim_state = "walking"

onready var max_speed: float = accel/frict

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
	anim_state = "attack"
	velocity += d_last*dash_impulse*0.2

func take_damage():
	var hearts = $Hearts.get_children()
	var l = len(hearts)
	if l > 0:
		hearts[l-1].queue_free()
	if len(hearts) == 0:
		get_tree().change_scene("res://Game Over Screen.tscn")

func step(delta):
	var pos: Transform = get_transform()
	#predict translation 1 frame ahead of step
	var approach = 2*max_speed*direction*delta 
	
	var forth = test_move(pos,approach)
	pos[3].y += STEP_UP_HEIGHT
	var step_up = test_move(pos,approach)

	#binary search for what approximate height to move to
	if forth and not step_up:
		pos[3].y -= STEP_UP_HEIGHT*0.5
		step_up = test_move(pos,approach)
		pos[3].y += STEP_UP_HEIGHT*(int(step_up)*0.5 - 0.25)
		step_up = test_move(pos,approach)
		pos[3].y += STEP_UP_HEIGHT*(int(step_up)*0.25 - 0.125)
		step_up = test_move(pos,approach)
		pos[3].y += STEP_UP_HEIGHT*(int(step_up)*0.125 - 0.0625)
		set_transform(pos)
		velocity = max_speed*direction*1.5

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
		
	if direction.x > 0:
			#aniP.flip_h = 0
			rotation_degrees.y = 0
	elif direction.x < 0:
			rotation_degrees.y = 180
			#aniP.flip_h = 1

func _on_SpriteAnimation_animation_finished():
	match anim_state:
		"attacking":
			anim_state = "walking"
			#also end hitbox time

## Main
func _ready():
	#animation initialization
	anim(anim_state)
	#dash
	dash_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	dash_timer.wait_time = time_dash
	
	#health
	var hearts = $Hearts
	for i in range(hp):
		hearts.add_child(load("res://Heart.tscn").instance())
		var heart = hearts.get_child(i)
		
		heart.position.x = (1+i)*40
		heart.position.y = (50)

func _physics_process(delta):
	# We check for each move input and update the direction accordingly.
	
	# Note: Seems to take the same time for using the direct method and 
	# the vector3 method
	direction = Vector3(
		+ int(Input.is_action_pressed("move_right")) 
		- int(Input.is_action_pressed("move_left")),
		0,
		+ int(Input.is_action_pressed("move_down")) 
		- int(Input.is_action_pressed("move_up"))
	)
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		d_last = direction
		step(delta)
	
	anim(anim_state)
	
	velocity += Vector3(
		+ direction.x * accel - velocity.x  * frict,
		- fall_acceleration,
		+ direction.z * accel - velocity.z  * frict
	) * delta
	
	velocity = move_and_slide(velocity, Vector3.UP)
	print(velocity.length())
	
	if is_on_floor(): 
		snap = Vector3.DOWN #return snapping
		dash_ready = dash_timer.is_stopped() #recover dash after timer
	
	if global_translation.y < -80: #OoB
		var err = get_tree().change_scene("res://Game Over Screen.tscn")
		
		if err: 
			print("what")
