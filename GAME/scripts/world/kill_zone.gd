# 掉出世界检测（挂在 playground.tscn 的 KillZone / Area2D 上）
# 只负责"报告失败"，不碰 UI、不碰 get_tree().paused —— 那是 Main 的活
extends Area2D

## 触发线保持在"当前视口底部下方多少像素"
@export var margin_below_view := 24.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_refresh_y()
	get_viewport().size_changed.connect(_refresh_y)   # expand 拉伸下视口尺寸会变（横屏/竖屏不同）

## 视口高度是运行时才知道的（expand 模式会随窗口比例变化），所以不能写死 y
func _refresh_y() -> void:
	position.y = get_viewport_rect().size.y + margin_below_view

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		GameState.report_failure(GameState.FailReason.FELL_OUT)
