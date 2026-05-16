extends Area2D

var direction := Vector2.ZERO
var speed := 400
var damage := 10

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

	queue_free()
