# HUD：每帧从 GameState 读缓存值，自己不做任何计算（速度由 spawner 写入 GameState）
extends Control

@onready var _speed_label: Label = $SpeedBox/SpeedLabel
@onready var _pause_button: Button = $PauseButton
@onready var _ready_hint: Label = $ReadyHint


func _ready() -> void:
	_pause_button.pressed.connect(GameState.toggle_pause)
	GameState.state_changed.connect(_on_state_changed)
	_on_state_changed(GameState.State.BOOT, GameState.state)   # 首帧按当前状态初始化


func _on_state_changed(_from: int, to: int) -> void:
	# 只有 READY 才提示"点击开始"（PLAYING 之后玩家显然已经知道要点了）
	_ready_hint.visible = to == GameState.State.READY


func _process(_delta: float) -> void:
	_speed_label.text = "速度 %.0f px/s" % GameState.obstacle_speed
