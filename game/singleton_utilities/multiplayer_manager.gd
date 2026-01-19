extends Node

var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port: int = 9999

func start_server() -> void:
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer

func start_client(join_address) -> void:
	enet_peer.create_client(join_address, port)
	multiplayer.multiplayer_peer = enet_peer
