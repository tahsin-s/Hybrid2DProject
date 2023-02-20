extends Area

const step_height = 1

onready var p = get_parent()

var d: float = 0


func closest_shape(hit: Array):
	var shape: CollisionShape
	for i in hit:
		var shapes = i.get_children()
		var dist = 100
		for s in shapes:
		#find closest shape
			if s.get_class() != 'CollisionShape':
				continue
			var d = s.global_translation
			if (global_translation).distance_to(d) < dist:
				shape = s
				dist = (global_translation).distance_to(d)
	return shape

func find_height(s):
		if s.get_class() == 'BoxShape':
			return s.get_extents().y
		if s.get_class() == 'CylinderShape':
			return s.get_height()

func _physics_process(delta):
	var hit = get_overlapping_bodies()
	var shape = closest_shape(hit)
	
	if shape!=null:
		d = find_height(shape.get_shape())
		d = d + shape.global_translation.y - global_translation.y
		
		if d <= step_height and d > 0:
			p.lift(d)
		
		
	

		
			
		
	

		
	#find the collision shape of the nearest platform
	#find the relative height difference
	#lift if height is reasonable
