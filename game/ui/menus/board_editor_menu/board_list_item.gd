class_name BoardListItem
extends HBoxContainer

@onready var board_name_label: Label = $BoardName

var board_name: String

func _ready() -> void:
	board_name_label.text = board_name

func _on_load_board_button_pressed() -> void:
	SceneChange.switch_to_board_creator(board_name)
