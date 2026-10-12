extends Node

enum State { BOOT, MENU, PLAYING, PAUSED, GAME_OVER, SETTINGS }

signal state_changed(from: State, to: State)

var state: State = State.BOOT:
	set(v):
		if v == state: return
		var prev := state
		state = v
		state_changed.emit(prev, v)

## 障碍物当前速度（px/s）——由 spawner 每帧写入，HUD 每帧读。
## 这里只做"缓存 + 转发"，谁都可以读，但只有 spawner 负责算它。
var obstacle_speed: float = 0.0

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
	state = State.GAME_OVER
	failed.emit(reason)

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
