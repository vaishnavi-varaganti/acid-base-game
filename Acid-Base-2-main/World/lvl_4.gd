extends Node2D

# --------- VARIABLES ---------- #
signal projectile_finished
@onready var fullHeart = preload("res://healthFull.png")
@onready var halfHeart = preload("res://healthHalf.png")
@onready var score = 0
@onready var highscore = 0
@onready var paused = false
@onready var player_dead = false
@onready var victory = false
@onready var current_value = str(Global.current_level)
@onready var http_request = $HTTPRequest
@onready var reactionIndex = Global.reactionIndex
@onready var compoundArray = Global.compoundArray
@onready var individualCompoundArray = Global.individualCompoundArray
@onready var option1 = $HBoxContainer/Option1
@onready var option2 = $HBoxContainer/Option2
@onready var option3 = $HBoxContainer2/Option3
@export var lives = 6  # This is the master source for lives
@onready var question_number = Global.question_number
@onready var correct_popup = $correctPopup
@onready var wrong_popup = $wrongPopup
var wrong_answer_count = 0

# --------- FUNCTIONS ---------- #

func _ready():
	$hud/TitleContainer/Title.text = "IDENTIFY THE INDIVIDUAL COMPOUNDS"
	Global.question_number = 1
	$hud/PanelContainer/HBoxContainer/Level.text = "LEVEL " + str(Global.current_level)
	$hud/HBoxContainer/Option1.visible = false
	$hud/HBoxContainer/Option2.visible = false
	$hud/HBoxContainer/Option3.visible = false
	$hud/HBoxContainer/VSeparator.visible = false
	$hud/HBoxContainer/VSeparator2.visible = false
	connect_option_signals()
	display_options_level4()
	$enemy.connect("projectile_finished", _on_projectile_finished)

func display_options_level4():
	$hud/QuestionContainer/QuestionNumber.text = "Question - " + str(Global.question_number)
	
	# Reset all option button colors to default 
	$HBoxContainer/Option1.modulate = Color(1, 1, 1)  
	$HBoxContainer/Option2.modulate = Color(1, 1, 1)  
	$HBoxContainer2/Option3.modulate = Color(1, 1, 1) 
	
	$HBoxContainer/Option1.disabled = false
	$HBoxContainer/Option2.disabled = false
	$HBoxContainer2/Option3.disabled = false
	
	print("RI is",Global.reactionIndex)
	if individualCompoundArray.size() < 3:
		print("Not enough data in compoundArray to display options")
		return
	var correct_option = individualCompoundArray[Global.reactionIndex][0]
	var	wrong_option1 = individualCompoundArray[randi_range(0, individualCompoundArray.size() - 1)][0]
	while wrong_option1 == correct_option:
		wrong_option1 = individualCompoundArray[randi_range(0, individualCompoundArray.size() - 1)][0]
	var	wrong_option2 = individualCompoundArray[randi_range(0, individualCompoundArray.size() - 1)][0]
	while wrong_option2 == correct_option or wrong_option2 == wrong_option1:
		wrong_option2 = individualCompoundArray[randi_range(0, individualCompoundArray.size() - 1)][0]
	var options = [correct_option, wrong_option1, wrong_option2]
	options.shuffle()
	print("option 1", correct_option)
	print("option 2", wrong_option1)
	print("option 3", wrong_option2)
	$HBoxContainer/Option1.text = options[0]
	$HBoxContainer/Option2.text = options[1]
	$HBoxContainer2/Option3.text = options[2]
	Global.correct_answer = correct_option

func connect_option_signals():
	option1.connect("pressed", _on_Option1_Selected)
	option2.connect("pressed", _on_Option2_Selected)
	option3.connect("pressed", _on_Option3_Selected)
	
func _on_Option1_Selected():
	check_answer($HBoxContainer/Option1.text)
		
func _on_Option2_Selected():
	check_answer($HBoxContainer/Option2.text)
		
func _on_Option3_Selected():
	check_answer($HBoxContainer2/Option3.text)
	
