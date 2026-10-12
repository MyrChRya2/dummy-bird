# 失败菜单：把 GameState.last_fail_reason 显示成死因；按钮只管改 state
extends Control

@onready var _reason_label: Label = $ReasonLabel
@onready var _restart_button: Button = $Buttons/RestartButton
@onready var _settings_button: Button = $Buttons/SettingsButton
@onready var _back_button: Button = $Buttons/BackButton

func _ready() -> void:
	GameState.state_changed.connect(_on_state_changed)
	_restart_button.pressed.connect(_on_restart_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_back_button.pressed.connect(_back_to_menu)
	_refresh_reason()

func _on_state_changed(_from: int, to: int) -> void:
	if to == GameState.State.GAME_OVER:
		_refresh_reason()

## 死因直接来自失败信号带上来的原因（以后加新死法只要在这里加一个分支）
func _refresh_reason() -> void:
	match GameState.last_fail_reason:
		GameState.FailReason.FELL_OUT:
			_reason_label.text = "FELL OUT"
		GameState.FailReason.HIT_OBSTACLE:
			_reason_label.text = "HIT OBSTACLE"
		_:
			_reason_label.text = ""

func _back_to_menu() -> void:
	GameState.state = GameState.State.MENU

func _on_restart_pressed() -> void:
	GameState.request_restart()

func _on_settings_pressed() -> void:
	GameState.open_settings()
