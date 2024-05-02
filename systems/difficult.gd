extends Node

@export var mob_spawner: MobSpawner
@export var initial_spawn_rate: float = 30.0
@export var spawn_increment_per_minute: float = 10.0
@export var wave_duration: float = 15.0
@export var break_intensity: float = 0.2

var time: float = 0.0

func _process(delta):
	if GameManager.is_game_over: return
	
	time += delta
	var max_spawn_rate = initial_spawn_rate + spawn_increment_per_minute * (time / 60.0)
	
	var sin_wave = sin((time * TAU)/wave_duration)
	var wave = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	
	mob_spawner.mobs_per_minute = max_spawn_rate * wave
