extends RigidBody3D
#
var examine_text: String = "A Box"

#TODO Pull this out somewhere more generic
@rpc("any_peer", "call_local")
func move_object(distance: float, direction: Vector3, speed: float) -> void:
	set_linear_damp(clampf(10.0 - (distance / 10.0), 0.1, 10.0))
	apply_force(direction * speed)

@rpc("any_peer", "call_local")
func rotate_object(torque: Vector3) -> void:
	set_angular_damp(10)
	apply_torque(torque)

@rpc("any_peer", "call_local")
func reset_damping() -> void:
	set_linear_damp(ProjectSettings.get_setting("physics/3d/default_linear_damp"))
	set_angular_damp(ProjectSettings.get_setting("physics/3d/default_angular_damp"))
