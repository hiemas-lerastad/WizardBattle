class_name InputGatherer;
extends Node;

@export var entity: Entity;

func gather_input() -> InputPackage:
	var new_input: InputPackage = InputPackage.new();
	return new_input;
