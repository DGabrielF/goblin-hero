class_name Enemy

extends Node2D

@onready var attack_area = $AttackArea
@onready var damage_digit_marker = $DamageDigitMarker
@onready var animation_player: AnimationPlayer  = $AnimationPlayer

@export_category("Attack")
@export var basic_attack_damage: int = 2
@export var attack_speed: float = 1.75
@export_category("Live")
@export var health: int = 10
@export var death_effect: PackedScene
@export_category("Drops")
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float]

var attack_cooldown: float = 0.0
var damage_digit_prefab: PackedScene
var max_health: int
var is_attacking: bool = false


func _ready():
	damage_digit_prefab = preload("res://effects/damage_digit.tscn")
	max_health = health

func _process(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta
	else:
		attack_cooldown = attack_speed
		animate_attack()

func animate_attack():
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			var player: Player = body
			var difference = player.position - position
			if abs(difference.x) > abs(difference.y):
				animation_player.play("attack_side")
			else:
				if difference.y > 0:
					animation_player.play("attack_down")
				else:
					animation_player.play("attack_up")

func deal_damage():
	var bodies = attack_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			var player: Player = body
			player.damage(basic_attack_damage)

func damage(amount):
	health -= amount
	
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)	
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	
	var damage_digit = damage_digit_prefab.instantiate()
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	
	get_parent().add_child(damage_digit)
	
	if is_dead():
		GameManager.experience += given_experience()
		die()

func die():
	GameManager.monsters_defeated += 1
	if death_effect:
		var death_object = death_effect.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	given_experience()
	
	drop_item()
	
	queue_free()

func drop_item():
	for i in drop_items.size():
		if randf() <= drop_chances[i]:
			var droped_item = drop_items[i].instantiate()
			droped_item.position = position
			get_parent().add_child(droped_item)

func is_dead():
	return health<=0

func given_experience():
	return int(basic_attack_damage / attack_speed) + max_health

func toggle_is_attacking():
	is_attacking = not is_attacking
