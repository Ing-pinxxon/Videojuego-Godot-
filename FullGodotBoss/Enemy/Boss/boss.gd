extends CharacterBody2D

@export var max_health := 500
@export var speed := 120
@export var melee_damage := 20
@export var projectile_damage := 10
@export var detection_range := 500.0
@export var attack_range := 80.0
@export var projectile_scene : PackedScene

var health := max_health
var phase := 1
var player = null
var can_attack := true

@onready var attack_timer = $AttackTimer

func _ready():
	player = get_tree().get_first_node_in_group("player")
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	if player == null:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= detection_range:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		if distance <= attack_range and can_attack:
			melee_attack()

		elif can_attack:
			ranged_attack()

func melee_attack():
	can_attack = false

	if player.has_method("take_damage"):
		player.take_damage(melee_damage)

	attack_timer.start()

func ranged_attack():
	can_attack = false

	if projectile_scene != null:
		var projectile = projectile_scene.instantiate()

		projectile.global_position = global_position
		projectile.direction = (player.global_position - global_position).normalized()
		projectile.damage = projectile_damage

		get_parent().add_child(projectile)

	attack_timer.start()

func take_damage(amount):
	health -= amount

	if health <= max_health * 0.7 and phase == 1:
		phase = 2
		speed = 180

	if health <= max_health * 0.3 and phase == 2:
		phase = 3
		speed = 250

	if health <= 0:
		queue_free()

func _on_attack_timer_timeout():
	can_attack = true
