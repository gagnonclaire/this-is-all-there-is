extends Node

const MAIN_MENU_SCENE: PackedScene = preload("res://game/main_scene/main_menu.tscn")
const GAME_WORLD_SCENE: PackedScene = preload("res://game/main_scene/game_world.tscn")
const BOARD_EDITOR_SCENE: PackedScene = preload("res://game/main_scene/board_editor.tscn")

var main_menu: MainMenu = null
var game_world: GameWorld = null
var board_editor: BoardEditor = null

func _ready():
	start_main_menu()

func _on_main_menu_start_game(game_name: String):
	start_game_world(game_name)

func _on_main_menu_host_game(game_name: String):
	host_game_world(game_name)

func _on_main_menu_join_game(address: String):
	join_game_world(address)

func _on_game_world_exit_game():
	start_main_menu()

func start_main_menu():
	unload_children()

	main_menu = MAIN_MENU_SCENE.instantiate()
	main_menu.start_game.connect(_on_main_menu_start_game)
	main_menu.host_game.connect(_on_main_menu_host_game)
	main_menu.join_game.connect(_on_main_menu_host_game)
	add_child(main_menu)

func start_game_world(game_name: String):
	unload_children()

	game_world = GAME_WORLD_SCENE.instantiate()
	game_world.game_name = game_name
	game_world.exit_game.connect(_on_game_world_exit_game)
	add_child(game_world)

func host_game_world(game_name: String):
	unload_children()

	game_world = GAME_WORLD_SCENE.instantiate()
	game_world.game_name = game_name
	game_world.exit_game.connect(_on_game_world_exit_game)
	game_world.offline = false
	add_child(game_world)

	game_world.start_server()

func join_game_world(address: String):
	unload_children()

	game_world = GAME_WORLD_SCENE.instantiate()
	game_world.exit_game.connect(_on_game_world_exit_game)
	add_child(game_world)

	game_world.join_server(address)

func switch_to_board_editor(board_name):
	unload_children()

	board_editor = BOARD_EDITOR_SCENE.instantiate()
	board_editor.board_name = board_name
	add_child(board_editor.instantiate())

func unload_children():
	for child in get_children():
		child.queue_free()
