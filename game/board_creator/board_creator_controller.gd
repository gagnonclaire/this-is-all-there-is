class_name BoardCreatorController
extends Node

@onready var board_creator_camera: Camera3D = $BoardCreatorCamera
var camera_speed = 10
var camera_sensitivity = 0.0025

func _ready() -> void:
	EventsManager.capture_mouse()
	board_creator_camera.make_current()

func _process(delta: float) -> void:
	if EventsManager.is_mouse_captured():
		move_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and EventsManager.is_mouse_captured():
		rotate_camera(event)
	if Input.is_action_just_pressed(KeybindManager.TOGGLE_MOUSE_CAPTURE):
		EventsManager.toggle_mouse()

func move_camera(delta: float) -> void:
	var input_direction = Input.get_vector(
		KeybindManager.LEFT,
		KeybindManager.RIGHT,
		KeybindManager.FORWARD,
		KeybindManager.BACKWARD,
	).normalized()
	var move_direction = Vector3(input_direction.x, 0, input_direction.y)

	if move_direction:
		board_creator_camera.translate_object_local(move_direction * delta * camera_speed)

func rotate_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		board_creator_camera.global_rotate(
			Vector3i(0, 1, 0),
			-event.relative.x * camera_sensitivity,
		)
		board_creator_camera.rotate_object_local(
			Vector3i(1, 0, 0),
			-event.relative.y * camera_sensitivity,
		)
		clamp_camera_rotation()

func normalized_camera_direction() -> Vector3:
	var camera_basis = board_creator_camera.transform.basis
	var input_direction = Input.get_vector(
		KeybindManager.LEFT,
		KeybindManager.RIGHT,
		KeybindManager.FORWARD,
		KeybindManager.BACKWARD,
	)
	var input_direction_vector = Vector3(input_direction.x, 0, input_direction.y)

	return (camera_basis * input_direction_vector).normalized()

func clamp_camera_rotation() -> void:
	board_creator_camera.rotation.x = clamp(
		board_creator_camera.rotation.x,
		-PI / 2.25,
		PI / 2.25,
	)
