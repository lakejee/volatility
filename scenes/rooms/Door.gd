extends Area2D
class_name Door
## Door that transitions to another room when touched

enum Direction { NORTH, SOUTH, EAST, WEST }

@export var direction: Direction = Direction.NORTH
@export var target_room: String = ""  # Scene path
@export var locked: bool = true

var _visual: ColorRect

func _ready() -> void:
	add_to_group("doors")
	body_entered.connect(_on_body_entered)
	
	# Get visual child
	_visual = get_node_or_null("Visual")
	_update_visual()

func lock() -> void:
	locked = true
	_update_visual()

func unlock() -> void:
	locked = false
	_update_visual()

func _update_visual() -> void:
	if _visual:
		if locked:
			_visual.color = Color(0.5, 0.2, 0.2, 1)  # Dark red = locked
		else:
			_visual.color = Color(0.2, 0.5, 0.2, 1)  # Green = open

func _on_body_entered(body: Node2D) -> void:
	print("[Door] Body entered: ", body.name, " locked=", locked)
	
	if locked:
		print("[Door] Door is locked, ignoring")
		return
	
	if body.is_in_group("player"):
		print("[Door] Player entered! Transitioning to: ", target_room)
		_transition_to_room()
	else:
		print("[Door] Not player, ignoring")

func _transition_to_room() -> void:
	if target_room.is_empty():
		push_warning("Door has no target room set!")
		return
	
	# Emit event for any listeners
	Events.room_entered.emit(target_room.hash())
	
	# Load the next room
	get_tree().change_scene_to_file(target_room)
