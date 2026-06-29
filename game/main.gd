extends Node

const MAIN_MENU: PackedScene = preload("res://game/ui/menus/main_menu/main_menu.tscn")
const GAME_WORLD: PackedScene = preload("res://game/game_world/game_world.tscn")
const BOARD_EDITOR: PackedScene = preload("res://game/board_editor/board_editor.tscn")

func _ready():
	load_main_menu()

func _on_main_menu_start_game(game_name):
	start_game_world(game_name)

func _on_main_menu_host_game(game_name):
	host_game_world(game_name)

func _on_game_world_exit_game():
	load_main_menu()

func load_main_menu():
	unload_children()

	var main_menu: MainMenu = MAIN_MENU.instantiate()
	main_menu.start_game.connect(_on_main_menu_start_game)
	main_menu.host_game.connect(_on_main_menu_host_game)
	add_child(MAIN_MENU.instantiate())

func start_game_world(game_name: String):
	unload_children()

	var game_world: GameWorld = GAME_WORLD.instantiate()
	game_world.game_name = game_name
	game_world.exit_game.connect(_on_game_world_exit_game)
	add_child(game_world)

func host_game_world(game_name: String):
	unload_children()

	var game_world: GameWorld = GAME_WORLD.instantiate()
	game_world.game_name = game_name
	game_world.exit_game.connect(_on_game_world_exit_game)
	add_child(game_world)

	game_world.start_server()


func join_game_world(address: String):
	unload_children()

	var game_world: GameWorld = GAME_WORLD.instantiate()
	game_world.exit_game.connect(_on_game_world_exit_game)
	add_child(game_world)

	game_world.join_server(address)

func switch_to_board_creator(board_name):
	unload_children()

	var board_editor: BoardEditor = BOARD_EDITOR.instantiate()
	board_editor.board_name = board_name
	add_child(BOARD_EDITOR.instantiate())

func unload_children():
	for child in get_children():
		child.queue_free()
