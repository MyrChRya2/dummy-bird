extends Node2D


const OBSTACLE := preload("res://scenes/obstacle/obstacle.tscn")

@export var curve: ObstacleCurve
var _n := 0

## 当前速度 px/s（只读语义：HUD / 调试件读它；想改请改下面的 @export 参数）
var speed := 100.0

@export var speed_start := 100.0:     # 起始速度 px/s
	set(v):
		speed_start = v
		speed = v                     # 拖滑块/改检查器时立刻生效（重开也从这个值开始）
@export var speed_accel := 1.0        # 第一阶段加速度 px/s²（0 = 恒定速度）
@export var accel_switch_speed := 400.0   # 速度达到这个值后改用第二阶段加速度（0 = 不切换）
@export var accel_after_switch := 5.0     # 第二阶段加速度 px/s²
@export var spacing := 138.0          # 相邻障碍物的水平间距 px
@export var spawn_margin := 32.0      # 生成线在屏幕右缘外多少像素

var _elapsed := 0.0                   # 已经开始多久（秒）。READY/暂停时世界是暂停的，不会累计
var _to_next := 0.0                   # 距离下一个障碍物还有多少像素

func _ready() -> void:
	# 兜底：检查器里没指 curve 资源时，自己建一个默认的（参数可后期用 .tres 覆盖）
	if curve == null:
		curve = ObstacleCurve.new()
	speed = speed_start

## 当前应该在用哪一档加速度
func current_accel() -> float:
	if accel_switch_speed > 0.0 and speed >= accel_switch_speed:
		return accel_after_switch
	return speed_accel

func _physics_process(delta: float) -> void:
	_elapsed += delta
	# 用"每帧累加"而不是 speed_start + a*t：这样加速度突变时速度是**连续的**（不会跳变）
	speed += current_accel() * delta
	GameState.obstacle_speed = speed          # 缓存给 HUD / 其它只读方
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
