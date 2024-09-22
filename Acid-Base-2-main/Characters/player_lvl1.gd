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
var duration = 0.75
var dodging = false
var returning = false

# --------- FUNCTIONS ---------- #
func _physics_process(_delta):
	movement(_delta)
	
	# Handle jumping logic after question
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		anim.play("Jump")
		jump()
	
	# Fall logic when in the air
	elif !is_on_floor() and anim.animation != "Jump" and not dodging and not returning:
		anim.play("Fall")
		
	elif is_on_floor() and anim.animation == "Fall":
		anim.play("Idle") 
	
	# Dodging and returning logic remains
	if dodging:
		t += _delta / duration
		var q0 = positionA.lerp(positionC, min(t, 1.0))
		var q1 = positionC.lerp(positionB, min(t, 1.0))
		self.position = q0.lerp(q1, min(t, 1.0))
		anim.flip_h = true
		if self.position.distance_to(positionB) < 0.01:
			anim.play("Wall_Cling")
			await get_tree().create_timer(0.5).timeout
			t = 0.0
			anim.flip_h = false
			dodging = false
			returning = true
			
	elif returning:
		anim.play("Dodge")
		t += _delta / duration
		var q0 = positionB.lerp(positionC, min(t, 1.0))
		var q1 = positionC.lerp(positionA, min(t, 1.0))
		self.position = q0.lerp(q1, min(t, 1.0))
		if self.position.distance_to(positionA) < 0.01:
			anim.play("Idle")
			returning = false
			positionA = self.position
			t = 0.0

# Handles animations to ensure no overwriting ongoing animations
func _on_AnimatedSprite_animation_finished(): 
	if anim.animation == "Jump" and !is_on_floor():
		anim.play("Fall")
		return # Skip the rest of the function to avoid playing "Idle" during jumps
		 
	elif anim.animation == "Dodge" and is_on_floor():
		anim.play("Idle")
		return
		
	elif anim.animation == "Wall_Cling":
		anim.play("Wall_Cling")
	
	elif anim.animation == "Fall" and !is_on_floor():
		anim.play("Fall") # Keep falling until player hits the ground
	
	else:
		anim.play("Idle")
		
func movement(delta):
	
	if not is_on_floor():# Simple Gravity Calculation
		velocity.y += gravity * delta
	
	# Allow player to move
	var inputAxis = Input.get_axis("Left", "Right")
	velocity = Vector2(inputAxis * move_speed, velocity.y)
	move_and_slide()

func jump():# Player jump function
	if is_on_floor():
		jump_tween()
	velocity.y = -jump_force

func flip_player(): # Flips sprite for dodging and wall-clinging
	if velocity.x < 0:
		anim.flip_h = true
	elif velocity.x > 0:
		anim.flip_h = false

func death_tween(): # Updates lives upon death, uses tween to shrink the character
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

func respawn_tween(): # Respawns the player, resizing back to full size
	anim.material.set_shader_parameter("active", false)
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 
	
func jump_tween(): # Stretches out the player when jumping, making it look realistic
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.65, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func ouch(): # When hit, inverts colors, freezes the game, and kills the player
	anim.material.set_shader_parameter("active", true)
	set_physics_process(false)
	await get_tree().create_timer(0.1).timeout
	death_tween()
	set_physics_process(true)
