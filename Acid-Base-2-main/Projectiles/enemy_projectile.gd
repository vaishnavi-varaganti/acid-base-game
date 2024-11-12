extends RigidBody2D

# --------- VARIABLES ---------- #
var positionA = Vector2(0, 0)
var positionC = Vector2(-400, -200)
var positionB = Vector2(-652, 44)
var t = 0.0
var duration = 15.0 
@onready var handled = false
var acidArray = []	
var baseArray = []
var compoundArray = []
var individualCompoundArray = []
@onready var http_request = $HTTPRequest
@onready var formula = $FormulaLabel
@onready var projectile_sprite = $Sprite2D
@onready var projectile = self
@onready var acidExplosion = $Explosion/Acid
@onready var baseExplosion = $Explosion/Base
@onready var neutralExplosion = $Explosion/Neutral
@onready var acidParticles = $Explosion/AcidParticles
@onready var baseParticles = $Explosion/BaseParticles
@onready var neutralParticles = $Explosion/NeutralParticles
@onready var reactionIndex = Global.reactionIndex

# --------- FUNCTIONS ---------- #
func _ready():
	# Fetch the data based on the level
	match Global.current_level:
		1, 2, 3:
			http_request.request("https://retoolapi.dev/tnFVDY/acidsbases")
		4:
			http_request.request("https://retoolapi.dev/JgRl9e/reactions")
	projectile_sprite.material.set_shader_parameter("active", false)
	acidParticles.emitting = false
	baseParticles.emitting = false
	neutralParticles.emitting = false
	acidExplosion.disabled = true
	baseExplosion.disabled = true
	neutralExplosion.disabled = true

	# Display the initial question when the projectile is about to start
	formula.show()  # Ensure the formula (question) is shown immediately
	_update_formula_visibility(true)  # Make the formula visible at the start of the shot


# This method handles hiding the formula after 15 seconds
func _update_formula_visibility(visible: bool):
	if visible:
		formula.show()
	else:
		formula.hide()

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()  # Create an instance of the JSON class
		var body_string = body.get_string_from_utf8()  # Convert PackedByteArray to String
		var parse_result = json.parse(body_string)
		if parse_result == OK:
			var data = json.get_data()
			if Global.current_level == 4:
				shoot_compound()  # Shoot compound for level 4
			else:
				handle_acids_bases(data)  # Handle acids and bases for levels 1, 2, and 3
		else:
			print("Error parsing JSON.")
	else:
		print("Request failed. Status code: ", response_code)

# Handles Levels 1, 2, 3 (Acids and Bases)
func handle_acids_bases(data):
	for entry in data:
		var formatted_compound = format_compound(entry["Compound"])
		match entry["Type"]:
			"Acid":
				Global.acidArray.append([entry["Compound"], "Acid"])
				acidArray.append([formatted_compound, "Acid"])
			"Base":
				Global.baseArray.append([entry["Compound"], "Base"])
				baseArray.append([formatted_compound, "Base"])
	match Global.current_level:
		1:
			shoot_acid()
		2:
			shoot_base()
		3:
			shoot_random_acid_base()

# Handles Level 4 (Compounds)
func shoot_compound():
	var index = get_node("/root/Global")
	index.set_reaction_index()
	print("Inside Shoot compound method")
	Global.question_number += 1
	# Randomly select a compound from compoundArray
	if Global.compoundArray.size() > 0:
		add_to_group(Global.compoundArray[Global.reactionIndex][1]) 
		print("The reaction index in enemy projectile is", Global.reactionIndex)
		print("The question is", Global.compoundArray[Global.reactionIndex][0])
		formula.text = "[center]" + Global.compoundArray[Global.reactionIndex][0] + "[/center]"
		formula.set_custom_minimum_size(Vector2(750, 75))
		print("the question is prepared")

# Formatting the formula text for acids, bases, and compounds
func format_compound(compound: String) -> String:
	var formatted = "[font_size=45]"
	for char in compound:
		if '0' <= char and char <= '9': 
			formatted += "[font_size=25]" + char + "[/font_size]"
		else:
			formatted += char
	formatted += "[/font_size]"
	return formatted

# Shoots acid for Level 1
func shoot_acid():
	if acidArray.size() > 0:
		Global.question_number += 1
		var selection = randi_range(0, acidArray.size() - 1)
		add_to_group(acidArray[selection][1])  # Add it to the "Acid" group
		formula.text = "[center]" + acidArray[selection][0] + "[/center]"
		formula.set_custom_minimum_size(Vector2(200, 75))

# Shoots base for Level 2
func shoot_base():
	if baseArray.size() > 0:
		Global.question_number += 1
		var selection = randi_range(0, baseArray.size() - 1)
		add_to_group(baseArray[selection][1])  # Add it to the "Base" group
		formula.text = "[center]" + baseArray[selection][0] + "[/center]"
		formula.set_custom_minimum_size(Vector2(200, 75))

# Shoots either acid or base for Level 3
func shoot_random_acid_base():
	if (Global.question_number % 2 ==0) :
		Global.acidShooted = true
		Global.baseShooted = false
		shoot_acid()
		print("acid shooted")
	elif (Global.question_number % 2 !=0):
		Global.acidShooted = false
		Global.baseShooted = true
		shoot_base()
		print("base shooted")

func _physics_process(delta):
	rotation = 0.00
	t += delta / duration  
	
	# Move the projectile between points A, C, and B
	var q0 = positionA.lerp(positionC, min(t, 1.0))
	var q1 = positionC.lerp(positionB, min(t, 1.0))
	self.position = q0.lerp(q1, min(t, 1.0))

	if self.position == positionB:  # When the projectile reaches the end position
		if not handled:
			handled = true  # Ensure this block is handled once
			if is_in_group("Acid"):
				acidParticles.emitting = true
				await get_tree().create_timer(0.1).timeout
				acidExplosion.disabled = false
			if is_in_group("Base"):
				baseParticles.emitting = true
				await get_tree().create_timer(0.1).timeout
				baseExplosion.disabled = false
			if is_in_group("Compound"):
				neutralParticles.emitting = true
				await get_tree().create_timer(0.1).timeout
				neutralExplosion.disabled = false
			
			await get_tree().create_timer(0.5).timeout
			_update_formula_visibility(false)  # Hide the formula after projectile reaches the end
			$"..".projectile_finished.emit()
		
		formula.hide()
		disable()
		await get_tree().create_timer(0.5).timeout
		acidExplosion.disabled = true
		baseExplosion.disabled = true
		neutralExplosion.disabled = true
		await get_tree().create_timer(3).timeout
		queue_free()

func disable():
	projectile_sprite.hide()
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

func ouch():
	projectile_sprite.material.set_shader_parameter("active", true)
	set_physics_process(false)
	await get_tree().create_timer(0.1).timeout
	set_physics_process(true)
	queue_free()
