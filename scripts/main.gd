extends Spatial

onready var player = $Player
onready var hp_label: Label = $HUD/HPLabel

func _ready() -> void:
	player.connect("hp_changed", self, "_on_player_hp_changed")
	_on_player_hp_changed(player.get_current_hp(), player.get_max_hp())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_restart"):
		var err := get_tree().reload_current_scene()
		if err != OK:
			push_warning("Failed to reload current scene. Error code: %d" % err)

func _on_player_hp_changed(current_health: int, max_health: int) -> void:
	hp_label.text = "HP: %d / %d" % [current_health, max_health]
