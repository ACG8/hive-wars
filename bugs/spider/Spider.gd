extends "res://bugs/Bug.gd"

export (PackedScene) var web

func primary_fire():
	rpc("shoot_web")

remotesync func shoot_web():
	shoot(web, 0)
