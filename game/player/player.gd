class_name Player
extends Node

const CHARACTER_CONTROLLER_SCENE: PackedScene = preload("res://game/player/controllers/character_controller/character_controller.tscn")

var player_name: String
var character_controller: CharacterController

func _ready():
	set_multiplayer_authority(str(name).to_int())
	create_character_controller()
	character_controller.create_base_character_body()

func create_character_controller():
	character_controller = CHARACTER_CONTROLLER_SCENE.instantiate()
	add_child(character_controller)
