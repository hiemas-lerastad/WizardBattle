class_name Entity;
extends CharacterBody3D;

@export var input_gatherer: InputGatherer;
@export var context_gatherer: ContextGatherer;
@export var event_processor: EventProcessor;
@export var animation_player: AnimationPlayer;

func _ready() -> void:
	pass;

func _physics_process(delta: float) -> void:
	var input: InputPackage = input_gatherer.gather_input();
	var context: ContextPackage = context_gatherer.gather_context(input);
	event_processor.update(input, context, delta);
	
	update(delta);

func update(_delta: float) -> void:
	pass;
