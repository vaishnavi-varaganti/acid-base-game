extends CanvasLayer

func _ready():
	if Global.current_level == 1:
		$Panel/PanelContainer/VBoxContainer/Level1.disabled = false
		$Panel/PanelContainer/VBoxContainer/Level2.disabled = true
		$Panel/PanelContainer/VBoxContainer/Level3.disabled = true
		$Panel/PanelContainer/VBoxContainer/Level4.disabled = true
	elif Global.level1Cleared == true:
		$Panel/PanelContainer/VBoxContainer/Level1.disabled = false
		$Panel/PanelContainer/VBoxContainer/Level2.disabled = false
		$Panel/PanelContainer/VBoxContainer/Level3.disabled = true
		$Panel/PanelContainer/VBoxContainer/Level4.disabled = true
	elif Global.level2Cleared == true:
		$Panel/PanelContainer/VBoxContainer/Level1.disabled = false
		$Panel/PanelContainer/VBoxContainer/Level2.disabled = false
		$Panel/PanelContainer/VBoxContainer/Level3.disabled = false
		$Panel/PanelContainer/VBoxContainer/Level4.disabled = true
	elif Global.level3Cleared == true:
		$Panel/PanelContainer/VBoxContainer/Level1.disabled = false
		$Panel/PanelContainer/VBoxContainer/Level2.disabled = false
		$Panel/PanelContainer/VBoxContainer/Level3.disabled = false
		$Panel/PanelContainer/VBoxContainer/Level4.disabled = false
	
func _on_level_1_pressed():
	Global.current_level = 1
	get_tree().change_scene_to_file("res://World/mainlevelmenu.tscn")
	print("Current Level: ", Global.current_level)
	pass # Replace with function body.
	
func _on_level_2_pressed():
	Global.current_level = 2
	get_tree().change_scene_to_file("res://World/level2menu.tscn")
	print("Current Level: ", Global.current_level)
	pass # Replace with function body.
	
func _on_level_3_pressed():
	Global.current_level = 3
	get_tree().change_scene_to_file("res://World/level3menu.tscn")
	print("Current Level: ", Global.current_level)
	pass # Replace with function body.
	
func _on_level_4_pressed():
	Global.current_level = 4
	get_tree().change_scene_to_file("res://World/level4menu.tscn")
	print("Current Level: ", Global.current_level)
	pass # Replace with function body.

func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://World/tutorial.tscn")
	pass # Replace with function body.

func _on_exit_pressed():
	get_tree().quit() # Replace with function body.
