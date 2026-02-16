extends Area2D
class_name Shard
## Collectible shard that drifts toward player

@export var value: int = 1
@export var magnet_range: float = 50.0
@export var magnet_speed: float = 200.0
@export var drop_speed: float = 100.0

var _velocity: Vector2 = Vector2.ZERO
var _player: Node2D = null
var _collected: bool = false

func _ready() -> void:
	add_to_group("shards")
	
	# Random initial drop velocity
	var angle: float = randf_range(-PI * 0.75, -PI * 0.25)
	_velocity = Vector2.from_angle(angle) * drop_speed
	
	# Find player
	call_deferred("_find_player")
	
	# Connect collision
	body_entered.connect(_on_body_entered)

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]

func _physics_process(delta: float) -> void:
	if _collected:
		return
	
	# Apply gravity/drag to drop velocity
	_velocity *= 0.9
	
	# Magnet toward player
	if _player and is_instance_valid(_player):
		var dist: float = global_position.distance_to(_player.global_position)
		if dist < magnet_range:
			var dir: Vector2 = global_position.direction_to(_player.global_position)
			var magnet_strength: float = 1.0 - (dist / magnet_range)
			_velocity += dir * magnet_speed * magnet_strength * delta * 10
	
	position += _velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	
	if body.is_in_group("player"):
		_collect()

func _collect() -> void:
	_collected = true
	
	# Notify volatility system
	VolatilitySystem.collect_shard(value)
	
	# Pop effect
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(queue_free)
