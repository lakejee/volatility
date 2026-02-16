extends CanvasLayer
## Simple HUD for rooms

@onready var volatility_label: Label = $VolatilityLabel
@onready var shards_label: Label = $ShardsLabel
@onready var health_label: Label = $HealthLabel

var _player: Node2D = null
var _game_over_panel: ColorRect = null
var _game_over_label: Label = null

func _ready() -> void:
	Events.volatility_changed.connect(_on_volatility_changed)
	Events.shard_collected.connect(_on_shard_collected)
	Events.room_cleared.connect(_on_room_cleared)
	Events.player_hit.connect(_on_player_hit)
	Events.player_died.connect(_on_player_died)
	Events.boss_defeated.connect(_on_boss_defeated)
	call_deferred("_find_player")
	_create_game_over_panel()
	_update_display()

func _create_game_over_panel() -> void:
	# Semi-transparent background
	_game_over_panel = ColorRect.new()
	_game_over_panel.color = Color(0, 0, 0, 0.7)
	_game_over_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_over_panel.visible = false
	add_child(_game_over_panel)
	
	# Centered label
	_game_over_label = Label.new()
	_game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_game_over_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_game_over_label.add_theme_font_size_override("font_size", 24)
	_game_over_panel.add_child(_game_over_label)

func _find_player() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_player = players[0]
		_update_health()

func _on_volatility_changed(_new_level: float) -> void:
	_update_display()

func _on_shard_collected(_value: int) -> void:
	_update_display()

func _on_room_cleared() -> void:
	# Flash volatility label green briefly
	if volatility_label:
		var orig_color: Color = volatility_label.modulate
		volatility_label.modulate = Color.GREEN
		await get_tree().create_timer(0.3).timeout
		volatility_label.modulate = orig_color

func _on_player_hit(_damage: int) -> void:
	_update_health()

func _on_player_died() -> void:
	_show_end_screen(false)

func _on_boss_defeated() -> void:
	_show_end_screen(true)

func _show_end_screen(victory: bool) -> void:
	if _game_over_panel and _game_over_label:
		var peak_vol: float = VolatilitySystem.current_volatility
		var shards: int = VolatilitySystem.shards_held
		
		if victory:
			_game_over_label.modulate = Color.GREEN
			_game_over_label.text = """VICTORY!

The Accumulator has been defeated!

Final Volatility: %d%%
Shards Banked: %d

Press SPACE to play again""" % [int(peak_vol * 100), shards]
		else:
			# Get room number from parent
			var room_id: int = 0
			var parent: Node = get_parent()
			if parent and parent.get("room_id") != null:
				room_id = parent.get("room_id")
			
			_game_over_label.modulate = Color.RED
			_game_over_label.text = """GAME OVER

Room Reached: %d / 4
Peak Volatility: %d%%

Press SPACE to restart""" % [room_id, int(peak_vol * 100)]
		
		_game_over_panel.visible = true

func _update_health() -> void:
	if not health_label or not _player:
		return
	
	var hp: int = _player.get("health") if _player.get("health") != null else 0
	health_label.text = "HP: %d" % hp
	
	if hp <= 2:
		health_label.modulate = Color.RED
	elif hp <= 4:
		health_label.modulate = Color.YELLOW
	else:
		health_label.modulate = Color.WHITE

func _update_display() -> void:
	if not volatility_label or not shards_label:
		return
	
	var vol_percent: int = int(VolatilitySystem.current_volatility * 100)
	volatility_label.text = "Volatility: %d%%" % vol_percent
	
	# Show decay status
	if VolatilitySystem.decay_pause_remaining > 0:
		volatility_label.text += " (PAUSED)"
	elif VolatilitySystem.is_decaying:
		volatility_label.text += " (decaying)"
	
	# Color based on level
	if VolatilitySystem.current_volatility < 0.5:
		volatility_label.modulate = Color.WHITE
	elif VolatilitySystem.current_volatility < 1.0:
		volatility_label.modulate = Color.YELLOW
	else:
		volatility_label.modulate = Color.RED
	
	shards_label.text = "Shards: %d" % VolatilitySystem.shards_held
