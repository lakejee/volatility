extends Area2D
class_name Projectile

enum Owner { PLAYER, ENEMY }

@export var speed: float = 300.0
@export var damage: float = 1.0
@export var owner_type: Owner = Owner.PLAYER

var direction: Vector2 = Vector2.RIGHT
var active: bool = false


func _physics_process(delta: float) -> void:
	if not active:
		return
	
	global_position += direction * speed * delta


func fire(start_pos: Vector2, dir: Vector2, dmg: float, owner: Owner) -> void:
	global_position = start_pos
	direction = dir.normalized()
	damage = dmg
	owner_type = owner
	active = true
	visible = true
	monitoring = true
	
	# Add to group for cleanup
	if not is_in_group("projectiles"):
		add_to_group("projectiles")
	
	# Set collision based on owner
	if owner == Owner.PLAYER:
		collision_mask = 2  # Hit enemies (layer 2)
	else:
		collision_mask = 1  # Hit player (layer 1)
	
	# Rotate to face direction
	rotation = direction.angle()


func deactivate() -> void:
	active = false
	visible = false
	monitoring = false
	global_position = Vector2(-1000, -1000)  # Move offscreen


func _on_body_entered(body: Node2D) -> void:
	if not active:
		return
	
	if owner_type == Owner.PLAYER and body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)
		# Muzzle flash at impact
		Juice.spawn_muzzle_flash(global_position)
		deactivate()
	elif owner_type == Owner.ENEMY and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(int(damage))
		deactivate()


func _on_screen_exited() -> void:
	deactivate()
