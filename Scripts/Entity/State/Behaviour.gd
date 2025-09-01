class_name Behaviour;
extends Node;

@export var secondary_behaviors: Array[SecondaryBehaviour];
@export var behaviour_string: String;

var used_actions: Array[String];

var entity: Entity;
var manager: BehaviourManager;

var actions: ActionContainer;
var current_action: Action;


func check_relevance(input: InputPackage, context: ContextPackage) -> String:
	return transition_logic(input, context);


func transition_logic(_input: InputPackage, _context: ContextPackage) -> String:
	return "okay";


func set_used_actions() -> Array[String]:
	return [];


func on_enter_behaviour(input: InputPackage, context: ContextPackage) -> void:
	if not used_actions:
		used_actions = set_used_actions();
	
	if not current_action or not used_actions.has(current_action.action_name):
		choose_initial_action(input, context);

	for behaviour in secondary_behaviors:
		var secondary_manager: BehaviourManager = manager.manager_mapping[behaviour.manager_id];
		secondary_manager.switch_to(get_node(behaviour.behaviour), input, context);

	_on_enter_behaviour(input, context);


func _on_enter_behaviour(_input: InputPackage, _context: ContextPackage) -> void:
	pass;


func on_exit_behaviour() -> void:
	pass;


func update(input: InputPackage, context: ContextPackage, delta: float) -> void:
	if current_action:
		current_action.update(input, context, delta);

	choose_action(input, context);
	
	
func choose_action(_input: InputPackage, _context: ContextPackage) -> void:
	pass;


func choose_initial_action(input: InputPackage, context: ContextPackage) -> void:
	if not current_action:
		if used_actions.size() > 0:
			current_action = manager.actions_container.get_action_by_name(used_actions[0]);
		else:
			current_action = manager.actions_container.get_first_action();

	choose_action(input, context);
	return;


func switch_to(next_action_name: String, input: InputPackage, context: ContextPackage) -> void:
	var previous_action: Action = current_action;
	if previous_action:
		if previous_action.action_name == next_action_name:
			return;

		current_action.on_exit_action(next_action_name);

	current_action = actions.get_action_by_name(next_action_name);
	current_action.current_action_duration = 0.0;
	current_action.on_enter_action(input, context);
