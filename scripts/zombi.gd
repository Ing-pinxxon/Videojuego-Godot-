extends Enemy
class_name Zombie

@export var projectile_scene: PackedScene = preload("res://scenes/entities/enemies/projectile_enemigo.tscn")
var attack_timer: float = 0.0
@export var fire_rate: float = 3.0
var hit_stun_timer: float = 0.0
const HIT_STUN_DURATION: float = 0.4

var is_charging: bool = false
var charge_timer: float = 0.0
var charge_direction: Vector2 = Vector2.ZERO
const CHARGE_DURATION: float = 0.5

func _ready():
	speed = 80
	detection_range = 400.0
	attack_range = 300.0
	max_health = 5
	show_health_bar = false
	super._ready()

	if hearts_container:
		hearts_container.alignment = BoxContainer.ALIGNMENT_CENTER

func _physics_process(_delta):
	if is_charging:
		charge_timer -= _delta
		velocity = charge_direction * (speed * 3.0)
		move_and_slide()
		if charge_timer <= 0:
			is_charging = false
		return

	# Cuenta regresiva del hit stun
	if hit_stun_timer > 0:
		hit_stun_timer -= _delta
		velocity = Vector2.ZERO
		move_and_slide()
		return

	super._physics_process(_delta)
	if current_state == State.ATTACK or current_state == State.CHASE:
		attack_timer += _delta
		if attack_timer >= fire_rate:
			_shoot()
			attack_timer = 0.0

func take_damage(amount: int):
	super.take_damage(amount)
	# Al recibir daño se queda quieto brevemente
	hit_stun_timer = HIT_STUN_DURATION

func _attack_logic(_delta):
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		if dist < 150:
			var moveDirection = global_position - target_player.global_position
			velocity = moveDirection.normalized() * speed
		elif dist > 250:
			var moveDirection = target_player.global_position - global_position
			velocity = moveDirection.normalized() * (speed * 0.5)
		else:
			velocity = Vector2.ZERO

func _chase_logic(_delta):
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		if dist < 200:
			var moveDirection = global_position - target_player.global_position
			velocity = moveDirection.normalized() * speed
		else:
			super._chase_logic(_delta)

func _shoot():
	if is_dead or not target_player: return

	is_charging = true
	charge_timer = CHARGE_DURATION
	charge_direction = (target_player.global_position - global_position).normalized()

	var tween = create_tween()
	tween.tween_property(animations, "modulate", Color.RED, 0.1)
	tween.tween_property(animations, "modulate", Color.WHITE, 0.1).set_delay(CHARGE_DURATION)

	if animations.sprite_frames.has_animation("attack"):
		animations.play("attack")
