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
## t=0 时的加速度 px/s²（曲线与 y 轴的交点）
@export var accel_start := 10.0
## 加速度的半衰期（秒）：每过这么久，加速度减半。越大 = 衰减越慢
@export var accel_half_life := 10.0
@export var spacing := 138.0          # 相邻障碍物的水平间距 px
@export var spawn_margin := 32.0      # 生成线在屏幕右缘外多少像素
@export var log_spawn := false         # 打开后在输出面板打印每次生成（默认关，避免刷屏）

var _elapsed := 0.0                   # 已经开始多久（秒）。READY/暂停时世界是暂停的，不会累计
var _to_next := 0.0                   # 距离下一个障碍物还有多少像素

func _ready() -> void:
	# 兜底：检查器里没指 curve 资源时，自己建一个默认的（参数可后期用 .tres 覆盖）
	if curve == null:
		curve = ObstacleCurve.new()
	speed = speed_start

## 加速度按指数衰减：a(t) = accel_start · 0.5^(t / accel_half_life)
## 性质：单调递减、恒大于 0、过 y 轴且交点 = accel_start。
## 因为速度是它的积分，所以速度有**自然上限**（最多再涨 accel_start·accel_half_life/ln2）。
func current_accel() -> float:
	if accel_half_life <= 0.0:
		return 0.0
	return accel_start * pow(0.5, _elapsed / accel_half_life)

func _physics_process(delta: float) -> void:
	_elapsed += delta
	# 用"每帧累加"而不是 speed_start + a*t：加速度随时间连续变化，速度保持连续、不会跳变
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
	if log_spawn:
		print("生成障碍物 @x=%.0f，场上 %d 个" % [ob.position.x, get_child_count()])
