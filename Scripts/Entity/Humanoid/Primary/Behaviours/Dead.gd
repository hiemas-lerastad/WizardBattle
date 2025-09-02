class_name HumanoidPrimaryDeadBehaviour;
extends Behaviour;

func set_used_actions() -> Array[String]:
	return [
		"dead",
	];

func choose_action(input: InputPackage, context: ContextPackage) -> void:
	switch_to("dead", input, context);
