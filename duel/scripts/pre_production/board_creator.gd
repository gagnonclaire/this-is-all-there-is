@tool
class_name BoardCreator
extends Node

var save_path = "res://duel/data/levels/"
@export var file_name = "defaultMap.json"

var tile_view_prefab: PackedScene = preload("res://duel/scenes/tile.tscn")
var tile_selection_indicator_prefab: PackedScene = preload("res://duel/scenes/tile_selection_indicator.tscn")
var marker: Node3D

@export var width: int = 10
@export var depth: int = 10
@export var height: int = 8
@export var position: Vector3i
var _old_position: Vector3i
var tiles: Dictionary = {}

func _ready() -> void:
	marker = tile_selection_indicator_prefab.instantiate()
	add_child(marker)

	position = Vector3i(0,0,0)
	_old_position = position

func _process(_delta) -> void:
	if not position == _old_position:
		_old_position = position
		marker.position = position

func clear():
	for position in tiles:
		tiles[position].free()
	tiles.clear()

func create() -> void:
	if not tiles.has(position):
		var tile: Tile = tile_view_prefab.instantiate()
		tile.load(position)
		tiles[position] = tile
		add_child(tile)

func delete():
	if tiles.has(position):
		var tile: Tile = tiles[position]
		tiles.erase(position)
		tile.free()

func save_map():
	var save_map: Dictionary = {
		"version": "1.0.0",
		"tiles": []
	}

	for position: Vector3i in tiles:
		var save_tile: Dictionary = {
			"position_x" : tiles[position].position.x,
			"position_y" : tiles[position].position.y,
			"position_z" : tiles[position].position.z,
			}
		save_map["tiles"].append(save_tile)

	var save_file: String = str(save_path) + str(file_name)
	var save_game: FileAccess = FileAccess.open(save_file, FileAccess.WRITE)

	var json_string: String = JSON.stringify(save_map, "\t", false)
	save_game.store_line(json_string)
	save_game.close()

func load_map():
	clear();

	var save_file: String = str(save_path) + str(file_name)
	if not FileAccess.file_exists(save_file):
		print("Error: file " + str(save_file) + " does not exist")
		return

	var save_game: FileAccess = FileAccess.open(save_file, FileAccess.READ)
	var save_game_json: JSON = JSON.new()
	var load_result = save_game_json.parse(save_game.get_as_text())
	if load_result != OK:
		print("Error: could not load " + str(save_file) + ": " + load_result)
		return

	var load_data: Dictionary = save_game_json.get_data()
	for position: Dictionary in load_data["tiles"]:
		var new_tile: Tile = tile_view_prefab.instantiate()
		var new_tile_position = Vector3i(position["position_x"], position["position_y"], position["position_z"])
		new_tile.load(new_tile_position)
		tiles[new_tile_position] = new_tile
		add_child(new_tile)

	save_game.close()
