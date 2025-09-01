class_name HumanoidMovementJumpAction;
extends HumanoidBaseMovementAction;

@export var jump_force: float = 2;

func _process_input_vector(_input: InputPackage, context: ContextPackage) -> void:
	if context.states.has("ground"):
		entity.velocity.y += jump_force;
