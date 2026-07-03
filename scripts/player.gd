extends KinematicBody

signal hp_changed(current_health, max_health)

export(float) var move_speed = 6.0
export(float) var mouse_sensitivity = 0.08
export(float) var gravity = 24.0

var velocity := Vector3.ZERO
var camera_pitch := 0.0

onready var camera: Camera = $Camera
onready var sword: Spatial = $Camera/SwordPivot
onready var health = $HealthComponent

func _ready() -> void:
	add_to_group("player")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health.connect("health_changed", self, "_on_health_changed")
	health.connect("died", self, "_on_died")
	_on_health_changed(health.current_health, health.max_health)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		camera_pitch = clamp(camera_pitch - event.relative.y * mouse_sensitivity, -80.0, 80.0)
		camera.rotation_degrees.x = camera_pitch

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseButton and event.pressed and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	var input_dir := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x

	input_dir.y = 0
	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * move_speed
	velocity.z = input_dir.z * move_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	velocity = move_and_slide(velocity, Vector3.UP)

	if Input.is_action_just_pressed("attack"):
		sword.try_slash()

func take_damage(amount: int) -> void:
	health.apply_damage(amount)

func get_current_hp() -> int:
	return health.current_health

func get_max_hp() -> int:
	return health.max_health

func _on_health_changed(current_health: int, max_health: int) -> void:
	emit_signal("hp_changed", current_health, max_health)

func _on_died() -> void:
	# Minimal death loop: reload test scene for immediate retry.
	var err := get_tree().reload_current_scene()
	if err != OK:
		push_warning("Failed to reload current scene. Error code: %d" % err)
