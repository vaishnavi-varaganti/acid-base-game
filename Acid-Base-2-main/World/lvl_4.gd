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
# --------- FUNCTIONS ---------- #

func _ready():
	$hud/PanelContainer/HBoxContainer/Level.text = "LEVEL - " + str(Global.current_level)
	
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
	update_score()
	player_dead = false
	
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
