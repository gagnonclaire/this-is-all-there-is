extends CharacterBody3D

@onready var frame: Node3D = $HumanFrame

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var character_name: String = "A Dummy"

func _ready():
	frame.speech_audio_stream.set_bus("Mute")
	frame.stamina_drain_multiplier = 0.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

@rpc("any_peer", "call_local")
func interacted_with():
	frame.set_speech_label("...")
