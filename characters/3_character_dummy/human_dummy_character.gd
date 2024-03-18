extends CharacterBody3D

@onready var frame: Node3D = $HumanFrame

var examine_text: String = "A Dummy"

func _ready():
	frame.speech_audio_stream.set_bus("Mute")
	frame.stamina_drain_multiplier = 0.0

@rpc("any_peer", "call_local")
func interacted_with():
	frame.set_speech_label("...")
