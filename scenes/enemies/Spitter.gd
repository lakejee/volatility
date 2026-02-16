extends CharacterBody2D
class_name Spitter
## Spitter - Stationary ranged enemy, fires projectile every 2s

@export var health: int = 2
@export var shard_drop: int = 2
@export var fire_rate: float = 2.0  # Seconds between shots
@export var projectile_speed: float = 120.0
@export var projectile_damage: float = 1.0

var target: Node2D = null
var fire_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player")
	
	# Randomize initial timer so they don't all fire at once
	fire_timer = randf_range(0.5, fire_rate)

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	# Count down to next shot
	fire_timer -= delta
	if fire_timer <= 0:
		_fire_at_player()
		fire_timer = fire_rate

func _fire_at_player() -> void:
	if not target:
		return
	
	# Aim directly at player
	var direction: Vector2 = (target.global_position - global_position).normalized()
	
	# Apply volatility scaling to damage
	var scaled_damage: float = projectile_damage * VolatilitySystem.enemy_damage_mult
	
	# Fire projectile
	ProjectilePool.fire(global_position, direction, scaled_damage, Projectile.Owner.ENEMY)
	
	# Visual feedback - flash when shooting
	modulate = Color.YELLOW
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

func take_damage(amount: float, from_position: Vector2 = Vector2.ZERO) -> void:
	health -= int(amount)
	
	Juice.flash_white(self, 0.05)
	if from_position != Vector2.ZERO:
		Juice.apply_knockback(self, from_position, 40.0)  # Less knockback than crawler
	
	if health <= 0:
		die()

func die() -> void:
	Events.enemy_died.emit(1, global_position)  # 1 = SPITTER type
	
	for i in shard_drop:
		_spawn_shard()
	
	queue_free()

const SHARD_SCENE: PackedScene = preload("res://scenes/pickups/Shard.tscn")

func _spawn_shard() -> void:
	var shard: Node2D = SHARD_SCENE.instantiate()
	shard.global_position = global_position
	get_tree().current_scene.add_child(shard)
