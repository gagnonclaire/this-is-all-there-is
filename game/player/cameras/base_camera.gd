class_name BaseCamera
extends Node3D

@onready var camera_node: Camera3D = $CameraNode

@export var sensitivity: float = 0.0025
@export var rotation_clamp: float = PI / 2.1
@export var transition_to_speed: float = 10
@export var transition_to_epsilon: float = 0.05

var active: bool = false
var transitioning_to: bool = false
var transition_target_position: Vector3 = Vector3.ZERO
var transition_target_rotation: Vector3 = Vector3.ZERO

func _physics_process(delta: float):
	if active and transitioning_to:
		move_to_transition_target(delta)
		rotate_to_transition_target(delta)
		finish_transition()

func move_to_transition_target(delta: float):
	position = position.lerp(transition_target_position, delta * transition_to_speed)

func rotate_to_transition_target(delta: float):
	rotation = rotation.lerp(transition_target_rotation, delta * transition_to_speed)

func finish_transition():
	if near_rotation_target and near_position_target:
		transitioning_to = false
		camera_node.position = position

func near_rotation_target():
	var rotation_difference = transition_target_rotation - rotation

	if abs( rotation_difference.x ) < transition_to_epsilon \
	 and abs( rotation_difference.y ) < transition_to_epsilon \
	 and abs( rotation_difference.z ) < transition_to_epsilon:
		return true

	return false

func near_position_target():
	var position_difference = transition_target_position - position

	if abs( position_difference.x ) < transition_to_epsilon \
	 and abs( position_difference.y ) < transition_to_epsilon \
	 and abs( position_difference.z ) < transition_to_epsilon:
		return true

	return false

func transition_to(from_position: Vector3, from_rotation: Vector3):
	transition_target_position = position
	transition_target_rotation = rotation
	position = from_position
	rotation = from_rotation
	transitioning_to = true

	activate()

func activate():
	active = true
	camera_node.make_current()

func deactivate():
	transitioning_to = false
	active = false
