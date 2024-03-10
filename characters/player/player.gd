extends CharacterBody3D

const SPEED = 5.0

@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var interact_raycast: RayCast3D = $CameraPivot/Camera3D/InteractRaycast

@onready var world_node: Node = get_parent()
@onready var main_node: Node = world_node.get_parent()

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.current = true

		#anim_player_hands.play("IdleHands")

func _physics_process(delta):
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

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
