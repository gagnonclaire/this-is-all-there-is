extends Node

const MAIN_MENU: PackedScene = preload("res://game/ui/menus/main_menu/main_menu.tscn")
const GAME_WORLD: PackedScene = preload("res://game/game_world/game_world.tscn")
const BOARD_EDITOR: PackedScene = preload("res://game/board_editor/board_editor.tscn")

@onready var _main_node: Node = get_node("/root/Main")

func switch_to_main_menu() -> void:
	_unload_main_children()
	_main_node.add_child(MAIN_MENU.instantiate())

func switch_to_start_game_world(game_name: String, host: bool) -> void:
	_unload_main_children()

	if host:
		MultiplayerManager.start_server()

	var game_world: GameWorld = GAME_WORLD.instantiate()
	game_world.game_name = game_name
	_main_node.add_child(game_world)

func switch_to_join_game_world(address: String) -> void:
	_unload_main_children()

	MultiplayerManager.start_client(address)
	_main_node.add_child(GAME_WORLD.instantiate())

func switch_to_board_creator(board_name) -> void:
	_unload_main_children()

	var board_editor: BoardEditor = BOARD_EDITOR.instantiate()
	board_editor.board_name = board_name
	_main_node.add_child(BOARD_EDITOR.instantiate())

func _unload_main_children() -> void:
	for child in _main_node.get_children():
		child.queue_free()
