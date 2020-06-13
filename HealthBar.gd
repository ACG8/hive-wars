extends Node2D

func _ready():
	set_as_toplevel(true)

func _process(delta):
	position = get_parent().position

func update_health(max_health, current_health):
	get_node("ProgressBar").value = 100 * current_health / max_health
