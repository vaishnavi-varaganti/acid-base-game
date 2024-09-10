extends RigidBody2D

# --------- VARIABLES ---------- #
var positionA = Vector2(0, 0)
var positionC = Vector2(-400, -200)
var positionB = Vector2(-652, 44)
var t = 0.0
var duration = 3.0
@onready var handled = false
var acidArray = [
	["[font_size=30]HClO[font_size=15]4[/font_size][/font_size]", "Acid"],
	["[font_size=30]CO[font_size=15]2[/font_size]H[/font_size]", "Acid"],
	["[font_size=30]HNO[font_size=15]2[/font_size][/font_size]", "Acid"],
	["[font_size=30]CH[font_size=15]3[/font_size]COOH[/font_size]", "Acid"],
	["[font_size=30]HCN[/font_size]", "Acid"],
	["[font_size=30]HCl[/font_size]", "Acid"],
	["[font_size=30]HNO[font_size=15]3[/font_size][/font_size]", "Acid"],
	["[font_size=30]H[font_size=15]2[/font_size]O[/font_size]", "Acid"],
	["[font_size=30]H[font_size=15]2[/font_size]SO[font_size=15]4[/font_size][/font_size]", "Acid"],
	["[font_size=30]H[font_size=15]2[/font_size]CO[font_size=15]3[/font_size][/font_size]", "Acid"],
	["[font_size=30]H[font_size=15]3[/font_size]PO[font_size=15]4[/font_size][/font_size]", "Acid"]
				]
					
var baseArray = [
	["[font_size=30]BaCrO[font_size=15]4[/font_size][/font_size]", "Base"],
	["[font_size=30]MgC[font_size=15]2[/font_size]O[font_size=15]4[/font_size][/font_size]", "Base"],
	["[font_size=30]CaCO[font_size=15]3[/font_size][/font_size]", "Base"],
	["[font_size=30]Na[font_size=15]2[/font_size]S[/font_size]", "Base"],
	["[font_size=30]K[font_size=15]2[/font_size]SO[font_size=15]3[/font_size][/font_size]", "Base"],
	["[font_size=30]CH[font_size=15]3[/font_size]-NH[font_size=15]2[/font_size][/font_size]", "Base"],
	["[font_size=30]Mg(OH)[font_size=15]2[/font_size][/font_size]", "Base"],
	["[font_size=30]K[font_size=15]3[/font_size]PO[font_size=15]4[/font_size][/font_size]", "Base"],
	["[font_size=30]KNO[font_size=15]2[/font_size][/font_size]", "Base"],
	["[font_size=30]KMnO[font_size=15]4[/font_size][/font_size]", "Base"],
	["[font_size=30](Ca[font_size=15]3[/font_size])[font_size=15]2[/font_size][/font_size]", "Base"],
	["[font_size=30]H[font_size=15]2[/font_size]O[/font_size]", "Both"]
]

					
var combinedArray = [
	["[font_size=30]BaCrO[font_size=15]4[/font_size][/font_size]", "Base"],
	["[font_size=30]HClO[font_size=15]4[/font_size][/font_size]", "Acid"],
	["[font_size=30]CO[font_size=15]2[/font_size]H[/font_size]", "Acid"],
	["[font_size=30]HNO[font_size=15]2[/font_size][/font_size]", "Acid"],
	["[font_size=30]CH[font_size=15]3[/font_size]COOH[/font_size]", "Acid"],
	["[font_size=30]MgC[font_size=15]2[/font_size]O[font_size=10]4[/font_size][/font_size]", "Base"],
	["[font_size=30]HCN[/font_size]", "Acid"],
	["[font_size=30]CaCO[font_size=15]3[/font_size][/font_size]", "Base"],
	["[font_size=30]Na[font_size=15]2[/font_size]S[/font_size]", "Base"],
	["[font_size=30]K[font_size=15]2[/font_size]SO[font_size=15]3[/font_size][/font_size]", "Base"],
	["[font_size=30]CH[font_size=15]3[/font_size]-NH[font_size=15]2[/font_size][/font_size]", "Base"],
	["[font_size=30]Mg(OH)[font_size=15]2[/font_size][/font_size]", "Base"],
	["[font_size=30]HCl[/font_size]", "Acid"],
	["[font_size=30]HNO[font_size=15]3[/font_size][/font_size]", "Acid"],
	["[font_size=30]K[font_size=15]3[/font_size]PO[font_size=15]4[/font_size][/font_size]", "Base"],
	["[font_size=30]KNO[font_size=15]2[/font_size][/font_size]", "Base"],
	["[font_size=30]KMnO[font_size=15]4[/font_size][/font_size]", "Base"],
	["[font_size=30](Ca[font_size=15]3[/font_size])[font_size=15]2[/font_size][/font_size]", "Base"],
	["[font_size=30]H[font_size=15]2[/font_size]O[/font_size]", "Both"]
]

