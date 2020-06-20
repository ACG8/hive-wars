extends "res://bugs/Bug.gd"

export (PackedScene) var web

func primary_fire():
	rpc("shoot", web)
