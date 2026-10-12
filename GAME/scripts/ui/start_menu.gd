# 开始菜单：按钮只改 GameState.state（UI 显隐交给 Main）；退出按钮仅桌面端显示
extends Control

@onready var _start_button: Button = $Buttons/StartButton
@onready var _settings_button: Button = $Buttons/SettingsButton
@onready var _quit_button: Button = $Buttons/QuitButton

func _ready() -> void:
	# Web(itch.io) 与移动端没有"退出应用"这回事：直接隐藏，桌面上才显示
	_quit_button.visible = OS.has_feature("pc")
	_start_button.pressed.connect(_on_start_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	GameState.state = GameState.State.PLAYING

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	GameState.open_settings()
