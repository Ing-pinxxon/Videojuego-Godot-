extends Node2D
# Este script hereda de Node2D, lo que significa que se usa en un nodo 2D dentro de la escena.

@onready var minimap = $CanvasLayer/TextureRect
# @onready: hace que la variable se inicialice cuando el nodo esté listo (_ready)
# minimap: referencia al nodo TextureRect que está dentro de CanvasLayer
# Este nodo representa el minimapa en pantalla

func _ready() -> void:
	# Esta función se ejecuta una vez cuando la escena se carga
	
	minimap.visible = false
	# Oculta el minimapa al iniciar el juego

func _input(event):
	# Esta función detecta entradas del usuario (teclado, mouse, etc.)
	
	if event.is_action_pressed("minimap"):
		# Verifica si se presionó la acción "minimap"
		# (Debe estar configurada en el Input Map del proyecto)
		
		minimap.visible = !minimap.visible
		# Cambia el estado de visibilidad:
		# Si está visible -> lo oculta
		# Si está oculto -> lo muestra

func _process(delta: float) -> void:
	# Esta función se ejecuta en cada frame (cada actualización del juego)
	
	pass
	# No hace nada por ahora (puedes usarla después si necesitas lógica continua)
