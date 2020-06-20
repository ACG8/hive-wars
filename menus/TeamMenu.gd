extends Panel

onready var blue_button = get_node("Blue")
onready var blue_label = get_node("Blue/Players")

onready var red_button = get_node("Red")
onready var red_label = get_node("Red/Players")

export (PackedScene) var character_menu

func _ready():
	blue_button.connect("button_down", self, "join_blue_team")
	red_button.connect("button_down", self, "join_red_team")

func _process(delta):
	var blue_count = NetworkSingleton.blue_team.size()
	var red_count = NetworkSingleton.red_team.size()

	blue_label.text = String(blue_count)
	red_label.text = String(red_count)

func join_red_team():
	var net_id = get_tree().get_network_unique_id()
	get_tree().change_scene_to(character_menu)

func join_blue_team():
	var net_id = get_tree().get_network_unique_id()
	get_tree().change_scene_to(character_menu)
