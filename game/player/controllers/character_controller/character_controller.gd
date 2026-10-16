class_name CharacterController
extends Node

const BASE_BODY_SCENE: PackedScene = preload("res://game/bodies/base_body.tscn")

var current_body: BaseBody

func _ready():
	if not is_multiplayer_authority():
		return

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float):
	if not is_multiplayer_authority():
		return

	process_movement(delta)
	process_jump() # should be an unhandled input event
	process_damping()

func _unhandled_input(event: InputEvent):
	if not is_multiplayer_authority():
		return

	if event is InputEventMouseMotion:
		process_camera_control(event)

func process_movement(delta: float):
	var input_direction: Vector2 = Input.get_vector(
		Keybinds.LEFT,
		Keybinds.RIGHT,
		Keybinds.FORWARD,
		Keybinds.BACKWARD
	)
	var normalized_direction: Vector3 = (
		current_body.camera.transform.basis * Vector3(input_direction.x, 0, input_direction.y)
	)
	normalized_direction.y = 0
	normalized_direction = normalized_direction.normalized()

	if normalized_direction and below_top_speed():
			current_body.apply_force(normalized_direction * current_body.acceleration * delta * 10)

func below_top_speed() -> bool:
	var horizontal_velocity: Vector3 = current_body.linear_velocity
	horizontal_velocity.y = 0
	return horizontal_velocity.length() < current_body.top_speed

func process_jump():
	if current_body.on_ground() and Input.is_action_pressed(Keybinds.FLYING_CONTROLLER_UP):
		current_body.apply_impulse(Vector3(0, current_body.jump_power, 0))

func process_damping():
	if Input.is_action_pressed(Keybinds.LEFT) or \
	Input.is_action_pressed(Keybinds.RIGHT) or \
	Input.is_action_pressed(Keybinds.FORWARD) or \
	Input.is_action_pressed(Keybinds.BACKWARD) or \
	Input.is_action_pressed(Keybinds.FLYING_CONTROLLER_UP) or \
	not current_body.on_ground():
		current_body.linear_damp = 0.0
	else:
		current_body.linear_damp = 5.0

# should not access camera, but instead move body's head
# (camera would be child of the head)
# (rest of body rotates towards head)
func process_camera_control(event: InputEventMouseMotion):
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		current_body.camera.global_rotate(
			Vector3(0, 1, 0),
			-event.screen_relative.x *.0025
		)
		current_body.camera.rotate_object_local(
			Vector3(1, 0, 0),
			-event.screen_relative.y *.0025
		)
		current_body.camera.global_rotation.x = clamp(
			current_body.camera.rotation.x, -PI / 2.25, PI / 2.25
		)

func create_base_character_body():
	current_body = BASE_BODY_SCENE.instantiate()
	add_child(current_body)
