extends Control




func _on_start_game_pressed():
	get_tree().change_scene_to_file("res://World/lvl_3.tscn") # Replace with function body.


func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://World/tutoraillevel_3.tscn")
	pass 


func _on_quit_pressed():
	get_tree().change_scene_to_file("res://World/menu.tscn")
	pass
