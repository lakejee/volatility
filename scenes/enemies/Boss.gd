extends CharacterBody2D
class_name Boss
## The Accumulator - Final boss

enum Phase { ONE, TWO, THREE }

@export var base_health: int = 60
@export var shard_drop: int = 10
@export var phase1_fire_rate: float = 2.0
@export var phase2_fire_rate: float = 2.0
@export var phase3_fire_rate: float = 1.0
@export var spawn_rate: float = 5.0
@export var projectile_damage: float = 1.0
@export var move_speed: float = 40.0
@export var phase3_chase_speed: float = 25.0

var health: int = 60
var max_health: int = 60
var target: Node2D = null
var current_phase: Phase = Phase.ONE
var fire_timer: float = 0.0
var spawn_timer: float = 0.0

const CRAWLER_SCENE: PackedScene = preload("res://scenes/enemies/Crawler.tscn")

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	
	# Apply volatility scaling to HP
	max_health = int(base_health * VolatilitySystem.boss_hp_mult)
	health = max_health
	
	target = get_tree().get_first_node_in_group("player")
	
	print("[Boss] The Accumulator awakens! HP: ", health)

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	# Movement depends on phase
	if current_phase == Phase.THREE:
		# Phase 3: Slowly chase player
		var to_player: Vector2 = (target.global_position - global_position).normalized()
		velocity = to_player * phase3_chase_speed
	else:
		# Phases 1-2: Move toward center
		var center: Vector2 = Vector2(480, 200)
		var to_center: Vector2 = center - global_position
		if to_center.length() > 20:
			velocity = to_center.normalized() * move_speed
		else:
			velocity = Vector2.ZERO
	move_and_slide()
	
	# Update phase
	_update_phase()
	
	# Phase behaviors
	_handle_shooting(delta)
	if current_phase == Phase.TWO or current_phase == Phase.THREE:
		_handle_spawning(delta)

func _update_phase() -> void:
	var health_percent: float = float(health) / float(max_health)
	
	if health_percent > 0.66:
		if current_phase != Phase.ONE:
			current_phase = Phase.ONE
			print("[Boss] Phase 1!")
	elif health_percent > 0.33:
		if current_phase != Phase.TWO:
			current_phase = Phase.TWO
			Juice.shake_large()
			print("[Boss] Phase 2 - Spawning minions!")
	else:
		if current_phase != Phase.THREE:
			current_phase = Phase.THREE
			Juice.shake_large()
			print("[Boss] Phase 3 - RAGE MODE!")

func _get_fire_rate() -> float:
	match current_phase:
		Phase.ONE:
			return phase1_fire_rate
		Phase.TWO:
			return phase2_fire_rate
		Phase.THREE:
			return phase3_fire_rate
	return phase1_fire_rate

func _handle_shooting(delta: float) -> void:
	fire_timer -= delta
	if fire_timer <= 0:
		_fire_spread()
		fire_timer = _get_fire_rate()

func _fire_spread() -> void:
	if not target:
		return
	
	var to_player: Vector2 = (target.global_position - global_position).normalized()
	var scaled_damage: float = projectile_damage * VolatilitySystem.boss_damage_mult
	
	# Phase 3: 5-projectile spread, Phases 1-2: 3-projectile spread
	var angles: Array[float]
	if current_phase == Phase.THREE:
		angles = [-0.5, -0.25, 0.0, 0.25, 0.5]  # Wider 5-shot spread
	else:
		angles = [-0.3, 0.0, 0.3]  # Standard 3-shot spread
	
	for angle in angles:
		var dir: Vector2 = to_player.rotated(angle)
		ProjectilePool.fire(global_position, dir, scaled_damage, Projectile.Owner.ENEMY)
	
	# Visual feedback
	modulate = Color.YELLOW
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

func _handle_spawning(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0:
		_spawn_crawlers()
		spawn_timer = spawn_rate

func _spawn_crawlers() -> void:
	for i in range(2):
		var crawler: Node2D = CRAWLER_SCENE.instantiate()
		var offset: Vector2 = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		crawler.global_position = global_position + offset
		get_tree().current_scene.add_child(crawler)
	
	print("[Boss] Spawned minions!")

func take_damage(amount: float, from_position: Vector2 = Vector2.ZERO) -> void:
	health -= int(amount)
	
	Juice.flash_white(self, 0.1)
	Juice.shake_small()
	
	print("[Boss] HP: ", health, "/", max_health)
	
	if health <= 0:
		die()

func die() -> void:
	print("[Boss] DEFEATED!")
	
	# Big shake
	Juice.shake_large()
	
	# Drop lots of shards
	for i in range(shard_drop):
		_spawn_shard()
	
	# Signal victory
	Events.boss_defeated.emit()
	Events.enemy_died.emit(99, global_position)  # 99 = boss
	
	queue_free()

const SHARD_SCENE: PackedScene = preload("res://scenes/pickups/Shard.tscn")

func _spawn_shard() -> void:
	var shard: Node2D = SHARD_SCENE.instantiate()
	shard.global_position = global_position + Vector2(randf_range(-30, 30), randf_range(-30, 30))
	get_tree().current_scene.add_child(shard)
