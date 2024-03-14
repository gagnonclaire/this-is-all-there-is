extends Node

const PLAYER: PackedScene = preload("res://characters/player_character/player.tscn")
const HUMAN: PackedScene = preload("res://characters/human_character/human_character.tscn")

@onready var main_node: Node = get_parent()

# Network vars
var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var join_address: String = ""
var port: int = 9999
var is_host: bool = false

func _ready() -> void:
	if is_host:
		start_server()
	else:
		start_client()

func _exit_tree() -> void:
	multiplayer.multiplayer_peer.close()

func _process(_delta) -> void:
	pass

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		main_node.return_to_menu()

func start_server() -> void:
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())

func start_client() -> void:
	enet_peer.create_client(join_address, port)
	multiplayer.multiplayer_peer = enet_peer

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
