class_name Enemy
extends CharacterBody2D

@export var SPEED = 100
const GRAVITY = 900
@export var MAX_HEALTH = 2
const ATTACK_DAMAGE = 1

var health = MAX_HEALTH
var is_alive = true
var attack_timer = 0.0
var attacking = false

@export var default_target: CharacterBody2D
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $TextureProgressBar

func _ready():
	sprite.play("idle")

func _physics_process(delta):
	if not is_alive:
		return

	velocity.y += GRAVITY * delta

	if is_instance_valid(default_target) and default_target.is_alive:
		var direction = (default_target.global_position - global_position).normalized()
		var distance = global_position.distance_to(default_target.global_position)

		if distance > 35 and not attacking:
			# Solo moverse si no está atacando
			velocity.x = direction.x * SPEED
			sprite.flip_h = direction.x > 0
			if sprite.animation != "run":
				sprite.play("run")
		else:
			# En rango de ataque
			velocity.x = 0
			attack_timer -= delta
			if attack_timer <= 0 and not attacking:
				attack_timer = 1.0
				attack()
	else:
		velocity.x = 0
		if sprite.animation != "idle":
			sprite.play("idle")

	move_and_slide()

func attack():
	attacking = true
	sprite.play("atack")
	await sprite.animation_finished

	if is_instance_valid(default_target) and default_target.has_method("take_damage"):
		default_target.take_damage(ATTACK_DAMAGE)
		print("Jugador atacado por el enemigo!")

	attacking = false

func take_damage():
	if not is_alive:
		return
	health -= 1
	health_bar.value = health
	print("Enemigo recibe daño. Salud: ", health)
	if health <= 0:
		die()

func die():
	is_alive = false
	sprite.play("dead")
	velocity = Vector2.ZERO
	$CollisionShape2D.scale.y = 0.1
	$CollisionShape2D.position.y += 20
	print("Enemigo muerto")

func revive():
	if is_alive:
		return
	print("Convertido en energía para curar al jugador")

	if is_instance_valid(default_target) and default_target.has_method("heal"):
		default_target.heal(1)

	queue_free()
