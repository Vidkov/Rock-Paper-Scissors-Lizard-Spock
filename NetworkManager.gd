extends Node

signal round_resolved(p1_id, c1, p2_id, c2, winner_id)

enum Choice {
	ROCK,
	PAPER,
	SCISSORS,
	LIZARD,
	SPOCK
}

const DEFAULT_PORT := 8910
const MAX_PLAYERS := 2

var peer: ENetMultiplayerPeer
var player_choices := {}

func _ready():
	print(
		"[NM] DisplayServer:",
		DisplayServer.get_name(),
		" is_server:",
		multiplayer.is_server()
	)

	if DisplayServer.get_name() == "headless":
		print("[NM] Starting as SERVER")
		_start_server()
	else:
		print("[NM] Starting as CLIENT")
		join_game("127.0.0.1")


@rpc("any_peer", "reliable", "call_remote")
func submit_choice(choice: int):
	print(
		"[SERVER?] submit_choice called on peer:",
		multiplayer.get_unique_id(),
		" sender:",
		multiplayer.get_remote_sender_id(),
		" choice:",
		choice
	)

	if not multiplayer.is_server():
		print("[ERROR] submit_choice executed on non-server")
		return

	var sender_id := multiplayer.get_remote_sender_id()
	player_choices[sender_id] = choice

	print("[SERVER] Current player_choices:", player_choices)

	if player_choices.size() == 2:
		print("[SERVER] Two choices received, resolving round")
		_resolve_round()

func _start_server():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	print("Server started")


func _resolve_round():
	print("[SERVER] _resolve_round called")
	var ids := player_choices.keys()
	print("[SERVER] Player IDs:", ids)
	var p1_id: int = ids[0]
	var p2_id: int = ids[1]
	var c1: int = player_choices[p1_id]
	var c2: int = player_choices[p2_id]

	var winner_id := _determine_winner(p1_id, c1, p2_id, c2)
	print("[SERVER] Winner:", winner_id)

	player_choices.clear()
	print("[SERVER] Sending round_result RPC")
	rpc("round_result", p1_id, c1, p2_id, c2, winner_id)

@rpc("authority", "reliable", "call_remote")
func round_result(p1_id, c1, p2_id, c2, winner_id):
	print(
		"[ROUND_RESULT] Received on peer:",
		multiplayer.get_unique_id()," p1:", p1_id, " p2:", p2_id, " winner:", winner_id)

	round_resolved.emit(p1_id, c1, p2_id, c2, winner_id)


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

func join_game(address: String, port := DEFAULT_PORT):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer

	await multiplayer.connected_to_server

	print(
		"[NM] CLIENT CONNECTED:",
		"is_server:", multiplayer.is_server(),
		" peer_id:", multiplayer.get_unique_id()
	)
