#player.gd
extends CharacterBody2D

const SPEED = 200
const JUMP_FORCE = -400
const GRAVITY = 900
const REVIVE_TIME := 3.0
const COYOTE_TIME := 0.15

var is_attacking = false
var is_reviving = false
var can_move = true
var is_alive = true
var respawn_position: Vector2

var max_health := 10
var current_health := 10
var revive_hold_time := 0.0
var coyote_timer := 0.0

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var health_bar = $TextureProgressBar  # Ajusta si no está como hijo directo
@onready var sword: AnimatedSprite2D = $AnimatedSprite2D2
@onready var extra: int = 5

func _ready():
	health_bar.value = max_health
	respawn_position = global_position
	update_health_bar()

func _physics_process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if is_reviving == false:
		health_bar.modulate = Color(1, 1, 1)
	
	if not is_alive:
		return

	var dir = Input.get_axis("move_left", "move_right")

	# Gravedad
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Coyote time
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	# Movimiento
	if can_move and not is_attacking:
		if not is_reviving:
			if dir != 0:
				velocity.x = dir * SPEED
				sprite.flip_h = dir > 0
				sword.flip_h = dir > 0
				if is_on_floor():
					sprite.play("run")
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				if is_on_floor():
					sprite.play("idle")

		# Salto con coyote time
		if coyote_timer > 0.0 and Input.is_action_just_pressed("jump") and not is_reviving:
			velocity.y = JUMP_FORCE
			sprite.play("jump")
			coyote_timer = 0.0
	else:
		velocity.x = 0

	# Ataque
	if can_move and Input.is_action_just_pressed("atack") and not is_attacking and not is_reviving:
		is_attacking = true
		sprite.play("atack")
		sword.play("sword_attack")
		for body in attack_area.get_overlapping_bodies():
			if body is Enemy:
				body.take_damage()
		await sprite.animation_finished
		is_attacking = false

	# Revivir (mantener presionado)
	if can_move and not is_attacking:
		if Input.is_action_pressed("revive"):
			is_reviving = true
			revive_hold_time += delta
			health_bar.modulate = Color(0, 1, 0)
			sprite.play("revive")

			if revive_hold_time >= REVIVE_TIME:
				for body in attack_area.get_overlapping_bodies():
					if body is CharacterBody2D and body.has_method("revive") and not body.is_alive:
						body.revive()
				is_reviving = false
				revive_hold_time = 0.0
				sprite.play("idle")
		else:
			if is_reviving:
				is_reviving = false
				revive_hold_time = 0.0
				sprite.play("idle")

	move_and_slide()

func die():
	is_alive = false
	print("¡El jugador ha muerto!")
	get_tree().reload_current_scene()

func take_damage(amount: int = 1):
	current_health -= amount
	update_health_bar()
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health += amount
	if current_health > max_health:
		current_health = max_health
	$AudioStreamPlayer2D.play()
	update_health_bar()
	print("Sanado: ", amount, " Vida actual: ", current_health)

func update_health_bar():
	if health_bar:
		health_bar.value = current_health

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("final"):
		get_tree().change_scene_to_file("res://menus/menu_next_level.tscn")
		
	elif body.is_in_group("muerte"):
		get_tree().reload_current_scene()
		
	elif body.is_in_group("extralife"):
		health_bar.value += extra
		body.queue_free()
