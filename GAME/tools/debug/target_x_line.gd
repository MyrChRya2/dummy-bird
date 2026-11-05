# 调试用：在 x = target_x 处画一根垂线，用来标出"小鸟的横向目标位置"。
# 挂在 playground.tscn 根节点下即可（世界坐标＝屏幕坐标，因为没有摄像机）。
# 发布前随 tools/debug/ 一并删除。
extends Node2D

@export var target_x := 120.0                          # 竖线所在的 x
@export var color := Color(1.0, 0.25, 0.25, 0.35)      # 颜色（默认淡红半透明，不挡画面）
@export var width := 1.0                               # 线宽 px
@export var dashed := true                             # 虚线（false = 实线）
@export var dash_length := 4.0                         # 虚线的线段长度

func _ready() -> void:
	# 视口尺寸变了要重画（aspect=keep 时恒为 320x180，但保留这个保险）
	get_viewport().size_changed.connect(queue_redraw)
	queue_redraw()

func _draw() -> void:
	var h := get_viewport_rect().size.y
	var top := Vector2(target_x, 0.0)
	var bottom := Vector2(target_x, h)
	if dashed:
		draw_dashed_line(top, bottom, color, width, dash_length)
	else:
		draw_line(top, bottom, color, width)
