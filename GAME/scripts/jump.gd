class_name Jump extends Movement


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("flap"):
		player.velocity.y = -player.JUMP_VELOCITY
