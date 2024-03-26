extends RigidBody3D

var examine_text: String = "A Box"
var holding_frame: CharacterBody3D = null

#TODO This needs some love and to be pulled out for generic objects
func _physics_process(delta):
	if is_multiplayer_authority() \
	and holding_frame:
		var destination: Vector3 = holding_frame.hold_point.get_global_position()
		var current_position: Vector3 = get_global_position()
		var distance: float = current_position.distance_to(destination)
		var direction: Vector3 = current_position.direction_to(destination)
		var speed: float = clampf(distance / delta, 0.0, 1000.0)

		set_linear_damp(clampf(10.0 - (distance / 10.0), 0.1, 10.0))
		apply_force(direction * speed)

@rpc("any_peer", "call_local")
func pick_up_by(controller_name: StringName):
	if is_multiplayer_authority():
		holding_frame = EventsManager.get_player_controller(controller_name).current_frame
		set_linear_damp(ProjectSettings.get_setting("physics/3d/default_linear_damp"))
		set_angular_damp(1.0)

@rpc("any_peer", "call_local")
func drop():
	if is_multiplayer_authority():
		holding_frame = null
		set_gravity_scale(1.0)
		set_linear_damp(ProjectSettings.get_setting("physics/3d/default_linear_damp"))
		set_angular_damp(ProjectSettings.get_setting("physics/3d/default_angular_damp"))

