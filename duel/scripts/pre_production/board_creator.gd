@tool
class_name BoardCreator
extends Node

@export var width: int = 10
@export var depth: int = 10
@export var height: int = 8
@export var position: Vector3i
var _old_position: Vector3i
var tiles = {}


var tile_view_prefab: PackedScene = preload("res://duel/scenes/tile.tscn")
var tile_selection_indicator_prefab: PackedScene = preload("res://duel/scenes/tile_selection_indicator.tscn")
var marker: Node3D

func _ready() -> void:
	marker = tile_selection_indicator_prefab.instantiate()
	add_child(marker)

	position = Vector3i(0,0,0)
	_old_position = position

func _process(delta) -> void:
	if not position == _old_position:
		_old_position = position
		marker.position = position

func clear():
	for key in tiles:
		tiles[key].free()
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

func GrowArea():
	print("GrowArea Pressed")

func ShrinkArea():
	print("ShrinkArea Pressed")

func Save():
	print("Save Pressed")

func load_tile():
	print("Load Pressed")

func SaveJSON():
	print("SaveJSON Pressed")

func LoadJSON():
	print("LoadJSON Pressed")
