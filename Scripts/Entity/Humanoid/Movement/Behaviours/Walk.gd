class_name HumanoidMovementWalkBehaviour;
extends Behaviour;

func set_used_actions() -> Array[String]:
	return [
		"idle",
		"walk",
		"jog",
		"sprint",
		"crouch idle",
		"crouch jog"
	];

func transition_logic(input: InputPackage, _context: ContextPackage) -> String:
	if input.actions.has("sprint"):
		return "sprint";

	if not input.actions.has("walk"):
		return "jog"

	return "okay";

func choose_action(input: InputPackage, context: ContextPackage) -> void:
	if not context.states.has("ground"):
		switch_to("idle", input, context);
		return;

	if input.actions.has("crouch") and input.input_direction != Vector2.ZERO:
		switch_to("crouch jog", input, context);
		return;

	if current_action.action_name == "crouch idle" and context.states.has("stand_blocked") and input.input_direction != Vector2.ZERO:
		switch_to("crouch jog", input, context);
		return;

	if current_action.action_name == "crouch idle" and context.states.has("stand_blocked"):
		return;

	if current_action.action_name == "crouch jog" and context.states.has("stand_blocked"):
		return;

	if input.actions.has("jump"):
		switch_to("jump", input, context);
		return;

	if input.input_direction != Vector2.ZERO:
		switch_to("walk", input, context);
		return;

	if input.actions.has("crouch"):
		switch_to("crouch idle", input, context);
		return;

	switch_to("idle", input, context);
