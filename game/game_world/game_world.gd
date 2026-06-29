class_name GameWorld
extends Node

@onready var board_overlay: BoardOverlay = $BoardOverlay

const PLAYER: PackedScene = preload("res://game/player/player.tscn")

signal exit_game

var game_name: String
var is_host: bool = false
var enet_peer: ENetMultiplayerPeer
var port: int = 9999

#TODO move into dedicated host/join functions
func _ready():
	if not GameSaveLoad.game_name_available(game_name):
		GameSaveLoad.load_game(game_name, self)

	if is_host:
		enet_peer = ENetMultiplayerPeer.new()
		enet_peer.create_server(port)
		multiplayer.multiplayer_peer = enet_peer

		multiplayer.peer_connected.connect(add_player)
		multiplayer.peer_disconnected.connect(remove_player)
		add_player(multiplayer.get_unique_id())

func _exit_tree():
	pass
	#multiplayer.multiplayer_peer.close()

func _unhandled_input(_event):
	if Input.is_action_just_pressed("menu"):
		GameSaveLoad.save_game(game_name)
		exit_game.emit()
	if Input.is_action_just_pressed(Keybinds.TOGGLE_MOUSE_CAPTURE):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed(Keybinds.TOGGLE_BOARD_OVERLAY):
		toggle_board_mode()

func start_server():
	pass

func join_server(address: String):
	pass

func toggle_board_mode():
	if board_overlay.active:
		board_overlay.make_inactive()
		#main_player.current_frame.camera.make_current()
	#else:
		#board_overlay.make_active(
			#player_controller.current_frame.camera.global_position,
			#player_controller.current_frame.camera.global_rotation
		#)

func add_player(peer_id):
	var player: Node = PLAYER.instantiate()
	player.name = str(peer_id)
	player.player_name = "player" + str(multiplayer.get_unique_id())
	add_child(player)
#
	#player_controller = player
#
	#if multiplayer.is_server():
		#main_player = player

func remove_player(peer_id):
	var player: Node = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
