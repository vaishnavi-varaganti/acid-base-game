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
@onready var http_request = $HTTPRequest
@onready var acidArray = Global.acidArray
@onready var baseArray = Global.baseArray
@onready var acidShooted = Global.acidShooted
@onready var baseShooted = Global.baseShooted
@onready var option1 = $hud/HBoxContainer/Option1
@onready var option2 = $hud/HBoxContainer/Option2
@onready var option3 = $hud/HBoxContainer/Option3
@export var lives = 6  # Master source for lives
@onready var correct_popup = $correctPopup
@onready var wrong_popup = $wrongPopup
var wrong_answer_count = 0

# --------- FUNCTIONS ---------- #


func _ready():
	$hud/TitleContainer/Title.text = "IDENTIFY THE ACIDS AND BASES"
	Global.question_number = 1
	print($hud/PanelContainer/HBoxContainer/Level.text)
	$hud/PanelContainer/HBoxContainer/Level.text = "LEVEL " + str(Global.current_level)
	http_request.request("https://retoolapi.dev/tnFVDY/acidsbases")
	connect_option_signals()
	# Display options when the scene is loaded
	display_options_level3()

func display_options_level3():
	var correct_option = ""
	var wrong_option1 = ""
	var wrong_option2 = ""
	$hud/QuestionContainer/QuestionNumber.text = "Question - " + str(Global.question_number)
	
	# Reset button colors
	$hud/HBoxContainer/Option1.modulate = Color(1, 1, 1)
	$hud/HBoxContainer/Option2.modulate = Color(1, 1, 1)
	$hud/HBoxContainer/Option3.modulate = Color(1, 1, 1)

	$hud/HBoxContainer/Option1.disabled = false
	$hud/HBoxContainer/Option2.disabled = false
	$hud/HBoxContainer/Option3.disabled = false
	
	if (Global.question_number % 2 ==0):
		correct_option = Global.baseArray[randi_range(0, baseArray.size() - 1)][0]
		wrong_option1 = Global.acidArray[randi_range(0, acidArray.size() - 1)][0]
		while wrong_option1 == correct_option:
			wrong_option1 = Global.acidArray[randi_range(0, acidArray.size() - 1)][0]
		wrong_option2 = Global.acidArray[randi_range(0, acidArray.size() - 1)][0]
		while wrong_option2 == correct_option or wrong_option2 == wrong_option1:
			wrong_option2 = Global.acidArray[randi_range(0, acidArray.size() - 1)][0]
	elif (Global.question_number % 2 !=0):
		correct_option = Global.acidArray[randi_range(0, acidArray.size() - 1)][0]
		wrong_option1 = Global.baseArray[randi_range(0, baseArray.size() - 1)][0]
		while wrong_option1 == correct_option:
			wrong_option1 = Global.baseArray[randi_range(0, baseArray.size() - 1)][0]
		wrong_option2 = Global.baseArray[randi_range(0, baseArray.size() - 1)][0]
		while wrong_option2 == correct_option or wrong_option2 == wrong_option1:
			wrong_option2 = Global.baseArray[randi_range(0, baseArray.size() - 1)][0]
	var options = [correct_option, wrong_option1, wrong_option2]
	options.shuffle()
	$hud/HBoxContainer/Option1.text = options[0]
	$hud/HBoxContainer/Option2.text = options[1]
	$hud/HBoxContainer/Option3.text = options[2]
	Global.correct_answer = correct_option
	print(correct_option)
	print(wrong_option1)
	print(wrong_option2)

func connect_option_signals():
	option1.connect("pressed", _on_Option1_Selected)
	option2.connect("pressed", _on_Option2_Selected)
	option3.connect("pressed", _on_Option3_Selected)

func _on_Option1_Selected():
	check_answer($hud/HBoxContainer/Option1.text)
		
func _on_Option2_Selected():
	check_answer($hud/HBoxContainer/Option2.text)
		
func _on_Option3_Selected():
	check_answer($hud/HBoxContainer/Option3.text)

