class_name GameStartMenu
extends PanelContainer

const GAME_ITEM_SCENE: PackedScene = preload("res://game/ui/menus/game_start_menu/game_list_item.tscn")

@onready var game_name_entry: LineEdit = $VBoxContainer/StartNewGameContainer2/GameNameEntry
@onready var game_list: VBoxContainer = $VBoxContainer/GameListScrollContainer/GameList

func _ready() -> void:
	populate_game_item_list()

func _on_game_start_button_pressed() -> void:
	if GameSaveLoad.game_name_available(game_name_entry.text):
		SceneChange.switch_to_start_game_world(game_name_entry.text, false)
	else:
		game_name_entry.text = ""
		game_name_entry.placeholder_text = "Name unavailable"

func _on_game_start_host_button_pressed() -> void:
	if GameSaveLoad.game_name_available(game_name_entry.text):
		SceneChange.switch_to_start_game_world(game_name_entry.text, true)
	else:
		game_name_entry.text = ""
		game_name_entry.placeholder_text = "Name unavailable"

func populate_game_item_list() -> void:
	for game_filename in GameSaveLoad.game_filenames():
		var game_item: GameListItem = GAME_ITEM_SCENE.instantiate()
		game_item.game_name = game_filename
		game_list.add_child(game_item)
