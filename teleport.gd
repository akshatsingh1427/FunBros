extends Area2D


@export var next_level: String = "res://scenes/main_menu_2.tscn"

func _ready():
	monitoring = true
	monitorable = true


func _on_body_entered(body):

	if body.name != "Player":
		return

	print("Player entered teleport")
	print("Loading:", next_level)

	Engine.time_scale = 1.0

	
	get_tree().change_scene_to_file(next_level)
