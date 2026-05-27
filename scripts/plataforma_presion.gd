extends Area2D

@onready var sprite = $Sprite2D

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name.contains("ObjetoEmpujable"):
		sprite.modulate = Color(0, 1, 0)  # verde = activada
		get_parent().plataforma_activada()

func _on_body_exited(body):
	if body.name.contains("ObjetoEmpujable"):
		sprite.modulate = Color(1, 1, 1)  # blanco = desactivada
		get_parent().plataforma_desactivada()
