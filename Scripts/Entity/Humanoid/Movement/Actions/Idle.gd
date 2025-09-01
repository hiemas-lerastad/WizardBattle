class_name HumanoidMovementIdleAction;
extends HumanoidBaseMovementAction;

@export var air_resistance: float = 0.01;

func _process_input_vector(_input: InputPackage, context: ContextPackage) -> void:
	if context.states.has("ground"):
		entity.velocity.x = move_toward(entity.velocity.x, 0, movement_speed);
		entity.velocity.z = move_toward(entity.velocity.z, 0, movement_speed);
	else:
		entity.velocity.x = move_toward(entity.velocity.x, 0, air_resistance);
		entity.velocity.z = move_toward(entity.velocity.z, 0, air_resistance);
