class_name ObstacleCurve extends Resource

@export var center_y := 90.0          # 通道中心基准高度
@export var half_range := 50.0        # 上下摆幅 → y ∈ center ± half_range

@export_group("正弦 1")
@export var amp1 := 1.0
@export var freq1 := 0.05             # 周期 / 个障碍物

@export_group("正弦 2")
@export var amp2 := 0.5
@export var freq2 := 0.083            # 与 freq1 取不可通约的比，避免规律重复

@export_group("噪声")
@export var noise_amp := 0.25         # 噪声倍率
@export var noise_step := 0.18        # 每个障碍物推进多少噪声坐标
@export var noise_seed := 20261011:
	set(v):
		noise_seed = v
		_reseed()

var phase1 := 0.0
var phase2 := 0.0
var _noise: FastNoiseLite              # 由 _reseed() 创建；不在这里 new，避免成员初始化把它覆盖掉

func _init() -> void:
	_reseed()

## 从 noise_seed 派生相位与噪声实例；_init() 与 setter 共用
func _reseed() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = noise_seed                  # 相位也由种子决定，方便复现
	phase1 = rng.randf_range(0.0, TAU)
	phase2 = rng.randf_range(0.0, TAU)
	_noise = FastNoiseLite.new()           # 每次重建，跟初始化顺序无关
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.frequency = 0.5
	_noise.seed = noise_seed

## 连续版：u 可以是小数（画曲线 / 采样更密时用）。纯新增，不影响数值
func y_at_float(u: float) -> float:
	var w := amp1 * sin(TAU * freq1 * u + phase1) \
			+ amp2 * sin(TAU * freq2 * u + phase2) \
			+ noise_amp * _noise.get_noise_1d(u * noise_step)
	var norm := amp1 + amp2 + noise_amp
	return center_y + (w / norm if norm > 0.0 else 0.0) * half_range


## n = 第几个障碍物（从 0 开始）
func y_at(n: int) -> float:
	return y_at_float(float(n))
