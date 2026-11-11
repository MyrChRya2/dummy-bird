# 失败菜单：把 GameState.last_fail_reason 显示成死因；按钮只管改 state
extends Control

@onready var _reason_label: Label = $ReasonLabel
@onready var _score_label: Label = $ScoreLabel
@onready var _best_label: Label = $BestLabel
@onready var _rank_label: Label = $RankLabel
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
		_refresh_score()

## 死因直接来自失败信号带上来的原因（以后加新死法只要在这里加一个分支）
func _refresh_reason() -> void:
	match GameState.last_fail_reason:
		GameState.FailReason.FELL_OUT:
			_reason_label.text = "FELL OUT"
		GameState.FailReason.HIT_OBSTACLE:
			_reason_label.text = "HIT OBSTACLE"
		_:
			_reason_label.text = ""

## 本局成绩 + 历史最高 + 排行榜 Top5（全部来自 GameState，本地存档）
func _refresh_score() -> void:
	_score_label.text = "本局  %.1fs" % GameState.last_score
	_best_label.text = "最高  %.1fs" % GameState.best_score
	var lines: PackedStringArray = []
	var n: int = mini(GameState.records.size(), 5)
	for i in range(n):
		var r: Dictionary = GameState.records[i]
		lines.append("%d.  %.1fs" % [i + 1, float(r.get("score", 0.0))])
	if lines.is_empty():
		lines.append("（暂无记录）")
	_rank_label.text = "\n".join(lines)

func _back_to_menu() -> void:
	GameState.state = GameState.State.MENU

func _on_restart_pressed() -> void:
	GameState.request_restart()

func _on_settings_pressed() -> void:
	GameState.open_settings()
