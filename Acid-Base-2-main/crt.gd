extends Control

static var username = ""
static var password = ""
static var created = false



func _on_button_pressed():
	if !created:
		username = $Panel/PanelContainer/VBoxContainer2/usernametext.text
		password = $Panel/PanelContainer/VBoxContainer2/Passwordtext.text.sha256_text()
		created = true
		$Panel/PanelContainer/VBoxContainer2/usernametext.text = ""
		$Panel/PanelContainer/VBoxContainer2/Passwordtext.text = ""
		print("Account Created")
		get_tree().change_scene_to_file("res://World/main_login.tscn")
	else:
		print("Success!! login now")
	pass # Replace with function body
	pass
