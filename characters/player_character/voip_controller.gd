extends Node

@onready var input: AudioStreamPlayer3D = $Input
@onready var player_node: Node = get_parent()

var idx: int
var effect: AudioEffectCapture
var playback: AudioStreamGeneratorPlayback
var output: AudioStreamPlayer3D
var owner_id: int

func _enter_tree():
	set_multiplayer_authority(owner_id)

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		print(input.stream)
		input.play()

		idx = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(idx, 0)

	playback = output.get_stream_playback()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if is_multiplayer_authority():
		if (effect.can_get_buffer(512)):
			send_data.rpc(effect.get_buffer(512))
			if player_node.is_severed:
				send_data_self(effect.get_buffer(512))

		effect.clear_buffer()

@rpc("any_peer", "call_local", "reliable")
func send_data(data : PackedVector2Array):
	for i in range(0,512):
		playback.push_frame(data[i])

func send_data_self(data : PackedVector2Array):
	for i in range(0,512):
		playback.push_frame(data[i])
