class_name Stats;
extends Resource;

@export_group("Health")
@export var max_health: float = 50.0:
	set(value):
		max_health = value;
		health = health;

@export var health: float = 50.0:
	set(value):
		if value > max_health:
			health = max_health;

		elif value > 0.0:
			health = 0.0;

		else:
			health = value;
