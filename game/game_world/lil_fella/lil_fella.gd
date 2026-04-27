class_name  LilFella
extends RigidBody3D

@onready var target_ray_cast: RayCast3D = $RayCast3D
@onready var ground_cast: ShapeCast3D = $ShapeCast3D

@export var follow_distance: float = 300
@export var stop_distance: float = 5
@export var speed: float = 1

var follow_target: Node3D = null

func _physics_process(delta: float):
	if is_multiplayer_authority() and follow_target:
		look_at(follow_target.global_position)
		move_towards_target(delta)

func update_target():
	var can_be_followed_nodes: Array[Node] = get_tree().get_nodes_in_group("can_be_followed")
	var target_node: Node3D = null
	var minimum_distance: float = follow_distance

	for node: Node3D in can_be_followed_nodes:
		var distance_to_node: float = global_position.distance_squared_to(node.global_position + Vector3(0, .2, 0))

		if distance_to_node > minimum_distance or distance_to_node > follow_distance:
			continue

		target_ray_cast.target_position = to_local(node.global_position)
		target_ray_cast.force_raycast_update()
		var collider = target_ray_cast.get_collider()

		# may have issues with one target in between the fella and another target
		# following code doesn't solve and it compares the satic body collision
		# to the collision shape of the world collider node
		#if collision and collision != node:
			#continue

		if collider and collider.is_in_group("can_be_followed"):
			target_node = node
			break

	follow_target = target_node

func move_towards_target(delta: float):
	# needs to not add force if already moving upwards
	if randi_range(1, 100) > 75 and ground_cast.is_colliding():
		apply_force(Vector3(0, randi_range(50, 100), 0))

	if global_position.distance_squared_to(follow_target.global_position) < stop_distance:
		return

	apply_force(-basis.z * speed * delta * 300)


func _on_update_target_timer_timeout():
	if is_multiplayer_authority():
		update_target()
