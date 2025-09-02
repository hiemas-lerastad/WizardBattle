class_name Player;
extends Entity;

@export var pivot: Node3D;
@export var camera: Camera3D;
@export var voice_transmitter: SpatialTransmitter;
@export var voip_manager: VOIPManager;
@export var first_person_visuals: Node3D;
@export var third_person_visuals: Node3D;

@export_group("Projectiles")
@export_file("*.tscn") var fireball_scene_path: String;
@export_file("*.tscn") var iceshard_scene_path: String;
@export_file("*.tscn") var magicmissile_scene_path: String;

var authority_id: int;
var index: int;

var last_transmitter_amount: int = 0;

signal spawn_projectile;


func _enter_tree() -> void:
	set_multiplayer_authority(authority_id);


func update(_delta: float) -> void:
	if is_multiplayer_authority() and get_tree().get_node_count_in_group("Transmitter") != last_transmitter_amount:
		var transmitters: Array[Node] = get_tree().get_nodes_in_group("Transmitter");
		last_transmitter_amount = transmitters.size();

		for sig in transmitters:
			sig.target = self;


func _ready() -> void:
	if is_multiplayer_authority():
		first_person_visuals.visible = true;
		third_person_visuals.visible = false;

		for sig in get_tree().get_nodes_in_group("Transmitter"):
			sig.target = self;

		camera.set_multiplayer_authority(authority_id);
		camera.current = true;

		voice_transmitter.transmitting = false;

		if voip_manager:
			voip_manager.connect("voice_command", handle_voice_command);
	else:
		first_person_visuals.visible = false;
		third_person_visuals.visible = true;


func set_casting(value: bool) -> void:
	if voip_manager and voip_manager.voice_command_recogniser:
		voip_manager.voice_command_recogniser.enabled = value;


func update_health(amount: float) -> void:
	context_gatherer.stats.health += amount;


func handle_voice_command(command: String) -> void:
	handle_client_voice_command.rpc(command);

	#rework
	if command == "fireball":
		spawn_projectile.emit(fireball_scene_path, -pivot.global_basis.z, index);
	if command == "iceshard":
		spawn_projectile.emit(iceshard_scene_path, -pivot.global_basis.z, index);
	if command == "magicmissile":
		spawn_projectile.emit(magicmissile_scene_path, -pivot.global_basis.z, index);

@rpc("any_peer", "call_remote", "reliable")
func handle_client_voice_command(_command: String) -> void:
	pass;
