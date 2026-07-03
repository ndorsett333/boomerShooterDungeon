extends Spatial

export(int) var damage = 35
export(float) var attack_range = 2.2
export(float) var cooldown = 0.45

onready var cooldown_timer: Timer = $CooldownTimer
onready var tween: Tween = $Tween
onready var camera: Camera = get_parent()

var can_slash := true
var default_rotation := Vector3.ZERO
var slash_rotation := Vector3.ZERO

func _ready() -> void:
	default_rotation = rotation_degrees
	slash_rotation = default_rotation + Vector3(-55, -25, 0)
	cooldown_timer.wait_time = cooldown

func try_slash() -> void:
	if not can_slash:
		return

	can_slash = false
	cooldown_timer.start()
	_play_slash_animation()
	_apply_hit_if_enemy_in_range()

func _play_slash_animation() -> void:
	tween.stop_all()
	tween.interpolate_property(self, "rotation_degrees", default_rotation, slash_rotation, 0.08, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(self, "rotation_degrees", slash_rotation, default_rotation, 0.12, Tween.TRANS_QUAD, Tween.EASE_IN, 0.08)
	tween.start()

func _apply_hit_if_enemy_in_range() -> void:
	var from: Vector3 = camera.global_transform.origin
	var forward: Vector3 = -camera.global_transform.basis.z
	var to: Vector3 = from + (forward * attack_range)
	var exclude := [get_parent().get_parent()]
	var hit := get_world().direct_space_state.intersect_ray(from, to, exclude)

	if hit.empty():
		return

	var collider = hit.collider
	if collider and collider.is_in_group("enemy") and collider.has_method("take_damage"):
		collider.take_damage(damage)

func _on_CooldownTimer_timeout() -> void:
	can_slash = true
