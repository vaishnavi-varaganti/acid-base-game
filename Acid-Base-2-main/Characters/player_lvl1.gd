extends CharacterBody2D

# --------- VARIABLES ---------- #
@export_category("Player Properties")
@export var move_speed : float = 320
@export var jump_force : float = 600
@export var gravity : float = 1000
@onready var anim = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var inverse = anim.get_canvas_item()
@onready var fullHeart = preload("res://healthFull.png")
@onready var halfHeart = preload("res://healthHalf.png")
@export var lives = 6  # This is updated by lvl1.gd
var positionA = Vector2(175, 600)
var positionB = Vector2(20, 400)
var positionC = Vector2(100, 300)
var t = 0.0
var duration = 15.0
var dodging = false
var returning = false

# Timer to manage animation duration
var animation_timer := Timer.new()

# --------- FUNCTIONS ---------- #
func _ready():
	add_child(animation_timer)
	animation_timer.connect("timeout", _on_animation_timeout)

func _physics_process(_delta):
	movement(_delta)

	# Handle jumping logic after question
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		pass

	# Fall logic when in the air
	elif !is_on_floor() and anim.animation != "Jump" and not dodging and not returning:
		pass

	elif is_on_floor() and anim.animation == "Fall":
		anim.play("Idle") 

# Handles animations to ensure no overwriting ongoing animations
func _on_AnimatedSprite_animation_finished():
	if anim.animation == "Dodge" or anim.animation == "Hit":  # Replace with "Hit" if using a different hit animation
		anim.play("Idle")  # Return to Idle after the dodge or hit animation

func movement(delta):
	if not is_on_floor():  # Simple Gravity Calculation
		velocity.y += gravity * delta

	# Allow player to move
	var inputAxis = Input.get_axis("Left", "Right")
	velocity = Vector2(inputAxis * move_speed, velocity.y)
	move_and_slide()

func jump():  # Player jump function
	if is_on_floor():
		jump_tween()
	velocity.y = -jump_force

func flip_player():  # Flips sprite for dodging and wall-clinging
	if velocity.x < 0:
		anim.flip_h = true
	elif velocity.x > 0:
		anim.flip_h = false

func death_tween():  # Updates lives upon death, uses tween to shrink the character
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	set_position(Vector2(0, 0))
	$"..".player_dead = true
	await get_tree().create_timer(3).timeout
	velocity.y = 0
	set_position(Vector2(155, 0))
	if lives > 0:
		respawn_tween()

func respawn_tween():  # Respawns the player, resizing back to full size
	anim.material.set_shader_parameter("active", false)
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 

func jump_tween():  # Stretches out the player when jumping, making it look realistic
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.65, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func ouch():  # Plays the dodge animation in the air, then transitions to idle
	velocity.y = -400  
	anim.play("Dodge")
	anim.material.set_shader_parameter("active", false) 
	animation_timer.start(4) 

func _on_animation_timeout():
	velocity.y = 0 
	anim.play("Idle") 
