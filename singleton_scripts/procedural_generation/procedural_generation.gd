extends Node

const HUMAN_NAMES_PATH: String = "res://singleton_scripts/procedural_generation/human_names.txt"
const HUMAN_LINES_PATH: String = "res://singleton_scripts/procedural_generation/human_dialogue.txt"

var human_names: Array[String]
var human_lines: Array[String]

#region Source File Read On Startup
func _ready() -> void:
	human_names = load_array_from_text(HUMAN_NAMES_PATH)
	human_lines = load_array_from_text(HUMAN_LINES_PATH)

func load_array_from_text(path: String) -> Array[String]:
	var read_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var file_array: Array = Array(read_file.get_as_text().split("\n"))
	read_file.close()

	var string_array: Array[String] = []
	string_array.assign(file_array)
	return string_array

#endregion

#region Text Generation
func get_human_name() -> String:
	# Use -2 to account for base 0 counting extra newline at EoF
	return human_names[randi_range(0, human_names.size() - 2)]

func get_human_lines(count: int) -> Array[String]:
	var lines: Array[String] = []

	for i in range(0, count):
		# Use -2 to account for base 0 counting extra newline at EoF
		var line: String = human_lines[randi_range(0, human_lines.size() - 2)]
		lines.append(line)

	return lines
#endregion
