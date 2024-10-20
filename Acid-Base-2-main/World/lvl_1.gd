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
@onready var acidArray = Global.acidArray
@onready var baseArray = Global.baseArray
@onready var option1 = $hud/HBoxContainer/Option1
@onready var option2 = $hud/HBoxContainer/Option2
@onready var option3 = $hud/HBoxContainer/Option3
@export var lives = 6  # This is the master source for lives
@onready var question_number = Global.question_number
@onready var correct_popup = $correctPopup
@onready var wrong_popup = $wrongPopup
var data_posted = false
var wrong_answer_count = 0
@onready var question_timer = $hud/TimerContainer/Timer
@onready var timer = $QuestionTimer
@onready var wrong_popup_label = $wrongPopup/wrong

# --------- FUNCTIONS ---------- #

func _ready():
	$hud/TitleContainer/Title.text = "IDENTIFY THE BASE"
	print($hud/PanelContainer/HBoxContainer/Level.text)
	$hud/PanelContainer/HBoxContainer/Level.text = "LEVEL " + current_value
	http_request.request("https://retoolapi.dev/tnFVDY/acidsbases")
	connect_option_signals()
	# Display options when the scene is loaded
	display_options_level1()
	# Connect the projectile_finished signal to update options when the projectile is shot
	$enemy.connect("projectile_finished", _on_projectile_finished)
	


func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var data = json.get_data()
			for entry in data:
				match entry["Type"]:
					"Acid":
						acidArray.append([entry["Compound"], "Acid"])
					"Base":
						baseArray.append([entry["Compound"], "Base"])
			print("Data fetched and formatted successfully!")
		else:
			print("Error parsing JSON: ", parse_result)
	else:
		print("Request failed with status code: ", response_code)

func display_options_level1():
	start_question_timer()
	await get_tree().create_timer(1.5).timeout
	$hud/QuestionContainer/QuestionNumber.text = "Question - " + str(Global.question_number)
	
	# Reset all option button colors to default 
	$hud/HBoxContainer/Option1.modulate = Color(1, 1, 1)  
	$hud/HBoxContainer/Option2.modulate = Color(1, 1, 1)  
	$hud/HBoxContainer/Option3.modulate = Color(1, 1, 1) 
	
	$hud/HBoxContainer/Option1.disabled = false
	$hud/HBoxContainer/Option2.disabled = false
	$hud/HBoxContainer/Option3.disabled = false
	
	var correct_option = Global.baseArray[randi_range(0, baseArray.size() - 1)][0]
	var wrong_option1 = Global.acidArray[randi_range(0, acidArray.size() - 1)][0]
	while wrong_option1 == correct_option:
		wrong_option1 = Global.acidArray[randi_range(0, acidArray.size() - 1)][0]
	var wrong_option2 = Global.acidArray[randi_range(0, acidArray.size() - 1)][0]
	while wrong_option2 == correct_option or wrong_option2 == wrong_option1:
		wrong_option2 = Global.acidArray[randi_range(0, acidArray.size() - 1)][0]
	var options = [correct_option, wrong_option1, wrong_option2]
	options.shuffle()
	$hud/HBoxContainer/Option1/RichText.text = format_option_text(options[0])
	$hud/HBoxContainer/Option2/RichText.text = format_option_text(options[1])
	$hud/HBoxContainer/Option3/RichText.text = format_option_text(options[2])
	Global.correct_answer = format_option_text(correct_option)

	

func format_option_text(option: String) -> String:
	var formatted = "[font_size=40]"
	for char in option:
		if '0' <= char and char <= '9': 
			formatted += "[font_size=20]" + char + "[/font_size]"
		else:
			formatted += char
	formatted += "[/font_size]"
	return formatted


func connect_option_signals():
	option1.connect("pressed", _on_Option1_Selected)
	option2.connect("pressed", _on_Option2_Selected)
	option3.connect("pressed", _on_Option3_Selected)

func _on_Option1_Selected():
	check_answer($hud/HBoxContainer/Option1.get_node("RichText").text)
		
func _on_Option2_Selected():
	check_answer($hud/HBoxContainer/Option2.get_node("RichText").text)
		
func _on_Option3_Selected():
	check_answer($hud/HBoxContainer/Option3.get_node("RichText").text)

func check_answer(selected_option: String):
	print(selected_option, "is the option selected")
	print(Global.correct_answer, "is the correct answer")
	
	# Disable all the options after a selection is made
	disable_options()
	if selected_option == Global.correct_answer:
		print("Correct Answer!!!")
		correct_popup.popup_centered()
		$correctPopup/Success_Sound.play()
		highlight_correct_answer(Global.correct_answer, true)
		#correct_popup.rect_min_size = Vector2(300, 15)
		update_score_and_progress()
		check_victory()
		$popupTimer.start()
	else:
		print("Wrong Answer!")
		wrong_popup.popup_centered()
		wrong_answer_count +=1
		$wrongPopup/Failure_Sound.play()
		highlight_wrong_answer(selected_option,Global.correct_answer)
		highlight_correct_answer(Global.correct_answer, true)
		# Highlight the selected wrong answer in red
		
		#wrong_popup.rect_min_size = Vector2(300, 15)
		update_lives(lives - 1)
		check_victory()
		$popupTimer.start()  # Update lives directly here

