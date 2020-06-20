extends "res://bugs/Bug.gd"

export (PackedScene) var barb

func primary_fire():
	rpc("shoot_barb")

remotesync func shoot_barb():
	shoot(barb, 0)
