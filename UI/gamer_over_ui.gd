class_name GameOverUI

extends CanvasLayer

@onready var time_value: Label = %TimeValue
@onready var kills_value: Label = %KillsValue

@export var restart_delay: float = 5.0

var restart_cooldown:float
var monsters_defeated: int

func _ready():
	time_value.text = GameManager.time_elapsed_string
	kills_value.text = str(GameManager.monsters_defeated)
	restart_cooldown = restart_delay

func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0.0:
		restart_game()

func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
