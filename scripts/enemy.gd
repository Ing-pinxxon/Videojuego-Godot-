extends CharacterBody2D
class_name Enemy

enum State { PATROL, CHASE, ATTACK, DEAD }
@export var enemy_id: String = ""
@export_group("Base Attributes")
@export var max_health: int = 2
@export var speed: int = 100
@export var detection_range: float = 200.0
@export var attack_range: float = 50.0
@export var show_health_bar: bool = false

var health: int = 0
var current_state: State = State.PATROL
var is_dead: bool = false
var target_player: Node2D = null

@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
var hearts_container: HBoxContainer
var health_bar: ProgressBar

var startPosition: Vector2
var endPosition: Vector2
var heart_texture = preload("res://assets/ui/heart.png")
var is_loading: bool = false
var can_damage: bool = true

func _ready():
	health = max_health if max_health > 0 else 2
	startPosition = global_position
	endPosition = startPosition + Vector2(100, 0)

	if enemy_id == "":
		enemy_id = name + "_" + str(int(startPosition.x)) + "_" + str(int(startPosition.y))
		print("🔑 ID auto-generado: ", enemy_id)

	_setup_ui()
	_setup_detection()
	_update_hearts()
	add_to_group("enemies")

func _setup_ui():
	hearts_container = HBoxContainer.new()
	hearts_container.size = Vector2(60, 20)
	add_child(hearts_container)

	health_bar = ProgressBar.new()
	health_bar.size = Vector2(80, 10)
	health_bar.show_percentage = false
	health_bar.visible = false
	add_child(health_bar)

func _setup_detection():
	for node in get_tree().get_nodes_in_group("player"):
		if node is CharacterBody2D:
			target_player = node
			break

func _physics_process(_delta):
	if is_dead: return

	_update_state()
	_apply_movement(_delta)
	_update_animation()
	_update_ui_position()

func _update_state():
	if target_player:
		var dist = global_position.distance_to(target_player.global_position)
		if dist <= attack_range:
			current_state = State.ATTACK
		elif dist <= detection_range:
			current_state = State.CHASE
		else:
			current_state = State.PATROL
	else:
		current_state = State.PATROL

func _apply_movement(_delta):
	match current_state:
		State.PATROL:
			_patrol_logic(_delta)
		State.CHASE:
			_chase_logic(_delta)
		State.ATTACK:
			_attack_logic(_delta)

	move_and_slide()

func _patrol_logic(_delta):
	var moveDirection = endPosition - global_position
	if moveDirection.length() < 5.0:
		var temp = endPosition
		endPosition = startPosition
		startPosition = temp

	velocity = moveDirection.normalized() * (speed * 0.5)

func _chase_logic(_delta):
	if target_player:
		var moveDirection = target_player.global_position - global_position
		velocity = moveDirection.normalized() * speed

func _attack_logic(_delta):
	velocity = Vector2.ZERO

func _update_animation():
	var anim_prefix = "walk"
	if current_state == State.ATTACK:
		anim_prefix = "attack"

	var direction = "Down"
	if abs(velocity.x) > abs(velocity.y):
		direction = "Right" if velocity.x > 0 else "Left"
	elif velocity.y < 0:
		direction = "Up"

	var anim_name = anim_prefix + direction
	if animations.sprite_frames.has_animation(anim_name):
		animations.play(anim_name)
	else:
		if animations.sprite_frames.has_animation("walkRight") and velocity.x >= 0:
			animations.play("walkRight")
		elif animations.sprite_frames.has_animation("walkLeft"):
			animations.play("walkLeft")

func _update_ui_position():
	if not is_instance_valid(hearts_container) or not is_instance_valid(health_bar):
		return
	var relative_offset = Vector2(-30, -50)
	hearts_container.position = relative_offset
	health_bar.position = relative_offset + Vector2(-10, 0)

func take_damage(amount: int):
	if is_dead or is_loading: return

	health -= amount
	_update_hearts()

	var tween = create_tween()
	tween.tween_property(animations, "modulate", Color.RED, 0.1)
	tween.tween_property(animations, "modulate", Color.WHITE, 0.1)

	if health <= 0:
		die()

func die():
	is_dead = true
	current_state = State.DEAD
	velocity = Vector2.ZERO

	if has_node("/root/GlobalState"):
		GlobalState.registrar_enemigo_derrotado(enemy_id)

	if animations.sprite_frames.has_animation("death"):
		animations.play("death")
		await animations.animation_finished

	queue_free()

func _update_hearts():
	if not is_instance_valid(hearts_container) or not is_instance_valid(health_bar):
		return

	for child in hearts_container.get_children():
		child.queue_free()

	for i in range(health):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.custom_minimum_size = Vector2(10, 10)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hearts_container.add_child(heart)

	if show_health_bar:
		hearts_container.visible = false
		health_bar.visible = true
		health_bar.max_value = max_health
		health_bar.value = health
	else:
		hearts_container.visible = true
		health_bar.visible = false
