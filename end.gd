extends Control

func _ready():
	Engine.time_scale = 1.0
	

func _process(_delta):
	# ESC always exits from menu
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")



	
