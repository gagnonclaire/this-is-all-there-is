extends Node

const BOARD_DIRECTORY: String = "user://boards/"
const BOARD_FILE_EXTENSION: String = ".json"

func board_filenames() -> PackedStringArray:
	var filenames: PackedStringArray = PackedStringArray()
	var user_data: DirAccess = DirAccess.open("user://")

	if user_data.dir_exists("boards"):
		var board_files: DirAccess = DirAccess.open(BOARD_DIRECTORY)
		filenames = board_files.get_files()
	else:
		user_data.make_dir("boards")

	return filenames
