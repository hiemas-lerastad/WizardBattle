class_name Player;
extends Entity;

@export var pivot: Node3D;
@export var camera: Camera3D;
@export var voice_transmitter: SpatialTransmitter;
@export var voip_manager: VOIPManager;

var authority_id: int;
var index: int;

var last_transmitter_amount: int = 0;

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
		for sig in get_tree().get_nodes_in_group("Transmitter"):
			sig.target = self;

		camera.set_multiplayer_authority(authority_id);
		camera.current = true;

		voice_transmitter.transmitting = false;

	if voip_manager:
		voip_manager.connect("voice_command", handle_voice_command);

func handle_voice_command(command: String) -> void:
	handle_client_voice_command.rpc(command);

@rpc("any_peer", "call_remote", "reliable")
func handle_client_voice_command(command: String) -> void:
	print(multiplayer.get_unique_id())
	print(str(authority_id) + " - voice command triggered: " + command)
