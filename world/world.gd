extends Node

const PLAYER: PackedScene = preload("res://characters/player/player.tscn")
const HUMAN: PackedScene = preload("res://characters/human/human_character.tscn")
const PORT: int = 9999

@onready var main_node: Node = get_parent()

var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if main_node.is_host:
		start_server()
	else:
		enet_peer.create_client(main_node.join_address, PORT)
		multiplayer.multiplayer_peer = enet_peer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func start_server():
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	#load_map(map_option)
	add_player(multiplayer.get_unique_id())

func add_player(peer_id):
	var player: CharacterBody3D = PLAYER.instantiate()
	player.name = str(peer_id)
	#rpc("sync_load_map", current_map)
	add_child(player)

func remove_player(peer_id):
	var player: CharacterBody3D = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func debug_spawn(position: Vector3):
	rpc("add_human_npc", position)

@rpc("any_peer", "call_local")
func add_human_npc(position: Vector3):
	var npc: CharacterBody3D = HUMAN.instantiate()
	npc.position = position
	add_child(npc)
