extends CharacterBody2D

# --------- VARIABLES ---------- #
@export_category("Player Properties")
@export var move_speed : float = 320
@export var jump_force : float = 600
@export var gravity : float = 1000
@onready var attack_animation_duration_timer = $AttackAnimationDurationTimer
@onready var anim = $AnimatedSprite2D
@onready var spawn_point = %SpawnPoint
@onready var particle_trails = $ParticleTrails
@onready var death_particles = $DeathParticles
@onready var sword = $SwordHurtbox/Box
@onready var inverse = anim.get_canvas_item()
@onready var fullHeart = preload("res://healthFull.png")
@onready var halfHeart = preload("res://healthHalf.png")
@export var lives = 6
var positionA = Vector2(175, 600)
var positionB = Vector2(20, 400)
var positionC = Vector2(100, 300)
var t = 0.0
var duration = 0.75
var dodging = false
var returning = false
var attacking = false
var player_attacks = [
	'Attack_1',
	'Attack_2',
	'Attack_3'
]

# --------- FUNCTIONS ---------- #
func _physics_process(_delta):
	movement(_delta)
	if Input.is_action_just_pressed("Attack") and is_on_floor():
		if not attacking:
			attacking = true
			anim.play(player_attacks[randi()%3])
			await get_tree().create_timer(0.6).timeout
			sword.disabled=false
			return
			
	elif Input.is_action_just_pressed("Dodge") and is_on_floor() and not attacking and lives > 1:
		positionA = self.position
		dodging = true
		anim.play("Dodge")
		lives -= 1
		$"..".update_lives(lives)
		pass
		
	elif is_on_floor() and anim.animation == "Fall":
		anim.play("Idle") 
		
	elif !is_on_floor() and anim.animation != "Jump" and not dodging and not returning:
		anim.play("Fall")
		
	elif Input.is_action_just_pressed("Jump") and is_on_floor() and not attacking:
		anim.play("Jump")
		jump()
		attacking = false
		
	if dodging:
		t += _delta / duration
		var q0 = positionA.lerp(positionC, min(t, 1.0))
		var q1 = positionC.lerp(positionB, min(t, 1.0))
		self.position = q0.lerp(q1, min(t, 1.0))
		anim.flip_h = true
		if self.position.distance_to(positionB)<0.01:
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
		if self.position.distance_to(positionA)<0.01:
			anim.play("Idle")
			returning = false
			positionA = self.position
			t=0.0
			
#Handles animations to ensure no animations overwrite an ongoing one unless its supposed to
func _on_AnimatedSprite_animation_finished(): 
	if anim.animation in player_attacks: #if attack 1, 2, or 3 finishes playing, it disables the sword's hitbox
		attacking = false
		sword.disabled=true
		anim.play("Idle")
		
	elif anim.animation == "Jump" and !is_on_floor():
		anim.play("Fall")
		return # Skip the rest of the function to avoid playing "Idle" during jumps
		 
	elif anim.animation == "Dodge" and is_on_floor():
		anim.play("Idle")
		return
		
	elif anim.animation == "Dodge":
		anim.play("Dodge")
		
	elif returning:
		anim.play("Dodge")
	
	elif anim.animation == "Wall_Cling":
		anim.play("Wall_Cling")
	
	elif anim.animation == "Fall" and !is_on_floor():
		anim.play("Fall") # keep falling until player hits the ground
	
	elif anim.animation == "Walk" and Input.is_action_pressed("Right") or Input.is_action_pressed("Left"):
		pass # keep playing the animation while moving
	
	else:
		anim.play("Idle")
		
func movement(delta):
	
	if not is_on_floor():# Simple Gravity Calculation
		velocity.y += gravity * delta
	
	if not attacking: # lets player move if they are not attacking
		var inputAxis = Input.get_axis("Left", "Right")
		velocity = Vector2(inputAxis * move_speed, velocity.y)
		move_and_slide()


func jump():# Player jump function
	if is_on_floor():
		jump_tween()
	velocity.y = -jump_force
	
func flip_player(): # flips sprite for player around for dodging and wall-clinging
	if velocity.x < 0 and not attacking: 
		anim.flip_h = true
	elif velocity.x > 0 and not attacking:
		anim.flip_h = false

func death_tween(): # updates lives upon death, and uses tween, or in-betweening,
					# shrinking them to make the character seemingly disappear upon death
	var tween = create_tween()
	lives -= 2
	$"..".update_lives(lives)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	await tween.finished
	set_position(Vector2(0, 0))
	$"..".player_dead = true
	await get_tree().create_timer(3).timeout
	velocity.y = 0
	set_position(Vector2(155, 0))
	if lives > 0:
		respawn_tween()

func respawn_tween(): # respawns the player, resizing them back to full size
	anim.material.set_shader_parameter("active", false)
	var tween = create_tween()
	tween.stop(); tween.play()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15) 
	
func jump_tween(): # stretches out the player when jumping, making the jump look realistic
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.65, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)

func _on_sword_hurtbox_body_entered(body): #Lets the sword's hitbox stop bases
	if body.is_in_group("Base"):
		body.ouch()
		$"..".projectile_finished.emit()
		
func ouch(): # when hit, inverts colors of player, freezes the game, and kills the player character
	anim.material.set_shader_parameter("active", true)
	set_physics_process(false)
	await get_tree().create_timer(0.1).timeout
	death_tween()
	set_physics_process(true)
