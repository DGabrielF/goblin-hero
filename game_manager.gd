extends Node

signal game_over

var player: Player
var player_position: Vector2
var is_game_over: bool = false

var level: int = 1
var experience: int = 0
var experience_to_next_level: int = 100

var time_elapsed: float = 0.0
var time_elapsed_string: String
var meat_counter: int = 0
var monsters_defeated: int =  0

func _process(delta):
	time_elapsed += delta
	
	var time_elapsed_in_seconds: int = floori(GameManager.time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = floori(time_elapsed_in_seconds / 60)
	
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]
	
	level_up()

func eng_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()

func reset():
	player = null
	player_position = Vector2.ZERO
	
	level = 1
	experience = 0
	experience_to_next_level = 100
	
	time_elapsed = 0.0
	time_elapsed_string = "00:00"
	meat_counter = 0
	monsters_defeated =  0
	
	is_game_over = false
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)

func level_up():
	if experience < experience_to_next_level: return
	experience -= experience_to_next_level
	level += 1
	experience_to_next_level = 99 + floori(level * 2.5)
