extends CharacterBody2D
class_name Player

enum State { IDLE, MOVING, DEAD }

@export var base_move_speed: float = 120.0
@export var base_fire_rate: float = 4.0
@export var base_damage: float = 2.0
@export var max_health: int = 6

var current_state: State = State.IDLE
var shards_held: int = 0
var health: int = 6
var fire_cooldown: float = 0.0
var move_speed: float
var fire_rate: float
var damage: float

# Track held keys manually since Input.is_key_pressed() isn't working
var keys_held := {}


var victory: bool = false

func _ready() -> void:
	add_to_group("player")
	
	# Restore HP from previous room, or use max if fresh run
	if VolatilitySystem.player_health > 0:
		health = VolatilitySystem.player_health
	else:
		health = max_health
		VolatilitySystem.player_health = health
	
	move_speed = base_move_speed
	fire_rate = base_fire_rate
	damage = base_damage
	Events.volatility_changed.connect(_on_volatility_changed)
	Events.boss_defeated.connect(_on_boss_defeated)

func _on_boss_defeated() -> void:
	victory = true
	current_state = State.IDLE
	velocity = Vector2.ZERO
	keys_held.clear()
	
	# Clear all remaining enemies and projectiles
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	# Deactivate all projectiles
	for proj in get_tree().get_nodes_in_group("projectiles"):
		if is_instance_valid(proj) and proj.has_method("deactivate"):
			proj.deactivate()
	
	print("[Player] VICTORY!")


func _input(event: InputEvent) -> void:
	# Handle restart on death or victory
	if current_state == State.DEAD or victory:
		if event.is_action_pressed("convert"):  # Space key
			_restart_run()
		return
	
	if event is InputEventKey:
		var key_event := event as InputEventKey
		keys_held[key_event.keycode] = key_event.pressed


func _physics_process(delta: float) -> void:
	if current_state == State.DEAD or victory:
		velocity = Vector2.ZERO
		return
	
	# Handle conversion (Space key - hold to convert incrementally)
	if Input.is_action_just_pressed("convert"):
		VolatilitySystem.start_converting()
	elif Input.is_action_just_released("convert"):
		VolatilitySystem.stop_converting()
	
	# Get movement from manually tracked keys
	var move_input := Vector2.ZERO
	if keys_held.get(KEY_D, false):
		move_input.x += 1.0
	if keys_held.get(KEY_A, false):
		move_input.x -= 1.0
	if keys_held.get(KEY_S, false):
		move_input.y += 1.0
	if keys_held.get(KEY_W, false):
		move_input.y -= 1.0
	
	if move_input != Vector2.ZERO:
		move_input = move_input.normalized()
		current_state = State.MOVING
	else:
		current_state = State.IDLE
	
	velocity = move_input * move_speed
	move_and_slide()
	
	# Shooting
	_handle_shooting(delta)


func _handle_shooting(delta: float) -> void:
	fire_cooldown -= delta
	if fire_cooldown > 0:
		return
	
	var shoot_dir := Vector2.ZERO
	if keys_held.get(KEY_UP, false):
		shoot_dir = Vector2.UP
	elif keys_held.get(KEY_DOWN, false):
		shoot_dir = Vector2.DOWN
	elif keys_held.get(KEY_LEFT, false):
		shoot_dir = Vector2.LEFT
	elif keys_held.get(KEY_RIGHT, false):
		shoot_dir = Vector2.RIGHT
	
	if shoot_dir != Vector2.ZERO:
		var spawn_pos := global_position + (shoot_dir * 12)
		# Calculate damage fresh each shot (includes volatility scaling)
		var shot_damage: float = base_damage * VolatilitySystem.player_damage_mult
		ProjectilePool.fire(spawn_pos, shoot_dir, shot_damage, Projectile.Owner.PLAYER)
		fire_cooldown = 1.0 / fire_rate


func _on_volatility_changed(_new_level: float) -> void:
	# Apply volatility multipliers to stats
	move_speed = base_move_speed * VolatilitySystem.player_speed_mult
	fire_rate = base_fire_rate * VolatilitySystem.player_fire_rate_mult
	damage = base_damage * VolatilitySystem.player_damage_mult


func collect_shard(value: int) -> void:
	shards_held += value
	Events.shard_collected.emit(value)


func take_damage(amount: int) -> void:
	if current_state == State.DEAD or victory:
		return
	
	health = maxi(health - amount, 0)  # Clamp to 0, no negative HP
	VolatilitySystem.player_health = health  # Persist across rooms
	Events.player_hit.emit(amount)
	Juice.flash_red(self, 0.1)
	
	print("[Player] Took ", amount, " damage! HP: ", health)
	
	if health <= 0:
		die()


func die() -> void:
	if current_state == State.DEAD:
		return
	
	current_state = State.DEAD
	visible = false
	Events.player_died.emit()
	print("[Player] DIED! Press SPACE to restart...")
	
	# Wait for Space press to restart (handled in _input)

func _restart_run() -> void:
	# Reset volatility
	VolatilitySystem.reset()
	
	# Reload Room 1
	get_tree().change_scene_to_file("res://scenes/rooms/TestRoom.tscn")
