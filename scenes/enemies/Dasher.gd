extends CharacterBody2D
class_name Dasher
## Dasher - Charges when player is aligned, pauses after

enum State { IDLE, TELEGRAPH, DASHING, RECOVERING }

@export var health: int = 4
@export var shard_drop: int = 3
@export var idle_speed: float = 30.0
@export var dash_speed: float = 350.0
@export var telegraph_time: float = 0.4
@export var dash_duration: float = 0.25
@export var recovery_time: float = 0.8
@export var alignment_threshold: float = 24.0  # How close to cardinal alignment
@export var contact_damage: float = 2.0

var target: Node2D = null
var state: State = State.IDLE
var state_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	match state:
		State.IDLE:
			_idle_behavior(delta)
		State.TELEGRAPH:
			_telegraph_behavior(delta)
		State.DASHING:
			_dash_behavior(delta)
		State.RECOVERING:
			_recovery_behavior(delta)
	
	move_and_slide()

func _idle_behavior(delta: float) -> void:
	# Slowly move toward player
	var to_player: Vector2 = target.global_position - global_position
	velocity = to_player.normalized() * idle_speed * VolatilitySystem.enemy_speed_mult
	
	# Check for cardinal alignment
	var aligned_dir: Vector2 = _check_alignment()
	if aligned_dir != Vector2.ZERO:
		_start_telegraph(aligned_dir)

func _check_alignment() -> Vector2:
	var to_player: Vector2 = target.global_position - global_position
	
	# Check horizontal alignment
	if abs(to_player.y) < alignment_threshold and abs(to_player.x) > 50:
		return Vector2.RIGHT if to_player.x > 0 else Vector2.LEFT
	
	# Check vertical alignment
	if abs(to_player.x) < alignment_threshold and abs(to_player.y) > 50:
		return Vector2.DOWN if to_player.y > 0 else Vector2.UP
	
	return Vector2.ZERO

func _start_telegraph(direction: Vector2) -> void:
	state = State.TELEGRAPH
	state_timer = telegraph_time
	dash_direction = direction
	velocity = Vector2.ZERO
	
	# Visual warning
	modulate = Color.YELLOW

func _telegraph_behavior(delta: float) -> void:
	velocity = Vector2.ZERO
	state_timer -= delta
	
	# Shake/pulse effect
	position.x += randf_range(-1, 1)
	
	if state_timer <= 0:
		_start_dash()

func _start_dash() -> void:
	state = State.DASHING
	state_timer = dash_duration
	modulate = Color.RED
	Juice.shake_small()

func _dash_behavior(delta: float) -> void:
	velocity = dash_direction * dash_speed
	state_timer -= delta
	
	# Check for player collision
	var to_player: Vector2 = target.global_position - global_position
	if to_player.length() < 20:
		_hit_player()
	
	if state_timer <= 0:
		_start_recovery()

func _hit_player() -> void:
	if target.has_method("take_damage"):
		var scaled_damage: int = int(contact_damage * VolatilitySystem.enemy_damage_mult)
		target.take_damage(scaled_damage)

func _start_recovery() -> void:
	state = State.RECOVERING
	state_timer = recovery_time
	velocity = Vector2.ZERO
	modulate = Color(0.5, 0.5, 0.5)  # Grayed out

func _recovery_behavior(delta: float) -> void:
	velocity = Vector2.ZERO
	state_timer -= delta
	
	if state_timer <= 0:
		state = State.IDLE
		modulate = Color.WHITE

func take_damage(amount: float, from_position: Vector2 = Vector2.ZERO) -> void:
	health -= int(amount)
	
	Juice.flash_white(self, 0.05)
	# No knockback during dash
	if state != State.DASHING and from_position != Vector2.ZERO:
		Juice.apply_knockback(self, from_position, 60.0)
	
	if health <= 0:
		die()

func die() -> void:
	Events.enemy_died.emit(2, global_position)  # 2 = DASHER type
	
	for i in shard_drop:
		_spawn_shard()
	
	queue_free()

const SHARD_SCENE: PackedScene = preload("res://scenes/pickups/Shard.tscn")

func _spawn_shard() -> void:
	var shard: Node2D = SHARD_SCENE.instantiate()
	shard.global_position = global_position
	get_tree().current_scene.add_child(shard)
