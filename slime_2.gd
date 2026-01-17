extends Node2D

const SPEED = 60
var direction = 1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var sprite = $AnimatedSprite2D

func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		sprite.flip_h = false

	position.x += direction * SPEED * delta


func die():
	play_enemy_death_sound()
	queue_free()


func play_enemy_death_sound():
	var sound := AudioStreamPlayer2D.new()
	sound.stream = preload("res://Assests/Sounds/explosion.wav")
	sound.global_position = global_position
	sound.volume_db = 0

	get_tree().current_scene.add_child(sound)
	sound.play()

	# Auto cleanup after sound finishes
	sound.finished.connect(sound.queue_free)
