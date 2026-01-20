extends Node

signal client_ready
signal round_resolved(p1_id, c1, p2_id, c2, winner_id)

const DEFAULT_PORT := 8910
const MAX_PLAYERS := 2

enum Choice {
	ROCK,
	PAPER,
	SCISSORS,
	LIZARD,
	SPOCK
}

var peer: ENetMultiplayerPeer
var player_choices := {}
var last_connect_address := ""
var mode := "none"

func _on_peer_disconnected(_id):
	if multiplayer.is_server():
		player_choices.clear()
		
func _ready():
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("[NM] Ready")
	print("[NM] Instance path:", get_path())

func host_game():
	if mode != "none":
		return
	mode = "host"
	_start_server()
	client_ready.emit()


func join_game_at(address: String):
	if mode != "none":
		return
	mode = "client"

	var host := address.strip_edges()
	var port := DEFAULT_PORT

	if ":" in host:
		var parts = host.split(":")
		host = parts[0]
		if parts.size() > 1 and parts[1].is_valid_int():
			port = int(parts[1])

	_join_game(host, port)

func go_to_game_scene():
	get_tree().change_scene_to_file("res://Game.tscn")

func _start_server():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer

	last_connect_address = _get_local_ip()
	print("[NM] Host address set to:", last_connect_address)

func _join_game(host: String, port: int):
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(host, port)
	if err != OK:
		print("[NM] Client create failed:", err)
		mode = "none"
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connect_failed)

func _on_connected():
	print("[NM] Connected to server")
	client_ready.emit()

func _on_connect_failed():
	print("[NM] Connection failed")
	mode = "none"



@rpc("any_peer", "reliable")
func submit_choice(choice: int):
	if not multiplayer.is_server():
		return

	var sender_id := multiplayer.get_remote_sender_id()
	player_choices[sender_id] = choice

	if player_choices.size() == 2:
		_resolve_round()

func _resolve_round():
	var ids := player_choices.keys()
	if ids.size() < 2:
		return

	var p1_id: int = ids[0]
	var p2_id: int = ids[1]
	var c1: int = player_choices[p1_id]
	var c2: int = player_choices[p2_id]

	var winner_id := _determine_winner(p1_id, c1, p2_id, c2)

	rpc("round_result", p1_id, c1, p2_id, c2, winner_id)
	player_choices.clear()

@rpc("any_peer", "reliable")
func round_result(p1_id, c1, p2_id, c2, winner_id):
	round_resolved.emit(p1_id, c1, p2_id, c2, winner_id)


func _get_local_ip() -> String:
	for ip in IP.get_local_addresses():
		if ip.contains(":"):
			continue
		if ip.begins_with("127."):
			continue
		if ip.begins_with("169.254."):
			continue
		return ip
	return "127.0.0.1"

func _determine_winner(p1_id, c1, p2_id, c2) -> int:
	if c1 == c2:
		return 0

	var wins := {
		Choice.SCISSORS: [Choice.PAPER, Choice.LIZARD],
		Choice.PAPER: [Choice.ROCK, Choice.SPOCK],
		Choice.ROCK: [Choice.LIZARD, Choice.SCISSORS],
		Choice.LIZARD: [Choice.SPOCK, Choice.PAPER],
		Choice.SPOCK: [Choice.SCISSORS, Choice.ROCK],
	}

	return p1_id if c2 in wins[c1] else p2_id
