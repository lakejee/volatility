extends Node
class_name VolatilitySystemClass
## VolatilitySystem - Core risk/reward mechanic
## Volatility boosts player stats AND enemy difficulty
## Emits through Events.gd for decoupled architecture

signal decay_paused(duration: float)
signal decay_resumed()

# === CONFIGURATION (V1.1 spec) ===
const SHARD_TO_VOLATILITY: float = 0.04  # 4% per shard (V1.1)
const CONVERSION_RATE: float = 0.2  # 1 shard every 0.2s while holding
const DECAY_RATE: float = 0.1  # Per second (10s to drain from 1.0)
const KILL_PAUSE_DURATION: float = 1.5  # Seconds per kill, stacking

# Player scaling (V1.2 - rebalanced)
const PLAYER_DAMAGE_SCALE: float = 0.4   # +40% at vol=1.0
const PLAYER_FIRE_RATE_SCALE: float = 0.25  # +25%
const PLAYER_SPEED_SCALE: float = 0.2   # +20%

# Enemy scaling (V1.1 - reduced)
const ENEMY_DAMAGE_SCALE: float = 0.2    # +20%
const ENEMY_SPEED_SCALE: float = 0.1     # +10%
# Enemy HP: NO SCALING

# Boss scaling (V1.1)
const BOSS_HP_SCALE: float = 0.2    # +20% HP per 1.0 vol
const BOSS_DAMAGE_SCALE: float = 0.1  # Capped at +10%

# === STATE ===
var current_volatility: float = 0.0
var shards_held: int = 0
var decay_pause_remaining: float = 0.0
var is_decaying: bool = false
var is_converting: bool = false  # V1.1: incremental conversion
var conversion_timer: float = 0.0
var room_clear_pause: bool = false  # Pause decay after room clear

# Player HP persistence (survives room transitions, resets on death/restart)
var player_health: int = -1  # -1 means "use max_health" (fresh run)

# === STAT MULTIPLIERS (derived from volatility) ===
var player_damage_mult: float = 1.0
var player_speed_mult: float = 1.0
var player_fire_rate_mult: float = 1.0
var enemy_damage_mult: float = 1.0
var enemy_speed_mult: float = 1.0
var enemy_health_mult: float = 1.0
var boss_hp_mult: float = 1.0
var boss_damage_mult: float = 1.0

func _ready() -> void:
	# Connect to Events bus
	Events.enemy_died.connect(_on_enemy_died)
	print("[VolatilitySystem] Initialized. Decay rate: ", DECAY_RATE, "/s")

func _on_enemy_died(_enemy_type: int, _position: Vector2) -> void:
	on_enemy_killed()

func _process(delta: float) -> void:
	# Handle incremental conversion (V1.1)
	if is_converting and shards_held > 0:
		conversion_timer -= delta
		if conversion_timer <= 0:
			_convert_single_shard()
			conversion_timer = CONVERSION_RATE
	
	if current_volatility <= 0:
		return
	
	# Don't decay if room is cleared (waiting for next room)
	if room_clear_pause:
		return
	
	# Handle decay pause
	if decay_pause_remaining > 0:
		decay_pause_remaining -= delta
		if decay_pause_remaining <= 0:
			decay_pause_remaining = 0
			is_decaying = true
			decay_resumed.emit()
		return
	
	# Apply decay
	if is_decaying:
		var decay_amount: float = DECAY_RATE * delta
		_set_volatility(current_volatility - decay_amount)

func reset() -> void:
	current_volatility = 0.0
	shards_held = 0
	decay_pause_remaining = 0.0
	is_decaying = false
	player_health = -1  # Reset to "use max" for fresh run
	_update_multipliers()
	Events.volatility_changed.emit(current_volatility)

# === SHARD COLLECTION ===

func collect_shard(amount: int = 1) -> void:
	shards_held += amount
	Events.shard_collected.emit(amount)
	print("[Volatility] Collected ", amount, " shards (total: ", shards_held, ")")

# === CONVERSION (V1.1: Incremental - hold to convert) ===

func start_converting() -> void:
	## Called when player starts holding convert button
	if shards_held > 0 and not is_converting:
		is_converting = true
		conversion_timer = 0.0  # Convert first shard immediately
		print("[Volatility] Starting conversion...")

