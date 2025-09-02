class_name HumanoidPrimaryCastAction;
extends Action;

func on_enter_action(_input: InputPackage, _context: ContextPackage) -> void:
	if "set_casting" in entity:
		entity.set_casting(true);

func on_exit_action(_previous_action: String) -> void:
	if "set_casting" in entity:
		entity.set_casting(false);
