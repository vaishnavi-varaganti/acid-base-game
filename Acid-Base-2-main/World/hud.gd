extends CanvasLayer

# --------- VARIABLES ---------- #
@onready var gameOverScreen = $Control
@onready var inGamePanel = $PanelContainer
@onready var options = $PanelContainer/HBoxContainer/OptionButton

# --------- FUNCTIONS ---------- #
func _ready():
	gameOverScreen.hide()
	$Control/VictoryAnims.hide()

func _physics_process(delta):
	$Control/VictoryAnims/Duckdance.play("duck")
	$Control/VictoryAnims/PlayerVictory.play("player")
func game_start():
	inGamePanel.show()
	gameOverScreen.hide()
	$"..".restart()
	
func game_over():
	inGamePanel.hide()
	gameOverScreen.show()
	$Control/GameOverScreen/VBoxContainer/HBoxContainer/Score.text = "Score: " + str($"..".score)
	#$Control/GameOverScreen/VBoxContainer/HBoxContainer/Score.text = "Score:\n" + str($"..".score)
	#$Control/GameOverScreen/VBoxContainer/HBoxContainer/HighScore.text = "High Score: " + str($"..".highscore)
	
func _on_restart_pressed():
	if Global.current_level == 1:
		Global.question_number = 0
		Global.level1_correctAnswers = 0
		get_tree().change_scene_to_file("res://World/lvl_1.tscn")
		pass

func _on_go_to_next_level_presses():
	if Global.current_level == 1:
		get_tree().change_scene_to_file("res://World/level2menu.tscn")
		Global.current_level = 2
		pass
	elif Global.current_level == 2:
		get_tree().change_scene_to_file("res://World/level3menu.tscn")
		Global.current_level = 3
		pass
	elif Global.current_level == 3:
		get_tree().change_scene_to_file("res://World/level4menu.tscn")
		Global.current_level = 4
		pass

func _on_play_again_pressed():
	if Global.current_level == 1:
		get_tree().change_scene_to_file("res://World/mainlevelmenu.tscn")


func _on_option_button_item_selected(index):
	match index:
		0:  pass
		1:  pause_game()
		2:  resume_game()
		3:  quit_game()
	pass # Replace with function body.

func quit_game():
	if Global.current_level == 1:
		Global.question_number = 0
		get_tree().change_scene_to_file("res://World/mainlevelmenu.tscn")
		
	
func resume_game():
	get_tree().paused = false
	
	#show()

func pause_game():
	get_tree().paused = true
	options.show()

func _on_option_1_pressed():
	$ButtonClickSound.play()
	pass 
	
func _on_option_2_pressed():
	$ButtonClickSound.play()
	pass 
	
func _on_option_3_pressed():
	$ButtonClickSound.play()
	pass 
