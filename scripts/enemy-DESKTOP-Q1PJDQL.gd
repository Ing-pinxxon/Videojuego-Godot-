extends CharacterBody2D

@export var max_health = 3
@export var damage_to_player = 1
@export var speed = 100
@export var limit = 0.5
var health = max_health

@onready var animations = $AnimatedSprite2D

var startPosition
var endPosition
var is_dead = false

var hearts_container : HBoxContainer
var heart_texture = preload("res://assets/ui/heart.png")

func _ready():
	health = max_health
	startPosition = position
	endPosition = startPosition + Vector2(100, 0) # empieza horizontal
	
	# Inicialización UI de Corazones
	hearts_container = HBoxContainer.new()
	hearts_container.alignment = BoxContainer.ALIGNMENT_CENTER
	# Posición encima del fantasma
	hearts_container.position = Vector2(550, 60) # Ajustado al offset de la escena de Mayerli
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
	# Si estamos muy cerca o vamos a pasarnos en el siguiente frame, cambiamos
	if moveDirection.length() < speed * get_physics_process_delta_time() or moveDirection.length() < limit:
		changeDirection()
		moveDirection = endPosition - position # Recalcular con el nuevo destino
	
	velocity = moveDirection.normalized() * speed

func updateAnimation():
	if is_dead: return
	
	var animationString = "walkDown"
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			animationString = "walkRight"
		else:
			animationString = "walkLeft"
	animations.play(animationString)

func _physics_process(delta):
	if not is_dead:
		updateVelocity()
		move_and_slide()
		updateAnimation()
		
		# Ajustar posición del contenedor de corazones para que siga al personaje virtualmente o compensar el offset masivo de los sprites en la escena de mayerli
		var relative_offset = Vector2(-25, -60)
		hearts_container.position = $CollisionShape2D.position + relative_offset

func take_damage(amount: int):
	if is_dead: return
	
	health -= amount
	_update_hearts()
	print("Enemigo dañado! Vida restante: ", health)
	
	# Efecto de daño visual
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
		heart.custom_minimum_size = Vector2(5, 5)
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hearts_container.add_child(heart)

func die():
	print("Enemigo derrotado!")
	is_dead = true
	queue_free()

func _on_hitbox_area_entered(area):
	if is_dead: return
	if area.name == "AttackArea":
		take_damage(1)

func _on_hitbox_body_entered(body):
	if body.name == "Player" and body.has_method("take_damage"):
		# El jugador recibe daño por tocar al enemigo
		body.take_damage(damage_to_player)
