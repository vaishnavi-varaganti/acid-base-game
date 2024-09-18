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
@onready var compoundArray = Global.compoundArray
@onready var acidShooted = Global.acidShooted
@onready var baseShooted = Global.baseShooted
# --------- FUNCTIONS ---------- #

func _ready():
	$hud/PanelContainer/HBoxContainer/Level.text = "LEVEL - " + str(Global.current_level)
	http_request.request("https://retoolapi.dev/Jqmkez/questions")
	# Display options when the scene is loaded
	display_options_level3()
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

func display_options_level3():
	await get_tree().create_timer(1.5).timeout
	var correct_option = ""
	var wrong_option1 = ""
	var wrong_option2 = ""
	if acidShooted:
		correct_option = baseArray[randi_range(0, baseArray.size() - 1)][0]
		wrong_option1 = acidArray[randi_range(0, acidArray.size() - 1)][0]
		wrong_option2 = acidArray[randi_range(0, acidArray.size() - 1)][0]
	else:
		correct_option = acidArray[randi_range(0, acidArray.size() - 1)][0]
		wrong_option1 = baseArray[randi_range(0, baseArray.size() - 1)][0]
		wrong_option2 = baseArray[randi_range(0, baseArray.size() - 1)][0]
	var options = [correct_option, wrong_option1, wrong_option2]
	options.shuffle()
	$hud/HBoxContainer/Option1.text = options[0]
	$hud/HBoxContainer/Option2.text = options[1]
	$hud/HBoxContainer/Option3.text = options[2]
	Global.correct_answer = correct_option

func update_score():
	if not player_dead:
		$hud/PanelContainer/HBoxContainer/ProgressBar.value+=10
		score += 1
		if (highscore<score):
			highscore = score
		if (score >= 15):
			victory = true
	$hud/PanelContainer/HBoxContainer/Score.text = "Score:" + str(score)
	
func update_lives(lives: int):
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
	# Update score and reset player_dead flag
	update_score()
	player_dead = false
	# Update the options every time the projectile is fired
	display_options_level3()
	
func gameover():
	paused = true
	$hud.game_over()
	
	# Set Game Over text depending on victory or not
	if victory:
		$hud/Control/GameOverScreen/VBoxContainer/GameOverText.text = "You Win!"
	else:
		$hud/Control/GameOverScreen/VBoxContainer/GameOverText.text = "Game Over"
		
	$hud/Control/VictoryAnims.show()

	# Hide buttons you don’t want to show on Game Over
	$hud/HBoxContainer/Option1.visible = false
	$hud/HBoxContainer/Option2.visible = false
	$hud/HBoxContainer/Option3.visible = false
	
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
	score = -1
	update_score()
	$hud/PanelContainer/HBoxContainer/ProgressBar.value=0
	$player_Lvl1.lives = 6
	update_lives(6)
	$player_Lvl1.set_position(Vector2(155, -300))
	$player_Lvl1.respawn_tween()
	$hud/HBoxContainer/Option1.visible = true
	$hud/HBoxContainer/Option2.visible = true
	$hud/HBoxContainer/Option3.visible = true
