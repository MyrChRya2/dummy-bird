# 调试可视化：把 ObstacleCurve 画成"打点计时器"式的点带
#   每隔 dot_step_px 像素打一个点，整条点带跟着障碍物一起左移 —— 看起来就是函数本身在往左走
# 用法：在 ObstacleSpawner 下面加一个 Node2D，挂上这个脚本（父节点必须是 ObstacleSpawner）
# 说明：只读父节点的 curve / spacing / _n / _to_next / spawn_margin，不修改任何游戏逻辑
extends Node2D

@export_group("点带")
@export var dot_step_px := 4.0                      # 相邻两个点的水平距离（越小点越密）
@export var dot_radius := 1.5
@export var dot_color := Color(1.0, 0.45, 0.35, 0.95)
@export var fade_with_x := true                     # 越靠左越淡，看起来像拖出来的轨迹

@export_group("真实采样点（障碍物实际会用到的位置）")
@export var show_samples := true
@export var sample_radius := 4.0
@export var sample_color := Color(1.0, 0.85, 0.2, 1.0)

@export_group("折线（可选，关掉就只剩点）")
@export var show_polyline := false                  # 注意：不能叫 draw_line，会和 CanvasItem.draw_line() 撞名
@export var line_color := Color(1.0, 1.0, 1.0, 0.25)
@export var line_width := 1.0

@export_group("X 轴")
@export var show_axis := true                       # 画出横轴 + 刻度 + 序号标签
@export var axis_y := 172.0                         # 轴线的 y（世界坐标；默认贴屏幕下沿）
@export var axis_color := Color(0.55, 0.8, 1.0, 0.9)
@export var minor_step_u := 0.25                    # 小刻度间距（单位：曲线坐标 = 个障碍物）
@export var major_step_u := 1.0                     # 大刻度 + 数字标签
@export var minor_len := 3.0
@export var major_len := 7.0
@export var label_size := 8
@export var label_offset := 11.0
@export var label_color := Color(0.65, 0.85, 1.0, 0.95)

var _spawner: Node2D = null
var _curve: Resource = null
var _warned := false

func _ready() -> void:
	_spawner = get_parent() as Node2D

## 懒解析：宿主和它的 curve 可能在我们的 _ready() 之后才就绪（节点加入顺序 / 延迟 ready），
## 所以这里每次用到时再取一次，取到就缓存，取不到就报一次警告并跳过这一帧。
func _ensure() -> bool:
	if _spawner == null or not is_instance_valid(_spawner):
		_spawner = get_parent() as Node2D
	if _spawner == null:
		return false
	if _curve == null:
		_curve = _spawner.get("curve")
	if _curve == null:
		if not _warned:
			_warned = true
			push_warning("CurvePreview：父节点不是 ObstacleSpawner，或它的 curve 还是空的 —— 已跳过绘制")
		return false
	return true

func _physics_process(_delta: float) -> void:
	queue_redraw()                                  # 跟障碍物同频重画

## 当前"曲线坐标 0"所在的 x；整条点带就是靠它随时间减小而左移
func phase() -> float:
	var spacing: float = _spawner.get("spacing")
	var spawn_x: float = get_viewport_rect().size.x + float(_spawner.get("spawn_margin"))
	return spawn_x + float(_spawner.get("_to_next")) - float(_spawner.get("_n")) * spacing

## 曲线坐标 u（可为小数）→ 屏幕 x
func x_of_u(u: float) -> float:
	return phase() + u * float(_spawner.get("spacing"))

## 曲线坐标 u → y。优先用 ObstacleCurve.y_at_float()，没有就退化成整数点之间线性插值
func y_of_u(u: float) -> float:
	if _curve.has_method("y_at_float"):
		return _curve.y_at_float(u)
	var i := int(floor(u))
	return lerpf(_curve.y_at(i), _curve.y_at(i + 1), u - float(i))

func _draw() -> void:
	if not _ensure():
		return
	var spacing: float = _spawner.get("spacing")
	if spacing <= 0.0 or dot_step_px <= 0.0:
		return

	var ph := phase()
	var view_w := get_viewport_rect().size.x
	var du := dot_step_px / spacing                 # 每个点推进多少"曲线坐标"

	# 当前屏幕覆盖的曲线坐标区间（多点一个间隔，保证边缘不断）
	var u0 := (0.0 - ph) / spacing - du
	var u1 := (view_w - ph) / spacing + du

	# ① 点带：u 取固定步长；ph 随时间变小，于是所有点一起左移
	var pts := PackedVector2Array()
	for k in range(int(floor(u0 / du)), int(ceil(u1 / du)) + 1):
		var u := float(k) * du
		var pos := Vector2(ph + u * spacing, y_of_u(u))
		pts.append(pos)
		var col := dot_color
		if fade_with_x:
			col.a *= clampf(pos.x / view_w, 0.12, 1.0)
		draw_circle(pos, dot_radius, col)

	if show_polyline and pts.size() >= 2:
		draw_polyline(pts, line_color, line_width, true)

	# ② 真实采样点：整数序号 = 每个障碍物真正会落到的位置
	if show_samples:
		for n in range(int(floor(u0)), int(ceil(u1)) + 1):
			draw_circle(Vector2(ph + float(n) * spacing, y_of_u(float(n))), sample_radius, sample_color)

	# ③ X 轴：刻度跟着曲线坐标走，所以它跟点带一起左移
	if show_axis:
		_draw_axis(ph, view_w, spacing)

## 把 u 格式化成标签文字：整数就不带小数点
static func _fmt_u(u: float) -> String:
	if is_equal_approx(u, roundf(u)):
		return str(int(roundf(u)))
	return "%.2f" % u

func _draw_axis(ph: float, view_w: float, spacing: float) -> void:
	# 轴线
	draw_line(Vector2(0.0, axis_y), Vector2(view_w, axis_y), axis_color, 1.0)

	var u0 := (0.0 - ph) / spacing
	var u1 := (view_w - ph) / spacing

	# 小刻度
	if minor_step_u > 0.0:
		var half := minor_len * 0.5
		for k in range(int(floor(u0 / minor_step_u)) - 1, int(ceil(u1 / minor_step_u)) + 2):
			var x := ph + float(k) * minor_step_u * spacing
			draw_line(Vector2(x, axis_y - half), Vector2(x, axis_y + half), axis_color, 1.0)

	# 大刻度 + 数字标签（数字 = 第几个障碍物）
	var font: Font = ThemeDB.fallback_font
	var half_major := major_len * 0.5
	for k in range(int(floor(u0 / major_step_u)) - 1, int(ceil(u1 / major_step_u)) + 2):
		var u := float(k) * major_step_u
		var x := ph + u * spacing
		draw_line(Vector2(x, axis_y - half_major), Vector2(x, axis_y + half_major), axis_color, 1.0)
		if font != null:
			draw_string(font, Vector2(x - 16.0, axis_y + label_offset), _fmt_u(u),
					HORIZONTAL_ALIGNMENT_CENTER, 32.0, label_size, label_color)