func stop_converting() -> void:
	## Called when player releases convert button
	is_converting = false
	conversion_timer = 0.0

func _convert_single_shard() -> void:
	## Convert one shard to volatility
	if shards_held <= 0:
		is_converting = false
		return
	
	shards_held -= 1
	var volatility_gained: float = SHARD_TO_VOLATILITY
	_set_volatility(current_volatility + volatility_gained)
	
	Events.shards_converted.emit(1)
	print("[Volatility] Converted 1 shard → +", volatility_gained, " (total: ", current_volatility, ")")
	
	if shards_held <= 0:
		is_converting = false

# === KILL PAUSE ===

func on_enemy_killed() -> void:
	## Called when player kills an enemy - pauses decay (stacking)
	decay_pause_remaining += KILL_PAUSE_DURATION
	
	if is_decaying:
		is_decaying = false
		decay_paused.emit(decay_pause_remaining)
	
	print("[Volatility] Kill! Decay paused for ", decay_pause_remaining, "s")

func pause_decay_until_next_room() -> void:
	## Called when room is cleared - pause decay until entering next room
	room_clear_pause = true
	print("[Volatility] Decay paused (room cleared)")

func resume_decay() -> void:
	## Called when entering a new room
	room_clear_pause = false
	print("[Volatility] Decay resumed (new room)")

# === INTERNAL ===

func _set_volatility(value: float) -> void:
	var old_value: float = current_volatility
	current_volatility = maxf(value, 0.0)  # Floor at 0, NO CAP (uncapped per spec)
	
	if current_volatility != old_value:
		_update_multipliers()
		Events.volatility_changed.emit(current_volatility)
		
		# Start decaying if we just gained volatility
		if current_volatility > 0 and old_value == 0:
			is_decaying = true

func _update_multipliers() -> void:
	## V1.1: Player outpaces enemies, boss has separate scaling
	var v: float = current_volatility
	
	# Player scales MORE than enemies (glass cannon)
	player_damage_mult = 1.0 + v * PLAYER_DAMAGE_SCALE      # +40% per 1.0
	player_fire_rate_mult = 1.0 + v * PLAYER_FIRE_RATE_SCALE  # +25% per 1.0
	player_speed_mult = 1.0 + v * PLAYER_SPEED_SCALE        # +20% per 1.0
	
	# Enemies scale less (V1.1 reduced)
	enemy_damage_mult = 1.0 + v * ENEMY_DAMAGE_SCALE    # +20% per 1.0
	enemy_speed_mult = 1.0 + v * ENEMY_SPEED_SCALE      # +10% per 1.0
	enemy_health_mult = 1.0  # NO SCALING
	
	# Boss has special scaling (V1.1)
	boss_hp_mult = 1.0 + v * BOSS_HP_SCALE        # +20% HP per 1.0 vol
	boss_damage_mult = 1.0 + v * BOSS_DAMAGE_SCALE  # Capped at +10%

# === DEBUG ===

func DEBUG_SET_VOLATILITY(value: float) -> void:
	_set_volatility(value)
	print("[Volatility DEBUG] Set to ", current_volatility)

func DEBUG_ADD_SHARDS(amount: int) -> void:
	collect_shard(amount)

func DEBUG_GET_STATE() -> Dictionary:
	return {
		"volatility": current_volatility,
		"shards": shards_held,
		"decay_pause": decay_pause_remaining,
		"is_decaying": is_decaying,
		"player_damage_mult": player_damage_mult,
		"enemy_damage_mult": enemy_damage_mult
	}

func get_debug_string() -> String:
	## One-line debug overlay (Architect's spec)
	var decay_status: String = "PAUSED (%.1fs)" % decay_pause_remaining if decay_pause_remaining > 0 else "ACTIVE"
	return "[V] %.2f | Decay: %s | Shards: %d | DMG: %.2fx | SPD: %.2fx | FIRE: %.2fx" % [
		current_volatility,
		decay_status,
		shards_held,
		player_damage_mult,
		player_speed_mult,
		player_fire_rate_mult
	]
