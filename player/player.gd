class_name Player

extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer  = $AnimationPlayer
@onready var attack_area = $AttackArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

@export_category("Movement")
@export var speed: float = 3.0
@export_category("Attack")
@export var basic_attack_damage: int = 2
@export var basic_attack_cooldown: float = 2.0
@export_category("Bless")
@export var bless_damage: int = 2
@export var bless_interval: float = 26
@export var bless_scene: PackedScene
@export_category("Health")
@export var health: int = 150
@export var max_health: int = 150
@export var death_effect: PackedScene
@export_category("Experience")
@export var level: int = 1
@export var experience: int = 0
@export var experience_to_next_level: int = 100

var input_vector: Vector2 = Vector2(0, 0)
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var bless_cooldown: float = 0.0

signal meat_collected(value:int)

func _ready():
	GameManager.player = self
	meat_collected.connect(func(value:int): GameManager.meat_counter += 1)

func _process(delta):
	GameManager.player_position = position
	
	read_move_input()
	
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("basic_attack"):
		basic_attack()
		
	update_bless(delta)
	
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health

func _physics_process(delta):
	var target_velocity = input_vector * speed * 100.0
	if is_attacking:
		target_velocity *= 0.05
	velocity = lerp(velocity, target_velocity, 0.1)
	move_and_slide()

func read_move_input():
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	var deadzone = 0.15
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0
		
	was_running = is_running
	is_running = not input_vector.is_zero_approx()

func play_run_idle_animation():
	if not is_attacking:
		if was_running != is_running:
			if is_running:
				animation_player.play("run")
			else:
				animation_player.play("idle")

func rotate_sprite():
	if input_vector.x > 0:
		sprite.flip_h = false
	elif input_vector.x < 0:
		sprite.flip_h = true

func update_attack_cooldown(delta):
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")

func update_bless(delta):
	bless_cooldown -= delta
	if bless_cooldown > 0: return	
	bless_cooldown = bless_interval
	
	var bless = bless_scene.instantiate()
	bless.damage_amount = bless_damage
	add_child(bless)

func basic_attack():
	if is_attacking:
		return

	if abs(input_vector.x) >= abs(input_vector.y):
		animation_player.play("attack_side")
	else:
		if (input_vector.y > 0):
			animation_player.play("attack_down")
		elif (input_vector.y < 0):
			animation_player.play("attack_up")
			
	attack_cooldown = 0.55
	
	is_attacking = true
	
func deal_damage():
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if abs(input_vector.x) >= abs(input_vector.y):
				if sprite.flip_h:
					attack_direction = Vector2.LEFT
				else:
					attack_direction = Vector2.RIGHT
			else:
				if (input_vector.y > 0):
					attack_direction = Vector2.DOWN
				elif (input_vector.y < 0):
					attack_direction = Vector2.UP
			
			var dot_product = direction_to_enemy.dot(attack_direction)
			
			if dot_product > 0.35:
				enemy.damage(basic_attack_damage)

func damage(amount):
	if health <= 0: return
	
	health -= amount
	
	sprite.modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)	
	tween.tween_property(self.sprite, "modulate", Color.WHITE, 0.3)
	
	if health <= 0:
		die()

func die():
	if death_effect:
		var death_object = death_effect.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
		
	GameManager.eng_game()
	queue_free()

func heal(amount):
	health += amount
	if health >= max_health:
		health = max_health

func level_up():
	if experience >= experience_to_next_level:
		experience -= experience_to_next_level
		level += 1
		experience_to_next_level = 99 + floori(level * 2.5)

