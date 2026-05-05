extends Area2D


@export var next_level: String = "res://scenes/game_3b.tscn"

func _ready():
	monitoring = true
	monitorable = false


func _on_body_entered(body):
	# Only Player can teleport
	if body.name != "Bot":
		return

	print("Player entered teleport")
	print("Loading:", next_level)

	# Safety reset
	Engine.time_scale = 3.0

	# Change scene (teleport)
	get_tree().change_scene_to_file(next_level)
