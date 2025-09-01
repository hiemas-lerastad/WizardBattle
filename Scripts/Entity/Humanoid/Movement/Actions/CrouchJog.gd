class_name HumanoidMovementCrouchJogAction;
extends HumanoidBaseMovementAction;

func _on_enter_action(_input: InputPackage, _context: ContextPackage) -> void:
	if "standing_collider" in entity and entity.standing_collider != null:
		entity.standing_collider.disabled = true;

	if "crouching_collider" in entity and entity.crouching_collider != null:
		entity.crouching_collider.disabled = false;

	if "pivot" in entity and entity.pivot != null and "crouching_pivot_position" in entity and entity.crouching_pivot_position != null:
		entity.pivot.direction = false;

func on_exit_action(new_action_name: String) -> void:
	if new_action_name != "crouch idle":
		if "standing_collider" in entity and entity.standing_collider != null:
			entity.standing_collider.disabled = false;

		if "crouching_collider" in entity and entity.crouching_collider != null:
			entity.crouching_collider.disabled = true;

		if "pivot" in entity and entity.pivot != null and "standing_pivot_position" in entity and entity.standing_pivot_position != null:
			entity.pivot.direction = true;

func _process_input_vector(input: InputPackage, context: ContextPackage) -> void:
	if context.states.has("ground"):
		var direction: Vector3 = (entity.transform.basis * Vector3(input.input_direction.x, 0, input.input_direction.y)).normalized();
		entity.velocity.x = direction.x * movement_speed;
		entity.velocity.z = direction.z * movement_speed;
