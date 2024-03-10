extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	var main_menu_scene: PackedScene = load("res://main_menu/main_menu.tscn")
	add_child(main_menu_scene.instantiate())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
