extends Area2D


@export var next_level: String = "res://scenes/end.tscn"

func _ready():
	monitoring = true
	monitorable = true


func _on_body_entered(body):

	if body.name != "Player":
		return

	print("Player entered teleport")
	print("Loading:", next_level)

	# Safety reset
	Engine.time_scale = 1.0

	# Change scene (teleport)
	get_tree().change_scene_to_file(next_level)
