class_name GameStartMenu
extends PanelContainer

const GAME_ITEM_SCENE: PackedScene = preload("res://game/ui/menus/game_start_menu/game_list_item.tscn")

@onready var game_name_entry: LineEdit = $VBoxContainer/StartNewGameContainer2/GameNameEntry
@onready var game_list: VBoxContainer = $VBoxContainer/GameListScrollContainer/GameList

func _ready() -> void:
	populate_game_item_list()

func _on_game_start_button_pressed() -> void:
	if game_name_entry.text.is_empty():
		set_default_game_name()
	start_game_with_game_name(game_name_entry.text, false)

func _on_game_start_host_button_pressed() -> void:
	if game_name_entry.text.is_empty():
		set_default_game_name()
	start_game_with_game_name(game_name_entry.text, true)

func populate_game_item_list() -> void:
	for game_filename in GameSaveLoad.game_filenames():
		var game_item: GameListItem = GAME_ITEM_SCENE.instantiate()
		game_item.game_name = game_filename.get_slice(".", 0)
		game_list.add_child(game_item)

func set_default_game_name() -> void:
	var default_game_name_base: String = "new_game_"
	var name_number: int = 1
	while not GameSaveLoad.game_name_available(default_game_name_base + str(name_number)):
		name_number += 1
		if name_number >= 99:
			break

	game_name_entry.text = default_game_name_base + str(name_number)

func start_game_with_game_name(game_name: String, host: bool) -> void:
	if GameSaveLoad.game_name_available(game_name):
		SceneChange.switch_to_start_game_world(game_name, host)
	else:
		game_name_entry.text = ""
		game_name_entry.placeholder_text = "Name unavailable"
