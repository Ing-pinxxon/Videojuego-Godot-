extends CharacterBody2D

@export var max_health = 3
@export var damage_to_player = 1
@export var speed = 100
@export var limit = 0.5
@export var damage_cooldown = 1.0

var health = max_health
var startPosition : Vector2
var endPosition : Vector2
var is_dead = false
var can_damage = true

@onready var animations = $AnimatedSprite2D

var hearts_container : HBoxContainer
var heart_texture = preload("res://assets/ui/heart.png")

func _ready():
	health = max_health
	startPosition = position
	# Establecer rango de movimiento (empieza moviendose en horizontal)
	endPosition = startPosition + Vector2(100, 0)
	
	# Inicialización de la UI de corazones
	hearts_container = HBoxContainer.new()
	hearts_container.alignment = BoxContainer.ALIGNMENT_CENTER
	# Ajuste sobre el murciélago
	hearts_container.position = Vector2(0, -60)
	hearts_container.size = Vector2(60, 20)
	
	add_child(hearts_container)
	_update_hearts()

func changeDirection():
	var tempEnd = endPosition
	endPosition = startPosition
	startPosition = tempEnd

func updateVelocity():
	if is_dead: return
	
	var moveDirection = endPosition - position
	# Si ya alcanzó el límite, dar la vuelta
	if moveDirection.length() < speed * get_physics_process_delta_time() or moveDirection.length() < limit:
		changeDirection()
		moveDirection = endPosition - position
	
	velocity = moveDirection.normalized() * speed

func updateAnimation():
	if is_dead: return
	
	# El usuario indicó que la animación se llama "movimiento"
	animations.play("movimiento")
	
	# Voltear sprite dependiendo de la dirección
	if velocity.x > 0:
		animations.flip_h = true
	elif velocity.x < 0:
		animations.flip_h = false

func _physics_process(delta):
	if not is_dead:
		updateVelocity()
		move_and_slide()
		updateAnimation()
		
		# Ajustar posición del contenedor de corazones
		var relative_offset = Vector2(-30, -50) 
		hearts_container.position = relative_offset
		
		# Lógica de daño
		if can_damage:
			for body in $Hitbox2.get_overlapping_bodies():
				if body.is_in_group("player") or body.name == "Player":
					_on_hitbox_body_entered(body)
					break

func take_damage(amount: int):
	if is_dead: return
	
	health -= amount
	_update_hearts()
	print("Murciélago dañado! Vida restante: ", health)
	
	# Efecto visual al recibir daño
	var tween = create_tween()
	animations.modulate = Color.WHITE
	tween.tween_property(animations, "modulate", Color(1, 0.3, 0.3, 1), 0.2)
	tween.tween_property(animations, "modulate", Color.WHITE, 0.2)
	
	if health <= 0:
		die()

func _update_hearts():
	if not hearts_container: return
	
	for child in hearts_container.get_children():
		child.queue_free()
	
	for i in range(health):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(265, 2565) # Ajustar tamaño según convenga
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hearts_container.add_child(heart)

func die():
	print("Murciélago derrotado!")
	is_dead = true
	queue_free()

func _on_hitbox_area_entered(area):
	if is_dead: return
	if area.name == "AttackArea": # Dejar el nombre del ataque igual que en los demás scripts
		take_damage(1)

func _on_hitbox_body_entered(body):
	if is_dead or not can_damage: return
	if (body.is_in_group("player") or body.name == "Player") and body.has_method("take_damage"):
		body.take_damage(damage_to_player)
		can_damage = false
		await get_tree().create_timer(damage_cooldown).timeout
		can_damage = true
