extends Enemy
class_name Bestia

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

	var shockwave = Shockwave.new()
	get_parent().add_child(shockwave)
	shockwave.global_position = global_position

	if animations.sprite_frames.has_animation("attack"):
		animations.play("attack")

class Shockwave extends Area2D:
	var current_radius: float = 0.0
	const MAX_RADIUS: float = 90.0
	const SPEED: float = 180.0 # Reaches 90 in 0.5s
	var player_hit: bool = false
	var line: Line2D = null
	var collision_shape: CollisionShape2D = null
	var circle_shape: CircleShape2D = null

	func _ready():
		collision_shape = CollisionShape2D.new()
		circle_shape = CircleShape2D.new()
		circle_shape.radius = 1.0
		collision_shape.shape = circle_shape
		add_child(collision_shape)

		line = Line2D.new()
		line.default_color = Color.ORANGE
		line.width = 3.0
		# Generate a unit circle
		var num_points = 32
		for i in range(num_points + 1):
			var angle = float(i) / num_points * TAU
			line.add_point(Vector2(cos(angle), sin(angle)))
		add_child(line)

		body_entered.connect(_on_body_entered)

	func _physics_process(delta):
		current_radius += SPEED * delta
		if current_radius >= MAX_RADIUS:
			queue_free()
			return

		# Update visual circle size
		line.scale = Vector2(current_radius, current_radius)
		# Update physical collision radius
		circle_shape.radius = current_radius

	func _on_body_entered(body: Node2D):
		if not player_hit and (body.is_in_group("player") or body.name == "Player"):
			player_hit = true
			if body.has_method("take_damage"):
				body.take_damage(1)
