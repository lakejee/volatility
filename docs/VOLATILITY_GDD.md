# ⚡ VOLATILITY — V1.2 Game Design Spec

*Last Updated: 2026-02-15 | Status: Phase 2 Complete*

---

## 🎮 ONE-LINER

**Kill enemies, collect shards, burn them for power — but power makes everything harder.**

---

## 🔄 CORE LOOP

```
ENTER ROOM → DOORS LOCK → KILL ENEMIES → COLLECT SHARDS
                                              ↓
                         HOLD SPACE → CONVERT TO VOLATILITY
                                              ↓
            VOLATILITY ↑ → PLAYER STRONGER + ENEMIES HARDER
                                              ↓
                    ROOM CLEARED → DOORS UNLOCK → NEXT ROOM
                                              ↓
                         BEAT BOSS → VICTORY → BANK SHARDS
```

**The tension:** Volatility is temporary power that decays over time. Stay aggressive to maintain it, or play safe and lose your edge.

---

## 🎯 WIN / LOSE CONDITIONS

| Condition | Trigger | Result |
|-----------|---------|--------|
| **WIN** | Defeat boss | Victory screen, bank shards, run complete |
| **LOSE** | Player HP reaches 0 | Game Over screen, shards lost, restart |

---

## 🕹️ CONTROLS

| Input | Action |
|-------|--------|
| WASD | Move (8-direction) |
| Arrow Keys | Shoot (4-direction projectile) |
| Space (hold) | Convert shards → Volatility (incremental) |

---

## ⚡ VOLATILITY SYSTEM (V1.2)

### Conversion
- **Hold Space** to convert shards incrementally (1 shard per 0.2s)
- Each shard = **4% volatility** (25 shards = 100%)
- **Uncapped** — can exceed 100%

### Decay
- Base decay: **10%/second** (0.1/sec)
- Each kill **pauses decay for 1.5 seconds** (stacking)
- **Decay pauses when room is cleared** (resumes on entering next room)

### Player Scaling (V1.2)

| Stat | @ 100% Volatility |
|------|-------------------|
| Damage | **+40%** |
| Fire Rate | **+25%** |
| Move Speed | **+20%** |

### Enemy Scaling (V1.2)

| Stat | @ 100% Volatility |
|------|-------------------|
| Damage | **+20%** |
| Speed | **+10%** |
| HP | No scaling |

*Player scaling outpaces enemy scaling — high volatility should feel powerful.*

---

## 👾 ENEMIES (3 Types)

| Type | Behavior | HP | Shards | Notes |
|------|----------|-----|--------|-------|
| **Crawler** | Chases player, contact damage | 3 | 1 | Intro enemy |
| **Spitter** | Stationary, fires aimed projectile every 2s | 2 | 2 | Teaches dodging |
| **Dasher** | Charges when aligned, yellow telegraph → red dash → gray recovery | 4 | 3 | High risk/reward |

---

## 🚪 ROOM FLOW (V1.2)

**4 rooms + boss** (expandable to 8-12 in Month 3)

| Room | Composition |
|------|-------------|
| Room 1 | 5 Crawlers (intro) |
| Room 2 | 4 Crawlers + 3 Spitters |
| Room 3 | 4 Crawlers + 2 Spitters + 3 Dashers |
| Room 4 | Boss: The Accumulator |

### Room Rules
- Doors **lock on entry**
- Doors **unlock when all enemies defeated**
- **HP persists across rooms** (resets on death)
- **Volatility pauses on room clear** (resumes on door enter)

---

## 👹 BOSS: THE ACCUMULATOR (V1.2)

### Stats
- **Base HP: 60** (scales +20% per 1.0 volatility)
- **Damage: capped at +10%** (not 1:1 with volatility)

### Phases
| Phase | HP Range | Behavior |
|-------|----------|----------|
| **Phase 1** | 100-66% | 3-projectile spread, 2s cooldown |
| **Phase 2** | 66-33% | Spawns 2 Crawlers every 5s + continues shooting |
| **Phase 3** | 33-0% | **Chases player** (slow) + 5-projectile spread, 1s cooldown. Continues spawning Crawlers. |

### Victory
- All enemies cleared
- Player invulnerable
- Victory screen with stats
- Press Space to restart

---

## 💰 META PROGRESSION (Month 3)

*Not yet implemented*

- Bank shards after boss defeat
- Persistent upgrades:
  - +1 Starting HP
  - +5% Base Damage
  - +0.5s Kill Pause Duration

---

## 🐛 FIXED BUGS (Session 2026-02-15)

- ✅ Volatility decays after room clear → Now pauses
- ✅ Damage after boss defeat → Player invulnerable on victory
- ✅ HP not persisting → Now tracks across rooms
- ✅ Negative HP display → Clamped to 0

---

## 🚫 OUT OF SCOPE (V1)

- Mouse aim / twin-stick
- Items / pickups
- Weapon variants
- Multiple characters
- Procedural generation
- Story / dialogue
- Multiple floors

---

*This document is the source of truth for V1. If it's not here, we're not building it.*
