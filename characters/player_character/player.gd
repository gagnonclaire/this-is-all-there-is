extends CharacterBody3D

const SPEED: float = 5.0
const SPRINT_MODIFIER: float = 3.0
const MAX_STAMINA: float = 100.0

@onready var hud: CanvasLayer = $HUD
@onready var stamina_vignette: TextureRect = $HUD/Control/StaminaVignette
@onready var unstuck_vignette: TextureRect = $HUD/Control/UnstuckVignette
@onready var physics_collision: CollisionShape3D = $PhysicsCollider

# Get references to frame nodes
@onready var frame: Node3D = $HumanFrame
@onready var skeleton: Skeleton3D = frame.skeleton
@onready var core_bone: PhysicalBone3D = frame.core_bone
@onready var camera: Camera3D = frame.camera
@onready var interact_raycast: RayCast3D = frame.interact_raycast

@onready var world_node: Node = get_parent()
@onready var main_node: Node = world_node.get_parent()

@onready var current_stamina: float = MAX_STAMINA
@onready var is_knocked_out: bool = false
@onready var unstuck_progress: float = 0.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hud.show()

		camera.current = true

func _physics_process(delta):
	if is_multiplayer_authority():
		# Add gravity
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Sprint check and stamina cost/regen
		var current_sprint_mod: float = 1.0
		if Input.is_action_pressed("sprint") and current_stamina > 0 and not is_knocked_out:
			current_sprint_mod = SPRINT_MODIFIER
			current_stamina = clampf(current_stamina - (delta * 10.0), 0, MAX_STAMINA)
		elif not is_knocked_out:
			current_stamina = clampf(current_stamina + (delta * 5.0), 0, MAX_STAMINA)
		else:
			current_stamina = clampf(current_stamina + (delta * 25.0), 0, MAX_STAMINA)

		# Update stamina vignette
		stamina_vignette.set_modulate(Color(1, 1, 1, 1 - (current_stamina / MAX_STAMINA)))

		# Check knockout state, prevent movement
		if current_stamina == 0:
			rpc("start_ragdoll")
			return
		elif is_knocked_out and current_stamina < MAX_STAMINA:
			return
		elif is_knocked_out and current_stamina == MAX_STAMINA:
			rpc("stop_ragdoll")
			return

		# Unstuck mechanic, want this to be blocked when knocked out
		if Input.is_action_pressed("unstuck"):
			unstuck_progress = clampf(unstuck_progress + (delta * 50.0), 0, 100.0)
		else:
			unstuck_progress = clampf(unstuck_progress - (delta * 100.0), 0, 100.0)

		unstuck_vignette.set_modulate(Color(1, 1, 1, (unstuck_progress / 100.0)))

		if unstuck_progress == 100.0:
			rpc("unstuck")

		# Basic movement
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED * current_sprint_mod
			velocity.z = direction.z * SPEED * current_sprint_mod
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * current_sprint_mod)
			velocity.z = move_toward(velocity.z, 0, SPEED * current_sprint_mod)

		move_and_slide()

func _unhandled_input(event):
	if is_multiplayer_authority() and not is_knocked_out:
		# Camera movement
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x *.005)
			camera.rotate_x(-event.relative.y *.005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

		# Interact events
		if Input.is_action_just_pressed("interact"):
			if interact_raycast.is_colliding():
				var hit_object: PhysicsBody3D = interact_raycast.get_collider()
				if hit_object.is_in_group("interactable"):
					hit_object.interacted_with()

		# Debug events
		if Input.is_action_just_pressed("debug_spawn") and main_node.is_host:
			var random_position: Vector3 = Vector3(randf_range(-50,50), 0, randf_range(-50,50))
			var random_rotation: Vector3 = Vector3(0, randf_range(-50,50), 0)
			world_node.debug_spawn(random_position, random_rotation)

@rpc("any_peer", "call_local")
func start_ragdoll():
	skeleton.physical_bones_start_simulation()
	physics_collision.set_disabled(true)
	is_knocked_out = true

@rpc("any_peer", "call_local")
func stop_ragdoll():
	# Get the final position of the core bone
	var bone_position: Vector3 = core_bone.get_global_position()

	# Weird hack to reset bones
	# When you start a simulation it seems that all bones reset
	skeleton.physical_bones_stop_simulation()
	skeleton.physical_bones_start_simulation()
	skeleton.physical_bones_stop_simulation()

# Correct position and return to normal
	set_global_position(bone_position)
	physics_collision.set_disabled(false)
	is_knocked_out = false

@rpc("any_peer", "call_local")
func unstuck():
	set_global_position(Vector3.ZERO)
	unstuck_progress = 0.0
