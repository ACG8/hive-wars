extends Node

var spawn_position

func _ready():
	pass

remotesync func die():
	get_node("Bug").die()

remotesync func respawn():
	get_node("Bug").respawn()

