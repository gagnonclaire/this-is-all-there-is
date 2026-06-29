class_name BaseControllerCamera
extends Node3D

@onready var camera: Camera3D = $Camera3D

@export var can_adjust_height: bool = false
@export var can_move_self: bool = false

var active: bool = false
var speed: float = 10
var sensitivity: float = 0.0025
var rotation_clamp: float = PI / 2.1
var target_position: Vector3 = Vector3.ZERO

var target_transition_rotation: Vector3 = Vector3.ZERO
var is_transitioning_rotation: bool = false
var transition_rotating_epsilon: float = 0.05

func _physics_process(delta: float):
	if not active:
		return

	if can_move_self and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		move_target_point(delta)

	position = position.lerp(target_position, delta * speed)

	if is_transitioning_rotation:
		rotation = rotation.lerp(target_transition_rotation, delta * speed)
		check_rotation_transition()

func _unhandled_input(event: InputEvent):
	if not active:
		return

	if event is InputEventMouseMotion \
	 and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED \
	 and not is_transitioning_rotation:
		rotate_camera(event)

func transition_to(from_position: Vector3, from_rotation: Vector3):
	var previous_position: Vector3 = position
	var previous_rotation: Vector3 = rotation
	position = from_position
	rotation = from_rotation
	target_position = previous_position
	target_transition_rotation = previous_rotation

	active = true
	is_transitioning_rotation = true
	camera.make_current()

func check_rotation_transition():
	var rotation_difference = target_transition_rotation - rotation
	if abs( rotation_difference.x ) < transition_rotating_epsilon \
	 and abs( rotation_difference.y ) < transition_rotating_epsilon \
	 and abs( rotation_difference.z ) < transition_rotating_epsilon:
		is_transitioning_rotation = false

func move_target_point(delta: float):
	var direction = target_point_direction()
	var move_direction = Vector3(
		direction.x,
		target_point_height_adjustment(),
		direction.z
	)

	if move_direction:
		target_position += move_direction * delta * speed

func target_point_direction() -> Vector3:
	var input_direction = Input.get_vector(
		Keybinds.LEFT,
		Keybinds.RIGHT,
		Keybinds.FORWARD,
		Keybinds.BACKWARD,
	).normalized()

	var forward: Vector3 = transform.basis.z
	var right: Vector3 = transform.basis.x
	forward.y = 0.0
	right.y = 0.0
	forward = forward.normalized()
	right = right.normalized()
	return (forward * input_direction.y) + (right * input_direction.x)

func target_point_height_adjustment() -> float:
	var height_adjustment = 0
	if can_adjust_height and Input.is_action_pressed(Keybinds.FLYING_CONTROLLER_UP):
		height_adjustment += 1
	if can_adjust_height and Input.is_action_pressed(Keybinds.FLYING_CONTROLLER_DOWN):
		height_adjustment -= 1

	return height_adjustment

func rotate_camera(event: InputEvent):
	if event is InputEventMouseMotion:
		var rotation_x: float = rotation.x - event.relative.y *.0025
		var rotation_y: float = rotation.y - event.relative.x *.0025
		rotation_x = clampf(
			rotation_x,
			-rotation_clamp,
			rotation_clamp
		)

		rotation = Vector3(rotation_x, rotation_y, 0)

func deactivate():
	is_transitioning_rotation = false
	active = false
