extends Control

func _ready():
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	


func _on_button_pressed():
	var email = $menu/Panel/PanelContainer/VBoxContainer2/usernametext
	var password = $menu/Panel/PanelContainer/VBoxContainer2/Passwordtext
	var user = email.text
	var passwd = password.text
	Firebase.Auth.login_with_email_and_password(user, passwd)
	pass
	
func on_login_succeeded(auth):
	print(auth)
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("res://World/menu.tscn")
	
	
func on_login_failed(error_code, message):
	print(error_code)
	print(message)


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://account_create.tscn")
	pass # Replace with function body.
