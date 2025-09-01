class_name HumanoidMovementSprintBehaviour;
extends Behaviour;

func set_used_actions() -> Array[String]:
	return [
		"idle",
		"jog",
		"sprint",
		"crouch idle",
		"crouch jog"
	];

func transition_logic(input: InputPackage, _context: ContextPackage) -> String:
	if input.actions.has("walk") and not input.actions.has("sprint"):
		return "walk"

	if not input.actions.has("sprint"):
		return "jog"

	return "okay";

func choose_action(input: InputPackage, context: ContextPackage) -> void:
	if not context.states.has("ground"):
		switch_to("idle", input, context);
		return;

	if current_action.action_name == "crouch idle" and context.states.has("stand_blocked") and input.input_direction != Vector2.ZERO:
		switch_to("crouch jog", input, context);
		return;

	if current_action.action_name == "crouch idle" and context.states.has("stand_blocked"):
		return;

	if input.actions.has("jump"):
		switch_to("jump", input, context);
		return;

	if input.input_direction != Vector2.ZERO:
		switch_to("sprint", input, context);
		return;

	if input.actions.has("crouch"):
		switch_to("crouch idle", input, context);
		return;

	switch_to("idle", input, context);
