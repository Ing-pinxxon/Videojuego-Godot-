extends Node

# Lo que ya tenías — no lo tocamos
var rooms_visited = {}

# ── PUZZLES ──────────────────────────────────────────────
# Guarda qué puzzles han sido resueltos
# Clave: nombre de la habitación  |  Valor: true/false
var puzzles_resueltos := {}

# Llama esta función cuando un puzzle se completa
func resolver_puzzle(nombre_habitacion: String) -> void:
	puzzles_resueltos[nombre_habitacion] = true
	print("✅ Puzzle resuelto en: ", nombre_habitacion)

# Llama esta función para saber si el puzzle ya fue resuelto
func puzzle_esta_resuelto(nombre_habitacion: String) -> bool:
	return puzzles_resueltos.get(nombre_habitacion, false)
