extends Node
## Global signal bus — all cross-system communication goes through here.
## Keeps systems decoupled. Nothing imports anything else directly.

# Combat
signal enemy_died(enemy_type: int, position: Vector2)
signal player_hit(damage: int)
signal player_died

# Shards & Volatility
signal shard_collected(value: int)
signal shards_converted(amount: int)
signal volatility_changed(new_level: float)

# Room flow
signal room_cleared
signal room_entered(room_id: int)

# Run state
signal run_started
signal run_ended(victory: bool)
signal boss_defeated
signal shards_banked(amount: int)
