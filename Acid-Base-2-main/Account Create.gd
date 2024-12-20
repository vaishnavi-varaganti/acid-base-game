extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$menu/Panel/PanelContainer/VBoxContainer2/status.visible = false
	$menu/Panel/PanelContainer/VBoxContainer2/PasswordContainer/LineEdit.secret = true
	Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	Firebase.Auth.signup_failed.connect(on_signup_failed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_signup_succeeded(auth):
	print(auth)
	$menu/Panel/PanelContainer/VBoxContainer2/status.visible = true
	$menu/Panel/PanelContainer/VBoxContainer2/status.text = "Sign up success!"
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("res://Game.tscn")
	
func on_signup_failed(error_code, message):
	print(error_code)
	print(message)
	$menu/Panel/PanelContainer/VBoxContainer2/status.visible = true
	$menu/Panel/PanelContainer/VBoxContainer2/status.text = "Sign up failed. Error: %s" % message

func _on_button_pressed():
	$menu/ButtonClickSound.play()
	$menu/Panel/PanelContainer/VBoxContainer2/status.visible = false
	var email = $menu/Panel/PanelContainer/VBoxContainer2/UsernameContainer/usernametext
	var password = $menu/Panel/PanelContainer/VBoxContainer2/PasswordContainer/LineEdit
	var user = email.text
	var passwd = password.text

	Firebase.Auth.signup_with_email_and_password(user, passwd)
	$menu/Panel/PanelContainer/VBoxContainer2/status.visible = true
	$menu/Panel/PanelContainer/VBoxContainer2/status.text = "Singing up"
	get_tree().change_scene_to_file("res://World/main_login.tscn")
	pass # Replace with function body.
	
func _on_cancel_button_pressed():
	$menu/ButtonClickSound.play()
	get_tree().change_scene_to_file("res://World/main_login.tscn")
	pass

func _on_show_password_pressed():
	var password_field = $menu/Panel/PanelContainer/VBoxContainer2/PasswordContainer/LineEdit 
	password_field.secret = not password_field.secret 
	
func _on_button_pressed_sound():
	$menu/ButtonClickSound.play()
	pass
	
func _on_button_2_pressed_sound():
	$menu/ButtonClickSound.play()
	pass

func _on_show_pressed_sound():
	$menu/ButtonClickSound.play()
	pass
