extends Control

var showing_result := false
var input_locked := false
var selected_choice := -1
var address_visible := false

enum {
	ROCK,
	PAPER,
	SCISSORS,
	LIZARD,
	SPOCK
}

@onready var selected_icon := $SelectedIcon
@onready var selected_text := $SelectedText
@onready var result_label := $ResultLabel
@onready var network := NetworkManager
@onready var address_toggle: Button = $AddressBox/AddressToggle
@onready var copy_button: Button = $AddressBox/CopyButton
@onready var click_catcher: Control = $ClickCatcher

var hand_icons := {}

func _choice_name(choice: int) -> String:
	match choice:
		ROCK: return "Rock"
		PAPER: return "Paper"
		SCISSORS: return "Scissors"
		LIZARD: return "Lizard"
		SPOCK: return "Spock"
	return ""

func _choice_icon(choice: int) -> Texture2D:
	return hand_icons.get(choice, null)

func _ready():
	hand_icons = {
		ROCK: load("res://ui/placeholders/rock.png"),
		PAPER: load("res://ui/placeholders/paper.png"),
		SCISSORS: load("res://ui/placeholders/scissors.png"),
		LIZARD: load("res://ui/placeholders/lizard.png"),
		SPOCK: load("res://ui/placeholders/Spock.png"),
	}

	address_toggle.visible = false
	copy_button.visible = false
	click_catcher.visible = false

	address_toggle.pressed.connect(_toggle_address)
	copy_button.pressed.connect(_copy_address)
	click_catcher.gui_input.connect(_on_click_catcher_input)

	$MainLayout/Rock.pressed.connect(_on_choice_pressed.bind(ROCK))
	$MainLayout/Paper.pressed.connect(_on_choice_pressed.bind(PAPER))
	$MainLayout/Scissors.pressed.connect(_on_choice_pressed.bind(SCISSORS))
	$MainLayout/Lizard.pressed.connect(_on_choice_pressed.bind(LIZARD))
	$MainLayout/Spock.pressed.connect(_on_choice_pressed.bind(SPOCK))

	network.round_resolved.connect(_on_round_resolved)

	result_label.text = "Make your choice!"
	result_label.disabled = true
	result_label.pressed.connect(_on_result_label_pressed)

func _process(_delta):
	if not address_toggle.visible and NetworkManager.last_connect_address != "":
		address_toggle.visible = true
		address_toggle.text = "(Click to view your host address)"

func _on_choice_pressed(choice: int):
	if input_locked:
		return
	if not multiplayer.multiplayer_peer:
		return

	selected_choice = choice
	selected_text.text = _choice_name(choice)
	selected_icon.texture = _choice_icon(choice)
	result_label.text = "Submit"
	result_label.disabled = false

func _on_result_label_pressed():
	if input_locked or selected_choice == -1:
		return

	input_locked = true
	result_label.disabled = true
	result_label.text = "Waiting for opponent…"
	network.rpc("submit_choice", selected_choice)

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

	await get_tree().create_timer(2.0).timeout

	result_label.text = "Make your choice!"
	input_locked = false
	selected_choice = -1
	showing_result = false
	result_label.disabled = true
	selected_text.text = ""
	selected_icon.texture = null

func _toggle_address():
	var addr := NetworkManager.last_connect_address
	if addr == "":
		return

	address_visible = not address_visible

	if address_visible:
		var full := "%s:%d" % [addr, NetworkManager.DEFAULT_PORT]
		address_toggle.text = full
		copy_button.visible = true
		click_catcher.visible = true
	else:
		address_toggle.text = "(Click to view your host address)"
		copy_button.visible = false
		click_catcher.visible = false

func _copy_address():
	if address_visible:
		DisplayServer.clipboard_set(address_toggle.text)

func _on_click_catcher_input(event):
	if event is InputEventMouseButton and event.pressed and address_visible:
		_toggle_address()

func _unhandled_input(event):
	if not address_visible:
		return
	if event is InputEventMouseButton and event.pressed:
		var pos = event.position
		if address_toggle.get_global_rect().has_point(pos):
			return
		if copy_button.get_global_rect().has_point(pos):
			return
		_toggle_address()
