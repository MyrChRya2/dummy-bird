class_name Player extends CharacterBody2D

@onready var animate: AnimatedSprite2D = $PlayerAnim

const GRAVITY := 980.0            # px/s²，与 project.godot 默认一致
@export var g_rate: float = 0.5
const MAX_FALL_SPEED := 1200.0    # 终端速度，防穿墙/手感

const JUMP_VELOCITY: float = 100

# Player.gd
func _ready() -> void:
	animate.play("default")

	
func _physics_process(delta: float) -> void:
	velocity.y += current_y_vlocity() * delta            # v += g·Δt
	velocity.y = minf(velocity.y, MAX_FALL_SPEED)
	move_and_slide()
	
	#handle_animate()
	
	
func current_y_vlocity() -> float:
	return GRAVITY * g_rate


#func handle_animate() -> void:
	
