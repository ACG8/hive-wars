extends Panel

onready var Bee = get_node("Bee")
onready var Spider = get_node("Spider")

export (Array, PackedScene) var bugs = []

func _ready():
	Bee.connect("button_down", self, "select_bee")
	Spider.connect("button_down", self, "select_spider")

func select_bee():
	NetworkSingleton.player_character = 0
	get_tree().change_scene_to(NetworkSingleton.level_packed_scene)

func select_spider():
	NetworkSingleton.player_character = 1
	get_tree().change_scene_to(NetworkSingleton.level_packed_scene)


