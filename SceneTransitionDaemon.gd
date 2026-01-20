#This daemon is not currently in use. Was used for an earlier debugging version while trying to design a
#'cockroach' system to withstand the adversarial private network system using HTTPS and other formats. As all failed
#I returned to the ENET format I'd set before
extends Node

var target_scene := ""
var armed := false

func request(path: String):
	if path.is_empty():
		return

	target_scene = path
	armed = true

func _process(_delta):
	if not armed:
		return

	armed = false
	var path := target_scene
	target_scene = ""

	await get_tree().process_frame
	await get_tree().process_frame

	if not ResourceLoader.exists(path):
		return

	get_tree().change_scene_to_file(path)
