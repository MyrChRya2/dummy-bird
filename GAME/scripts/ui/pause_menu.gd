# 暂停菜单：按钮只管改 GameState.state，UI 显隐交给 Main
extends Control

@onready var _continue_button: Button = $Buttons/ContinueButton
@onready var _restart_button: Button = $Buttons/RestartButton
@onready var _settings_button: Button = $Buttons/SettingsButton
@onready var _back_button: Button = $Buttons/BackButton

func _ready() -> void:
	_continue_button.pressed.connect(GameState.toggle_pause)          # 回到暂停前的状态
	_back_button.pressed.connect(_back_to_menu)
	_restart_button.pressed.connect(_on_restart_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)

func _back_to_menu() -> void:
	GameState.state = GameState.State.MENU

func _on_restart_pressed() -> void:
	GameState.request_restart()

func _on_settings_pressed() -> void:
	GameState.open_settings()
