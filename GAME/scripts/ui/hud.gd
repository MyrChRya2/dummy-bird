# HUD：每帧从 GameState 读缓存值，自己不做任何计算（速度由 spawner 写入 GameState）
extends Control

@onready var _speed_label: Label = $SpeedBox/SpeedLabel
@onready var _pause_button: Button = $PauseButton


func _ready() -> void:
	_pause_button.pressed.connect(GameState.toggle_pause)
	
	
func _process(_delta: float) -> void:
	_speed_label.text = "速度 %.0f px/s" % GameState.obstacle_speed
