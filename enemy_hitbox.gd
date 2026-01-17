extends Area2D

func _on_body_entered(body):
	if body.name != "Player":
		return

	# ✅ ROLL KILL
	if body.is_rolling:
		get_parent().die()
		return

	# ✅ JUMP KILL (player falling onto enemy)
	if body.velocity.y > 0 and body.global_position.y < global_position.y:
		body.velocity.y = -200
		get_parent().die()
		return

	# ❌ NORMAL TOUCH → PLAYER DIES
	body.die()
