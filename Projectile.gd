extends Area2D

export var lifetime = 1.00
export var speed = 375
export var damage = 1

var ignored_bodies = []

func _ready():
	set_network_master(1)
	rset_config("position", MultiplayerAPI.RPC_MODE_PUPPET)
	rset_config("rotation", MultiplayerAPI.RPC_MODE_PUPPET)

	if is_network_master():
		rset("rotation", rotation)

	connect("body_entered", self, "body_entered")

func _physics_process(delta):
	var dx = cos(rotation)
	var dy = sin(rotation)
	position += Vector2(dx, dy) * delta * speed
	lifetime -= delta

	if is_network_master():
		if lifetime <= 0:
			rpc("die")
		else:
			rset("position", position)

func body_entered(body):
	if body in ignored_bodies:
		return
	if body.has_method("damage"):
		body.call("damage", damage)

remotesync func die():
	queue_free()
