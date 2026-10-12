class_name Jump extends Movement

# 用事件驱动而不是每帧轮询 Input.is_action_just_pressed：
# 被 UI 吃掉的点击不会传到 _unhandled_input（实测），所以点 HUD 的暂停按钮不会再触发跳跃。
# （轮询则只看全局输入状态，鼠标左键绑在 flap 上时，点任何按钮都会顺带跳一下。）
var _jump_requested := false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("flap"):
		_jump_requested = true


func _physics_process(_delta: float) -> void:
	if _jump_requested:
		_jump_requested = false
		player.velocity.y = -player.JUMP_VELOCITY
