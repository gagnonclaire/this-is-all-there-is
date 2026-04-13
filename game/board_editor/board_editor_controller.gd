class_name BoardEditorController
extends Node

@onready var board_editor_position: Node3D = $BoardEditorPosition
@onready var board_editor_camera: Camera3D = $BoardEditorPosition/BoardEditorCamera

var camera_speed = 10
var camera_sensitivity = 0.0025
var camera_rotation_clamp = PI / 2.25

func _ready() -> void:
	EventsManager.capture_mouse()
	board_editor_camera.make_current()

func _process(delta: float) -> void:
	if EventsManager.is_mouse_captured():
		move_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and EventsManager.is_mouse_captured():
		rotate_camera(event)
	if Input.is_action_just_pressed(Keybinds.TOGGLE_MOUSE_CAPTURE):
		EventsManager.toggle_mouse()

func move_camera(delta: float) -> void:
	var height_adjustment = 0
	var input_direction = Input.get_vector(
		Keybinds.LEFT,
		Keybinds.RIGHT,
		Keybinds.FORWARD,
		Keybinds.BACKWARD,
	).normalized()

	if Input.is_action_pressed(Keybinds.FLYING_CONTROLLER_UP):
		height_adjustment += 1
	if Input.is_action_pressed(Keybinds.FLYING_CONTROLLER_DOWN):
		height_adjustment -= 1

	var move_direction = Vector3(input_direction.x, height_adjustment, input_direction.y)

	if move_direction:
		board_editor_position.translate_object_local(move_direction * delta * camera_speed)

func rotate_camera(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		board_editor_position.rotate_y(-event.relative.x *.0025)
		board_editor_camera.rotate_x(-event.relative.y *.0025)
		board_editor_camera.rotation.x = clamp(
			board_editor_camera.rotation.x,
			-camera_rotation_clamp,
			camera_rotation_clamp
		)
