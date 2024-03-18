extends Node

var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var join_address: String = ""
var port: int = 9999
var is_host: bool = false
