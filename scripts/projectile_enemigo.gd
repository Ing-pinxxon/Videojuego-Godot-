extends Area2D

@export var speed: float = 300.0
@export var damage: int = 1
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player") or body.name == "Player":
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	elif body is TileMap or body is StaticBody2D:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