func check_answer(selected_option: String):
	print(selected_option, "is the option selected")
	print(Global.correct_answer, "is the correct answer")
	disable_options()

	if selected_option == Global.correct_answer:
		print("Correct Answer!!!")
		correct_popup.popup_centered()
		$correctPopup/Success_Sound.play()
		highlight_correct_option()
		update_score_and_progress()
		check_victory()
		$popupTimer.start()
	else:
		print("Wrong Answer!")
		wrong_popup.popup_centered()
		wrong_answer_count +=1
		$wrongPopup/Failure_Sound.play()
		highlight_wrong_option(selected_option)
		update_lives(lives - 1)
		check_victory()
		$popupTimer.start()

func highlight_correct_option():
	# Highlight correct answer in green
	$hud/HBoxContainer/Option1.modulate = Color(0, 1, 0) if $hud/HBoxContainer/Option1.text == Global.correct_answer else Color(1, 1, 1)
	$hud/HBoxContainer/Option2.modulate = Color(0, 1, 0) if $hud/HBoxContainer/Option2.text == Global.correct_answer else Color(1, 1, 1)
	$hud/HBoxContainer/Option3.modulate = Color(0, 1, 0) if $hud/HBoxContainer/Option3.text == Global.correct_answer else Color(1, 1, 1)

func highlight_wrong_option(selected_option: String):
	# Highlight wrong answer in red and correct one in green
	$hud/HBoxContainer/Option1.modulate = Color(1, 0, 0) if $hud/HBoxContainer/Option1.text == selected_option else $hud/HBoxContainer/Option1.modulate
	$hud/HBoxContainer/Option2.modulate = Color(1, 0, 0) if $hud/HBoxContainer/Option2.text == selected_option else $hud/HBoxContainer/Option2.modulate
	$hud/HBoxContainer/Option3.modulate = Color(1, 0, 0) if $hud/HBoxContainer/Option3.text == selected_option else $hud/HBoxContainer/Option3.modulate
	highlight_correct_option()

func disable_options():
	$hud/HBoxContainer/Option1.disabled = true
	$hud/HBoxContainer/Option2.disabled = true
	$hud/HBoxContainer/Option3.disabled = true

func update_score_and_progress():
	Global.level3_correctAnswers += 1
	score += 3
	$hud/PanelContainer/HBoxContainer/ProgressBar.value += 10
	$hud/PanelContainer/HBoxContainer/Score.text = "Score: " + str(score)
	if highscore < score:
		highscore = score

func check_victory():
	if score >= 21 and Global.question_number == 10 or Global.level3_correctAnswers == 7:
		victory = true
		Global.level3Score = score
		$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = false
		$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = true
		gameover()
	elif score < 21 and Global.question_number == 11:
		victory = false
		Global.level3Score = score
		$hud/Control/GameOverScreen/VBoxContainer/MainMenu.disabled = true
		$hud/Control/GameOverScreen/VBoxContainer/Restart.disabled = false
		gameover()
	find_id_by_sid()

func update_lives(new_lives: int):
	lives = new_lives
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
	display_options_level3()
	check_victory()

func gameover():
	await get_tree().create_timer(1.5).timeout
	paused = true
	$hud.game_over()
	if victory:
		$hud/Control/GameOverScreen/VBoxContainer/GameOverText.text = "You Win!"
	else:
		$hud/Control/GameOverScreen/VBoxContainer/GameOverText.text = "You Lost"
	$hud/Control/VictoryAnims.show()
	print("Correct answer count", Global.level3_correctAnswers)
	var wrong_answers = 0
	if score == 21:
		wrong_answer_count = 0
	$hud/Control/GameOverScreen/VBoxContainer/HBoxContainer2/CorrectlyAnswered.text = "Correct Answers:\n" + str(Global.level3_correctAnswers)
	$hud/Control/GameOverScreen/VBoxContainer/HBoxContainer2/IncorrectlyAnswered.text = "Wrong Answers:\n" + str(wrong_answer_count)
	Global.level3Score = score
	$hud/QuestionContainer/QuestionNumber.visible = false
	$hud/TitleContainer/Title.visible = false
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
	score = 0
	$hud/PanelContainer/HBoxContainer/ProgressBar.value = 0
	$hud/PanelContainer/HBoxContainer/Score.text = "Score: 0"
	Global.level3_correctAnswers = 0
	Global.question_number = 1
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
	pass

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
		"Level_4_Score": "0"
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
