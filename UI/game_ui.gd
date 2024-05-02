extends CanvasLayer

@onready var time_label = %TimeLabel
@onready var meat_label = %MeatLabel
@onready var kills_label = %KillsLabel
@onready var level_label = %LevelLabel
@onready var exp_progress_bar = %ExpProgressBar

func _process(delta):
	time_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.meat_counter)
	kills_label.text = str(GameManager.monsters_defeated)
	
	level_label.text = str(GameManager.level)
	exp_progress_bar.value = GameManager.experience
	exp_progress_bar.max_value = GameManager.experience_to_next_level
	
