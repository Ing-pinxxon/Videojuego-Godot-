extends Area2D

@export var speed: float = 300.0
@export var damage: int = 1
var direction: Vector2 = Vector2.ZERO

@export var is_homing: bool = false
var target: Node2D = null
@export var homing_speed: float = 2.0
@export var base_scale: float = 1.0

var lifetime: float = 0.0
var trail_points: Array = []
const MAX_TRAIL_POINTS := 8

func _ready():
	# Ocultar el ColorRect rojo por defecto que es extremadamente pequeño (8x8)
	var color_rect = get_node_or_null("ColorRect")
	if color_rect:
		color_rect.visible = false
	
	# Expandir la colisión física para ajustarla al nuevo tamaño visual
	var shape_node = get_node_or_null("CollisionShape2D")
	if shape_node and shape_node.shape is CircleShape2D:
		# Escala la colisión física un poco menor que la visual para evitar colisiones absurdas con paredes
		shape_node.shape.radius = 10.0 * (1.0 + (base_scale - 1.0) * 0.4)
		
	queue_redraw()

func _physics_process(delta):
	lifetime += delta
	
	# Añadir punto al inicio de la estela (coordenada local inicial)
	trail_points.push_front(Vector2.ZERO)
	if trail_points.size() > MAX_TRAIL_POINTS:
		trail_points.pop_back()
	
	# Desplazar todos los puntos de la estela en sentido opuesto al movimiento del proyectil
	var movement = direction * speed * delta
	for i in range(trail_points.size()):
		trail_points[i] -= movement
	
	if is_homing and is_instance_valid(target):
		var target_dir = (target.global_position - global_position).normalized()
		direction = direction.lerp(target_dir, homing_speed * delta).normalized()
	
	position += direction * speed * delta
	
	# Efecto de pulsación premium: hace vibrar la escala visual usando una onda senoidal
	var pulse = base_scale * (1.0 + sin(lifetime * 14.0) * 0.15)
	scale = Vector2(pulse, pulse)
	
	queue_redraw()

func _draw():
	var col = modulate
	
	# 0. Dibujar estela mágica difuminada (Trail)
	for i in range(1, trail_points.size()):
		var ratio = float(i) / MAX_TRAIL_POINTS
		var alpha = (1.0 - ratio) * 0.45
		var thickness = 14.0 * (1.0 - ratio)
		var trail_color = Color(col.r, col.g, col.b, alpha)
		draw_line(trail_points[i-1], trail_points[i], trail_color, thickness)
	
	if has_meta("vampire_shooter"):
		# 1. Resplandor exterior (Aura de sangre)
		draw_circle(Vector2.ZERO, 16.0, Color(col.r, col.g, col.b, 0.3))
		
		# 2. Dibujar un murciélago animado con alas aleteando
		var flap = sin(lifetime * 20.0) # Frecuencia de aleteo rápido
		var wing_y = flap * 12.0
		
		# Puntos para el ala izquierda
		var left_wing = PackedVector2Array([
			Vector2(0, 2),
			Vector2(-10, -5 + wing_y),
			Vector2(-20, 2 + wing_y * 0.5),
			Vector2(-12, 6),
			Vector2(-6, 3),
			Vector2(0, 2)
		])
		
		# Puntos para el ala derecha
		var right_wing = PackedVector2Array([
			Vector2(0, 2),
			Vector2(10, -5 + wing_y),
			Vector2(20, 2 + wing_y * 0.5),
			Vector2(12, 6),
			Vector2(6, 3),
			Vector2(0, 2)
		])
		
		# Dibujar el cuerpo de las alas (color carmesí oscuro)
		draw_colored_polygon(left_wing, Color(0.18, 0.0, 0.0))
		draw_colored_polygon(right_wing, Color(0.18, 0.0, 0.0))
		
		# Dibujar bordes de las alas (rojo brillante)
		draw_polyline(left_wing, Color(1.0, 0.1, 0.1), 1.5)
		draw_polyline(right_wing, Color(1.0, 0.1, 0.1), 1.5)
		
		# Dibujar cabeza con orejas de murciélago
		draw_circle(Vector2(0, -5), 4.5, Color(1.0, 0.1, 0.1))
		
		# Ojos brillantes amarillos del murciélago para que se vea genial y malvado
		draw_circle(Vector2(-1.5, -6), 1.0, Color.YELLOW)
		draw_circle(Vector2(1.5, -6), 1.0, Color.YELLOW)
		
		# Dibujar cuerpo central
		draw_circle(Vector2(0, 1), 5.0, Color.BLACK)
	else:
		# 1. Resplandor exterior (Aura semi-transparente)
		draw_circle(Vector2.ZERO, 18.0, Color(col.r, col.g, col.b, 0.35))
		
		# 2. Núcleo de alta energía (Blanco brillante en el centro)
		draw_circle(Vector2.ZERO, 9.0, Color.WHITE)
		
		# 3. Borde coloreado del núcleo
		draw_arc(Vector2.ZERO, 9.0, 0, TAU, 32, col, 2.0)

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(damage)
		if has_meta("vampire_shooter"):
			var vampire = get_meta("vampire_shooter")
			if is_instance_valid(vampire) and not vampire.is_dead:
				if vampire.has_method("heal"):
					vampire.heal(1)
				# Espectacular rayo de robo de vida de color rojo sangre
				var parent = get_parent()
				if parent:
					var beam = Line2D.new()
					beam.default_color = Color(1.0, 0.05, 0.1, 0.85) # Rojo sangre brillante y resplandeciente
					beam.width = 5.0
					# Conectar desde el pecho del jugador (16px arriba de su origen) al pecho del vampiro (10px arriba)
					beam.add_point(body.global_position - Vector2(0, 16))
					beam.add_point(vampire.global_position - Vector2(0, 10))
					parent.add_child(beam)
					# Desvanecer el rayo en 0.4 segundos
					var beam_tween = parent.create_tween()
					beam_tween.tween_property(beam, "modulate:a", 0.0, 0.4)
					beam_tween.tween_callback(beam.queue_free)
		queue_free()
	elif body is TileMap or body is StaticBody2D:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
