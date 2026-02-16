extends CharacterBody2D
class_name Crawler

@export var move_speed: float = 60.0
@export var health: int = 3
@export var shard_drop: int = 1
@export var contact_damage: int = 1
@export var contact_cooldown: float = 0.5

var target: Node2D = null
var spawned_at_volatility: float = 0.0  # Captured at spawn, immutable
var can_damage: bool = true


func _ready() -> void:
	add_to_group("enemies")
	# Find player
	target = get_tree().get_first_node_in_group("player")
	if not target:
		# Fallback: find by class
		for node in get_tree().get_nodes_in_group(""):
			if node is Player:
				target = node
				break


func _physics_process(_delta: float) -> void:
	if not target:
		return
	
	# Simple chase: move toward player
	var direction := (target.global_position - global_position).normalized()
	velocity = direction * move_speed * VolatilitySystem.enemy_speed_mult
	move_and_slide()
	
	# Contact damage check
	if can_damage:
		var distance: float = global_position.distance_to(target.global_position)
		if distance < 16:  # Contact range
			_deal_contact_damage()

func _deal_contact_damage() -> void:
	if not target or not can_damage:
		return
	
	can_damage = false
	var scaled_damage: int = int(contact_damage * VolatilitySystem.enemy_damage_mult)
	if target.has_method("take_damage"):
		target.take_damage(scaled_damage)
	
	# Cooldown
	await get_tree().create_timer(contact_cooldown).timeout
	can_damage = true


func take_damage(amount: float, from_position: Vector2 = Vector2.ZERO) -> void:
	health -= int(amount)
	
	# Juice: hit flash + knockback
	Juice.flash_white(self, 0.05)
	if from_position != Vector2.ZERO:
		Juice.apply_knockback(self, from_position, 80.0)
	
	if health <= 0:
		die()


func die() -> void:
	# Emit signal for shard spawning
	Events.enemy_died.emit(0, global_position)  # 0 = CRAWLER type
	
	# Spawn shards
	for i in shard_drop:
		_spawn_shard()
	
	queue_free()


const SHARD_SCENE: PackedScene = preload("res://scenes/pickups/Shard.tscn")

func _spawn_shard() -> void:
	var shard: Node2D = SHARD_SCENE.instantiate()
	shard.global_position = global_position
	get_tree().current_scene.add_child(shard)
