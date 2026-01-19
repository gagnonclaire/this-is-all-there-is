extends RigidBody3D

## Mouse over text.
@export var examine_text: String = "A Grabbable Object"

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

	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)

func _body_entered(_body) -> void:
	_is_colliding = true

func _body_exited(_body) -> void:
	_is_colliding = false

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority() and _is_grabbed:
		var distance: float = global_position.distance_to(_moving_towards)
		var direction: Vector3 = global_position.direction_to(_moving_towards)
		var speed: float = clampf(distance / delta, 0.0, 1000.0)
		set_linear_damp(clampf(10.0 - (distance / 10.0), 0.1, 10.0))
		apply_force(direction * speed)

		if not _is_colliding:
			var target_basis: Basis = (_pointing_towards * _rotation_transform).basis
			global_basis = global_basis.slerp(target_basis, 0.1)

@rpc("any_peer", "call_local")
func set_grabbed(grabbed: bool) -> void:
	if is_multiplayer_authority():
		_is_grabbed = grabbed
		can_sleep = not grabbed

		if (grabbed):
			_rotation_transform = _pointing_towards.affine_inverse() * global_transform
			set_angular_damp(10 / size_mod)
		else:
			_rotation_transform = Transform3D()
			set_linear_damp(ProjectSettings.get_setting("physics/3d/default_linear_damp"))
			set_angular_damp(ProjectSettings.get_setting("physics/3d/default_angular_damp"))

@rpc("any_peer", "call_local")
func set_move_point(point: Vector3) -> void:
	if is_multiplayer_authority():
		_moving_towards = point

@rpc("any_peer", "call_local")
func set_point_direction(pointing_transform: Transform3D) -> void:
	if is_multiplayer_authority():
		_pointing_towards = pointing_transform

@rpc("any_peer", "call_local")
func rotate_object(torque: Vector3) -> void:
	if is_multiplayer_authority():
		set_angular_damp(10 / size_mod)
		apply_torque(torque * size_mod)
		_rotation_transform = _pointing_towards.affine_inverse() * global_transform
