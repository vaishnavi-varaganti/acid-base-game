extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$menu/Panel/PanelContainer/VBoxContainer2/Firstnamecontainer/firstnametext.text = str(Global.firstName)
	$menu/Panel/PanelContainer/VBoxContainer2/lastnamecontainer/lastnametext.text = str(Global.lastName)
	$menu/Panel/PanelContainer/VBoxContainer2/sidcontainer/sidtext.text = str(Global.sid)
	$menu/Panel/PanelContainer/VBoxContainer2/level1Container/score1text.text = str(Global.level1Score)
	$menu/Panel/PanelContainer/VBoxContainer2/level2Container/score2text.text = str(Global.level2Score)
	$menu/Panel/PanelContainer/VBoxContainer2/level3Container/score3text.text = str(Global.level3Score)
	$menu/Panel/PanelContainer/VBoxContainer2/level4Container/score4text.text = str(Global.level4Score)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().quit()
	pass
