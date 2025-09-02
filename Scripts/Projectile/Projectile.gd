class_name Projectile;
extends Node3D;

@export var direction: Vector3;
@export var speed: float = 1.0;
@export var excluded_bodies: Array[PhysicsBody3D];
@export var damage: float = 10.0;

func _ready() -> void:
	var new_basis = Basis()
	new_basis.z = -direction
	new_basis.x = Vector3.UP.cross(new_basis.z).normalized()
	new_basis.y = new_basis.z.cross(new_basis.x).normalized()

	basis = new_basis;

func _physics_process(_delta: float) -> void:
	position += direction * speed;


func _on_body_collision(body: Node3D) -> void:
	if not excluded_bodies.has(body):
		if body is Entity and "update_health" in body:
			body.update_health(-damage);

		self.queue_free();
