class_name BoardController
extends Node

@onready var board_controller_hud: CanvasLayer = $BoardControllerHUD
@onready var board_controller_position: Node3D = $BoardControllerPosition
@onready var board_controller_camera: Camera3D = $BoardControllerPosition/BoardControllerCamera

var active: bool = false
var camera_speed: float = 10
var camera_sensitivity: float = 0.0025
var camera_rotation_clamp: float = PI / 2.25

func _process(delta: float) -> void:
	if not active:
		return

	if EventsManager.is_mouse_captured():
		move_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventMouseMotion and EventsManager.is_mouse_captured():
		rotate_camera(event)
	if Input.is_action_just_pressed(Keybinds.TOGGLE_MOUSE_CAPTURE):
		EventsManager.toggle_mouse()

func make_active() -> void:
	active = true
	board_controller_hud.show()
	board_controller_camera.make_current()

func make_inactive() -> void:
	active = false
	board_controller_hud.hide()

func move_camera(delta: float) -> void:
	if not active:
		return

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
		board_controller_position.translate_object_local(move_direction * delta * camera_speed)

func rotate_camera(event: InputEvent) -> void:
	if not active:
		return

	if event is InputEventMouseMotion:
		board_controller_position.rotate_y(-event.relative.x *.0025)
		board_controller_camera.rotate_x(-event.relative.y *.0025)
		board_controller_camera.rotation.x = clamp(
			board_controller_camera.rotation.x,
			-camera_rotation_clamp,
			camera_rotation_clamp
		)
