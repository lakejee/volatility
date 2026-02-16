extends Node
## Object pool for projectiles. Avoids instantiation hitches.
## Cap at 50 as Architect recommended.

const POOL_SIZE: int = 50
const PROJECTILE_SCENE: String = "res://scenes/projectiles/Projectile.tscn"

var pool: Array[Projectile] = []
var projectile_scene: PackedScene


func _ready() -> void:
	projectile_scene = load(PROJECTILE_SCENE)
	_initialize_pool()


func _initialize_pool() -> void:
	for i in POOL_SIZE:
		var proj: Projectile = projectile_scene.instantiate()
		proj.deactivate()
		add_child(proj)
		pool.append(proj)


func get_projectile() -> Projectile:
	for proj in pool:
		if not proj.active:
			return proj
	
	# Pool exhausted — return null, don't spawn more
	# This enforces the 50 cap
	push_warning("ProjectilePool exhausted!")
	return null


func fire(start_pos: Vector2, direction: Vector2, damage: float, owner: Projectile.Owner) -> void:
	var proj := get_projectile()
	if proj:
		proj.fire(start_pos, direction, damage, owner)
