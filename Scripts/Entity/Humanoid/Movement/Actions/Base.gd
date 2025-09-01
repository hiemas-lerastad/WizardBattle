class_name HumanoidBaseMovementAction;
extends Action;

@export var movement_speed: float = 1.5;
@export var animation_lerp_duration: float = 0.2;
@export var rotation_lerp_duration: float = 0.2;

var time: float = 0.0;
var animation_lerp_time: float;
var rotation_lerp_time: float;

func on_enter_action(input: InputPackage, context: ContextPackage) -> void:
	time = 0.0;
	animation_lerp_time = 1.0 / animation_lerp_duration;
	rotation_lerp_time = 1.0 / rotation_lerp_duration;

	_on_enter_action(input, context);

func _on_enter_action(_input: InputPackage, _context: ContextPackage) -> void:
	pass;

func process_input_vector(input: InputPackage, context: ContextPackage, delta: float) -> void:
	time += delta;

	if not entity.rotation.x == 0.0 or not entity.rotation.z == 0.0:
		var new_rotation: Vector3 = entity.rotation;
		new_rotation.x = 0.0;
		new_rotation.z = 0.0;
		entity.rotation = entity.rotation.lerp(new_rotation, clamp(time * rotation_lerp_time, 0.0, 1.0));

	if not entity.is_on_floor():
		entity.velocity += entity.get_gravity() * delta;

	if "animation_tree" in entity and entity.animation_tree != null:
		entity.animation_tree.set("parameters/Movement Climb Blend/blend_amount", clamp(1.0 - time * animation_lerp_time, 0.0, entity.animation_tree.get("parameters/Movement Climb Blend/blend_amount")));

	_process_input_vector(input, context);

func _process_input_vector(_input: InputPackage, _context: ContextPackage) -> void:
	pass;
