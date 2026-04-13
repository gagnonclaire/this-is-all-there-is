class_name GameWorld
extends Node

@onready var board_overlay: BoardOverlay = $BoardOverlay
@onready var board_controller: BoardController = $BoardController

const _PLAYER_CONTROLLER: PackedScene = preload("res://game/characters/3_controllers/player_controller/player_controller.tscn")

@export var credits: int

var game_name: String
var main_player

#TODO This should mostly be handled in the multiplayer manager
func _ready() -> void:
	if not GameSaveLoad.game_name_available(game_name):
		GameSaveLoad.load_game(game_name, self)

	if is_multiplayer_authority():
		multiplayer.peer_connected.connect(_add_player)
		multiplayer.peer_disconnected.connect(_remove_player)
		_add_player(multiplayer.get_unique_id())

		credits = 0
		#EventsManager.connect("credits_gained", _on_credits_gained)
		#EventsManager.connect("credits_lost", _on_credits_lost)

#TODO This should all be handled in the multiplayer manager
func _exit_tree() -> void:
	multiplayer.multiplayer_peer.close()

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		GameSaveLoad.save_game(game_name)
		SceneChange.switch_to_main_menu()
	if Input.is_action_just_pressed(Keybinds.TOGGLE_MOUSE_CAPTURE):
		EventsManager.toggle_mouse()
	if Input.is_action_just_pressed(Keybinds.TOGGLE_BOARD_OVERLAY):
		toggle_board_mode()

func toggle_board_mode() -> void:
	if board_controller.active:
		board_controller.make_inactive()
		board_overlay.hide()
		main_player.current_frame.camera.make_current()
	else:
		board_controller.make_active()
		board_overlay.show()

func _on_credits_gained(amount: int) -> void:
	credits += amount

func _on_credits_lost(amount: int) -> void:
	credits -= amount

func _add_player(peer_id) -> void:
	var player: Node = _PLAYER_CONTROLLER.instantiate()
	player.name = str(peer_id)
	add_child(player)

	if multiplayer.is_server():
		main_player = player

func _remove_player(peer_id) -> void:
	var player: Node = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
