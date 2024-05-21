extends ParallaxBackground
# --------- FUNCTIONS ---------- #
func _physics_process(delta):
	scroll_offset.x += int(60 * delta)
