extends Node2D

# --------- VARIABLES ---------- #
signal projectile_finished
const enemyProjectileScn = preload("res://Projectiles/enemy_projectile.tscn")
@onready var enemy_sprite = $AnimatedSprite2D
@onready var formula = $FormulaLabel
@onready var attack_timer = $AttackTimer  # Replace with the actual path to your attack timer
@onready var attack_duration_timer = $AttackDurationTimer  # Replace with the actual path to your attack duration timer
var victory = false
var hit_animation_playing = false

# --------- FUNCTIONS ---------- #
func _physics_process(delta):
	enemy_animations()

func enemy_animations():
	if hit_animation_playing:
		# Do nothing while the hit animation is playing
		pass
	else:
		enemy_sprite.play("Idle")

func _on_attack_timer_timeout():
	if ($"..".paused == false):
		enemy_sprite.play("Hit")
		hit_animation_playing = true
		attack_duration_timer.start()
		attack()
	else: enemy_sprite.play("Idle")
	
func attack():
	var compound = enemyProjectileScn.instantiate()
	add_child(compound)

func _on_attack_duration_timer_timeout():
	enemy_sprite.play("Idle")
	hit_animation_playing = false
	attack_timer.start()  # Restart the attack timer for the next attack cycle


func _on_projectile_finished():
	$"..".projectile_finished.emit() # Replace with function body.
