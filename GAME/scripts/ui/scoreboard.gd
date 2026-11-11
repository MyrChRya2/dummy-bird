# 排行榜界面：从 GameState.records 读本地成绩，填 Score1/2/3 与对应时间。
# 数据来源是 GameState 的本地存档（user://records.json），本脚本不碰存档读写。
extends Control

@onready var _scores: Array[Label] = [
	$HBoxContainer/Score1, $HBoxContainer/Score2, $HBoxContainer/Score3,
]
@onready var _times: Array[Label] = [
	$HBoxContainer/Score1/Time, $HBoxContainer/Score2/Time, $HBoxContainer/Score3/Time,
]
@onready var _back_button: Button = $Back
@onready var _global_button: Button = $ToGlobal


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)
	_global_button.pressed.connect(_on_global_pressed)
	GameState.state_changed.connect(_on_state_changed)
	refresh()


func _on_state_changed(_from: int, to: int) -> void:
	# 每次进入排行榜都重读一遍，避免显示上一轮的旧数据
	if to == GameState.State.RANKING:
		refresh()


## 按当前 GameState.records 重填前三名；不足三行显示占位
func refresh() -> void:
	for i in range(_scores.size()):
		if i < GameState.records.size():
			var r: Dictionary = GameState.records[i]
			_scores[i].text = GameState.format_time(float(r.get("score", 0.0)))
			_times[i].text = format_stamp(str(r.get("date", "")))
		else:
			_scores[i].text = "--.--.---"
			_times[i].text = ""


## "2026-11-11T20:37:12" → "20:37 11/11"（与场景占位的 "HH:MM MM/DD" 对齐）
func format_stamp(iso: String) -> String:
	if iso.length() < 16:
		return ""
	var time_part: String = iso.substr(11, 5)   # HH:MM
	var mm: String = iso.substr(5, 2)
	var dd: String = iso.substr(8, 2)
	return "%s %s/%s" % [time_part, mm, dd]


func _on_back_pressed() -> void:
	GameState.close_ranking()


## 全局榜：用户 2026-11-11「暂时只记录本地」+「挂起一个全局回放功能」→ 先占位
func _on_global_pressed() -> void:
	print("[scoreboard] 全局榜尚未实现（当前只记录本地成绩）")
