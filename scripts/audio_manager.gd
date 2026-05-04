extends Node

# Diccionario de sonidos (puedes añadir más aquí)
var sfx_paths = {
	"door_open": "res://audio/sfx/door_open.wav",
	"door_close": "res://audio/sfx/door_close.wav",
	"enemy_death": "res://audio/sfx/enemy_death.wav",
	"player_attack": "res://audio/sfx/attack.wav",
	"player_hit": "res://audio/sfx/hit.wav",
	"player_death": "res://audio/sfx/player_death.wav",
	"error": "res://audio/sfx/error.wav",
	"ui_click": "res://audio/sfx/ui_click.wav"
}

var music_paths = {
	"main_theme": "res://audio/music/main_theme.mp3"
}

var music_player: AudioStreamPlayer

func _ready():
	# Inicializar el reproductor de música
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)

func play_sfx(sound_name: String, volume_db: float = 0.0):
	if not sfx_paths.has(sound_name):
		print("⚠️ AudioManager: SFX no definido -> ", sound_name)
		return
		
	var path = sfx_paths[sound_name]
	if not FileAccess.file_exists(path):
		print("🔊 AudioManager: Archivo de sonido no encontrado -> ", path)
		return
		
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = load(path)
	sfx_player.volume_db = volume_db
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	sfx_player.play()
	
	# Liberar el nodo cuando termine de sonar
	sfx_player.finished.connect(sfx_player.queue_free)

func play_music(music_name: String, volume_db: float = -10.0):
	if not music_paths.has(music_name):
		print("⚠️ AudioManager: Música no definida -> ", music_name)
		return
		
	var path = music_paths[music_name]
	if not FileAccess.file_exists(path):
		print("🔊 AudioManager: Archivo de música no encontrado -> ", path)
		return
		
	if music_player.playing and music_player.stream.resource_path == path:
		return # Ya está sonando esta misma pista
		
	music_player.stream = load(path)
	music_player.volume_db = volume_db
	music_player.play()

func stop_music():
	music_player.stop()
