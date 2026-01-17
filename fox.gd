extends Node2D

# ================= CONSTANTS =================
const WALK_SPEED := 60.0
const DASH_SPEED := 180.0

const ROAM_RANGE := 110.0   # horizontal roam (10 blocks)

const VERTICAL_FOLLOW_SPEED := 120.0
const VERTICAL_DEAD_ZONE := 6.0   # prevents jitter (half tile feel)

# ================= VARIABLES =================
var direction := 1
var player_detected := false
var is_dashing := false
var player_ref: Node2D = null
var patrol_center_x := 0.0

# ================= NODES =================
@onready var ray_cast_right := $RayCastRight
@onready var ray_cast_left := $RayCastLeft
@onready var sprite := $AnimatedSprite2D
@onready var player_detector := $PlayerDetector

# ================= READY =================
func _ready() -> void:
	patrol_center_x = global_position.x

# ================= PROCESS =================
func _process(delta: float) -> void:
	var speed := WALK_SPEED
	var between_walls := is_between_walls()

	player_detector.monitoring = not between_walls

	# ---------- PLAYER CHASE ----------
	if player_detected and player_ref and not between_walls:
		# Face & move toward player horizontally
		if player_ref.global_position.x > global_position.x:
			direction = 1
			sprite.flip_h = false
		else:
			direction = -1
			sprite.flip_h = true

		is_dashing = true
		speed = DASH_SPEED
	else:
		is_dashing = false

	# ---------- HORIZONTAL MOVE ----------
	position.x += direction * speed * delta

	# ---------- GLOBAL VERTICAL FOLLOW (🔥 FIX) ----------
	handle_vertical_follow(delta)

	# ---------- TURNING ----------
	if ray_cast_right.is_colliding():
		direction = -1
		sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		sprite.flip_h = false
	elif not player_detected:
		if abs(global_position.x - patrol_center_x) >= ROAM_RANGE:
			direction *= -1
			sprite.flip_h = direction < 0

# ================= VERTICAL FOLLOW =================
func handle_vertical_follow(delta: float) -> void:
	if not player_detected or not player_ref:
		return

	var y_diff := player_ref.global_position.y - global_position.y

	# Dead zone → do nothing (prevents jitter)
	if abs(y_diff) < VERTICAL_DEAD_ZONE:
		return

	# Move smoothly toward player vertically
	position.y += sign(y_diff) * VERTICAL_FOLLOW_SPEED * delta

# ================= HELPERS =================
func is_between_walls() -> bool:
	return ray_cast_left.is_colliding() or ray_cast_right.is_colliding()

# ================= PLAYER DETECTION =================
func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_detected = true
		player_ref = body

func _on_player_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_detected = false
		player_ref = null
		is_dashing = false

# ================= KILL LOGIC =================
func try_die(player: Node) -> void:
	if player.has_method("is_rolling") and player.is_rolling():
		die()
		return

	if is_dashing:
		return

	die()

func die() -> void:
	var sound := AudioStreamPlayer2D.new()
	sound.stream = preload("res://Assests/Sounds/explosion.wav")
	sound.global_position = global_position
	get_tree().current_scene.add_child(sound)
	sound.play()
	sound.finished.connect(sound.queue_free)

	queue_free()
