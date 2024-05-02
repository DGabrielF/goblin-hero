extends Node2D

@onready var area2d: Area2D = $RageArea

@export var damage_amount: int = 2

func deal_demage():
	var bodies = area2d.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			enemy.damage(damage_amount)
			
			if enemy.is_dead():
				GameManager.experience += enemy.given_experience()
				enemy.die()
				#level_up()
