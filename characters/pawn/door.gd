extends RigidBody3D

#TODO Extend grabbable object, expanding grabbable object as needed

## Mouse over text.
@export var examine_text: String = "A Door"

## Modifies physics for various object sizes.
## Smaller numbers adjust for smaller objects.
@export var size_mod: float = 1

var _is_grabbed: bool = false
var _is_colliding: bool = false
var _moving_towards: Vector3
var _pointing_towards: Transform3D
var _rotation_transform: Transform3D = Transform3D()

func _ready() -> void:
	add_to_group("grab_target")
	add_to_group("examine_target")


	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_layer_value(3, true)

	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority() and _is_grabbed and !is_freeze_enabled():
		var distance: float = global_position.distance_to(_moving_towards)
		var direction: Vector3 = global_position.direction_to(_moving_towards)
		var speed: float = clampf(distance / delta, 0.0, 100.0)
		set_linear_damp(clampf(10.0 - (distance / 10.0), 0.1, 10.0))
		apply_force(direction * speed * 0.5)

	if abs(rotation.y) < 0.25:
		add_to_group("interact_target")
	else:
		remove_from_group("interact_target")

func _set_locked(locked: bool) -> void:
	if is_multiplayer_authority():
		if locked:
			examine_text = "A Locked Door"
			set_freeze_enabled(true)

			_rotation_transform = Transform3D()
			set_linear_damp(ProjectSettings.get_setting("physics/3d/default_linear_damp"))
			set_angular_damp(ProjectSettings.get_setting("physics/3d/default_angular_damp"))
		else:
			examine_text = "A Door"
			set_freeze_enabled(false)

@rpc("any_peer", "call_local")
func set_grabbed(grabbed: bool) -> void:
	if is_multiplayer_authority():
		_is_grabbed = grabbed
		can_sleep = !grabbed

		if (grabbed):
			_rotation_transform = _pointing_towards.affine_inverse() * global_transform
			set_angular_damp(10 / size_mod)
		else:
			_rotation_transform = Transform3D()
			set_linear_damp(1)
			set_angular_damp(1)

@rpc("any_peer", "call_local")
func set_move_point(point: Vector3) -> void:
	if is_multiplayer_authority():
		_moving_towards = point

@rpc("any_peer", "call_local")
func set_point_direction(pointing_transform: Transform3D) -> void:
	if is_multiplayer_authority():
		return

@rpc("any_peer", "call_local")
func rotate_object(torque: Vector3) -> void:
	if is_multiplayer_authority():
		return

@rpc("any_peer", "call_local")
func interacted_with():
	if is_multiplayer_authority():
		_set_locked(!is_freeze_enabled())
