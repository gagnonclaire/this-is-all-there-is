class_name Player
extends Node

var player_name: String

func _ready():
	set_multiplayer_authority(str(name).to_int())
