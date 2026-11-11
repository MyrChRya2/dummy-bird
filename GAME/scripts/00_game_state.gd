extends Node

enum State { BOOT, MENU, READY, PLAYING, PAUSED, GAME_OVER, SETTINGS, RANKING }

signal state_changed(from: State, to: State)

var state: State = State.BOOT:
	set(v):
		if v == state: return
		var prev := state
		state = v
		if v == State.READY:
			_reset_run()          # 每进一次 READY = 新一局开始，计时归零
		state_changed.emit(prev, v)

## 障碍物当前速度（px/s）——由 spawner 每帧写入，HUD 每帧读。
## 这里只做"缓存 + 转发"，谁都可以读，但只有 spawner 负责算它。
var obstacle_speed: float = 0.0

# ---------------- 分数（存活时间）----------------

## 本局已存活秒数。PLAYING 时每帧累加；READY 时归零；
## 暂停时世界整体 paused，Autoload 的 _process 也不会跑，所以天然不计时。
var elapsed: float = 0.0

## 上一局定格成绩（失败时写入），失败界面用它显示
var last_score: float = 0.0

## 历史最好成绩
var best_score: float = 0.0

## 排行榜：按分数降序，最多保留 KEEP_RECORDS 条
var records: Array = []

const RECORDS_PATH := "user://records.json"
const KEEP_RECORDS := 10

func _ready() -> void:
	_load_records()

func _process(delta: float) -> void:
	if state == State.PLAYING:
		elapsed += delta

## 当前分数 = 存活时间（秒）
func current_score() -> float:
	return elapsed

## 把秒数格式化成「分.秒.毫秒」，与排行榜占位 "00.00.00" 对齐。
## 例：12.3456 → "00.12.346"（毫秒位四舍五入）；83.05 → "01.23.050"
func format_time(seconds: float) -> String:
	# 第 1 步：秒 → 整毫秒（这里做四舍五入，0.4ms 舍、0.5ms 进）
	var total_ms: int = int(roundf(maxf(seconds, 0.0) * 1000.0))
	# 第 2 步：把整毫秒按 60/1000 进制**拆成三个字段**（不是丢弃精度）：
	#   83450ms → /60000 得 1 分（余 23450）→ /1000 得 23 秒（余 450）→ 450 毫秒
	# 余数由下一级接住，一个毫秒都不丢，所以这里的整数除法是语义正确的。
	@warning_ignore("integer_division")
	var m: int = total_ms / 60000
	@warning_ignore("integer_division")
	var s2: int = (total_ms % 60000) / 1000
	var ms: int = total_ms % 1000
	return "%02d.%02d.%03d" % [m, s2, ms]

func _reset_run() -> void:
	elapsed = 0.0

## 结算一局：定格成绩、更新最高分与排行榜、写盘
func _commit_run(reason: FailReason) -> void:
	last_score = elapsed
	if elapsed > best_score:
		best_score = elapsed
	records.append({
		"score": elapsed,
		"date": Time.get_datetime_string_from_system(false, false),
		"reason": fail_reason_name(reason),
	})
	records.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("score", 0.0)) > float(b.get("score", 0.0)))
	while records.size() > KEEP_RECORDS:
		records.pop_back()
	_save_records()

func fail_reason_name(reason: FailReason) -> String:
	match reason:
		FailReason.FELL_OUT:
			return "FELL_OUT"
		FailReason.HIT_OBSTACLE:
			return "HIT_OBSTACLE"
		_:
			return "NONE"

func _load_records() -> void:
	records.clear()
	best_score = 0.0
	if not FileAccess.file_exists(RECORDS_PATH):
		return
	var f := FileAccess.open(RECORDS_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var data: Variant = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		return
	best_score = float(data.get("best", 0.0))
	var raw: Variant = data.get("records", [])
	if typeof(raw) == TYPE_ARRAY:
		for item: Variant in raw:
			if typeof(item) == TYPE_DICTIONARY:
				records.append(item)

## 清空所有本地成绩：排行榜、最高分、上一局成绩，并把存档写成空
## （设置面板的「重置游戏」用它）
func clear_records() -> void:
	records.clear()
	best_score = 0.0
	last_score = 0.0
	_save_records()

func _save_records() -> void:
	var f := FileAccess.open(RECORDS_PATH, FileAccess.WRITE)
	if f == null:
		push_warning("无法写入成绩存档：%s" % RECORDS_PATH)
		return
	f.store_string(JSON.stringify({"best": best_score, "records": records}, "\t"))
	f.close()

# ---------------- 失败信号 ----------------

## 失败原因：以后加新死法就往这里加一项
enum FailReason { NONE, FELL_OUT, HIT_OBSTACLE }

## 唯一的"失败"出口：掉出世界、撞到障碍、以及以后的新死法都走它
signal failed(reason: FailReason)

var last_fail_reason: FailReason = FailReason.NONE

## 谁发现失败就调它（检测方只报告，不负责 UI / 暂停）。
## 幂等：只有 PLAYING 状态的第一次上报有效，之后重复上报会被忽略
func report_failure(reason: FailReason) -> void:
	if state != State.PLAYING:
		return
	last_fail_reason = reason
	_commit_run(reason)          # 先定格成绩并写盘，再切状态（此时 elapsed 才是本局最终值）
	state = State.GAME_OVER
	failed.emit(reason)

# ---------------- 开局准备（READY）----------------

## READY = 世界已装载但整体冻结（get_tree().paused = true）：鸟不动、障碍不生成、曲线不走。
## 玩家第一次点击/触摸时才真正开始。给玩家留出"看清楚局面"的准备时间。
func begin_play() -> void:
	if state != State.READY:
		return
	state = State.PLAYING

# ---------------- 暂停 ----------------

## 记住"暂停前是什么状态"，恢复时回到它，而不是硬编码回 PLAYING
var _state_before_pause: State = State.PLAYING

## Esc 呼出 / 收起暂停
func toggle_pause() -> void:
	if state == State.PLAYING:
		_state_before_pause = state
		state = State.PAUSED
	elif state == State.PAUSED:
		state = _state_before_pause

# ---------------- 重开 ----------------

## 请求"重开一局"：菜单按钮只发这个请求，具体怎么做（重建世界）由 Main 负责
signal restart_requested

func request_restart() -> void:
	restart_requested.emit()

# ---------------- 设置面板 ----------------

## 设置面板是"叠在"当前画面上的，所以记住"打开前是什么状态"，返回时回到它
var _state_before_settings: State = State.MENU

## 主菜单 / 暂停 / 失败界面里的 SETTINGS 按钮都调它
func open_settings() -> void:
	if state == State.SETTINGS:
		return
	_state_before_settings = state
	state = State.SETTINGS

func close_settings() -> void:
	if state != State.SETTINGS:
		return
	state = _state_before_settings

# ---------------- 排行榜面板 ----------------

## 排行榜是"叠在"当前画面上的独立界面（从主菜单进），与 SETTINGS 同一套模式：
## 记住打开前的状态，关闭时回到它。
var _state_before_ranking: State = State.MENU

func open_ranking() -> void:
	if state == State.RANKING:
		return
	_state_before_ranking = state
	state = State.RANKING

func close_ranking() -> void:
	if state != State.RANKING:
		return
	state = _state_before_ranking