func highlight_correct_answer(correct_answer: String, highlight: bool):
	var options = [$hud/HBoxContainer/Option1, $hud/HBoxContainer/Option2, $hud/HBoxContainer/Option3]
	for option in options:
		var rich_text = option.get_node("RichText")  # Access the RichText node
		if rich_text.text == correct_answer:
			rich_text.bbcode_text = "[color=green]" + correct_answer + "[/color]" if highlight else correct_answer
		else:
			rich_text.bbcode_text = "[color=gray]" + rich_text.text + "[/color]"

func highlight_wrong_answer(wrong_answer: String, correct_answer : String):
	var options = [$hud/HBoxContainer/Option1, $hud/HBoxContainer/Option2, $hud/HBoxContainer/Option3]
	for option in options:
		var rich_text = option.get_node("RichText")  # Access the RichText node
		if rich_text.text == wrong_answer:
			rich_text.bbcode_text = "[color=red]" + wrong_answer + "[/color]"
		elif rich_text.text == correct_answer:
			rich_text.bbcode_text = "[color=green]" + correct_answer + "[/color]"
		else:
			rich_text.bbcode_text = "[color=red]" + rich_text.text + "[/color]"

	



func update_score_and_progress():
	Global.level1_correctAnswers += 1
	# Increase score by 3 and progress bar by 10%
	score += 3
	$hud/PanelContainer/HBoxContainer/ProgressBar.value += 10
	$hud/PanelContainer/HBoxContainer/Score.text = "Score: " + str(score)
	if (highscore < score):
		highscore = score
		
func check_victory():
	# Check if victory conditions are met
	if score >= 21 && Global.question_number == 10 || Global.level1_correctAnswers == 7:
		victory = true
		Global.level1Score = score
		$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = false
		$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = true
		gameover()
		if(!data_posted):
			post_score()
	#elif Global.level1_correctAnswers == 7:
		#victory = true
		#Global.level1Score = score
		#$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = false
		#$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = true
		#post_level_1_score()
		#gameover()
	if score < 21 && Global.question_number == 10:
		victory = false
		Global.level1Score = score
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
	# Update the options every time the projectile is fired
	display_options_level1()
	# Call check_victory after the projectile finishes, to ensure game logic continues
	check_victory()

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
	print("Correct answer count", Global.level1_correctAnswers)
	if score == 21:
		wrong_answer_count = 0
	$hud/Control/GameOverScreen/VBoxContainer/HBoxContainer2/CorrectlyAnswered.text = "Correct Answers:\n" + str(Global.level1_correctAnswers)            
	$hud/Control/GameOverScreen/VBoxContainer/HBoxContainer2/IncorrectlyAnswered.text = "Wrong Answers:\n" + str(wrong_answer_count)
	Global.level1Score = score
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
	Global.question_number = 1

func restart():
	print("restart")
	paused = false
	player_dead = false
	set_process(true)
	set_physics_process(true)
	$enemy.set_process(true)
	$enemy.set_physics_process(true)
	$enemy.attack_timer.start()
	Global.level1Score = 0
	Global.question_number = 1
	Global.level1_correctAnswers = 0
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
	$hud/HBoxContainer/Option1.disabled = true
	$hud/HBoxContainer/Option2.disabled = true
	$hud/HBoxContainer/Option3.disabled = true
	timer.stop()
	
func post_score():
	data_posted = true
	var user_data = {
		"SID": Global.sid,
		"Lastname": Global.lastName,
		"Firstname": Global.firstName,
		"Level_1_Score": str(Global.level1Score),
		"Level_2_Score": "0",
		"Level_3_Score": "0",
		"Level_4_Score": "0"
	}
	var json_data = JSON.stringify(user_data)
	print("Sending POST request with the following data: ", json_data)
	var headers = ["Content-Type: application/json"]
	http_request.request("https://api-generator.retool.com/R5pZpT/gamedetails", headers, HTTPClient.METHOD_POST, json_data)
	
func _on_POST_request_completed(result, response_code, headers, body):
	http_request.disconnect("request_completed", _on_POST_request_completed)
	if response_code == 200:
		print("POST request successful! User data added to API.")
	else:
		print("Failed to POST user data. Status code: ", response_code)

func start_question_timer():
	timer.stop()  
	timer.wait_time = 15
	timer.start()
	update_timer_label(15)  
	
func _process(delta):
	if timer.is_stopped() == false:
		var remaining_time = int(timer.time_left)
		update_timer_label(remaining_time)
	
func _on_Timer_timeout():
	print("Time's up! Marking the question as incorrect.")
	wrong_popup_label.text = "Time's up!"
	wrong_popup.popup_centered()
	wrong_answer_count += 1
	$wrongPopup/Failure_Sound.play()
	update_lives(lives - 1)
	check_victory()
	$popupTimer.start()

func update_timer_label(time_left: int):
	question_timer.text = "Time Left: " +str(time_left) + " sec"
	if time_left <= 5:
		question_timer.modulate = Color(1, 0, 0)  
	else:
		question_timer.modulate = Color(1, 1, 1)  

