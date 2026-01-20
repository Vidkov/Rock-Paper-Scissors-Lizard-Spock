extends Control

@onready var host_btn: Button = $HostButton
@onready var join_btn: Button = $JoinButton
@onready var address_box: HBoxContainer = $AddressBox
@onready var address_field: LineEdit = $AddressBox/AddressField
@onready var submit_btn: Button = $AddressBox/SubmitButton

func _ready():
	_hide_join_ui()

	host_btn.pressed.connect(_on_host_pressed)
	join_btn.pressed.connect(_on_join_pressed)
	submit_btn.pressed.connect(_on_submit_pressed)
	address_field.text_submitted.connect(_on_address_submitted)

	NetworkManager.client_ready.connect(_on_client_ready)

func _on_host_pressed():
	NetworkManager.host_game()
	NetworkManager.go_to_game_scene()

func _on_join_pressed():
	address_box.visible = true
	join_btn.visible = false
	address_field.visible = true
	submit_btn.visible = true
	address_field.grab_focus()

func _on_submit_pressed():
	_do_join()

func _on_address_submitted(_t):
	_do_join()

func _do_join():
	var addr := address_field.text.strip_edges()
	if addr.is_empty():
		return
	print("Joining:", addr)
	NetworkManager.join_game_at(addr)

func _on_client_ready():
	NetworkManager.go_to_game_scene()

func _hide_join_ui():
	address_box.visible = false
	address_field.visible = false
	submit_btn.visible = false
	join_btn.visible = true
