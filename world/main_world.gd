extends Node

const _PLAYER_CONTROLLER: PackedScene = preload("res://characters/3_controllers/player_controller/player_controller.tscn")

@export var crodots: int

#TODO This should mostl be handled in the multiplayer manager
func _ready() -> void:
	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player(multiplayer.get_unique_id())

		crodots = 0
		EventsManager.connect("crodots_gained", _on_crodots_gained)
		EventsManager.connect("crodots_lost", _on_crodots_lost)

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

func _add_player(peer_id) -> void:
	var player: Node = _PLAYER_CONTROLLER.instantiate()
	player.name = str(peer_id)
	add_child(player)

func _remove_player(peer_id) -> void:
	var player: Node = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
