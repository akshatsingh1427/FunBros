extends Area2D

# Path of the next level
@export var next_level: String = "res://scenes/main_menu_2.tscn"

func _ready():
	monitoring = true
	monitorable = true


func _on_body_entered(body):
	# Only Player can teleport
	if body.name != "Player":
		return

	print("Player entered teleport")
	print("Loading:", next_level)

	# Safety reset
	Engine.time_scale = 1.0

	# Change scene (teleport)
	get_tree().change_scene_to_file(next_level)
