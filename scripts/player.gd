extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2d
@onready var attack_area = $AttackArea

@export var max_health = 5
var speed = 250.0
@export var attack_cooldown = 0.5 

var health = max_health
var can_attack = true
var is_attacking = false

var last_direction = "up"
var is_invincible = false
@export var invincibility_duration = 1.0

var hearts_container : HBoxContainer
var heart_texture = preload("res://assets/ui/heart.png")

func _ready():
	# Attack Area setup
	if attack_area:
		attack_area.monitoring = false
		attack_area.monitorable = false
		attack_area.visible = false
		if not attack_area.area_entered.is_connected(_on_attack_area_entered):
			attack_area.area_entered.connect(_on_attack_area_entered)
		# Aumentar tamaño del área de ataque programáticamente (vuelve el rectángulo de 20x20 a 40x40)
		var shape = attack_area.get_node("CollisionShape2D").shape
		if shape is RectangleShape2D:
			shape.size = Vector2(40, 40)
	
	health = max_health
	
	# Inicialización UI de Corazones
	hearts_container = HBoxContainer.new()
	hearts_container.alignment = BoxContainer.ALIGNMENT_CENTER
	# Posición encima del jugador
	hearts_container.position = Vector2(-30, -30)
	# Fix size
	hearts_container.size = Vector2(60, 20)
	
	add_child(hearts_container)
	_update_hearts()
	add_to_group("player")
	print("DEBUG: Player ready. Groups: ", get_groups())


func _physics_process(delta):
	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

	if not is_attacking:
		get_input()
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	
func get_input():
	var input_direction = Input.get_vector("left","right","up","down")
	
	if input_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		update_animation("idle")
		return
	
	if abs(input_direction.x) > abs(input_direction.y):
		#MOVIMIENTO HORIZONTAL
		if input_direction.x > 0:
			last_direction = "right"
		else :
			last_direction = "left"
	else :
		if input_direction.y > 0:
			last_direction = "down"
		else :
			last_direction = "up"
	
	update_animation("run")
	velocity = input_direction * speed

func update_animation(state):
	animated_sprite_2d.play(state + "_"+ last_direction)

func attack():
	print("Jugador Atacando!")
	can_attack = false
	is_attacking = true
	
	# Posicionar el área de ataque según la dirección
	_position_attack_area()
	
	# Play attack animation
	animated_sprite_2d.play("attack_" + last_direction)
	
	if attack_area:
		attack_area.monitoring = true
		attack_area.monitorable = true
		attack_area.visible = true
		print("DEBUG: AttackArea activado en pos: ", attack_area.position)
	
	if not is_inside_tree(): return
	# Desactivar área (0.4s para coincidir con la animación)
	await get_tree().create_timer(0.4).timeout
	if not is_inside_tree(): return
	
	if attack_area:
		attack_area.monitoring = false
		attack_area.monitorable = false
		attack_area.visible = false
		print("DEBUG: AttackArea desactivado")
	
	# Esperar a que la animación termine (6 frames a 10fps = 0.6s)
	await get_tree().create_timer(0.4).timeout
	if not is_inside_tree(): return
	
	is_attacking = false
	can_attack = true
	
	# Volver a idle se manejará en el siguiente _physics_process automáticamente 
	# si dejamos de presionar teclas

func _position_attack_area():
	if not attack_area: return
	
	# Posiciones del área de ataque según dirección (offset a 8 para que sea "unido")
	# Posiciones ajustadas al centro del sprite (offset 10, 9 aprox)
	if last_direction == "right":
		attack_area.position = Vector2(18, 9)
		attack_area.rotation_degrees = 0
	elif last_direction == "left":
		attack_area.position = Vector2(2, 9)
		attack_area.rotation_degrees = 180
	elif last_direction == "up":
		attack_area.position = Vector2(10, 1)
		attack_area.rotation_degrees = -90
	elif last_direction == "down":
		attack_area.position = Vector2(10, 17)
		attack_area.rotation_degrees = 90

func take_damage(amount: int):
	if is_invincible: return
	
	health -= amount
	_update_hearts()
	print("Jugador dañado! Vida: ", health)
	
	# Activar invencibilidad
	is_invincible = true
	
	# Efecto visual de daño (Cian/Azul para "choque de fantasma")
	var tween = create_tween()
	animated_sprite_2d.modulate = Color.WHITE
	tween.tween_property(animated_sprite_2d, "modulate", Color(0, 0.65, 1, 1), 0.2)
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.2)
	
	# Titileo de invencibilidad opcional (Flash)
	var flash_tween = create_tween().set_loops(int(invincibility_duration / 0.2))
	flash_tween.tween_property(animated_sprite_2d, "modulate", Color(1, 1, 1, 0.5), 0.1)
	flash_tween.tween_property(animated_sprite_2d, "modulate", Color(1, 1, 1, 1), 0.1)
	
	if health <= 0:
		die()
	else:
		if not is_inside_tree(): return
		await get_tree().create_timer(invincibility_duration).timeout
		is_invincible = false

func _update_hearts():
	if not hearts_container: return
	
	# Borrar corazones actuales
	for child in hearts_container.get_children():
		child.queue_free()
	
	# Crear nuevos corazones según la vida actual
	for i in range(health):
		var heart = TextureRect.new()
		heart.texture = heart_texture
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(8, 8)
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		hearts_container.add_child(heart)

func die():
	print("Jugador derrotado! Volviendo al Nivel 1...")
	get_tree().change_scene_to_file("res://scenes/Nivel_1.tscn")

func _on_attack_area_entered(area):
	print("DEBUG: Player AttackArea entró en: ", area.name, " del objeto: ", area.get_parent().name)
	
	# Obtener el padre del área (debería ser el enemigo)
	var enemy = area.get_parent()
	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(1)
		print("DEBUG: Enemigo dañado! ", enemy.name)


func _on_texture_button_pressed():
	print("Botón presionado")
