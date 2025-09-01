class_name ActionContainer;
extends Node;

var actions: Dictionary;
var entity: Entity;


func register_actions() -> void:
	for child in get_children():
		if child is Action:
			actions[child.action_name] = child;
			child.entity = entity;


func get_action_by_name(action_name : String) -> Action:
	return actions[action_name];


func get_first_action() -> Action:
	var action_name: String = "idle";

	if get_children().size() > 0 and get_child(0) is Action:
		action_name = get_child(0).action_name;

	return actions[action_name];
