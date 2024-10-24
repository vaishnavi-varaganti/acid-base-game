extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$menu/Panel/PanelContainer/VBoxContainer2/Status.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var first_name = $menu/Panel/PanelContainer/VBoxContainer2/Firstnamecontainer/firstnametext.text
	var last_name = $menu/Panel/PanelContainer/VBoxContainer2/lastnamecontainer/LineEdit.text
	var sid = $menu/Panel/PanelContainer/VBoxContainer2/sidcontainer/LineEdit.text

	if first_name != "" and last_name != "" and sid != "":
		print("entered")  
		var gd = get_node("/root/Global")
		gd.set_user_info(first_name, last_name, sid)
		get_tree().change_scene_to_file("res://World/menu.tscn")
	else:
		print("not entered") 
		$menu/Panel/PanelContainer/VBoxContainer2/Status.visible = true
		$menu/Panel/PanelContainer/VBoxContainer2/Status.text = "Please Enter All the Fields"
	pass # Replace with function body.
