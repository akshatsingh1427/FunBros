extends CharacterBody2D

# ================= CONSTANTS =================
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ROLL_SPEED = 200.0
const ROLL_TIME = 0.25

# ================= VARIABLES =================
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_rolling = false
var is_dead = false

# ================= NODES =================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var hud: Control = get_parent().get_node("HUD")


func _ready():
	# SAFETY RESET
	Engine.time_scale = 1.0
	is_dead = false
	set_physics_process(true)

	# Update HUD (if you still have score / coins etc.)
	if hud and hud.has_method("update_lives"):
		hud.update_lives()


func _physics_process(delta):
	# 🔴 ESC → GO TO MAIN MENU (kept same as your code)
	if Input.is_action_just_pressed("ui_cancel"):
		go_to_main_menu()
		return

	# ================= GRAVITY =================
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# ================= INPUT =================
	var direction = Input.get_axis("move_left", "move_right")

	# Flip sprite
	if direction != 0:
		sprite.flip_h = direction < 0

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_rolling:
		velocity.y = JUMP_VELOCITY

	# Roll
	if Input.is_action_just_pressed("roll") and is_on_floor() and not is_rolling:
		start_roll()
		return

	# Horizontal movement
	if not is_rolling:
		velocity.x = direction * SPEED

	move_and_slide()

	# ================= ANIMATIONS =================
	if is_rolling:
		sprite.play("roll")
	elif not is_on_floor():
		sprite.play("jump")
	elif direction == 0:
		sprite.play("idle")
	else:
		sprite.play("run")


func start_roll():
	is_rolling = true

	var roll_dir = -1 if sprite.flip_h else 1
	velocity.x = roll_dir * ROLL_SPEED
	velocity.y = 0

	await get_tree().create_timer(ROLL_TIME).timeout

	is_rolling = false
	velocity.x = 0


func die():
	if is_dead:
		return
	is_dead = true

	Engine.time_scale = 0.5
	velocity = Vector2.ZERO
	set_physics_process(false)

	sprite.play("death")
	if hurt_sound:
		hurt_sound.play()

	await get_tree().create_timer(0.6).timeout

	Engine.time_scale = 1.0
	get_tree().reload_current_scene()


# ================= MAIN MENU FUNCTION =================
func go_to_main_menu():
	Engine.time_scale = 1.0
	is_dead = false
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_tree().change_scene_to_file("res://scenes/main_menu_1.tscn")
