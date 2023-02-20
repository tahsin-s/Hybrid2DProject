extends AnimatedSprite3D
var thres = 0.3
func physics_process(_delta):
	#get player direction
	var velocity: Vector3 = get_parent().direction
	print(velocity)
	if velocity.is_equal_approx(Vector3.LEFT):
		play("walk")
	if velocity.is_equal_approx(Vector3.RIGHT):
		play("walk")
	else:
		play("idle")
	
	#play appropriate scene.
	
	pass
