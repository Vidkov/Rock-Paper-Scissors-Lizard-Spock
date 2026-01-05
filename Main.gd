extends Control
var showing_result := false

enum {
	ROCK,
	PAPER,
	SCISSORS,
	LIZARD,
	SPOCK
}

var input_locked := false

@onready var result_label := $ResultLabel
@onready var network := NetworkManager

func _ready():
	print(
	"[UI] NetworkManager:",
	network,
	" path:",
	network.get_path()
)
	$MainLayout/Rock.pressed.connect(_on_choice_pressed.bind(ROCK))
	$MainLayout/Paper.pressed.connect(_on_choice_pressed.bind(PAPER))
	$MainLayout/Scissors.pressed.connect(_on_choice_pressed.bind(SCISSORS))
	$MainLayout/Lizard.pressed.connect(_on_choice_pressed.bind(LIZARD))
	$MainLayout/Spock.pressed.connect(_on_choice_pressed.bind(SPOCK))

	# Listen to network results
	network.round_resolved.connect(_on_round_resolved)

	result_label.text = "Make your choice!"

func _on_choice_pressed(choice: int):
	print("[UI] Button pressed. Peer:", multiplayer.get_unique_id(), " Choice:", choice)

	if input_locked:
		print("[UI] Input locked, returning")
		return

	if not multiplayer.has_multiplayer_peer():
		print("[UI] No multiplayer peer, returning")
		return

	input_locked = true
	result_label.text = "Waiting for opponent..."

	print("[UI] Sending submit_choice RPC")
	network.rpc("submit_choice", choice)




func _on_round_resolved(p1_id, c1, p2_id, c2, winner_id):
	if showing_result:
		return

	showing_result = true
	input_locked = true

	var my_id := multiplayer.get_unique_id()

	if winner_id == 0:
		result_label.text = "Draw!"
	elif winner_id == my_id:
		result_label.text = "You win!"
	else:
		result_label.text = "You lose!"

	# Make the delay long enough to be human-visible
	await get_tree().create_timer(2.0).timeout

	result_label.text = "Make your choice!"
	input_locked = false
	showing_result = false
