extends Control
enum {
	ROCK,
	PAPER,
	SCISSORS,
	LIZARD,
	SPOCK
}

const WINS := {
	ROCK:     [SCISSORS, LIZARD],
	PAPER:    [ROCK, SPOCK],
	SCISSORS: [PAPER, LIZARD],
	LIZARD:   [PAPER, SPOCK],
	SPOCK:    [ROCK, SCISSORS]
}

var input_locked := false
var hand1= -1;
var hand2= -1;
var turn=1; #odd if player 1, even if player 2

@onready var result_label := $ResultLabel

func resetboard() -> void:
	input_locked= true
	hand1=-1
	hand2=-1
	turn=1
	await get_tree().create_timer(0.8).timeout
	input_locked= false
	result_label.text = "Waiting for players..."

func resolve_round() -> void:
	#edge case crash handler
	if hand1 == -1 or hand2 == -1:
		return
		
	if hand1==hand2:
		result_label.text= "Draw!"
	elif hand2 in WINS[hand1]:
		result_label.text= "Player 1 Wins!"
	else:
		result_label.text= "Player 2 Wins!"
	await resetboard()

func _on_choice_pressed(choice: int) -> void:
	if input_locked:
		return
	match turn % 2:
		1:
			result_label.text = "Waiting for opponent..."
			hand1 = choice
			turn+=1
		0:
			hand2 = choice
			resolve_round()
			return
