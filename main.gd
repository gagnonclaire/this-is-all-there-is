# Top level parent node directly under the root window,
# doesn't do much on its own
#
# LoadManager uses it as an anchor point to add other nodes like
# MainMenu and MainWorld

extends Node

func _ready() -> void:
	LoadManager.show_main_menu()
