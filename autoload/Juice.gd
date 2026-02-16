extends Node
class_name JuiceClass
## Juice effects - screen shake, flashes, particles

var _camera: Camera2D = null
var _shake_intensity: float = 0.0
var _shake_decay: float = 5.0

func _ready() -> void:
	Events.player_hit.connect(_on_player_hit)
	Events.enemy_died.connect(_on_enemy_died)

func _process(delta: float) -> void:
	if _shake_intensity > 0:
		_shake_intensity = maxf(_shake_intensity - _shake_decay * delta, 0.0)
		if _camera:
			_camera.offset = Vector2(
				randf_range(-_shake_intensity, _shake_intensity),
				randf_range(-_shake_intensity, _shake_intensity)
			)
		if _shake_intensity <= 0 and _camera:
			_camera.offset = Vector2.ZERO

func set_camera(camera: Camera2D) -> void:
	_camera = camera

# === SCREEN SHAKE ===

func shake(intensity: float, decay: float = 5.0) -> void:
	_shake_intensity = maxf(_shake_intensity, intensity)
	_shake_decay = decay

func shake_small() -> void:
	shake(2.0, 8.0)

func shake_medium() -> void:
	shake(4.0, 6.0)

func shake_large() -> void:
	shake(8.0, 4.0)

# === HIT FLASH ===

func flash_white(node: Node2D, duration: float = 0.05) -> void:
	if not node or not is_instance_valid(node):
		return
	var original_modulate: Color = node.modulate
	node.modulate = Color.WHITE
	await node.get_tree().create_timer(duration).timeout
	if is_instance_valid(node):
		node.modulate = original_modulate

func flash_red(node: Node2D, duration: float = 0.1) -> void:
	if not node or not is_instance_valid(node):
		return
	var original_modulate: Color = node.modulate
	node.modulate = Color.RED
	await node.get_tree().create_timer(duration).timeout
	if is_instance_valid(node):
		node.modulate = original_modulate

# === KNOCKBACK ===

func apply_knockback(target: Node2D, from_position: Vector2, force: float = 50.0) -> void:
	if not target or not is_instance_valid(target):
		return
	var direction: Vector2 = (target.global_position - from_position).normalized()
	if target is CharacterBody2D:
		target.velocity += direction * force

# === DEATH PARTICLES ===

func spawn_death_particles(position: Vector2, color: Color = Color.RED, count: int = 6) -> void:
	var scene_root: Node = get_tree().current_scene
	if not scene_root:
		return
	
	for i in range(count):
		var particle: ColorRect = ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.position = position - Vector2(2, 2)
		particle.color = color
		scene_root.add_child(particle)
		
		# Animate outward
		var angle: float = (TAU / count) * i + randf_range(-0.3, 0.3)
		var velocity: Vector2 = Vector2.from_angle(angle) * randf_range(80, 150)
		var lifetime: float = randf_range(0.2, 0.4)
		
		_animate_particle(particle, velocity, lifetime)

func _animate_particle(particle: ColorRect, velocity: Vector2, lifetime: float) -> void:
	var elapsed: float = 0.0
	while elapsed < lifetime and is_instance_valid(particle):
		var delta: float = get_process_delta_time()
		elapsed += delta
		particle.position += velocity * delta
		velocity *= 0.95  # Drag
		particle.modulate.a = 1.0 - (elapsed / lifetime)
		await get_tree().process_frame
	
	if is_instance_valid(particle):
		particle.queue_free()

# === MUZZLE FLASH ===

func spawn_muzzle_flash(position: Vector2) -> void:
	var scene_root: Node = get_tree().current_scene
	if not scene_root:
		return
	
	var flash: ColorRect = ColorRect.new()
	flash.size = Vector2(8, 8)
	flash.position = position - Vector2(4, 4)
	flash.color = Color(1, 1, 0.8, 0.8)
	scene_root.add_child(flash)
	
	await get_tree().create_timer(0.05).timeout
	if is_instance_valid(flash):
		flash.queue_free()

# === EVENT HANDLERS ===

func _on_player_hit(_damage: int) -> void:
	shake_medium()

func _on_enemy_died(_type: int, position: Vector2) -> void:
	shake_small()
	spawn_death_particles(position, Color.RED, 6)
