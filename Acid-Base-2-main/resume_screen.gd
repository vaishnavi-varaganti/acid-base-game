extends Control


# Called when the node enters the scene tree for the first time.



func _on_resume_pressed():
	get_tree().change_scene_to_file("res://World/lvl_1.tscn")


func _on_quit_pressed():
	get_tree().quit()
