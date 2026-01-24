extends Node

const GAME_DIRECTORY: String = "user://games/"
const GAME_FILE_EXTENSION: String = ".tres"
const PERSIST_DATA_GROUP: String = "persist_data"

func _ready() -> void:
	_init_games_directory()

func _init_games_directory() -> void:
	var user_data: DirAccess = DirAccess.open("user://")
	if not user_data.dir_exists("games"):
		user_data.make_dir("games")

func game_filenames() -> PackedStringArray:
	var filenames: PackedStringArray = PackedStringArray()
	var user_data: DirAccess = DirAccess.open("user://")

	if user_data.dir_exists("games"):
		var game_files: DirAccess = DirAccess.open(GAME_DIRECTORY)
		filenames = game_files.get_files()

	return filenames

func game_name_available(game_name: String) -> bool:
	return not game_filenames().has(game_name + GAME_FILE_EXTENSION)

func full_game_path(game_name) -> String:
	return GAME_DIRECTORY + game_name + GAME_FILE_EXTENSION

func save_game(game_name: String) -> void:
	var saved_game := SavedGame.new()
	saved_game.save_version = 1

	var saved_data:Array[SavedData] = []
	get_tree().call_group(PERSIST_DATA_GROUP, "on_save_game", saved_data)
	saved_game.saved_data = saved_data

	ResourceSaver.save(saved_game, GAME_DIRECTORY + game_name + GAME_FILE_EXTENSION)

func load_game(game_name: String, parent_node: Node) -> void:
	if game_name_available(game_name):
		return

	var saved_game:SavedGame = ResourceLoader.load(full_game_path(game_name)) as SavedGame
	if saved_game == null:
		return

	# clear the stage
	get_tree().call_group(PERSIST_DATA_GROUP, "on_before_load_game")

	# restore all dynamic game elements
	for item in saved_game.saved_data:
		# load the scene of the saved item and create a new instance
		var scene := load(item.scene_path) as PackedScene
		var restored_node = scene.instantiate()
		# add it to the world root
		parent_node.add_child(restored_node)
		# and run any custom load logic
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(item)

func delete_game(game_name: String) -> void:
	if not game_name_available(game_name):
		var user_data: DirAccess = DirAccess.open("user://")
		user_data.remove(GAME_DIRECTORY + game_name + GAME_FILE_EXTENSION)
