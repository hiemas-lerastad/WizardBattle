class_name Level;
extends Node

@export var player_scene: PackedScene;
@export var player_spawner: MultiplayerSpawner;

var player_index = 0;


func _ready() -> void:
	player_spawner.spawn_function = _multiplayer_spawner_player;


func spawn_player(authority_pid: int) -> void:
	player_spawner.spawn(authority_pid);


func _multiplayer_spawner_player(authority_pid: int) -> Player:
	var player = player_scene.instantiate();
	player.authority_id = str(authority_pid);
	player.index = player_index;
	player.position.x += player_index;
	player_index += 1;
	return player;
