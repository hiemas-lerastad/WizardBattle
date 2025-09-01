class_name BehaviourManager;
extends Node;

@export var behavior_container: BehaviourContainer;
@export var actions_container: ActionContainer;
@export var current_behaviour: Behaviour;
@export var id: String;

@export var secondary_behaviour_managers: Array[BehaviourManager];

@export var debug_label: Label;

var entity: Entity;
var manager_mapping: Dictionary;
var initalised: bool = false;


func init() -> void:
	behavior_container.entity = entity;
	behavior_container.register_behaviours(self);

	actions_container.entity = entity;
	actions_container.register_actions();

	if secondary_behaviour_managers.size() > 0:
		for secondary_manager in secondary_behaviour_managers:
			manager_mapping[secondary_manager.id] = secondary_manager;
			secondary_manager.entity = entity;
			secondary_manager.init();


func get_behaviour_by_name(behavior_string: String) -> Behaviour:
	return behavior_container.get_behaviour_by_name(behavior_string);


func update(input: InputPackage, context: ContextPackage, delta: float) -> void:
	var behavior_string: String = current_behaviour.check_relevance(input, context);
	
	if not initalised:
		current_behaviour.on_enter_behaviour(input, context);
		initalised = true;

	if debug_label:
		debug_label.text = name + ": " + current_behaviour.behaviour_string + "; Action: " + current_behaviour.current_action.action_name;

	if behavior_string != "okay":
		if behavior_container.has_behaviour(behavior_string):
			var new_behaviour: Behaviour = behavior_container.get_behaviour_by_name(behavior_string);
			switch_to(new_behaviour, input, context);

	if secondary_behaviour_managers.size() > 0:
		for secondary_manager in secondary_behaviour_managers:
			secondary_manager.update(input, context, delta);

	current_behaviour.update(input, context, delta);


func switch_to(next_behaviour: Behaviour, input: InputPackage, context: ContextPackage) -> void:
	if next_behaviour != current_behaviour:
		next_behaviour.current_action = current_behaviour.current_action;
		current_behaviour.on_exit_behaviour();
		current_behaviour = next_behaviour;
		current_behaviour.on_enter_behaviour(input, context);
