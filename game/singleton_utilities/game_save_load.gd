extends Node

const GAME_DIRECTORY: String = "user://games/"
const GAME_FILE_EXTENSION: String = ".sav"

func game_filenames() -> PackedStringArray:
	var filenames: PackedStringArray = PackedStringArray()
	var user_data: DirAccess = DirAccess.open("user://")

	if user_data.dir_exists("games"):
		var game_files: DirAccess = DirAccess.open(GAME_DIRECTORY)
		filenames = game_files.get_files()
	else:
		user_data.make_dir("games")

	return filenames

func game_name_available(game_name: String) -> bool:
	if game_name.is_empty():
		return false
	else:
		return not game_filenames().has(game_name + GAME_FILE_EXTENSION)
