class_name PlayerInputGatherer;
extends InputGatherer;

@export var toggle_crouch: bool = false;
@export var toggle_sprint: bool = false;
@export var toggle_walk: bool = false;

var mouse_event: InputEvent;

var crouching: bool = false;
var sprinting: bool = false;
var walking: bool = false;


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			mouse_event = event;


func gather_input() -> InputPackage:
	var new_input: InputPackage = InputPackage.new();

	# Basic Movement
	new_input.actions.append("idle");

	new_input.input_direction = Input.get_vector("movement_left", "movement_right", "movement_forward", "movement_backward");

	if new_input.input_direction != Vector2.ZERO:
		new_input.actions.append("jog");

	# Crouch
	if toggle_crouch:
		if Input.is_action_just_pressed("movement_crouch"):
			crouching = !crouching;
	elif Input.is_action_pressed("movement_crouch"):
		crouching = true;
	else:
		crouching = false;

	if Input.is_action_just_pressed("movement_jump") and crouching and toggle_crouch:
		crouching = false;
	elif Input.is_action_just_pressed("movement_jump") and not crouching:
		new_input.actions.append("jump");

	if crouching:
		new_input.actions.append("crouch");

	# Sprint
	if toggle_sprint:
		if Input.is_action_just_pressed("movement_sprint"):
			sprinting = !sprinting;
	elif Input.is_action_pressed("movement_sprint"):
		sprinting = true;
	else:
		sprinting = false;

	if sprinting:
		new_input.actions.append("sprint");

	# Walk
	if toggle_walk:
		if Input.is_action_just_pressed("movement_walk"):
			walking = !walking;
	elif Input.is_action_pressed("movement_walk"):
		walking = true;
	else:
		walking = false;

	if walking:
		new_input.actions.append("walk");

	# Mouse Events
	if mouse_event:
		new_input.pivot_event = mouse_event.relative;
		mouse_event = null;

	return new_input;
