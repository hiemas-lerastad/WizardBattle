class_name Player;
extends Entity;

@export var pivot: Node3D;
@export var camera: Camera3D;
@export var voice_transmitter: SpatialTransmitter;

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
