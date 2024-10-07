extends Control

func _ready():
	$menu/Panel/PanelContainer/VBoxContainer2/Status.visible = false
	$menu/Panel/PanelContainer/VBoxContainer2/PasswordContainer/LineEdit .secret = true
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)

func _on_button_pressed():
	$menu/ButtonClickSound.play()
	var email = $menu/Panel/PanelContainer/VBoxContainer2/UsernameContainer/usernametext
	var password = $menu/Panel/PanelContainer/VBoxContainer2/PasswordContainer/LineEdit 
	var user = email.text
	var passwd = password.text
	Firebase.Auth.login_with_email_and_password(user, passwd)
	pass
	
func on_login_succeeded(auth):
	print(auth)
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("res://World/menu.tscn")
	
func on_login_failed(error_code, message):
	$menu/Panel/PanelContainer/VBoxContainer2/Status.visible = true
	$menu/Panel/PanelContainer/VBoxContainer2/Status.text = message
	print(error_code)
	print(message)

func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://account_create.tscn")
	pass # Replace with function body.
	
func _on_show_password_pressed():
	var password_field = $menu/Panel/PanelContainer/VBoxContainer2/PasswordContainer/LineEdit 
	password_field.secret = not password_field.secret 

func _on_button_2_pressed_sound():
	$menu/ButtonClickSound.play()
	pass

func _on_button_pressed_sound():
	$menu/ButtonClickSound.play()
	pass

func _on_show_pressed_sound():
	$menu/ButtonClickSound.play()
	pass
