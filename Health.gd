extends Control

export var hp = 3

onready var hearts: Array = $Hearts.get_children()
var l: int

func _ready():
	l = len(hearts) - 1
	
func _on_hit(arg):
	print("hit!")
	print(arg)
	if hearts[l] != null:
		hearts[l].queue_free()
		l -= 1
	if l == -1:
		get_tree().change_scene("res://Game Over Screen.tscn")
		queue_free()
