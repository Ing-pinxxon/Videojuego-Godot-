extends Area2D

@export var numero: int = 1

var jugador_cerca := false
var encendida := false

@onready var sprite = $Sprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	apagar()

func _process(_delta):
	if jugador_cerca and Input.is_action_just_pressed("ui_accept"):
		if not encendida:
			encender()

func encender() -> void:
	encendida = true
	sprite.modulate = Color(1, 0.5, 0)  # naranja = encendida
	print("🔥 Antorcha ", numero, " encendida")
	get_parent().antorcha_encendida(numero)

func apagar() -> void:
	encendida = false
	sprite.modulate = Color(0.3, 0.3, 0.3)  # gris oscuro = apagada

func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		jugador_cerca = true

func _on_body_exited(body):
	if body.name == "Player" or body.is_in_group("player"):
		jugador_cerca = false
