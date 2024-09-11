extends Control

static var username = ""
static var password = ""
static var created = false


#
#func _on_button_pressed():
	#if !created:
		#username = $menu/Panel/PanelContainer/VBoxContainer2/usernametext.text
		#password = $menu/Panel/PanelContainer/VBoxContainer2/Passwordtext.text.sha256_text()
		#created = true
		#$menu/Panel/PanelContainer/VBoxContainer2/usernametext.text = ""
		#$menu/Panel/PanelContainer/VBoxContainer2/usernametext.text=""
		#print("Account Created")
	#else:
		#print("..............")
		#
		#
		#
	#get_tree().change_scene_to_file("res://World/main_login.tscn")
	#pass # Replace with function body.


func _on_button_pressed():
	var usernameTF = $menu/Panel/PanelContainer/VBoxContainer2/usernametext
	var passwordTF = $menu/Panel/PanelContainer/VBoxContainer2/Passwordtext
	var status = $menu/Panel/PanelContainer/VBoxContainer2/status
	 
	
	var user = usernameTF.text
	var passwd = passwordTF.text
	
	if user == "" or passwd == "":
		status.text = "must not be empty"
		print("/....")
		return
		
	if !is_valid_password(passwd):
		status.text = "Invalid Password"
		print("....................")
		return
	if !created:
		username = user
		password = passwd.sha256_text()
		created = true
		status.text= "Account created"
		usernameTF.text = ""
		passwordTF.text = ""
		print("Account Created")
	else:
		status.text= "account not created"
		print("2........")
	get_tree().change_scene_to_file("res://World/main_login.tscn")
	pass 

func is_valid_password(password: String) -> bool:
	var has_upper = false
	var has_number = false
	var has_special = false
	var special = "!@#$%^&*"
	for char in password:
		if char >= 'A' and char <= 'Z':
			has_upper = true
		elif char >= '0' and char <= '9':
			has_number = true
		elif char in special:
			has_special = true
		if has_upper and has_number:
			return true

	return false
