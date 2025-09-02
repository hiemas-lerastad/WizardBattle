class_name HumanoidPrimaryIdleBehaviour;
extends Behaviour;

func set_used_actions() -> Array[String]:
	return [
		"idle",
		"cast"
	];

func transition_logic(_input: InputPackage, context: ContextPackage) -> String:
	if "stats" in context and context.stats.health <= 0.0:
		return "dead";

	return "okay";

func choose_action(input: InputPackage, context: ContextPackage) -> void:
	if input.actions.has("cast"):
		switch_to("cast", input, context);
	else:
		switch_to("idle", input, context);
