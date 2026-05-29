extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2d
@onready var attack_area = $AttackArea
@onready var interfaz_escena = preload("res://scenes/interfazMenu.tscn")
var interfaz_canvas: CanvasLayer
var interfaz_instancia: Control
var objeto_cercano = null
var objeto_cargado = null

@export var max_health: int = 5
var speed: float = 250.0
@export var attack_cooldown: float = 0.5

var health: int = 5
var can_attack: bool = true
var is_attacking: bool = false

var last_direction: String = "up"
var is_invincible: bool = false
@export var invincibility_duration: float = 1.5

var hearts_container: HBoxContainer
var heart_texture = preload("res://assets/ui/heart.png")

func _ready():
	health = max_health if max_health > 0 else 5

	if attack_area:
		attack_area.monitoring = false
		attack_area.monitorable = false
		attack_area.visible = false
		if not attack_area.area_entered.is_connected(_on_attack_area_entered):
			attack_area.area_entered.connect(_on_attack_area_entered)
		var shape = attack_area.get_node("CollisionShape2D").shape
		if shape is RectangleShape2D:
			shape.size = Vector2(120, 90)

	hearts_container = HBoxContainer.new()
	hearts_container.alignment = BoxContainer.ALIGNMENT_CENTER
	hearts_container.position = Vector2(-30, -30)
	hearts_container.size = Vector2(60, 20)
	add_child(hearts_container)
	_update_hearts()
	add_to_group("player")
	print("DEBUG: Player ready. Groups: ", get_groups())

	interfaz_canvas = CanvasLayer.new()
	interfaz_canvas.process_mode = PROCESS_MODE_ALWAYS
	interfaz_instancia = interfaz_escena.instantiate()
	interfaz_canvas.add_child(interfaz_instancia)
	add_child(interfaz_canvas)
	if interfaz_instancia.has_method("hide_menu"):
		interfaz_instancia.hide_menu()
	else:
		interfaz_instancia.hide()

	if GlobalState.should_load_game:
		call_deferred("_apply_save_deferred")

	var menu_button = get_node_or_null("TextureButton")
	if menu_button:
		menu_button.process_mode = PROCESS_MODE_ALWAYS

	get_tree().paused = false

func _apply_save_deferred():
	GlobalState.apply_load_game(self)

func _physics_process(delta):
	if Input.is_action_just_pressed("attack") and can_attack:
		attack()

	if not is_attacking:
		get_input()
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	# Empujar objetos dinámicos (piedras/rocas) al hacer contacto físico
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.has_method("push_object"):
			collider.push_object(collision.get_normal())

	# Solo empujar objetos si NO estamos cargando uno
	if objeto_cargado == null:
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			var obj = col.get_collider()
			if obj and obj.is_in_group("empujable"):
				obj.velocity = velocity.normalized() * 70.0

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")

	if input_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		update_animation("idle")
		return

	if abs(input_direction.x) > abs(input_direction.y):
		last_direction = "right" if input_direction.x > 0 else "left"
	else:
		last_direction = "down" if input_direction.y > 0 else "up"

	update_animation("run")
	velocity = input_direction * speed

func update_animation(state: String):
	animated_sprite_2d.play(state + "_" + last_direction)

func attack():
	print("Jugador Atacando!")
	can_attack = false
	is_attacking = true

	_position_attack_area()
	animated_sprite_2d.play("attack_" + last_direction)

	if attack_area:
		attack_area.monitoring = true
		attack_area.monitorable = true
		attack_area.visible = true
		print("DEBUG: AttackArea activado en pos: ", attack_area.position)

	if not is_inside_tree(): return
	await get_tree().create_timer(0.4).timeout
	if not is_inside_tree(): return

	if attack_area:
		attack_area.monitoring = false
		attack_area.monitorable = false
		attack_area.visible = false
		print("DEBUG: AttackArea desactivado")

	await get_tree().create_timer(0.4).timeout
	if not is_inside_tree(): return

	is_attacking = false
	can_attack = true

func _position_attack_area():
	if not attack_area: return

	match last_direction:
		"right":
			attack_area.position = Vector2(18, 9)
			attack_area.rotation_degrees = 0
		"left":
			attack_area.position = Vector2(2, 9)
			attack_area.rotation_degrees = 180
		"up":
			attack_area.position = Vector2(10, 1)
			attack_area.rotation_degrees = -90
		"down":
			attack_area.position = Vector2(10, 17)
			attack_area.rotation_degrees = 90

func take_damage(amount: int):
	if is_invincible: return

	# Modo Prueba: Inmortalidad completa
	if "modo_prueba" in GlobalState and GlobalState.modo_prueba:
		print("🛡️ [Modo Prueba] ¡Daño de ", amount, " bloqueado!")
		return

	health -= amount
	_update_hearts()
	print("Jugador dañado! Vida: ", health)

	is_invincible = true

	var tween = create_tween()
	animated_sprite_2d.modulate = Color.WHITE
	tween.tween_property(animated_sprite_2d, "modulate", Color(0, 0.65, 1, 1), 0.2)
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.2)

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

	for child in hearts_container.get_children():
		child.queue_free()

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
	var enemy = area.get_parent()
	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(1)
		print("DEBUG: Enemigo dañado! ", enemy.name)

func _on_texture_button_pressed():
	print("Botón presionado")
	if interfaz_instancia:
		if interfaz_instancia.visible:
			if interfaz_instancia.has_method("hide_menu"):
				interfaz_instancia.hide_menu()
			else:
				interfaz_instancia.hide()
		else:
			if interfaz_instancia.has_method("show_menu"):
				interfaz_instancia.show_menu()
			else:
				interfaz_instancia.show()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("empujable"):
		objeto_cercano = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("empujable"):
		if objeto_cercano == body:
			objeto_cercano = null

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if objeto_cargado == null and objeto_cercano != null:
			objeto_cargado = objeto_cercano
			objeto_cercano = null
			objeto_cargado.ser_recogido(self)
		elif objeto_cargado != null:
			objeto_cargado.ser_soltado()
			objeto_cargado = null

func soltar_objeto():
	if objeto_cargado != null:
		objeto_cargado.ser_soltado()
		objeto_cargado = null
