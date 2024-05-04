extends Node


@export var speed = 2.0

var enemy: Enemy

var sprite: Sprite2D
var input_vector: Vector2


func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("Sprite2D")

func _physics_process(delta):
	if GameManager.is_game_over: return
	
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position
	input_vector = difference.normalized()
	
	if not enemy.is_attacking:
		if abs(enemy.velocity) > Vector2.ZERO:
			enemy.animation_player.play("run")
		else:
			enemy.animation_player.play("idle")
			
	var target_velocity = input_vector * speed * 100.0
	if enemy.is_attacking:
		target_velocity *= 0
	enemy.velocity = lerp(enemy.velocity, target_velocity, 0.1)
	
	enemy.move_and_slide()
	
	rotate_sprite()

func rotate_sprite():
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true
