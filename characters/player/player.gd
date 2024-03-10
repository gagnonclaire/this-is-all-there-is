extends CharacterBody3D

const SPEED: float = 5.0
const SPRINT_MODIFIER: float = 2.0
const MAX_STAMINA: float = 100.0

@onready var camera: Camera3D = $HeadPosition/CameraPivot/Camera3D
@onready var interact_raycast: RayCast3D = $HeadPosition/CameraPivot/Camera3D/InteractRaycast
@onready var stamina_vignette: TextureRect = $HUD/Control/StaminaVignette
@onready var player_collision: CollisionShape3D = $CollisionShape3D

@onready var player_skeleton: Skeleton3D = $PlayerSkeleton
@onready var head_bone: PhysicalBone3D = $PlayerSkeleton/HeadBone
@onready var body_bone: PhysicalBone3D = $PlayerSkeleton/BodyBone

@onready var world_node: Node = get_parent()
@onready var main_node: Node = world_node.get_parent()

@onready var current_stamina: float = MAX_STAMINA
@onready var is_knocked_out: bool = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.current = true

		#anim_player_hands.play("IdleHands")

		# Set up bones
		player_skeleton.add_bone(head_bone.get_bone_id())

func _physics_process(delta):
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Sprint check and stamina cost/regen
		print(current_stamina)
		var current_sprint_mod: float = 1.0
		if Input.is_action_pressed("sprint") and current_stamina > 0 and not is_knocked_out:
			current_sprint_mod = SPRINT_MODIFIER
			current_stamina = clampf(current_stamina - (delta * 25), 0, MAX_STAMINA)
		else:
			current_stamina = clampf(current_stamina + (delta * 10), 0, MAX_STAMINA)

		# Update stamina vignette
		stamina_vignette.set_modulate(Color(1, 1, 1, 1 - (current_stamina / MAX_STAMINA)))

		# Check knockout state, prevent movement
		if current_stamina == 0:
			player_skeleton.physical_bones_start_simulation()
			player_collision.set_disabled(true)
			is_knocked_out = true
			return
		elif is_knocked_out and current_stamina < MAX_STAMINA:
			return
		elif is_knocked_out and current_stamina == MAX_STAMINA:
			player_skeleton.physical_bones_stop_simulation()
			player_collision.set_disabled(false)
			is_knocked_out = false
			return



		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
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
	if is_multiplayer_authority():
		# Camera movement
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x *.005)
			camera.rotate_x(-event.relative.y *.005)
			camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

		# Interact events
		if Input.is_action_just_pressed("interact"):
			if interact_raycast.is_colliding():
				var hit_object: PhysicsBody3D = interact_raycast.get_collider()
				hit_object.interacted_with()

		# Debug events
		if Input.is_action_just_pressed("debug_spawn"):
			world_node.debug_spawn(Vector3(randi_range(-9,9), 0, randi_range(-9,9)))
