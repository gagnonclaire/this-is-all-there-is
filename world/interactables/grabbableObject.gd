extends RigidBody3D

## Mouse over text.
@export var examine_text: String = "An Object"

## Modifies physics for various object sizes.
## Smaller numbers adjust for smaller objects.
@export var size_mod: float = 1

var relative_transform: Transform3D

func _ready() -> void:
	add_to_group("grab_target")
	add_to_group("examine_target")

	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_layer_value(3, true)

	set_collision_mask_value(1, true)
	set_collision_mask_value(3, true)

@rpc("any_peer", "call_local")
func set_original_transform(hold_transform: Transform3D) -> void:
	if is_multiplayer_authority():
		relative_transform = hold_transform.affine_inverse() * global_transform

@rpc("any_peer", "call_local")
func move_object(
	distance: float,
	direction: Vector3,
	speed: float,
	hold_transform: Transform3D
) -> void:
	if is_multiplayer_authority():
		set_linear_damp(clampf(10.0 - (distance / 10.0), 0.1, 10.0))
		apply_force(direction * speed)

		var target_transform = hold_transform * relative_transform
		global_transform.basis =global_transform.basis.slerp(target_transform.basis, 0.1)

@rpc("any_peer", "call_local")
func rotate_object(torque: Vector3, hold_transform: Transform3D) -> void:
	if is_multiplayer_authority():
		set_angular_damp(10 / size_mod)
		apply_torque(torque * size_mod)

		relative_transform = hold_transform.affine_inverse() * global_transform

@rpc("any_peer", "call_local")
func reset_damping() -> void:
	if is_multiplayer_authority():
		set_linear_damp(ProjectSettings.get_setting("physics/3d/default_linear_damp"))
		set_angular_damp(ProjectSettings.get_setting("physics/3d/default_angular_damp"))
