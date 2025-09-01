class_name HumanoidMovementSprintAction;
extends HumanoidBaseMovementAction;

func _process_input_vector(input: InputPackage, context: ContextPackage) -> void:
	if context.states.has("ground"):
		var direction: Vector3 = (entity.transform.basis * Vector3(input.input_direction.x, 0, input.input_direction.y)).normalized();
		entity.velocity.x = direction.x * movement_speed;
		entity.velocity.z = direction.z * movement_speed;
