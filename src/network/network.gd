extends Node


const PLAYER: PackedScene = preload("uid://ed3ymhltg8qv")
const TUBE_CONTEXT: Resource = preload("uid://b5qrd57ir8f10")


var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var tube_client: TubeClient = TubeClient.new()
var tube_enabled: bool = true

var port: int = 9999
var ip_address: String = '127.0.0.1'


func _ready() -> void:
	if tube_enabled:
		tube_client.context = TUBE_CONTEXT
		get_tree().root.add_child.call_deferred(tube_client)


func tube_create() -> void:
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	tube_client.create_session()
	add_player(1)


func tube_join(session_id: String) -> void:
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	tube_client.join_session(session_id)


func start_server() -> void:
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)


func join_server() -> void:
	enet_peer.create_client(ip_address, port)
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.multiplayer_peer = enet_peer


func on_connected_to_server() -> void:
	add_player(multiplayer.get_unique_id())


func add_player(peer_id: int) -> void:
	if peer_id == 1 and multiplayer.multiplayer_peer is ENetMultiplayerPeer:
		return
	
	var new_player: CharacterBody3D = PLAYER.instantiate()
	new_player.name = str(peer_id)
	
	new_player.position = Vector3(randf_range(-5.0, 5.0), 1.0, randf_range(-5.0, 5.0))
	get_tree().current_scene.add_child(new_player, true)


func remove_player(peer_id: int) -> void:
	if peer_id == 1:
		leave_server()
	
	var players: Array[Node] = get_tree().get_nodes_in_group('Player')
	var player_to_remove: int = players.find_custom(func(item: Node) -> bool: return item.name == str(peer_id))
	
	if player_to_remove != -1:
		players[player_to_remove].queue_free()


func leave_server() -> void:
	if tube_enabled:
		tube_client.leave_session()
	
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	clean_up_signals()
	get_tree().reload_current_scene()


func clean_up_signals() -> void:
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(remove_player)
	multiplayer.connected_to_server.disconnect(on_connected_to_server)


func _exit_tree() -> void:
	if tube_enabled:
		tube_client.leave_session()
