extends Enemy
class_name Sombra

@export var projectile_scene: PackedScene = preload("res://scenes/entities/enemies/projectile_enemigo.tscn")
var attack_timer: float = 0.0
@export var fire_rate: float = 3.0
var hit_stun_timer: float = 0.0
const HIT_STUN_DURATION: float = 0.4

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

	var puddle = ShadowPuddle.new()
	get_parent().add_child(puddle)
	puddle.global_position = target_player.global_position

	if animations.sprite_frames.has_animation("attack"):
		animations.play("attack")

class ShadowPuddle extends Area2D:
	var player_ref: Node2D = null
	var damage_timer: Timer = null

	func _ready():
		# Create collision shape
		var collision_shape = CollisionShape2D.new()
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = 35.0
		collision_shape.shape = circle_shape
		add_child(collision_shape)

		# Create timer for periodic damage
		damage_timer = Timer.new()
		damage_timer.wait_time = 2.5
		damage_timer.one_shot = false
		damage_timer.timeout.connect(_on_damage_timer_timeout)
		add_child(damage_timer)

		# Connect body entered/exited signals
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

		# Draw puddle
		queue_redraw()

		# Add a lifetime timer so it eventually gets destroyed after 5 seconds
		var lifetime_timer = get_tree().create_timer(5.0)
		lifetime_timer.timeout.connect(queue_free)

	func _draw():
		draw_circle(Vector2.ZERO, 35.0, Color(0.1, 0.05, 0.15, 0.6))

	func _on_body_entered(body: Node2D):
		if body.is_in_group("player") or body.name == "Player":
			player_ref = body
			player_ref.speed = 125.0
			damage_timer.start()

	func _on_body_exited(body: Node2D):
		if body == player_ref:
			if is_instance_valid(player_ref):
				player_ref.speed = 250.0
			player_ref = null
			damage_timer.stop()

	func _on_damage_timer_timeout():
		if is_instance_valid(player_ref) and player_ref.has_method("take_damage"):
			player_ref.take_damage(1)

	func _exit_tree():
		if is_instance_valid(player_ref):
			player_ref.speed = 250.0
