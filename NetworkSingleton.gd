extends Node

var networkPeer = NetworkedMultiplayerENet.new()
var peers = []
var levelPackedScene = preload("res://Level.tscn")
var levelInstance

signal levelLoaded

var playerScene = preload("res://Player.tscn")

func _ready():
	networkPeer.connect("peer_connected", self, "_peer_connected")
	networkPeer.connect("peer_disconnected", self, "_peer_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	networkPeer.connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")

func create_server(port):
	self.connect("levelLoaded", self, "server_setup_after_load")
	get_tree().change_scene_to(levelPackedScene)
	networkPeer.create_server(port, 2)

func server_setup_after_load():
	levelInstance = get_tree().current_scene
	get_tree().network_peer = networkPeer
	peers.append(1)
	create_player(1)

func create_client(address, port):
	self.connect("levelLoaded", self, "client_setup_after_load")
	get_tree().change_scene_to(levelPackedScene)
	networkPeer.create_client(address, port)

func client_setup_after_load():
	levelInstance = get_tree().current_scene
	get_tree().network_peer = networkPeer

func _peer_connected(peerId):
	peers.append(peerId)
	create_player(peerId)

func _peer_disconnected(peerId):
	peers.remove(peers.find(peerId))
	destroy_player(peerId)

func _connected_to_server():
	create_player(get_tree().get_network_unique_id())

func _connection_failed():
	_server_disconnected()

func _server_disconnected():
	peers.clear()
	get_tree().change_scene("res://Menu.tscn")

func create_player(peerId):
	var spawn
	if(peerId == 1):
		spawn = levelInstance.get_node("RedSpawn")
	else:
		spawn = levelInstance.get_node("BlueSpawn")

	var new_player = playerScene.instance();
	new_player.set_network_master(peerId)
	new_player.name = String(peerId)
	new_player.get_node("Bug").position = spawn.position
	new_player.get_node("Bug").rotation = spawn.rotation
	levelInstance.add_child(new_player)

func destroy_player(peerId):
	levelInstance.remove_node(levelInstance.get_node(String(peerId)))
