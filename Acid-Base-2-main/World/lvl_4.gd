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
@onready var question_timer = $hud/TimerContainer/Timer
@onready var timer = $QuestionTimer
@onready var wrong_popup_label = $wrongPopup/wrong
var option_selected = false
var timer_expired = false
@onready var player = $player_Lvl1
# --------- FUNCTIONS ---------- #

func _ready():
	$hud/TitleContainer/Title.text = "BALANCE THE REACTIONS"
	Global.current_level = 4
	Global.question_number = 0
	$hud/PanelContainer/HBoxContainer/Level.text = "LEVEL " + str(Global.current_level)
	$hud/HBoxContainer/Option1.visible = false
	$hud/HBoxContainer/Option2.visible = false
	$hud/HBoxContainer/Option3.visible = false
	$hud/HBoxContainer/VSeparator.visible = false
	$hud/HBoxContainer/VSeparator2.visible = false
	connect_option_signals()
	display_options_level4()
	$hud/Button.visible = false
	$enemy.connect("projectile_finished", _on_projectile_finished)

func display_options_level4():
	option_selected = false
	start_question_timer()
	$hud/QuestionContainer/QuestionNumber.text = "Question - " + str(Global.question_number + 1) +"/10"
	
	# Reset all option button colors to default 
	$HBoxContainer/Option1.modulate = Color(1, 1, 1)  
	$HBoxContainer/Option2.modulate = Color(1, 1, 1)  
	$HBoxContainer2/Option3.modulate = Color(1, 1, 1) 
	
	$HBoxContainer/Option1.disabled = false
	$HBoxContainer/Option2.disabled = false
	$HBoxContainer2/Option3.disabled = false
	
	print("The reaction Index in level 4 is",Global.reactionIndex)
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
	$HBoxContainer/Option1/RichText.text = format_option_text(options[0])
	$HBoxContainer/Option2/RichText.text = format_option_text(options[1])
	$HBoxContainer2/Option3/RichText.text = format_option_text(options[2])
	Global.correct_answer = format_option_text(correct_option)
	
func format_option_text(option: String) -> String:
	var formatted = "[center][font_size=30]"
	for char in option:
		if '0' <= char and char <= '9': 
			formatted += "[font_size=14]" + char + "[/font_size]"
		else:
			formatted += char
	formatted += "[/font_size][/center]"
	return formatted

func connect_option_signals():
	option1.connect("pressed", _on_Option1_Selected)
	option2.connect("pressed", _on_Option2_Selected)
	option3.connect("pressed", _on_Option3_Selected)
	
func _on_Option1_Selected():
	check_answer($HBoxContainer/Option1.get_node("RichText").text)
		
func _on_Option2_Selected():
	check_answer($HBoxContainer/Option2.get_node("RichText").text)
		
func _on_Option3_Selected():
	check_answer($HBoxContainer2/Option3.get_node("RichText").text)
	
func check_answer(selected_option: String):
	print(selected_option, "is the option selected")
	print(Global.correct_answer, "is the correct answer")
	#Global.correct_answer = Global.correct_answer[0]
	#print(Global.correct_answer , "is the correct answer")
	# Disable all the options after a selection is made
	disable_options()
	
	if selected_option == Global.correct_answer:
		print("Correct Answer!!!")
		player.ouch()
		correct_popup.popup_centered()
		$correctPopup/Success_Sound.play()
		# Highlight correct answer visually (optional, e.g., change button color or text)
		highlight_correct_answer(Global.correct_answer, true)
		#correct_popup.rect_min_size = Vector2(300, 15)
		update_score_and_progress()
		check_victory()
		$popupTimer.start()
	else :
		print("Wrong Answer!")
		if timer_expired:
			wrong_popup_label.text = "Time's up!"
		else:
			wrong_answer_count += 1
			wrong_popup_label.text = "Wrong answer!"
			$popupTimer.start()
		wrong_popup.popup_centered()
		$wrongPopup/Failure_Sound.play()
		highlight_wrong_answer(selected_option, Global.correct_answer)
		highlight_correct_answer(Global.correct_answer, true)
		update_lives(lives - 1)
		check_victory()
		
func highlight_correct_answer(correct_answer: String, highlight: bool):
	var options = [$HBoxContainer/Option1, $HBoxContainer/Option2, $HBoxContainer2/Option3]
	for option in options:
		var rich_text = option.get_node("RichText")  # Access the RichText node
		if rich_text.text == correct_answer:
			rich_text.bbcode_text = "[center][color=green]" + correct_answer + "[/color][/center]" if highlight else correct_answer
		else:
			rich_text.bbcode_text = "[center][color=gray]" + rich_text.text + "[/color][/center]"

