extends CharacterBody3D

const SEVER_STAMINA_DRAIN_RATE: float = 0.0

@onready var frame: Node3D = $HumanFrame
@onready var camera: Camera3D = frame.camera

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	frame.speech_audio_stream.set_bus("Mute")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func interacted_with():
	frame.set_speech_label.rpc("...")
