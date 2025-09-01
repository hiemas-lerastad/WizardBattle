class_name PlayerContextGatherer;
extends ContextGatherer;

@export var ground_check: RayCast3D;


func gather_context(_input: InputPackage) -> ContextPackage:
	var new_context: ContextPackage = ContextPackage.new();

	if ground_check.is_colliding():
		new_context.states.append("ground");

		new_context.collisions["ground"] = {
			"point": ground_check.get_collision_point(),
			"normal": ground_check.get_collision_normal(),
			"collider": ground_check.get_collider()
		};

	return new_context;
