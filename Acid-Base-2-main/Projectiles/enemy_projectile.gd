extends RigidBody2D

# --------- VARIABLES ---------- #
var positionA = Vector2(0, 0)
var positionC = Vector2(-400, -200)
var positionB = Vector2(-652, 44)
var t = 0.0
var duration = 5.0
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
	#http_request.request("https://retoolapi.dev/Jqmkez/questions")
	match Global.current_level:
		1, 2, 3:
			http_request.request("https://retoolapi.dev/Jqmkez/questions")
		4:
			http_request.request("https://retoolapi.dev/JgRl9e/reactions")
	projectile_sprite.material.set_shader_parameter("active", false)
	acidParticles.emitting = false
	baseParticles.emitting = false
	neutralParticles.emitting = false
	acidExplosion.disabled = true
	baseExplosion.disabled = true
	neutralExplosion.disabled = true
		
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()  # Create an instance of the JSON class
		var body_string = body.get_string_from_utf8()  # Convert PackedByteArray to String
		var parse_result = json.parse(body_string)
		if parse_result == OK:
			var data = json.get_data()
			if Global.current_level == 4:
				#handle_compound_reactions(data)  # Handle reactions from the new API
				shoot_compound()
			else:
				handle_acids_bases(data)  # Handle acids and bases for levels 1, 2, 3
		else:
			print("Error parsing JSON.")
	else:
		print("Request failed. Status code: ", response_code)

# Handles Level 4 compound reactions
#func handle_compound_reactions(data):
	#print("inside handle compound reactions")
	#for entry in data:
		#var formatted_compound = format_compound(entry["Reaction"])
		#compoundArray.append([formatted_compound, "Compound"])
		#individualCompoundArray.append([entry["Answer"], "Compound"])
		#Global.compoundArray.append([formatted_compound, "Compound"])
		#Global.individualCompoundArray.append([entry["Answer"], "Compound"])
	#shoot_compound()
	
# Existing function for Levels 1, 2, 3
func handle_acids_bases(data):
	for entry in data:
		var formatted_compound = format_compound(entry["Compound"])
		match entry["Type"]:
			"Acid":
				acidArray.append([formatted_compound, "Acid"])
			"Base":
				baseArray.append([formatted_compound, "Base"])
	match Global.current_level:
		1:
			shoot_acid()
		2:
			shoot_base()
		3:
			shoot_random_acid_base()

func format_compound(compound: String) -> String:
	var formatted = "[font_size=40]"
	for char in compound:
		if '0' <= char and char <= '9': 
			formatted += "[font_size=20]" + char + "[/font_size]"
		else:
			formatted += char
	formatted += "[/font_size]"
	return formatted

func shoot_acid():
	#print("shooting acids")
	# Randomly select an acid from acidArray
	if acidArray.size() > 0:
		#print("The acid array is", acidArray)
		Global.question_number += 1
		#print("The question number is:", Global.question_number)
		var selection = randi_range(0, acidArray.size() - 1)
		print(selection)
		add_to_group(acidArray[selection][1])  # Add it to the "Acid" group
		formula.text = "[center]" + acidArray[selection][0] + "[/center]"
		formula.set_custom_minimum_size(Vector2(100, 75))

func shoot_base():
	# Randomly select a base from baseArray
	if baseArray.size() > 0:
		Global.question_number += 1
		var selection = randi_range(0, baseArray.size() - 1)
		add_to_group(baseArray[selection][1])  # Add it to the "Base" group
		formula.text = "[center]" + baseArray[selection][0] + "[/center]"
		formula.set_custom_minimum_size(Vector2(100, 75))

func shoot_random_acid_base():
	# Randomly decide whether to shoot an acid or base
	if randi() % 2 == 0:
		Global.acidShooted = true
		Global.baseShooted = false
		shoot_acid()
	else:
		shoot_base()
		Global.acidShooted = false
		Global.baseShooted = true

func shoot_compound():
	print("Inside Shoot compound method")
	# Randomly select a compound from compoundArray
	if Global.compoundArray.size() > 0:
		#var selection = randi_range(0, compoundArray.size() - 2)
		#Global.reactionIndex = selection
		add_to_group(Global.compoundArray[Global.reactionIndex][1]) 
		print("The reaction index is", Global.reactionIndex)
		print("The question is", Global.compoundArray[Global.reactionIndex][0])
		formula.text = "[center]" + Global.compoundArray[Global.reactionIndex][0] + "[/center]"
		formula.set_custom_minimum_size(Vector2(750, 75))
		print("the question is prepared")

func _physics_process(delta):
	rotation = 0.00
	t += delta / duration
	var q0 = positionA.lerp(positionC, min(t, 1.0))
	var q1 = positionC.lerp(positionB, min(t, 1.0))
	self.position = q0.lerp(q1, min(t, 1.0))
	
	if (self.position == positionB):
		if not handled:
			handled = true
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
			$"..".projectile_finished.emit()
		formula.hide()
		disable()
		await get_tree().create_timer(0.5).timeout
		acidExplosion.disabled = true
		baseExplosion.disabled = true
		neutralExplosion.disabled = true
		await get_tree().create_timer(3).timeout
		queue_free()
	
func _on_explosion_body_entered(body):
	body.ouch()
	
func disable():
	projectile_sprite.hide()
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

func ouch():
	projectile_sprite.material.set_shader_parameter("active", true)
	set_physics_process(false)
	await get_tree().create_timer(0.1).timeout
	set_physics_process(true)
	queue_free()
