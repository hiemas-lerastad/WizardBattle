class_name EventProcessor;
extends Node;

@export var entity: Entity;
@export var primary_behaviour_manager: BehaviourManager;


func _ready() -> void:
	primary_behaviour_manager.entity = entity;
	primary_behaviour_manager.init();


func update(input: InputPackage, context: ContextPackage, delta: float) -> void:
	primary_behaviour_manager.update(input, context, delta);
