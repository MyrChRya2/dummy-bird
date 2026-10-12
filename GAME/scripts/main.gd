# Main：把 GameState 的状态映射到 UI 面板显隐 + 集中处理暂停 + 世界的装载/卸载。
# 约定：
#   · 只有这里碰"面板显隐"和 get_tree().paused，其它地方只改 GameState.state；
#   · 世界（World）在**主菜单里根本不存在**——进 PLAYING 才实例化，回 MENU 就卸掉。
#     所以主菜单既不跑游戏也不占内存；RESTART 直接"卸了重建"，不用写世界重置。
extends Node2D

const WORLD_PATH := "res://scenes/playground.tscn"

@onready var _start_menu: Control = $UILayer/StartMenu
@onready var _pause_menu: Control = $UILayer/PauseMenu
@onready var _hud: Control = $UILayer/HUD
@onready var _failed_menu: Control = $UILayer/FailedManu
@onready var _settings_panel: Control = $UILayer/SettingsPanel

var _world: Node = null
var _world_wanted := false      # 世界"该不该存在"只由游戏流程决定，设置面板不影响它

func _ready() -> void:
	# Main 与 UI 层要在暂停时继续工作：否则收不到 Esc（暂停就再也解不开）、按钮也点不动。
	# ⚠️ 但 ALWAYS 会**向下传染**给 INHERIT 的子节点——所以世界必须显式设 PAUSABLE，
	#    否则整棵游戏树会跟着 Main 一起无视暂停（这个坑踩过，见 _load_world()）。
	process_mode = Node.PROCESS_MODE_ALWAYS
	$UILayer.process_mode = Node.PROCESS_MODE_ALWAYS

	GameState.state_changed.connect(_on_state_changed)
	GameState.restart_requested.connect(_on_restart_requested)

	if GameState.state == GameState.State.BOOT:
		GameState.state = GameState.State.MENU      # 启动后先进主菜单
	else:
		_apply(GameState.state)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):        # Esc：暂停 / 继续
		GameState.toggle_pause()

func _on_state_changed(_from: int, to: int) -> void:
	_apply(to)

func _on_restart_requested() -> void:
	_unload_world()                                  # 先卸掉，_apply 会重新建一个
	GameState.state = GameState.State.PLAYING

func _apply(state: int) -> void:
	_start_menu.visible = state == GameState.State.MENU
	_pause_menu.visible = state == GameState.State.PAUSED
	_failed_menu.visible = state == GameState.State.GAME_OVER
	_settings_panel.visible = state == GameState.State.SETTINGS
	_hud.visible = state == GameState.State.PLAYING \
			or state == GameState.State.PAUSED \
			or state == GameState.State.GAME_OVER

	# 世界的存亡只看"在不在游戏流程里"：主菜单/启动→不存在；进行中/暂停/失败→存在。
	# SETTINGS 是叠在画面上的浮层，打开或关闭都不该动世界（否则从暂停进设置会把画面弄没）。
	if state == GameState.State.MENU or state == GameState.State.BOOT:
		_world_wanted = false
	elif state != GameState.State.SETTINGS:
		_world_wanted = true

	if _world_wanted and _world == null:
		_load_world()
	elif not _world_wanted and _world != null:
		_unload_world()

	# 只有真正在玩的时候世界才跑
	get_tree().paused = state != GameState.State.PLAYING

func _load_world() -> void:
	# 用 load() 而不是 preload()：主菜单里连资源都不加载，进 PLAYING 才读
	var packed := load(WORLD_PATH) as PackedScene
	_world = packed.instantiate()
	_world.name = "World"
	_world.process_mode = Node.PROCESS_MODE_PAUSABLE   # 覆盖父节点的 ALWAYS，让暂停对它生效
	add_child(_world)
	move_child(_world, 0)                              # 画在 UI 底下

func _unload_world() -> void:
	if _world == null:
		return
	remove_child(_world)                               # 先摘出树，名字/物理立刻失效
	_world.queue_free()
	_world = null
