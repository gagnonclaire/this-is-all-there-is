extends Node

const PLAYER: PackedScene = preload("res://characters/3_character_player/player.tscn")
const HUMAN: PackedScene = preload("res://characters/3_character_human/human_character.tscn")

@export var crodots: int

@onready var main_node: Node = get_parent()

var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var join_address: String = ""
var port: int = 9999
var is_host: bool = false

func _ready() -> void:
	if is_host:
		start_server()
		crodots = 0
		Events.connect("crodots_gained", _on_crodots_gained)
		Events.connect("crodots_lost", _on_crodots_lost)
	else:
		start_client()

func _exit_tree() -> void:
	multiplayer.multiplayer_peer.close()

func _process(_delta) -> void:
	pass

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		main_node.return_to_menu()

func _on_crodots_gained(amount: int) -> void:
	crodots += amount

func _on_crodots_lost(amount: int) -> void:
	crodots -= amount

func start_server() -> void:
	#TODO When you start or join a game, go back to menu, then start a
	#TODO new game, we fail to create a server here (null enet_peer)
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
