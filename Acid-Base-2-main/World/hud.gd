extends CanvasLayer

# --------- VARIABLES ---------- #
@onready var gameOverScreen = $Control
@onready var inGamePanel = $PanelContainer

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
	$Control/GameOverScreen/VBoxContainer/HBoxContainer/Score.text = "Score: " 
	#$Control/GameOverScreen/VBoxContainer/HBoxContainer/Score.text = "Score:\n" + str($"..".score)
	#$Control/GameOverScreen/VBoxContainer/HBoxContainer/HighScore.text = "High Score:\n" + str($"..".highscore)
	
func _on_restart_pressed():
	game_start()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res:///World/menu.tscn")

func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://World/tutorial.tscn")











func _on_button_pressed():
	get_tree().change_scene_to_file("res://resume_screen.tscn")
	
	
	pass # Replace with function body.
