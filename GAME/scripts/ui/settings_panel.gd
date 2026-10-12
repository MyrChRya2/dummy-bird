# 设置面板（占位）：现在只有「返回」，显隐由 Main 按 GameState.state 决定。
# 以后往里加：音量（Master/Music/SFX）、全屏开关、返回；值存 user://settings.cfg
extends Control

@onready var _back_button: Button = $Buttons/BackButton

func _ready() -> void:
	_back_button.pressed.connect(GameState.close_settings)
