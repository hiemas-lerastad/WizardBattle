class_name HumanoidMovementCrouchIdleAction;
extends HumanoidBaseMovementAction;

@export var air_resistance: float = 0.01;

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

func _process_input_vector(_input: InputPackage, context: ContextPackage) -> void:
	if context.states.has("ground"):
		entity.velocity.x = move_toward(entity.velocity.x, 0, movement_speed);
		entity.velocity.z = move_toward(entity.velocity.z, 0, movement_speed);
	else:
		entity.velocity.x = move_toward(entity.velocity.x, 0, air_resistance);
		entity.velocity.z = move_toward(entity.velocity.z, 0, air_resistance);
