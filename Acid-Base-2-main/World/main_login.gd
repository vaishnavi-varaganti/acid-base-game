extends Control




func _on_button_pressed():
	if preload("res://Account Create.gd").created:
		var stored_username = preload("res://Account Create.gd").username
		var stored_password = preload("res://Account Create.gd").password
		var status= $menu/Panel/PanelContainer/VBoxContainer2/Status
		
		if $menu/Panel/PanelContainer/VBoxContainer2/usernametext.text == stored_username and $menu/Panel/PanelContainer/VBoxContainer2/Passwordtext.text.sha256_text() == stored_password:
			print("Successful")
			get_tree().change_scene_to_file("res://World/mainmenulogin.tscn")
			$menu/Panel/PanelContainer/VBoxContainer2/usernametext.text = ""
			$menu/Panel/PanelContainer/VBoxContainer2/Passwordtext.text = ""
		else:
			status.text = "Invalid Login"
			print("Invalid username or password")
	#
	pass


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://account_create.tscn")
	pass # Replace with function body.
