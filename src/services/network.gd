class_name Network
extends Node

const PORT = 4433
const MAX_CLIENTS = 1

#-----------------------------------------------------------------#
## Only emitted on server
signal player_joined
## Only emitted on server
signal player_left


func start_server() -> Error:
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CLIENTS)
	if error != OK:
		Log.error("error on creating server: %s" % error_string(error))
		return error

	Player.id = 0
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_joined)
	Log.info("Server created at port %s" % PORT)
	multiplayer.peer_disconnected.connect(_on_player_left)
	return OK


func terminate_server() -> void:
	multiplayer.peer_connected.disconnect(_on_player_joined)
	multiplayer.peer_disconnected.disconnect(_on_player_left)
	Log.info("Server terminated at port %s" % PORT)
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()


func _on_player_joined(id: int) -> void:
	Log.info("Player %d joined!" % id)
	player_joined.emit()


func _on_player_left(id: int) -> void:
	Log.info("Player %d left!" % id)
	player_left.emit()

#-----------------------------------------------------------------#
const CONNECTION_SUCCESS_MESSAGE = "Connected to server %s (unique id: %d)"
const CONNECTION_FAILURE_MESSAGE = "Connection to server %s failed"
const DISCONNECTION_MESSAGE = "Disconnected from server %s (unique id: %d)"


func start_client(ip_string: String) -> Error:
	Log.debug("Client try connecting to %s" % ip_string)
	if not ip_string.is_valid_ip_address():
		if not IP.resolve_hostname(ip_string):
			Log.error("Not valid ip string/ hostname")

	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(ip_string, PORT)
	if error != OK:
		Log.error("error on creating server: %s" % error_string(error))
		return error

	Player.id = 1
	multiplayer.multiplayer_peer = peer
	var network_info := [ip_string, multiplayer.get_unique_id()]
	multiplayer.connected_to_server.connect(Log.info.bind(CONNECTION_SUCCESS_MESSAGE % network_info), CONNECT_ONE_SHOT)
	multiplayer.connection_failed.connect(Log.error.bind(CONNECTION_FAILURE_MESSAGE % ip_string, CONNECT_ONE_SHOT))
	multiplayer.server_disconnected.connect(Log.info.bind(DISCONNECTION_MESSAGE % network_info), CONNECT_ONE_SHOT)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	return OK


func terminate_client() -> void:
	multiplayer.server_disconnected.disconnect(_on_server_disconnected)
	Log.info("Client terminated at port %s" % PORT)
	multiplayer.multiplayer_peer = null


signal server_disconnected


func _on_server_disconnected() -> void:
	server_disconnected.emit()


#-----------------------------------------------------------------#
static func is_server() -> bool:
	if instance.multiplayer.multiplayer_peer == null:
		return false
	if instance.multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	return instance.multiplayer.is_server()


static func is_client() -> bool:
	if instance.multiplayer.multiplayer_peer == null:
		return false
	if instance.multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	return not instance.multiplayer.is_server()


#-----------------------------------------------------------------#
static func get_local_ip() -> String:
	for ip_string in IP.get_local_addresses():
		if ip_string.begins_with("192.168."):
			return ip_string
	return ""


#-----------------------------------------------------------------#
func rpc_call(node_path: NodePath, function_name: StringName, ...args) -> void:
	rpc_callv(node_path, function_name, args)


func rpc_callv(node_path: NodePath, function_name: StringName, args) -> void:
	Log.debug("creating rpc call on $%s::%s" % [node_path, function_name])
	_handle_rpc_call.rpc(node_path, function_name, var_to_bytes(args))


@rpc("any_peer", "call_remote", "reliable")
func _handle_rpc_call(node_path: NodePath, function_name: StringName, packed_args: PackedByteArray) -> void:
	Log.debug("handling rpc call on $%s::%s" % [node_path, function_name])
	var args = bytes_to_var(packed_args)
	if args is not Array:
		Log.error("The args received from remote rpc is not an Array")
		return

	var node := Game.instance.get_node_and_resource(node_path)
	var object: Object = node[1] if node[1] else node[0]
	if not object:
		Log.error("rpc_call Remote Node %s does not exist" % node_path)
		return

	if not object.has_method(function_name):
		Log.error("rpc_call Remote Node %s does not have function: %s" % [node_path, function_name])
		return

	object.callv(function_name, args)

#-----------------------------------------------------------------#
static var instance: Network


func _init() -> void:
	#assert(not instance, "a singleton already exists")
	instance = self


func _to_string() -> String:
	if not multiplayer or not multiplayer.multiplayer_peer.get_connection_status():
		return str(null)
	return ("Server" if multiplayer.is_server() else "Client")