var compoundArray = [
	["[font_size=30]KNO[font_size=15]2[/font_size] (aq) + HClO[font_size=15]4[/font_size] (aq) →[/font_size]", "Compound"],
	["[font_size=30]KNO[font_size=15]3[/font_size] (aq) + HClO[font_size=15]4[/font_size] (aq) →[/font_size]", "Compound"],
	["[font_size=30]CH[font_size=15]3[/font_size]COOH (aq) + CaCO[font_size=15]3[/font_size] (s) → [/font_size]", "Compound"],
	["[font_size=30]HCN (aq) + Ca(OH)[font_size=15]2[/font_size] (aq) →[/font_size]", "Compound"],
	["[font_size=30]HCl (aq) + H[font_size=15]2[/font_size]O (l) →[/font_size]", "Compound"],
	["[font_size=30]HCN (aq) + H[font_size=15]2[/font_size]O (l) →[/font_size]", "Compound"],
	["[font_size=30]CaCO[font_size=15]3[/font_size] (s) + H[font_size=15]2[/font_size]O (l) →[/font_size]", "Compound"],
	["[font_size=30]HCl (aq) + Mg(OH)[font_size=15]2[/font_size] (aq) →[/font_size]", "Compound"],
	["[font_size=30]HNO[font_size=15]2[/font_size] (aq) + CaCO[font_size=15]3[/font_size] (s) →[/font_size]", "Compound"],
	["[font_size=30]Na[font_size=15]2[/font_size]CO[font_size=15]3[/font_size] (aq) + HCl (aq) →[/font_size]", "Compound"],
	["[font_size=30]ZnS (s) + HCl (aq) →[/font_size]", "Compound"],
	["[font_size=30]K[font_size=15]2[/font_size]SO[font_size=15]3[/font_size] (aq) + HI (aq) →[/font_size]", "Compound"],
	["[font_size=30]CH[font_size=15]3[/font_size]-NH[font_size=15]2[/font_size] + H[font_size=15]2[/font_size]O →[/font_size]", "Compound"],
	["[font_size=30]CH[font_size=15]3[/font_size]-NH[font_size=15]2[/font_size] + HCl →[/font_size]", "Compound"],
	["[font_size=30]CH[font_size=15]3[/font_size]-NH[font_size=15]3[/font_size][sup][font_size=15]+[/font_size][/sup] + H[font_size=10]2[/font_size]O →[/font_size]", "Compound"],
	["[font_size=30]KClO[font_size=15]4[/font_size] (aq) + HBr (aq) →[/font_size]", "Compound"],
	["[font_size=30]CH[font_size=15]3[/font_size]COOH (aq) + H[font_size=15]2[/font_size]O (l) →[/font_size]", "Compound"],
	["[font_size=30]Na[font_size=15]2[/font_size]SO[font_size=15]3[/font_size] (aq) + H[font_size=15]2[/font_size]O (l) →[/font_size]", "Compound"],
	["[font_size=30]HNO[font_size=15]3[/font_size] (aq) + KOH (aq) →[/font_size]", "Compound"],
	["[font_size=30]CH[font_size=15]3[/font_size]COOH (aq) + NaOH (aq) →[/font_size]", "Compound"],
	["[font_size=30]Ca(CN)[font_size=15]2[/font_size] (aq) + HBr (aq) →[/font_size]", "Compound"]
]


					#This list of chemical compounds can be expanded if need be.
					#To add more, simply create a string array of size 2, containing the compound itself,
					# as well as whether it is a  base, acid, neutral or both
					
@onready var formula = $FormulaLabel
@onready var projectile_sprite = $Sprite2D
@onready var projectile = self
@onready var acidExplosion = $Explosion/Acid
@onready var baseExplosion = $Explosion/Base
@onready var neutralExplosion = $Explosion/Neutral
@onready var acidParticles = $Explosion/AcidParticles
@onready var baseParticles = $Explosion/BaseParticles
@onready var neutralParticles = $Explosion/NeutralParticles


# --------- FUNCTIONS ---------- #
func _ready():
	projectile_sprite.material.set_shader_parameter("active", false)
	acidParticles.emitting = false
	baseParticles.emitting = false
	neutralParticles.emitting = false
	acidExplosion.disabled
	baseExplosion.disabled
	match Global.current_level:
		1:
			shoot_acid()
		2:
			shoot_base()
		3:
			shoot_random_acid_base()
		4:
			shoot_compound()

func shoot_acid():
	# Randomly select an acid from acidArray
	var selection = randi_range(0, acidArray.size() - 1)
	add_to_group(acidArray[selection][1])  # Add it to the "Acid" group
	formula.text = "[center]" + acidArray[selection][0] + "[/center]"
	formula.set_custom_minimum_size(Vector2(100, 75))
	
func shoot_base():
	# Randomly select a base from baseArray
	var selection = randi_range(0, baseArray.size() - 1)
	add_to_group(baseArray[selection][1])  # Add it to the "Base" group
	formula.text = "[center]" + baseArray[selection][0] + "[/center]"
	formula.set_custom_minimum_size(Vector2(100, 75))
	
func shoot_random_acid_base():
	# Randomly decide whether to shoot an acid or base
	if randi() % 2 == 0:
		shoot_acid()
	else:
		shoot_base()
		
func shoot_compound():
	# Randomly select a compound from compoundArray
	var selection = randi_range(0, compoundArray.size() - 1)
	add_to_group(compoundArray[selection][1])  # Add it to the "Compound" group
	formula.text = "[center]" + compoundArray[selection][0] + "[/center]"
	formula.set_custom_minimum_size(Vector2(750, 75))

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
				acidParticles.emitting=true
				await get_tree().create_timer(0.1).timeout
				acidExplosion.disabled=false
			
			if is_in_group("Base"):
				baseParticles.emitting=true
				await get_tree().create_timer(0.1).timeout
				baseExplosion.disabled=false
				#show_feedback("Base")
			
			if is_in_group("Compound"):
				neutralParticles.emitting = true
				await get_tree().create_timer(0.1).timeout
				neutralExplosion.disabled=false
			
			await get_tree().create_timer(0.5).timeout
			$"..".projectile_finished.emit()
		formula.hide()
		disable()
		await get_tree().create_timer(0.5).timeout
		acidExplosion.disabled=true
		baseExplosion.disabled=true
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
	
