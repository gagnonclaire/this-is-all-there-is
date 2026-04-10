class_name BoardEditorMenu
extends PanelContainer

const BOARD_ITEM_SCENE: PackedScene = preload("res://game/ui/menus/board_editor_menu/board_list_item.tscn")

@onready var board_name_entry: LineEdit = $VBoxContainer/CreateNewBoardContainer/BoardNameEntry
@onready var board_list: VBoxContainer = $VBoxContainer/BoardListScrollContainer/BoardList

func _ready() -> void:
	populate_board_item_list()

func _on_create_new_board_button_pressed() -> void:
	if board_name_entry.text.is_empty():
		set_default_board_name()
	create_board_with_board_name(board_name_entry.text)

func populate_board_item_list() -> void:
	for board_filename in BoardSaveLoad.board_filenames():
		var board_item: BoardListItem = BOARD_ITEM_SCENE.instantiate()
		board_item.board_name = board_filename
		board_list.add_child(board_item)

func set_default_board_name() -> void:
	var default_board_name_base: String = "new_board_"
	var name_number: int = 1
	while not BoardSaveLoad.board_name_available(default_board_name_base + str(name_number)):
		name_number += 1
		if name_number >= 99:
			break

	board_name_entry.text = default_board_name_base + str(name_number)

func create_board_with_board_name(board_name: String) -> void:
	if BoardSaveLoad.board_name_available(board_name):
		SceneChange.switch_to_board_creator(board_name)
	else:
		board_name_entry.text = ""
		board_name_entry.placeholder_text = "Name unavailable"
