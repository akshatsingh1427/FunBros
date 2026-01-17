extends Area2D

@onready var pickup_sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(body: Node2D) -> void:
	# Optional: check if it's the player
	if body.name == "Player":
		pickup_sound.play()
		hide() # hide coin immediately
		
		# wait for sound to finish, then remove coin
		await pickup_sound.finished
		queue_free()
