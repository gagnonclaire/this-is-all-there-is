class_name MainMenuControls
extends HBoxContainer

@onready var sub_menu_container: MarginContainer = $SubMenuContainer
@onready var start_game_menu: PanelContainer = $SubMenuContainer/StartGameMenu
@onready var join_game_menu: PanelContainer = $SubMenuContainer/JoinGameMenu
@onready var board_editor_menu: PanelContainer = $SubMenuContainer/BoardEditorMenu
@onready var settings_menu: PanelContainer = $SubMenuContainer/SettingsMenu

func _ready() -> void:
	close_all_menus()

func _on_start_game_button_pressed() -> void:
	switch_to(start_game_menu)

func _on_join_game_button_pressed() -> void:
	switch_to(join_game_menu)

func _on_board_editor_button_pressed():
	switch_to(board_editor_menu)

func _on_settings_button_pressed() -> void:
	switch_to(settings_menu)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func switch_to(item: PanelContainer) -> void:
	close_all_menus()
	item.show()

func close_all_menus() -> void:
	for menu in sub_menu_container.get_children():
		menu.hide()
