# 设置面板（占位）：现在只有「返回」，显隐由 Main 按 GameState.state 决定。
# 以后往里加：音量（Master/Music/SFX）、全屏开关、返回；值存 user://settings.cfg
extends Control

@onready var _back_button: Button = $Buttons/BackButton
@onready var _reset_button: Button = $Buttons/ResetButton

## 重置是破坏性操作：第一次点只"上膛"，再点一次才真清空；
## 离开设置面板会取消上膛（见 _on_state_changed）
var _reset_armed := false

func _ready() -> void:
	_back_button.pressed.connect(GameState.close_settings)
	_reset_button.pressed.connect(_on_reset_pressed)
	GameState.state_changed.connect(_on_state_changed)

func _on_reset_pressed() -> void:
	if not _reset_armed:
		_reset_armed = true
		_reset_button.text = "CONFIRM?"
		return
	GameState.clear_records()
	_disarm_reset()
	print("[settings] 本地成绩已清空")

func _disarm_reset() -> void:
	_reset_armed = false
	_reset_button.text = "RESET DATA"

func _on_state_changed(_from: int, to: int) -> void:
	if to != GameState.State.SETTINGS:
		_disarm_reset()
