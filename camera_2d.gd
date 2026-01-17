extends Camera2D

var shake_time := 0.0
var shake_strength := 0.0
var original_offset := Vector2.ZERO

func _ready() -> void:
	original_offset = offset

func shake(duration := 0.15, strength := 6.0) -> void:
	shake_time = duration
	shake_strength = strength

func _process(delta: float) -> void:
	if shake_time > 0:
		shake_time -= delta
		offset = original_offset + Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = original_offset