func check_answer(selected_option: String):
	print(selected_option, "is the option selected")
	print(Global.correct_answer, "is the correct answer")
	#Global.correct_answer = Global.correct_answer[0]
	#print(Global.correct_answer , "is the correct answer")
	# Disable all the options after a selection is made
	disable_options()
	
	if selected_option == Global.correct_answer:
		print("Correct Answer!!!")
		correct_popup.popup_centered()
		$correctPopup/Success_Sound.play()
		# Highlight correct answer visually (optional, e.g., change button color or text)
		$HBoxContainer/Option1.modulate = Color(0, 1, 0) if $HBoxContainer/Option1.text == Global.correct_answer else Color(1, 1, 1)
		$HBoxContainer/Option2.modulate = Color(0, 1, 0) if $HBoxContainer/Option2.text == Global.correct_answer else Color(1, 1, 1)
		$HBoxContainer2/Option3.modulate = Color(0, 1, 0) if $HBoxContainer2/Option3.text == Global.correct_answer else Color(1, 1, 1)
		
		#correct_popup.rect_min_size = Vector2(300, 15)
		update_score_and_progress()
		check_victory()
		$popupTimer.start()
	else:
		print("Wrong Answer!")
		wrong_popup.popup_centered()
		wrong_answer_count +=1
		$wrongPopup/Failure_Sound.play()
		# Highlight the selected wrong answer in red
		$HBoxContainer/Option1.modulate = Color(1, 0, 0) if $HBoxContainer/Option1.text == selected_option else Color(1, 1, 1)
		$HBoxContainer/Option2.modulate = Color(1, 0, 0) if $HBoxContainer/Option2.text == selected_option else Color(1, 1, 1)
		$HBoxContainer2/Option3.modulate = Color(1, 0, 0) if $HBoxContainer2/Option3.text == selected_option else Color(1, 1, 1)
		
		# Highlight the correct answer in green
		$HBoxContainer/Option1.modulate = Color(0, 1, 0) if $HBoxContainer/Option1.text == Global.correct_answer else $HBoxContainer/Option1.modulate
		$HBoxContainer/Option2.modulate = Color(0, 1, 0) if $HBoxContainer/Option2.text == Global.correct_answer else $HBoxContainer/Option2.modulate
		$HBoxContainer2/Option3.modulate = Color(0, 1, 0) if $HBoxContainer2/Option3.text == Global.correct_answer else $HBoxContainer2/Option3.modulate
		
		#wrong_popup.rect_min_size = Vector2(300, 15)
		update_lives(lives - 1)
		check_victory()
		$popupTimer.start()  # Update lives directly here
		
func update_score_and_progress():
	Global.level4_correctAnswers += 1
	# Increase score by 3 and progress bar by 10%
	score += 3
	$hud/PanelContainer/HBoxContainer/ProgressBar.value += 10
	$hud/PanelContainer/HBoxContainer/Score.text = "Score: " + str(score)
	if (highscore < score):
		highscore = score

func check_victory():
	# Check if victory conditions are met
	if score >= 21 && Global.question_number == 10 || Global.level4_correctAnswers == 7:
		victory = true
		Global.level2Score = score
		$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = false
		$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = true
		gameover()
	#elif Global.level2_correctAnswers == 7:
		#victory = true
		#$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = false
		#$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = true
		#gameover()
	elif score < 21 && Global.question_number == 11:
		victory = false
		$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = true
		$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = false
		gameover()
	
func update_lives(new_lives: int):
	lives = new_lives  # Update the lives variable
	# Ensure that player_lvl1.gd reflects the correct life count
	$player_Lvl1.lives = lives

	# Update the hearts display based on lives
	if lives == 6:
		$hud/PanelContainer/HBoxContainer/First.set_texture(fullHeart)
		$hud/PanelContainer/HBoxContainer/Second.set_texture(fullHeart)
		$hud/PanelContainer/HBoxContainer/Third.set_texture(fullHeart)
	elif lives == 5:
		$hud/PanelContainer/HBoxContainer/First.set_texture(fullHeart)
		$hud/PanelContainer/HBoxContainer/Second.set_texture(fullHeart)
		$hud/PanelContainer/HBoxContainer/Third.set_texture(halfHeart)
	elif lives == 4:
		$hud/PanelContainer/HBoxContainer/First.set_texture(fullHeart)
		$hud/PanelContainer/HBoxContainer/Second.set_texture(fullHeart)
		$hud/PanelContainer/HBoxContainer/Third.set_texture(null)
	elif lives == 3:
		$hud/PanelContainer/HBoxContainer/First.set_texture(fullHeart)
		$hud/PanelContainer/HBoxContainer/Second.set_texture(halfHeart)
		$hud/PanelContainer/HBoxContainer/Third.set_texture(null)
	elif lives == 2:
		$hud/PanelContainer/HBoxContainer/First.set_texture(fullHeart)
		$hud/PanelContainer/HBoxContainer/Second.set_texture(null)
		$hud/PanelContainer/HBoxContainer/Third.set_texture(null)
	elif lives == 1:
		$hud/PanelContainer/HBoxContainer/First.set_texture(halfHeart)
		$hud/PanelContainer/HBoxContainer/Second.set_texture(null)
		$hud/PanelContainer/HBoxContainer/Third.set_texture(null)
	elif lives <= 0:
		$hud/PanelContainer/HBoxContainer/First.set_texture(null)
		$hud/PanelContainer/HBoxContainer/Second.set_texture(null)
		$hud/PanelContainer/HBoxContainer/Third.set_texture(null)
		gameover()
	
