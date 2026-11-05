# 用 PID 把玩家（CharacterBody2D）的 x 位置稳在 target_x（默认 120）。
# 用法：挂在 Player 下作为一个子节点即可（不需要改 Player.gd）。
# 输出的是**水平速度**，由 Player 里的 move_and_slide() 执行；y 方向（重力/跳跃）完全不受影响。
#
# ⚠️ 2026-11-06 修掉一个坑（"回正时高频震荡、看起来像两只鸟，偶尔瞬移很远"）：
#   原来阻尼项用的是"误差的帧间差分" (error - prev_error)/delta。在这个结构里
#   （**每帧直接给 velocity.x 赋值** = 被控对象是"纯积分器"），这会形成一个**滞后一帧的负反馈**：
#       v_n = kp·e_n − kd·v_{n−1}
#   kd ≥ ~1 时特征根落到单位圆外，且有一根是负的 → 目标点附近**一帧左一帧右、幅度越来越大**（周期-2 发散）。
#   这就是"看起来裂成两只鸟"和"偶尔获得极高速度瞬移"的来源（关掉 Max Speed 后发散不再被截断）。
#   ✅ 修法：把阻尼项和"本帧要设定的速度"当成同一个未知量，**在帧内解出来**：
#       v = kp·e + ki·∫e − kd·v   ⇒   v = (kp·e + ki·∫e) / (1 + kd)
#   这在连续时间下与"对误差求导"等价（de/dt = −v），但离散步里没有一帧滞后，
#   **任何 kd 都不会发散**（kd 越大 = 速度被压得越低 = 越"刹车"）。
extends Node

@export var enabled := true
@export var target_x := 120.0

@export_group("PID")
@export var kp := 10.0             # 比例：误差(px) → 期望速度(px/s)
@export var ki := 0.0              # 积分：消除长期偏差（有恒定外力时才有必要）
@export var kd := 1.0              # 阻尼：对**当前速度**做负反馈（越大越"刹车"，不会引起震荡）

@export_group("限速 / 限加速度")
@export var use_max_speed := true  # 关掉 = 不限输出速度（小心：发散时会被放大成瞬移）
@export var max_speed := 120.0     # 输出速度上限 px/s（仅 use_max_speed 打开时生效）
@export var use_max_accel := false # 打开 = 限加速度（消掉"一帧内速度突变"的弹射感）
@export var max_accel := 300.0     # 加速度上限 px/s²（仅 use_max_accel 打开时生效）

@export_group("其它")
@export var integral_limit := 60.0 # 积分限幅，防积分饱和
@export var deadband := 0.05       # 误差小于这个就认为到位

var _integral := 0.0

@onready var _body: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	# 比 Player 先跑：Player 的 _physics_process 里才调用 move_and_slide()
	process_physics_priority = -1

func _physics_process(delta: float) -> void:
	if not enabled or _body == null or delta <= 0.0:
		return

	var error := target_x - _body.position.x          # 目标 - 当前（正 = 该往右）

	if absf(error) <= deadband:
		_integral = 0.0
		_body.velocity.x = 0.0
		return

	_integral = clampf(_integral + error * delta, -integral_limit, integral_limit)

	# ① 期望速度：P + I，再解出阻尼后的速度
	#    （阻尼项 −kd·v 与未知量 v 同帧，移到等式左边 → 除以 (1+kd)；
	#      直接读上一帧速度做 −kd·v 会形成 v_n = kp·e − kd·v_{n−1} 的一帧滞后递归，kd≥1 就震荡发散）
	var out := (kp * error + ki * _integral) / (1.0 + maxf(kd, 0.0))

	# ② 限速开关
	if use_max_speed:
		out = clampf(out, -max_speed, max_speed)

	# ③ 限加速度开关（不限时直接赋值，就是"一帧内到位"的原始行为）
	if use_max_accel:
		_body.velocity.x = move_toward(_body.velocity.x, out, max_accel * delta)
	else:
		_body.velocity.x = out
