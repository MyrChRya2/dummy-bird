# 排行榜界面：从 GameState.records 读本地成绩，填 Score1/2/3 与对应时间。
# 数据来源是 GameState 的本地存档（user://records.json），本脚本不碰存档读写。
extends Control

@onready var _rows: VBoxContainer = $Rows
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


## 按当前 GameState.records **动态重建**行：有几条记录就生成几行（不再固定 3 行）。
## 容器高度按最多 10 条（KEEP_RECORDS）预留，超出的记录本就不会被存档。
func refresh() -> void:
	for child in _rows.get_children():
		_rows.remove_child(child)     # 先摘出树，避免同帧内多次 refresh 时旧行还挂着
		child.queue_free()
	if GameState.records.is_empty():
		_rows.add_child(_make_row("--.--.---", ""))
		return
	for i in range(GameState.records.size()):
		var r: Dictionary = GameState.records[i]
		_rows.add_child(_make_row(
			GameState.format_time(float(r.get("score", 0.0))),
			format_stamp(str(r.get("date", "")))
		))


## 一行 = 左分数 + 右时间
func _make_row(score_text: String, time_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 10)
	var score_label := Label.new()
	score_label.text = score_text
	score_label.add_theme_font_size_override("font_size", 6)
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(score_label)
	var time_label := Label.new()
	time_label.text = time_text
	time_label.add_theme_font_size_override("font_size", 6)
	time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(time_label)
	return row


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