func highlight_wrong_answer(wrong_answer: String, correct_answer : String):
	var options = [$HBoxContainer/Option1, $HBoxContainer/Option2, $HBoxContainer2/Option3]
	for option in options:
		var rich_text = option.get_node("RichText")  # Access the RichText node
		if rich_text.text == wrong_answer:
			rich_text.bbcode_text = "[color=red]" + wrong_answer + "[/color]"
		elif rich_text.text == correct_answer:
			rich_text.bbcode_text = "[color=green]" + correct_answer + "[/color]"
		else:
			rich_text.bbcode_text = "[color=red]" + rich_text.text + "[/color]"
		
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
		Global.level4Score = score
		$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = false
		$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = true
		gameover()
	#elif Global.level2_correctAnswers == 7:
		#victory = true
		#$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = false
		#$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = true
		#gameover()
	elif score < 21 && Global.question_number == 10:
		victory = false
		Global.level4Score = score
		$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = true
		$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = false
		gameover()
	find_id_by_sid()
	
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
	player.jump()
	await get_tree().create_timer(1.0).timeout
	player.ouch()
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
	$hud/Button.visible = true
	if score >= 21:
		$hud/Control/GameOverScreen/VBoxContainer/MainMenu.visible = false
		$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = true
	elif score < 21:
		$hud/Control/GameOverScreen/VBoxContainer/MainMenu.visible = false
		$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = false
	# Set Game Over text depending on victory or not
	if victory:
		$hud/Control/GameOverScreen/VBoxContainer/GameOverText.text = "You Win!"
	else:
		$hud/Control/GameOverScreen/VBoxContainer/GameOverText.text = "You Lost"
	$hud/Control/VictoryAnims.show()
	print("Correct answer count", Global.level4_correctAnswers)
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
	$hud/Control/GameOverScreen/VBoxContainer/MainMenu.visible = false
	set_process(false)
	set_physics_process(false)
	$enemy.set_process(false)
	$enemy.set_physics_process(false)
	Global.question_number = 1
	question_timer.visible = false
	
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
	question_timer.visible = true
	
func _on_PopupTimer_timeout():
	correct_popup.hide()
	wrong_popup.hide()
	pass # Replace with function body.
	
func disable_options():
	$HBoxContainer/Option1.disabled = true
	$HBoxContainer/Option2.disabled = true
	$HBoxContainer2/Option3.disabled = true
	timer.stop()

func delete_multiple_records(user_ids: Array):
	for user_id in user_ids:
		var url = "https://api-generator.retool.com/R5pZpT/gamedetails/" + str(user_id)
		print("Deleting record with URL: ", url)
		
		var headers = ["Content-Type: application/json"]
		http_request.request(url, headers, HTTPClient.METHOD_DELETE)
		http_request.connect("request_completed", _on_delete_request_completed)

func _on_delete_request_completed(result, response_code, headers, body):
	http_request.disconnect("request_completed", _on_delete_request_completed)
	
	if response_code == 200:
		print("Delete request successful!")
	else:
		print("Failed to delete record. Status code: ", response_code)
	post_score()

func find_id_by_sid():
	var headers = ["Content-Type: application/json"]
	http_request.request("https://api-generator.retool.com/R5pZpT/gamedetails", headers)
	http_request.connect("request_completed", _on_get_request_completed)

func _on_get_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var data = json.get_data()
			print("Received Data: ", data)  
			
			var user_ids_to_delete = []  

			for entry in data:
				if typeof(entry) == TYPE_DICTIONARY and entry.has("SID"):
					if entry["SID"] == Global.sid:
						user_ids_to_delete.append(entry["id"])
						print("Matching SID found. User ID: ", entry["id"])
			
			if user_ids_to_delete.size() > 0:
				delete_multiple_records(user_ids_to_delete)
			else:
				print("No matching SID found for: ", Global.sid)
				post_score()
		else:
			print("Error parsing JSON: ", parse_result)
	else:
		print("Failed to GET data. Status code: ", response_code)
		
func post_score():
	var user_data = {
		"SID": Global.sid,
		"Lastname": Global.lastName,
		"Firstname": Global.firstName,
		"Level_1_Score": str(Global.level1Score),
		"Level_2_Score": str(Global.level2Score),
		"Level_3_Score": str(Global.level3Score),
		"Level_4_Score": str(Global.level4Score)
	}
	
	var json_data = JSON.stringify(user_data)
	print("Sending POST request with the following data: ", json_data)
	
	var headers = ["Content-Type: application/json"]
	http_request.request("https://api-generator.retool.com/R5pZpT/gamedetails", headers, HTTPClient.METHOD_POST, json_data)
	http_request.connect("request_completed", _on_POST_request_completed)
	
func _on_POST_request_completed(result, response_code, headers, body):
	http_request.disconnect("request_completed", _on_POST_request_completed)
	if response_code == 200:
		print("POST request successful! User data added to API.")
	else:
		print("Failed to POST user data. Status code: ", response_code)

func start_question_timer():
	timer_expired = false
	timer.stop()  
	timer.wait_time = 15  
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	timer.start()
	update_timer_label(16) 
	
func _process(delta):
	if timer.is_stopped() == false:
		var remaining_time = int(timer.time_left)
		update_timer_label(remaining_time)
	
func _on_Timer_timeout():
	print("Time's up!")
	timer_expired = true
	if not option_selected:
		handle_wrong_answer()
	else:
		print("An option was already selected.")
		timer_expired = false
		
func handle_wrong_answer():
	wrong_answer_count += 1
	$wrongPopup/Failure_Sound.play()
	wrong_popup_label.text = "Time's up!"
	wrong_popup.popup_centered()
	update_lives(lives - 1)
	check_victory()
	$popupTimer.start()

func update_timer_label(time_left: int):
	question_timer.text = "Time Left: " +str(time_left) + " sec"
	if time_left <= 5:
		question_timer.modulate = Color(1, 0, 0)  
	else:
		question_timer.modulate = Color(1, 1, 1)  
