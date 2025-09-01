class_name HumanoidMovementLockedBehaviour;
extends Behaviour;

func set_used_actions() -> Array[String]:
	return [
		"locked"
	];

func choose_initial_action(input: InputPackage, context: ContextPackage) -> void:
	switch_to("locked", input, context);
