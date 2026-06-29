class_name MainMenu
extends CanvasLayer

signal start_game(game_name: String)
signal host_game(game_name: String)

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(_event):
	if Input.is_action_just_pressed("menu"):
		get_tree().quit()

func _on_main_menu_controls_start_game(game_name):
	start_game.emit(game_name)

func _on_main_menu_controls_host_game(game_name):
	host_game.emit(game_name)
