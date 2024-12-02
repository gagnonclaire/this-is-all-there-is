class_name MoveableObject
extends StaticBody3D

const OBJECT_SYNCHRONIZER_SCENE: PackedScene = preload("res://world/interactables/object_synchronizer.tscn")

## Mouse over text.
@export var examine_text: String = "A Moveable Object"

var _is_moving: bool = false
var _move_point: Vector3
var _rotation: float = 0

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
	var ghost_mesh: MeshInstance3D = $MeshInstance3D.duplicate()
	var ghost_mesh_material: StandardMaterial3D = StandardMaterial3D.new()

	ghost_mesh_material.set_albedo(Color(1, 1, 1, 0.25))
	ghost_mesh_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost_mesh_material.emission = Color(1, 1, 1)
	ghost_mesh_material.emission_enabled = true
	ghost_mesh.set_surface_override_material(0, ghost_mesh_material)

	_ghost.add_child(ghost_mesh)
	add_child(_ghost)

func despawn_ghost() -> void:
	_ghost.queue_free()

func set_moving(moving: bool) -> void:
	_is_moving = moving

func set_move_point(point: Vector3) -> void:
	_move_point = point

## TODO
func rotate_object(change: float) -> void:
	_ghost.rotate_y(change)

func place_object() -> void:
	place_object_rpc.rpc_id(1, _move_point, _rotation)

@rpc("any_peer", "call_local")
func place_object_rpc(point: Vector3, rotation: float) -> void:
	if is_multiplayer_authority():
		global_position = point
