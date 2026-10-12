# 调试用：游戏内实时调 曲线参数 + 障碍物生成频率
# 用法：在 ObstacleSpawner 下加一个 CanvasLayer，挂上本脚本
#   （CanvasLayer 忽略父节点变换，所以它固定贴在屏幕上，不受 spawner 位置影响）
# 说明：只读写 curve 资源与 spawner 的 spacing/speed，不修改任何游戏逻辑
extends CanvasLayer

@export var spawner: Node2D            # 留空就用父节点（挂在 ObstacleSpawner 下时）
@export var toggle_key := KEY_F1       # 按这个键隐藏/显示面板
@export var print_key := KEY_F2        # 按这个键把当前参数打印到「输出」面板
@export var stats_window := 64         # 统计"相邻落差"时向前看多少个障碍物

var _spawner: Node2D
var _curve: Resource
var _panel: PanelContainer
var _stats: Label
var _sliders := {}                     # 属性名 -> HSlider（方便脚本/probe 直接设值）
var _value_labels := {}                # 属性名 -> Label
var _built := false

func _ready() -> void:
	_spawner = spawner

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == toggle_key:
		if _panel != null:
			_panel.visible = not _panel.visible
	elif event.keycode == print_key and _ensure():
		_print_params()

func _process(_delta: float) -> void:
	if not _ensure():
		return
	_update_stats()

## 懒解析宿主（节点的 ready / 加入顺序都不保证），拿到就缓存
func _ensure() -> bool:
	if _spawner == null or not is_instance_valid(_spawner):
		_spawner = spawner if (spawner != null and is_instance_valid(spawner)) else get_parent() as Node2D
	if _spawner == null:
		return false
	if _curve == null:
		_curve = _spawner.get("curve")
	if _curve == null:
		return false
	if not _built:
		_build()
	return _built

# ---------------- UI ----------------

func _build() -> void:
	_built = true

	_panel = PanelContainer.new()
	_panel.position = Vector2(3, 3)
	add_child(_panel)

	var cols := HBoxContainer.new()
	cols.add_theme_constant_override("separation", 4)
	_panel.add_child(cols)

	var left := VBoxContainer.new()
	var right := VBoxContainer.new()
	left.add_theme_constant_override("separation", 2)
	right.add_theme_constant_override("separation", 2)
	cols.add_child(left)
	cols.add_child(right)

	_heading(left, "曲线 (ObstacleCurve)")
	_add_slider(left, "half_range", 0.0, 89.0, 1.0)
	_add_slider(left, "freq1", 0.0, 0.3, 0.001)
	_add_slider(left, "freq2", 0.0, 0.3, 0.001)
	_add_slider(left, "noise_amp", 0.0, 1.0, 0.01)
	_add_slider(left, "noise_step", 0.0, 1.0, 0.01)

	_heading(right, "生成 (Spawner)")
	_add_slider(right, "spacing", 40.0, 480.0, 1.0, _spawner)
	_add_slider(right, "speed", 0.0, 300.0, 1.0, _spawner)
	_add_slider(right, "noise_seed", 0.0, 99999.0, 1.0)

	var print_button := Button.new()
	print_button.text = "打印参数"
	print_button.add_theme_font_size_override("font_size", 9)
	print_button.pressed.connect(_print_params)
	right.add_child(print_button)

	_stats = Label.new()
	_stats.add_theme_font_size_override("font_size", 9)
	_stats.text = "..."
	right.add_child(_stats)

	_heading(right, "F1 显隐  F2 打印参数")

func _heading(parent: Control, text: String) -> void:
	var lb := Label.new()
	lb.text = text
	lb.add_theme_font_size_override("font_size", 9)
	lb.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	parent.add_child(lb)

## 打印当前全部参数到 Output，格式直接可以抄
func _print_params() -> void:
	var src := "内存实例（没有文件）"
	if _curve.resource_path != "":
		src = _curve.resource_path
	var out := PackedStringArray()
	out.append("========== 曲线参数（%s）==========" % src)
	for p in ["center_y", "half_range", "amp1", "freq1", "amp2", "freq2", "noise_amp", "noise_step", "noise_seed"]:
		out.append("%s = %s" % [p, _fmt_full(_curve.get(p))])
	out.append("========== 生成参数（Spawner 节点）==========")
	for p in ["spacing", "speed", "spawn_margin"]:
		out.append("%s = %s" % [p, _fmt_full(_spawner.get(p))])
	print("\n".join(out))

static func _fmt_full(v: Variant) -> String:
	if typeof(v) == TYPE_INT:
		return str(v)
	var f := float(v)
	if is_equal_approx(f, roundf(f)):
		return "%.1f" % f
	return "%.4f" % f

func _add_slider(parent: Control, prop: String, mn: float, mx: float, step: float, target: Object = null) -> void:
	var obj: Object = target if target != null else _curve
	var as_int := _prop_is_int(obj, prop)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 2)
	parent.add_child(row)

	var name_label := Label.new()
	name_label.text = prop
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.custom_minimum_size = Vector2(50, 0)
	row.add_child(name_label)

	var slider := HSlider.new()
	slider.min_value = mn
	slider.max_value = mx
	slider.step = 1.0 if as_int else step
	slider.value = float(obj.get(prop))
	slider.custom_minimum_size = Vector2(46, 10)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)

	var value_label := Label.new()
	value_label.add_theme_font_size_override("font_size", 9)
	value_label.custom_minimum_size = Vector2(34, 0)
	value_label.text = _fmt(slider.value, as_int)
	row.add_child(value_label)

	_sliders[prop] = slider
	_value_labels[prop] = value_label

	slider.value_changed.connect(func(v: float) -> void:
		obj.set(prop, float(roundi(v)) if as_int else v)  # 两个分支同为 float，否则 INCOMPATIBLE_TERNARY（走 set() → 会触发 noise_seed 的 setter）
		value_label.text = _fmt(v, as_int))

func _prop_is_int(obj: Object, prop: String) -> bool:
	if obj == null:
		return false
	for p in obj.get_property_list():
		if String(p["name"]) == prop:
			return int(p["type"]) == TYPE_INT
	return false

## 数字显示：大数不带小数，小数按量级给精度
static func _fmt(v: float, as_int: bool) -> String:
	if as_int:
		return str(roundi(v))
	var a := absf(v)
	if a >= 100.0:
		return "%.0f" % v
	if a >= 1.0:
		return "%.2f" % v
	return "%.3f" % v

## 用当前参数向前看 stats_window 个障碍物，算出"相邻落差"等实时统计
func _update_stats() -> void:
	if _stats == null:
		return
	var n0: int = _spawner.get("_n")
	var prev: float = _curve.y_at(n0)
	var lo := prev
	var hi := prev
	var max_delta := 0.0
	var sum_delta := 0.0
	for i in range(1, stats_window + 1):
		var y: float = _curve.y_at(n0 + i)
		var d: float = absf(y - prev)
		max_delta = maxf(max_delta, d)
		sum_delta += d
		lo = minf(lo, y)
		hi = maxf(hi, y)
		prev = y
	var spacing: float = _spawner.get("spacing")
	var speed: float = _spawner.get("speed")
	var interval := (spacing / speed) if speed > 0.0 else INF
	_stats.text = "Δy 最大 %.1f  平均 %.1f\n间隔 %.2f s   y %.0f~%.0f" % [
		max_delta, sum_delta / float(stats_window), interval, lo, hi]
