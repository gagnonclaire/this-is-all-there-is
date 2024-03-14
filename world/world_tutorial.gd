extends Node

const PLAYER: PackedScene = preload("res://characters/player_character/player.tscn")
const HUMAN: PackedScene = preload("res://characters/human_character/human_character.tscn")
const PORT: int = 9999

@onready var main_node: Node = get_parent()

var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if main_node.is_host:
		start_server()
	else:
		enet_peer.create_client(main_node.join_address, PORT)
		multiplayer.multiplayer_peer = enet_peer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		main_node.return_to_menu()

func start_server() -> void:
	# This is thworing a bunch of multiplayer peer errors
	# when you exit to main menu then start another server
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())

func add_player(peer_id) -> void:
	var player: CharacterBody3D = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id) -> void:
	var player: CharacterBody3D = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func debug_spawn(position: Vector3, rotation: Vector3) -> void:
	var npc: CharacterBody3D = HUMAN.instantiate()
	npc.set_position(position)
	npc.set_rotation(rotation)
	add_child(npc, true)
