class_name BoardEditorMenu
extends PanelContainer

const BOARD_ITEM_SCENE: PackedScene = preload("res://game/ui/menus/board_editor_menu/board_list_item.tscn")

@onready var board_name_entry: LineEdit = $VBoxContainer/CreateNewBoardContainer/BoardNameEntry
@onready var board_list: VBoxContainer = $VBoxContainer/BoardListScrollContainer/BoardList

func _ready() -> void:
	populate_board_item_list()

func _on_create_new_board_button_pressed() -> void:
	if board_name_available(board_name_entry.text):
		SceneChange.switch_to_board_creator(board_name_entry.text)
	else:
		board_name_entry.text = ""
		board_name_entry.placeholder_text = "Name unavailable"

func populate_board_item_list() -> void:
	for board_filename in BoardSaveLoad.board_filenames():
		var board_item: BoardListItem = BOARD_ITEM_SCENE.instantiate()
		board_item.board_name = board_filename
		board_list.add_child(board_item)

func board_name_available(board_name: String) -> bool:
	return not BoardSaveLoad.board_filenames().has(board_name + BoardSaveLoad.BOARD_FILE_EXTENSION)
