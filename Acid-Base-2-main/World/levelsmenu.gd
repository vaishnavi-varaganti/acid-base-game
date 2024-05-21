extends CanvasLayer




func _on_level_1_pressed():
	get_tree().change_scene_to_file("res://World/mainlevelmenu.tscn")
	pass # Replace with function body.


func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://World/tutorial.tscn")
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit() # Replace with function body.
