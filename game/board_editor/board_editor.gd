class_name BoardEditor
extends Node

const BOARD_CREATOR_CONTROLLER: PackedScene = preload("res://game/board_editor/board_editor_controller.tscn")
const TILE_PREFAB: PackedScene = preload("res://game/board_editor/tile.tscn")

var board_name = "new_board"
var current_position: Vector3i = Vector3i(0,0,0)
var old_position: Vector3i = Vector3i(0,0,0)
var tiles: Dictionary = {} # Vector3i keyed tile dictionary

func _ready() -> void:
	if board_already_exists():
		load_board()

	var controller: Node = BOARD_CREATOR_CONTROLLER.instantiate()
	add_child(controller)

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		SceneChange.switch_to_main_menu()

func board_already_exists() -> bool:
	var board_filenames: PackedStringArray = BoardSaveLoad.board_filenames()
	return board_filenames.has(board_filename())

func board_filename() -> String:
	return board_name + BoardSaveLoad.BOARD_FILE_EXTENSION

func clear_board():
	for position in tiles:
		tiles[position].free()
	tiles.clear()

func create() -> void:
	if not tiles.has(current_position):
		var tile: Tile = TILE_PREFAB.instantiate()
		tile.load(current_position)
		tiles[current_position] = tile
		add_child(tile)

func delete():
	if tiles.has(current_position):
		var tile: Tile = tiles[current_position]
		tiles.erase(current_position)
		tile.free()

func save_board():
	#TODO board class to handle all board model logic
	var board: Dictionary = {
		"version": "1.0.0",
		"tiles": []
	}

	for position: Vector3i in tiles:
		#TODO also pull tile out into it's own object
		var tile: Dictionary = {
			"position_x" : tiles[position].position.x,
			"position_y" : tiles[position].position.y,
			"position_z" : tiles[position].position.z,
			}
		board["tiles"].append(tile)

	var save_file_name: String = board_name + ".json"
	var save_file_write: FileAccess = FileAccess.open(save_file_name, FileAccess.WRITE)

	var board_json: String = JSON.stringify(board)
	save_file_write.store_line(board_json)
	save_file_write.close()

func load_board():
	clear_board();

	if not FileAccess.file_exists(board_filename()):
		print("Error: file " + str(board_filename()) + " does not exist")
		return

	var save_file_read: FileAccess = FileAccess.open(board_filename(), FileAccess.READ)
	var board_json: JSON = JSON.new()

	if board_json.parse(save_file_read.get_as_text()) != OK:
		print("Error: could not load " + str(board_filename()))
		return

	var board: Dictionary = board_json.get_data()
	for position: Dictionary in board["tiles"]:
		var new_tile: Tile = TILE_PREFAB.instantiate()
		var new_tile_position = Vector3i(position["position_x"], position["position_y"], position["position_z"])
		new_tile.load(new_tile_position)
		tiles[new_tile_position] = new_tile
		add_child(new_tile)

	save_file_read.close()
