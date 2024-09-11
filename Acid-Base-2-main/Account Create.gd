extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	Firebase.Auth.signup_failed.connect(on_signup_failed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func on_signup_succeeded(auth):
	print(auth)
	$menu/Panel/PanelContainer/VBoxContainer2/status.text = "Sign up success!"
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("res://Game.tscn")

	
func on_signup_failed(error_code, message):
	print(error_code)
	print(message)
	$menu/Panel/PanelContainer/VBoxContainer2/status.text = "Sign up failed. Error: %s" % message

func _on_button_pressed():
	var email = $menu/Panel/PanelContainer/VBoxContainer2/usernametext
	var password = $menu/Panel/PanelContainer/VBoxContainer2/Passwordtext
	var user = email.text
	var passwd = password.text
	

	Firebase.Auth.signup_with_email_and_password(user, passwd)
	$menu/Panel/PanelContainer/VBoxContainer2/status.text = "Singing up"
	get_tree().change_scene_to_file("res://World/main_login.tscn")
	pass # Replace with function body.
