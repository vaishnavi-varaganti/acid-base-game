extends Control




func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://World/lvl_1.tscn")
	pass # Replace with function body.


func _on_tutorial_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit() # Replace with function body.
