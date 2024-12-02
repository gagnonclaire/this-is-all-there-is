class_name MoveableObject
extends StaticBody3D

const OBJECT_SYNCHRONIZER_SCENE: PackedScene = preload("res://world/interactables/object_synchronizer.tscn")

## Mouse over text.
@export var examine_text: String = "A Moveable Object"

var _is_moving: bool = false
var _move_point: Vector3

var _ghost: StaticBody3D

## Tentative controls:
## 	Interact to start moving
## 	Scroll to rotate
## 	Right click to cancel
## 	Left click to accept
func _ready() -> void:
	add_to_group("move_target")
	add_to_group("examine_target")

	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_layer_value(3, true)

func _physics_process(_delta: float) -> void:
	if _is_moving and _ghost:
		_ghost.global_position = _move_point

func spawn_ghost() -> void:
	_ghost = StaticBody3D.new()
	_ghost.add_child($MeshInstance3D.duplicate())
	add_child(_ghost)

func despawn_ghost() -> void:
	_ghost.queue_free()

func set_moving(moving: bool) -> void:
	_is_moving = moving

func set_move_point(point: Vector3) -> void:
	_move_point = point

## TODO
func rotate_object(change: float) -> void:
	if is_multiplayer_authority():
		_ghost.rotate_y(change)

@rpc("any_peer", "call_local")
func place_object(point: Vector3) -> void:
	if is_multiplayer_authority():
		global_position = point
