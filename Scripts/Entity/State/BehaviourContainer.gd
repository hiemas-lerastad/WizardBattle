class_name BehaviourContainer;
extends Node;

var behaviours: Dictionary;
var entity: Entity;


func register_behaviours(manager: BehaviourManager) -> void:
	for child in get_children():
		if child is Behaviour:
			behaviours[child.behaviour_string] = child;
			child.entity = entity;
			child.manager = manager;
			child.actions = manager.actions_container;


func get_behaviour_by_name(behaviour_name : String) -> Behaviour:
	return behaviours[behaviour_name];


func has_behaviour(behaviour_name : String) -> bool:
	return behaviour_name in behaviours;
