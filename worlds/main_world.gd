extends Node

const PLAYER: PackedScene = preload("res://characters/3_character_player/player.tscn")
const HUMAN: PackedScene = preload("res://characters/3_character_human/human_character.tscn")

@export var crodots: int

#TODO This should mostl be handled in the multiplayer manager
func _ready() -> void:
	if MultiplayerManager.is_host:
		start_server()
		crodots = 0
		EventsManager.connect("crodots_gained", _on_crodots_gained)
		EventsManager.connect("crodots_lost", _on_crodots_lost)
	else:
		start_client()

#TODO This should all be handled in the multiplayer manager
func _exit_tree() -> void:
	multiplayer.multiplayer_peer.close()

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		LoadManager.switch_to_main_menu()

func _on_crodots_gained(amount: int) -> void:
	crodots += amount

func _on_crodots_lost(amount: int) -> void:
	crodots -= amount

#TODO Everything below here (minus debug_spawn) should be handled
#TODO by the multiplayer manager
func start_server() -> void:
	#TODO When you start or join a game, go back to menu, then start a
	#TODO new game, we fail to create a server here (null enet_peer)
	#TODO Moving everything to the multiplayer manager might fix this
	MultiplayerManager.enet_peer.create_server(MultiplayerManager.port)
	multiplayer.multiplayer_peer = MultiplayerManager.enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())

func start_client() -> void:
	MultiplayerManager.enet_peer.create_client(MultiplayerManager.join_address, MultiplayerManager.port)
	multiplayer.multiplayer_peer = MultiplayerManager.enet_peer

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
