extends KinematicBody2D

export var speed = 100
export var max_health = 10
onready var current_health = max_health

signal health_changed(max_health, current_health)

func _ready():
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("current_health", MultiplayerAPI.RPC_MODE_PUPPET)

	rset_config("visible", MultiplayerAPI.RPC_MODE_PUPPET)

	connect("health_changed", get_node("HealthBar"), "update_health")
	emit_signal("health_changed", max_health, current_health)

	if(is_network_master()):
		set_process_input(true)
	else:
		set_process_input(false)

func _process(delta):
	if is_network_master():
		rpc("face", get_global_mouse_position())
		rset("current_health", current_health)


remotesync func face(global_position):
	look_at(global_position)

func _input(event):
	if event.is_action_pressed("ui_primary_fire"):
		rpc("shoot")

func _physics_process(delta):

	var x_axis = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y_axis = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	var direction = Vector2(x_axis * delta * speed, y_axis * delta * speed)

	self.move_and_slide(direction * speed)

	if(self.position.x < 0): self.position.x = 1000
	if(self.position.x > 1024): self.position.x = 0
	if(self.position.y < 0): self.position.y = 600
	if(self.position.y > 600): self.position.y = 0

	if is_network_master():
		synchronize()

func synchronize():
	rset("position", position)
	rset("rotation", rotation)
	rset("visible", visible)

func die():
	self.visible = false

remotesync func shoot():
	var projectile = preload("res://Barb.tscn")
	var instance = projectile.instance()
	instance.position = self.position
	instance.rotation = self.rotation + PI
	instance.ignored_bodies.append(self)
	get_parent().get_parent().add_child(instance)

remotesync func damage(amount):
	current_health -= amount
	emit_signal("health_changed", max_health, current_health)

func respawn():
	var spawn
	if(self.get_network_master() == 1):
		spawn = get_parent().get_node("P1_Spawn")
	else:
		spawn = get_parent().get_node("P2_Spawn")

	self.position = spawn.position
	self.rotation = spawn.rotation
	self.visible = true
