extends Control

func _ready():
	$Respawn.grab_focus()

func _on_Respawn_pressed():
	var err = get_tree().change_scene("res://DemoArea.tscn")
	
	if err:
		print("Button failure")

func _on_Quit_pressed():
	get_tree().quit()
