extends RigidBody3D

var examine_text: String = "A Box"
var holding_character: CharacterBody3D = null

func _physics_process(delta):
	if MultiplayerControls.is_host \
	and holding_character:
		var destination: Vector3 = holding_character.frame.hold_point.get_global_position()
		var current_position: Vector3 = get_global_position()
		var distance: float = current_position.distance_to(destination)
		var direction: Vector3 = current_position.direction_to(destination)
		var speed: float = clampf(distance / delta, 0.0, 1000.0)

		set_linear_damp(clampf(10.0 - (distance / 10.0), 0.1, 10.0))
		print(distance, direction, speed)
		apply_force(direction * speed)

@rpc("any_peer", "call_local")
func pick_up_by(character_name: StringName):
	if MultiplayerControls.is_host:
		holding_character = EventsManager.world_node.get_node(NodePath(character_name))
		set_linear_damp(ProjectSettings.get_setting("physics/3d/default_linear_damp"))
		set_angular_damp(1.0)

@rpc("any_peer", "call_local")
func drop():
	if MultiplayerControls.is_host:
		holding_character = null
		set_gravity_scale(1.0)
		set_linear_damp(ProjectSettings.get_setting("physics/3d/default_linear_damp"))
		set_angular_damp(ProjectSettings.get_setting("physics/3d/default_angular_damp"))

