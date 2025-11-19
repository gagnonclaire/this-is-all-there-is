class_name BoardCreator
extends Node

const BOARD_CREATOR_CONTROLLER: PackedScene = preload("res://game/board_creator/board_creator_controller.tscn")
const TILE_PREFAB: PackedScene = preload("res://game/board_creator/tile.tscn")
const TILE_INDICATOR_PREFAB: PackedScene = preload("res://game/board_creator/tile_indicator.tscn")

#TODO make name and path editable in the in-game editor, expose controls for general vars
var file_name = "customBoard.json"
var save_path = "res://data/boards/"
var marker: Node3D
var width: int = 10
var depth: int = 10
var height: int = 10
var current_position: Vector3i = Vector3i(0,0,0)

var old_position: Vector3i = Vector3i(0,0,0)
var tiles: Dictionary = {} # Vector3i keyed tile dictionary

func _ready() -> void:
	marker = TILE_INDICATOR_PREFAB.instantiate()
	add_child(marker)

	var controller: Node = BOARD_CREATOR_CONTROLLER.instantiate()
	add_child(controller)

func _process(_delta) -> void:
	#TODO move this to be event driven on click
	if current_position != old_position:
		old_position = current_position
		marker.position = current_position

func _unhandled_input(_event) -> void:
	if Input.is_action_just_pressed("menu"):
		LoadManager.switch_to_main_menu()

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

	var save_file_name: String = str(save_path) + str(file_name)
	var save_file_write: FileAccess = FileAccess.open(save_file_name, FileAccess.WRITE)

	var board_json: String = JSON.stringify(board)
	save_file_write.store_line(board_json)
	save_file_write.close()

func load_board():
	clear_board();

	var save_file_name: String = str(save_path) + str(file_name)
	if not FileAccess.file_exists(save_file_name):
		print("Error: file " + str(save_file_name) + " does not exist")
		return

	var save_file_read: FileAccess = FileAccess.open(save_file_name, FileAccess.READ)
	var board_json: JSON = JSON.new()

	if board_json.parse(save_file_read.get_as_text()) != OK:
		print("Error: could not load " + str(save_file_name))
		return

	var board: Dictionary = board_json.get_data()
	for position: Dictionary in board["tiles"]:
		var new_tile: Tile = TILE_PREFAB.instantiate()
		var new_tile_position = Vector3i(position["position_x"], position["position_y"], position["position_z"])
		new_tile.load(new_tile_position)
		tiles[new_tile_position] = new_tile
		add_child(new_tile)

	save_file_read.close()
