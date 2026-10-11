extends Node2D


const OBSTACLE := preload("res://DEV/test_scenes/obstacle.tscn")

@export var curve: ObstacleCurve
var _n := 0

@export var speed := 129.0           # 障碍物左移速度 px/s（2026-10-11 游戏内调参后定稿）
@export var spacing := 138.0         # 相邻障碍物的水平间距 px
@export var spawn_margin := 32.0     # 生成线在屏幕右缘外多少像素

var _to_next := 0.0                  # 距离下一个障碍物还有多少像素

func _ready() -> void:
	# 兜底：检查器里没指 curve 资源时，自己建一个默认的（参数可后期用 .tres 覆盖）
	if curve == null:
		curve = ObstacleCurve.new()

func _physics_process(delta: float) -> void:
	_to_next -= speed * delta
	while _to_next <= 0.0:
		_spawn()
		_to_next += spacing

func _spawn() -> void:
	var ob := OBSTACLE.instantiate()
	ob.speed = speed                                    # 把速度传给它
	ob.position = Vector2(get_viewport_rect().size.x + spawn_margin, curve.y_at(_n))
	add_child(ob)
	_n += 1
	print("生成障碍物 @x=%.0f，场上 %d 个" % [ob.position.x, get_child_count()])
