extends CanvasLayer

onready var Bee = get_node("Bee")
onready var Spider = get_node("Spider")

export (Array, PackedScene) var bugs = []

signal bug_selected(bug_index)

func _ready():
	Bee.connect("button_down", self, "select_bee")
	Spider.connect("button_down", self, "select_spider")

func select_bee():
	emit_signal("bug_selected", 0)

func select_spider():
	emit_signal("bug_selected", 1)
