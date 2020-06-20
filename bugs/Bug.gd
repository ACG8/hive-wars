extends KinematicBody2D

export var speed = 100
export var max_health = 10
onready var current_health = max_health

export (PackedScene) var camera

signal health_changed(max_health, current_health)
signal died

func _ready():
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("current_health", MultiplayerAPI.RPC_MODE_PUPPET)

	rset_config("visible", MultiplayerAPI.RPC_MODE_PUPPET)

	connect("health_changed", get_node("HealthBar"), "update_health")
	emit_signal("health_changed", max_health, current_health)

	if is_network_master():
		add_child(camera.instance())
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
		primary_fire()
	if event.is_action_pressed("ui_secondary_fire"):
		secondary_fire()

func primary_fire():
	pass

func secondary_fire():
	pass

func shoot(packed_projectile, rotation_delta):
	var projectile = packed_projectile.instance()
	projectile.position = self.position
	projectile.rotation = self.rotation
	projectile.ignored_bodies.append(self)
	get_parent().get_parent().add_child(projectile)

#remotesync func shoot(packed_projectile):
#	var projectile = packed_projectile
#	projectile.position = self.position
#	projectile.rotation = self.rotation
#	projectile.ignored_bodies.append(self)
#	get_parent().get_parent().add_child(projectile)

func _physics_process(delta):

	var x_axis = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var y_axis = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	var direction = Vector2(x_axis * delta * speed, y_axis * delta * speed)

	self.move_and_slide(direction * speed)

	if is_network_master():
		synchronize()

func synchronize():
	rset("position", position)
	rset("rotation", rotation)
	rset("visible", visible)

func die():
	self.visible = false

func damage(amount):
	if is_network_master():
		rpc("change_health", current_health - amount)

remotesync func change_health(new_health):
	current_health = new_health
	if current_health <= 0:
#		emit_signal("died")
		respawn()
	else:
		emit_signal("health_changed", max_health, current_health)

func respawn():
	var respawn_bug = load("res://bugs/larva/Larva.tscn").instance()
	respawn_bug.position = get_parent().spawn_position
	respawn_bug.rotation = rotation
	respawn_bug.set_network_master(get_network_master())
	get_parent().add_child(respawn_bug)
	queue_free()

