class_name PlayerCameraFreeAction;
extends Action;

func process_input_vector(input: InputPackage, _context: ContextPackage, _delta: float) -> void:
	if "pivot" in entity:
		entity.rotate_y(-input.pivot_event.x * 0.006);
		entity.pivot.rotate_x(-input.pivot_event.y * 0.006);
		entity.pivot.rotation.x = clamp(entity.pivot.rotation.x, deg_to_rad(-60), deg_to_rad(60));
