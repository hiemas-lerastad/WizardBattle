class_name PlayerCameraFreeBehaviour;
extends Behaviour;

func set_used_actions() -> Array[String]:
	return [
		"free look"
	];

func choose_action(input: InputPackage, context: ContextPackage) -> void:
	switch_to("free look", input, context);
