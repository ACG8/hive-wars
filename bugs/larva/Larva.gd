extends "res://bugs/Bug.gd"

export (PackedScene) var bug_select_menu_packed
export (Array, PackedScene) var bugs

func _ready():
	if is_network_master():
		var bug_select_menu = bug_select_menu_packed.instance()
		add_child(bug_select_menu)
		bug_select_menu.connect("bug_selected", self, "bug_selected")

func bug_selected(bug_index):
	rpc("morph", bug_index)

remotesync func morph(bug_index):
	var new_bug = bugs[bug_index].instance()
	new_bug.position = position
	new_bug.rotation = rotation
	new_bug.set_network_master(get_network_master())
	get_parent().add_child(new_bug)
	queue_free()


