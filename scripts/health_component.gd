extends Node

signal health_changed(current_health, max_health)
signal died

export(int) var max_health = 100
var current_health = 100

func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func apply_damage(amount: int) -> void:
	if amount <= 0:
		return

	current_health = max(current_health - amount, 0)
	emit_signal("health_changed", current_health, max_health)

	if current_health <= 0:
		emit_signal("died")

func reset_health() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0
