extends Position3D


onready var target: Object = get_node("../Player")
export var smooth_speed: float = 10
export var offset: Vector3

var displaced: Vector3 = Vector3.ZERO

func _physics_process(delta):
	#camera will pan only on the plane that it lies
	#camera will accelerate and decelerate based on distance to the player.
	if (target != null):
		displaced = lerp(get_translation(),target.get_translation(),smooth_speed*delta)
		set_translation(displaced)