func _on_projectile_finished():
	player_dead = false
	var index = get_node("/root/Global")
	index.set_reaction_index()
	# Update the options every time the projectile is fired
	display_options_level4()
	# Call check_victory after the projectile finishes, to ensure game logic continues
	check_victory()
	
func _on_question_prepared():
	display_options_level4()
	
func gameover():
	await get_tree().create_timer(1.5).timeout
	paused = true
	$hud.game_over()
	# Set Game Over text depending on victory or not
	if victory:
		$hud/Control/GameOverScreen/VBoxContainer/GameOverText.text = "You Win!"
	else:
		$hud/Control/GameOverScreen/VBoxContainer/GameOverText.text = "You Lost"
	$hud/Control/VictoryAnims.show()
	print("Correct answer count", Global.level4_correctAnswers)
	if score == 21:
		wrong_answer_count = 0
	$hud/Control/GameOverScreen/VBoxContainer/HBoxContainer2/CorrectlyAnswered.text = "Correct Answers:\n" + str(Global.level4_correctAnswers)            
	$hud/Control/GameOverScreen/VBoxContainer/HBoxContainer2/IncorrectlyAnswered.text = "Wrong Answers:\n" + str(wrong_answer_count)
	Global.level4Score = score
	$hud/QuestionContainer/QuestionNumber.visible = false
	$hud/TitleContainer/Title.visible = false
	# Hide buttons you don’t want to show on Game Over
	$hud/HBoxContainer/Option1.visible = false
	$hud/HBoxContainer/Option2.visible = false
	$hud/HBoxContainer/Option3.visible = false
	$hud/HBoxContainer/VSeparator.visible = false
	$hud/HBoxContainer/VSeparator2.visible = false
	set_process(false)
	set_physics_process(false)
	$enemy.set_process(false)
	$enemy.set_physics_process(false)
	
func restart():
	print("restart")
	paused = false
	player_dead = false
	set_process(true)
	set_physics_process(true)
	$enemy.set_process(true)
	$enemy.set_physics_process(true)
	$enemy.attack_timer.start()
	Global.level4Score = 0
	Global.question_number = 1
	Global.level4_correctAnswers = 0
	score = 0
	$hud/PanelContainer/HBoxContainer/ProgressBar.value = 0
	$hud/PanelContainer/HBoxContainer/Score.text = "Score: 0"
	$hud/QuestionContainer/QuestionNumber.visible = true
	$hud/TitleContainer/Title.visible = true
	$player_Lvl1.lives = 6
	update_lives(6)
	$player_Lvl1.set_position(Vector2(155, -300))
	$player_Lvl1.respawn_tween()
	$hud/HBoxContainer/Option1.visible = true
	$hud/HBoxContainer/Option2.visible = true
	$hud/HBoxContainer/Option3.visible = true
	$hud/HBoxContainer/VSeparator.visible = true
	$hud/HBoxContainer/VSeparator2.visible = true
	
func _on_PopupTimer_timeout():
	correct_popup.hide()
	wrong_popup.hide()
	pass # Replace with function body.
	
func disable_options():
	$HBoxContainer/Option1.disabled = true
	$HBoxContainer/Option2.disabled = true
	$HBoxContainer2/Option3.disabled = true
