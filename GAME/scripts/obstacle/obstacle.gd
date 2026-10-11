extends Node2D

@export var speed := 80.0
@export var kill_margin := 32.0

func _physics_process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < -kill_margin:
		queue_free()
