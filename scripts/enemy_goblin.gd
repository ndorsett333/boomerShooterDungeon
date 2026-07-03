extends KinematicBody

export(float) var move_speed = 3.2
export(float) var detection_range = 18.0
export(float) var attack_range = 1.6
export(int) var attack_damage = 12
export(float) var attack_cooldown = 1.0
export(float) var gravity = 24.0

onready var health = $HealthComponent
onready var attack_timer: Timer = $AttackCooldown

var player: KinematicBody = null
var velocity := Vector3.ZERO
var can_attack := true

func _ready() -> void:
	add_to_group("enemy")
	health.connect("died", self, "_on_died")
	_find_player()

func _physics_process(delta: float) -> void:
	if health.is_dead():
		return

	if not is_instance_valid(player):
		_find_player()
		if not is_instance_valid(player):
			return

	var to_player := player.global_transform.origin - global_transform.origin
	var horizontal_to_player := Vector3(to_player.x, 0, to_player.z)
	var distance := horizontal_to_player.length()

	if distance <= attack_range:
		velocity.x = 0
		velocity.z = 0
		if can_attack:
			player.take_damage(attack_damage)
			can_attack = false
			attack_timer.start(attack_cooldown)
	elif distance <= detection_range:
		var dir := horizontal_to_player.normalized()
		velocity.x = dir.x * move_speed
		velocity.z = dir.z * move_speed
	else:
		velocity.x = 0
		velocity.z = 0

	if distance > 0.1:
		look_at(Vector3(player.global_transform.origin.x, global_transform.origin.y, player.global_transform.origin.z), Vector3.UP)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	velocity = move_and_slide(velocity, Vector3.UP)

func take_damage(amount: int) -> void:
	health.apply_damage(amount)

func _find_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _on_AttackCooldown_timeout() -> void:
	can_attack = true

func _on_died() -> void:
	queue_free()
