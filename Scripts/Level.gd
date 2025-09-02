class_name Level;
extends Node

@export var player_scene: PackedScene;
@export var fireball_scene: PackedScene;
@export var player_spawner: MultiplayerSpawner;
@export var projectile_spawner: MultiplayerSpawner;

var player_index: int = 0;
var players: Array[Player];

func _ready() -> void:
	player_spawner.spawn_function = _multiplayer_spawner_player;
	projectile_spawner.spawn_function = _multiplayer_spawner_projectile;

func spawn_player(authority_pid: int) -> void:
	player_spawner.spawn(authority_pid);

func spawn_projectile(scene_path: String, direction: Vector3, source: int) -> void:
	projectile_spawner.spawn({"scene_path": scene_path, "direction": direction, "source": source});

func _multiplayer_spawner_projectile(data: Dictionary) -> Projectile:
	var projectile: Projectile = load(data.scene_path).instantiate();
	projectile.direction = data.direction;
	projectile.excluded_bodies.append(players[data.source]);
	projectile.position = players[data.source].position;
	return projectile;

func _multiplayer_spawner_player(authority_pid: int) -> Player:
	var player: Player = player_scene.instantiate();
	player.authority_id = authority_pid;
	player.index = player_index;
	player.position.x += player_index;
	player_index += 1;
	player.connect("spawn_projectile", spawn_projectile);
	players.append(player);
	return player;
