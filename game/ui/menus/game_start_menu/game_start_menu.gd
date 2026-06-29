class_name StartGameMenu
extends PanelContainer

const GAME_ITEM_SCENE: PackedScene = preload("res://game/ui/menus/game_start_menu/game_list_item.tscn")

signal start_game(game_name: String)
signal host_game(game_name: String)

@onready var game_name_entry: LineEdit = $VBoxContainer/StartNewGameContainer/GameNameEntry
@onready var game_list: VBoxContainer = $VBoxContainer/GameListScrollContainer/GameList

func _ready():
	populate_game_item_list()

func _on_start_game_button_pressed():
	if game_name_entry.text.is_empty():
		set_default_game_name()

	start_game.emit(game_name_entry)

func _on_host_game_button_pressed():
	if game_name_entry.text.is_empty():
		set_default_game_name()

	host_game.emit(game_name_entry)

func populate_game_item_list():
	for game_filename in GameSaveLoad.game_filenames():
		var game_item: GameListItem = GAME_ITEM_SCENE.instantiate()
		game_item.game_name = game_filename.get_slice(".", 0)
		game_list.add_child(game_item)

func set_default_game_name():
	var default_game_name_base: String = "new_game_"
	var name_number: int = 1
	while not GameSaveLoad.game_name_available(default_game_name_base + str(name_number)):
		name_number += 1
		if name_number >= 99:
			break

	game_name_entry.text = default_game_name_base + str(name_number)
