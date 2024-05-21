extends RigidBody2D

# --------- VARIABLES ---------- #
var positionA = Vector2(0, 0)
var positionC = Vector2(-400, -200)
var positionB = Vector2(-652, 44)
var t = 0.0
var duration = 3.0
@onready var handled = false
var acidArray = [
					["[font_size=40]HClO4[/font_size]","Acid"],
					["[font_size=40]CO2H[/font_size]","Acid"],
					["[font_size=40]HNO2[/font_size]","Acid"],
					["[font_size=40]CH3COOH[/font_size]","Acid"],
					["[font_size=40]HCN[/font_size]","Acid"],
					["[font_size=40]HCl[/font_size]","Acid"],
					["[font_size=40]HNO3[/font_size]","Acid"],
					["[font_size=40]H2O[/font_size]","Acid"],
					["[font_size=40]H2SO4[/font_size]","Acid"],
					["[font_size=40]H2CO3[/font_size]","Acid"],
					["[font_size=40]H3PO4[/font_size]","Acid"]
				]
					
var baseArray = [
					["[font_size=40]BaCrO4[/font_size]","Base"],
					["[font_size=40]MgC2O4[/font_size]","Base"],
					["[font_size=40]CaCO3[/font_size]","Base"],
					["[font_size=40]Na2[/font_size]S","Base"],
					["[font_size=40]K2SO3[/font_size]","Base"],
					["[font_size=40]CH3-NH2[/font_size]","Base"],
					["[font_size=40]Mg(OH)2[/font_size]","Base"],
					["[font_size=40]K3PO4[/font_size]","Base"],
					["[font_size=40]KNO2[/font_size]","Base"],
					["[font_size=40]KMnO4[/font_size]","Base"],
					["[font_size=40](Ca3)2[/font_size]","Base"],
					["[font_size=40]H2O[/font_size]","Both"]
					]
					
var combinedArray = [
					["[font_size=40]BaCrO4[/font_size]","Base"],
					["[font_size=40]HClO4[/font_size]","Acid"],
					["[font_size=40]CO2H[/font_size]","Acid"],
					["[font_size=40]HNO2[/font_size]","Acid"],
					["[font_size=40]CH3COOH[/font_size]","Acid"],
					["[font_size=40]MgC2O4[/font_size]","Base"],
					["[font_size=40]HCN[/font_size]","Acid"],
					["[font_size=40]CaCO3[/font_size]","Base"],
					["[font_size=40]Na2[/font_size]S","Base"],
					["[font_size=40]K2SO3[/font_size]","Base"],
					["[font_size=40]CH3-NH2[/font_size]","Base"],
					["[font_size=40]Mg(OH)2[/font_size]","Base"],
					["[font_size=40]HCl[/font_size]","Acid"],
					["[font_size=40]HNO3[/font_size]","Acid"],
					["[font_size=40]K3PO4[/font_size]","Base"],
					["[font_size=40]KNO2[/font_size]","Base"],
					["[font_size=40]KMnO4[/font_size]","Base"],
					["[font_size=40](Ca3)2[/font_size]","Base"],
					["[font_size=40]H2O[/font_size]","Both"]
					]
var compoundArray = [
					["[font_size=40]KNO2 (aq) + HClO4 (aq) →[/font_size]"],
					["[font_size=40]KNO3 (aq) + HClO4 (aq) →[/font_size]"],
					["[font_size=40]CH3COOH (aq) + CaCO3 (s) → [/font_size]"],
					["[font_size=40]HCN (aq) + Ca(OH)2 (aq) →[/font_size]"],
					["[font_size=40]HCl (aq) + H2O (l) →[/font_size]"],
					["[font_size=40]HCN (aq) + H2O (l) →[/font_size]"],
					["[font_size=40]CaCO3 (s) + H2O (l) →[/font_size]"],
					["[font_size=40]HCl (aq) + Mg(OH)2 (aq) →[/font_size]"],
					["[font_size=40]HNO2 (aq) + CaCO3 (s) →[/font_size]"],
					["[font_size=40]Na2CO3 (aq) + HCl (aq) →[/font_size]"],
					["[font_size=40]ZnS (s) + HCl (aq) →[/font_size]"],
					["[font_size=40]K2SO3(aq) + HI (aq) →[/font_size]"],
					["[font_size=40]CH3-NH2 + H2O →[/font_size]"],
					["[font_size=40]CH3-NH2 + HCl →[/font_size]"],
					["[font_size=40]CH3-NH3+ + H2O →[/font_size]"],
					["[font_size=40]KClO4 (aq) + HBr (aq) →[/font_size]"],
					["[font_size=40]CH3COOH (aq) + H2O (l) →[/font_size]"],
					["[font_size=40]Na2SO3 (aq) + H2O (l) →[/font_size]"],
					["[font_size=40]HNO3 (aq) + KOH (aq) →[/font_size]"],
					["[font_size=40]CH3COOH (aq) + NaOH (aq) →[/font_size]"],
					["[font_size=40]Ca(CN)2 (aq) + HBr (aq) →[/font_size]"]
					]
					#This list of chemical compounds can be expanded if need be.
					#To add more, simply create a string array of size 2, containing the compound itself,
					# as well as whether it is a  base, acid, neutral or both
					
@onready var formula = $FormulaLabel
@onready var projectile_sprite = $Sprite2D
@onready var projectile = self
@onready var acidExplosion = $Explosion/Acid
@onready var baseExplosion = $Explosion/Base
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
	var selection = randi_range(0, acidArray.size() - 1)
	add_to_group(acidArray[selection][1])
	formula.text = "[center]" + acidArray[selection][0] + "[/center]"
	
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
			
			if is_in_group("Both"):
				neutralParticles.emitting=true
				#show_feedback("Neutral")
			
			if is_in_group("Neutral"):
				neutralParticles.emitting=true
				#show_feedback("Neutral")
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
	
