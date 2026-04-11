extends Node2D


const SPEED := 60.0
const CHASE_SPEED := 200.0
const REVIVE_TIME := 2.0

const VERTICAL_FOLLOW_SPEED := 120.0
const VERTICAL_DEAD_ZONE := 6.0

const MAX_REVIVES := 3
const SPIDER_ROAM_RANGE := 160.0   


var direction := 1
var is_dead := false
var revive_timer := 0.0
var player_detected := false
var player_ref: Node2D = null

var revives_left := MAX_REVIVES
var patrol_center_x := 0.0


var can_kill_player := true


@onready var ray_cast_right := $RayCastRight
@onready var ray_cast_left := $RayCastLeft
@onready var sprite := $AnimatedSprite2D
@onready var enemy_hitbox := $enemy_hitbox
@onready var killzone := $KillZone
@onready var player_detector := $PlayerDetector


func _ready() -> void:
	sprite.play("idle")
	patrol_center_x = global_position.x


func _process(delta: float) -> void:
	if is_dead:
		handle_revive(delta)
		return

	if player_detected and player_ref:
		chase_player(delta)
	else:
		patrol(delta)

# ================= PATROL =================
func patrol(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
		sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		sprite.flip_h = false
	else:
		# 🧭 Fox-style roaming limit (larger range)
		if abs(global_position.x - patrol_center_x) >= SPIDER_ROAM_RANGE:
			direction *= -1
			sprite.flip_h = direction < 0

	position.x += direction * SPEED * delta

# ================= CHASE =================
func chase_player(delta: float) -> void:
	if player_ref.global_position.x > global_position.x:
		if not ray_cast_right.is_colliding():
			direction = 1
			sprite.flip_h = false
	else:
		if not ray_cast_left.is_colliding():
			direction = -1
			sprite.flip_h = true

	position.x += direction * CHASE_SPEED * delta
	handle_vertical_follow(delta)

# ================= VERTICAL FOLLOW =================
func handle_vertical_follow(delta: float) -> void:
	if not player_ref:
		return

	var y_diff := player_ref.global_position.y - global_position.y
	if abs(y_diff) < VERTICAL_DEAD_ZONE:
		return

	position.y += sign(y_diff) * VERTICAL_FOLLOW_SPEED * delta

# ================= DIE (FAKE OR FINAL) =================
func die() -> void:
	if is_dead:
		return

	is_dead = true
	can_kill_player = false
	revive_timer = REVIVE_TIME

	player_detected = false
	player_ref = null

	enemy_hitbox.set_deferred("monitoring", false)
	killzone.set_deferred("monitoring", false)
	player_detector.set_deferred("monitoring", false)

	# 🔊 Explosion sound + screen shake
	play_enemy_death_sound()

	sprite.stop()
	sprite.frame = 0
	sprite.play("death")

# ================= REVIVE =================
func handle_revive(delta: float) -> void:
	revive_timer -= delta
	if revive_timer <= 0:
		revives_left -= 1

		if revives_left <= 0:
			queue_free()   # ☠️ final death
		else:
			revive()

func revive() -> void:
	is_dead = false
	can_kill_player = true

	enemy_hitbox.set_deferred("monitoring", true)
	killzone.set_deferred("monitoring", true)
	player_detector.set_deferred("monitoring", true)

	sprite.stop()
	sprite.frame = 0
	sprite.play("idle")

# ================= PLAYER DETECTION =================
func _on_player_detector_body_entered(body: Node) -> void:
	if is_dead:
		return

	if body.name == "Player":
		player_detected = true
		player_ref = body

func _on_player_detector_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_detected = false
		player_ref = null

# ================= HIT PLAYER =================
func _on_kill_zone_body_entered(body: Node) -> void:
	if not can_kill_player:
		return

	if body.name == "Player":
		body.die()

# ================= PLAYER ATTACK =================
func _on_enemy_hitbox_body_entered(body: Node) -> void:
	if is_dead:
		return

	if body.name == "Player" and body.is_rolling:
		die()

# ================= SOUND =================
func play_enemy_death_sound() -> void:
	var sound := AudioStreamPlayer2D.new()
	sound.stream = preload("res://Assests/Sounds/explosion.wav")
	sound.global_position = global_position
	get_tree().current_scene.add_child(sound)
	sound.play()
	sound.finished.connect(sound.queue_free)

	# 🔥 Screen shake
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("shake"):
		cam.shake(0.15, 6.0)
