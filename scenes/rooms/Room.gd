extends Node2D
class_name Room
## Base room - tracks enemies, locks/unlocks doors

@export var room_id: int = 0

var enemies_remaining: int = 0
var cleared: bool = false

func _ready() -> void:
	# Count enemies
	call_deferred("_setup_room")

func _setup_room() -> void:
	# Resume decay when entering new room
	VolatilitySystem.resume_decay()
	
	# Count enemies
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
	enemies_remaining = enemies.size()
	
	# Listen to Events bus for enemy deaths
	Events.enemy_died.connect(_on_enemy_died)
	
	# Lock all doors if there are enemies
	if enemies_remaining > 0:
		_lock_all_doors()
	else:
		_unlock_all_doors()
	
	# Set camera reference for Juice
	var camera: Camera2D = get_node_or_null("Camera2D")
	if camera:
		Juice.set_camera(camera)
	
	Events.room_entered.emit(room_id)
	print("[Room] Started with ", enemies_remaining, " enemies")

func _on_enemy_died(_enemy_type: int, _position: Vector2) -> void:
	enemies_remaining -= 1
	print("[Room] Enemy died. Remaining: ", enemies_remaining)
	
	if enemies_remaining <= 0:
		_clear_room()

func _clear_room() -> void:
	if cleared:
		return
	
	cleared = true
	_unlock_all_doors()
	
	# Pause volatility decay until next room
	VolatilitySystem.pause_decay_until_next_room()
	
	Events.room_cleared.emit()
	print("[Room] CLEARED!")

func _lock_all_doors() -> void:
	var doors: Array[Node] = get_tree().get_nodes_in_group("doors")
	for door in doors:
		if door.has_method("lock"):
			door.lock()

func _unlock_all_doors() -> void:
	var doors: Array[Node] = get_tree().get_nodes_in_group("doors")
	for door in doors:
		if door.has_method("unlock"):
			door.unlock()
