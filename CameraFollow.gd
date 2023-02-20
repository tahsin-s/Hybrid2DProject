extends Position3D


onready var target: Object = get_parent().get_node("Player")
export var smooth_speed: float
export var offset: Vector3


func _physics_process(delta):
	# camera will pan only on the plane that it lies
	# camera will accelerate and decelerate based on distance to the player.
	if (target != null):
		set_translation(lerp(get_translation(),target.get_translation(),smooth_speed*delta))
