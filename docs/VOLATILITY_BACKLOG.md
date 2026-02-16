# 📋 VOLATILITY — V1 Backlog

*4 Months | ~10 hrs/week | ~160 total hours*

---

## 🗓️ MILESTONE 1: FOUNDATION (Month 1)
**Goal:** One room, one enemy, movement and shooting work.

| ID | Task | Acceptance Criteria | Est. Hours |
|----|------|---------------------|------------|
| 1.1 | Project setup | Godot 4 project, folder structure, git repo, .tres configs created | 2 |
| 1.2 | Player movement | WASD moves player in 8 directions, collision with walls works | 4 |
| 1.3 | Player shooting | Arrow keys fire projectile in 4 directions, projectiles destroy on wall hit | 6 |
| 1.4 | Basic enemy (Crawler) | Spawns, moves toward player, dies when hit, drops placeholder shard | 8 |
| 1.5 | Shard collection | Player walks over shard, shard disappears, `shards_held` increments | 3 |
| 1.6 | Room scene template | Single room with walls, camera locks to bounds, door placeholder | 6 |
| 1.7 | Player HP + death | Player has HP, takes damage from enemy contact, dies at 0, restarts room | 4 |
| 1.8 | Basic UI | HUD shows HP, shards held (placeholder art OK) | 3 |

**Milestone 1 Deliverable:** Playable single room — kill Crawlers, collect shards, die and restart.

**Hours subtotal:** 36

---

## 🗓️ MILESTONE 2: VOLATILITY CORE (Month 2)
**Goal:** Volatility system fully functional, 2 more enemy types, multi-room flow.

| ID | Task | Acceptance Criteria | Est. Hours |
|----|------|---------------------|------------|
| 2.1 | Volatility system | Spacebar converts shards → volatility, meter displays on HUD, decays at 5%/s | 8 |
| 2.2 | Kill-pause decay | Each kill pauses decay for 1.5s, stacks up to 3, visual/audio feedback | 4 |
| 2.3 | Stat scaling (player) | Player damage/fire rate/speed scale with volatility per GDD table | 4 |
| 2.4 | Stat scaling (enemies) | Enemy HP/damage scale with volatility at spawn time | 4 |
| 2.5 | Spitter enemy | Stationary, fires slow projectiles at player, 3 HP, drops 2 shards | 6 |
| 2.6 | Charger enemy | Telegraph, dash, 4 HP, drops 3 shards | 6 |
| 2.7 | Room transitions | Door collision loads next room, camera transitions, enemies spawn fresh | 6 |
| 2.8 | Room clear detection | Doors locked until all enemies dead, unlock signal fires | 3 |
| 2.9 | 4 hand-authored rooms | Start room + 3 normal rooms, different enemy compositions | 6 |

**Milestone 2 Deliverable:** Play through 4 rooms with all 3 enemy types. Volatility system works end-to-end.

**Hours subtotal:** 47 (cumulative: 83)

---

## 🗓️ MILESTONE 3: BOSS + FULL RUN (Month 3)
**Goal:** Complete run from start to boss. Win/lose states.

| ID | Task | Acceptance Criteria | Est. Hours |
|----|------|---------------------|------------|
| 3.1 | 4 more normal rooms | Total 8 rooms before boss, varied layouts | 6 |
| 3.2 | Boss room layout | Larger room, boss spawn point, no regular enemies | 3 |
| 3.3 | Boss Phase 1 | Slow movement, spreadshot pattern, spawns Crawlers every 10s | 8 |
| 3.4 | Boss Phase 2 | Phase transition at 50% HP, faster, aimed shots, spawns Spitters | 6 |
| 3.5 | Boss volatility twist | Boss damage scales with player's current volatility | 2 |
| 3.6 | Victory state | Boss death → shards banked → victory screen → return to menu | 4 |
| 3.7 | Defeat state | Player death → run over screen → return to menu | 3 |
| 3.8 | Shard banking system | Banked shards persist across runs (save to file) | 4 |
| 3.9 | Meta-upgrade shop | Pre-run screen, buy upgrades with banked shards, upgrades apply to next run | 6 |

**Milestone 3 Deliverable:** Full playable run. Start → 8 rooms → boss → win/lose. Banking works.

**Hours subtotal:** 42 (cumulative: 125)

---

## 🗓️ MILESTONE 4: POLISH + SHIP (Month 4)
**Goal:** Playtest, balance, polish, ship.

| ID | Task | Acceptance Criteria | Est. Hours |
|----|------|---------------------|------------|
| 4.1 | Placeholder art pass | Player, enemies, projectiles, shards, rooms have readable sprites | 8 |
| 4.2 | Audio pass | Shoot SFX, hit SFX, death SFX, shard pickup, volatility convert, boss music | 6 |
| 4.3 | Balance tuning | 3+ full playthroughs with tuning adjustments per session | 6 |
| 4.4 | Juice pass | Screen shake, hit flash, death particles, volatility visual effects | 6 |
| 4.5 | Bug fixing | Address all P0/P1 bugs from Tester | 6 |
| 4.6 | Build + export | Windows + Mac builds, tested, zipped | 3 |
| 4.7 | Itch.io page | Upload builds, write description, screenshots | 2 |

**Milestone 4 Deliverable:** Shipped game on Itch.io. Playable, polished, no critical bugs.

**Hours subtotal:** 37 (cumulative: 162)

---

## 🚨 TOP 5 DESIGN RISKS

| Risk | Why It's Dangerous | Countermeasure |
|------|-------------------|----------------|
| **1. Volatility feels pointless** | If scaling is too weak, players ignore it | Make 100% volatility feel DRAMATICALLY different. Big numbers. |
| **2. Volatility feels mandatory** | If enemies are too hard at 0%, players must convert | Baseline must be beatable at 0%. Volatility = faster, not required. |
| **3. Decay feels punishing** | Missing one kill resets momentum, frustrating | Kill-pause is generous (1.5s, stacks). Decay starts slow. Tune UP if needed. |
| **4. Boss is a wall** | Undertested boss = run-ending frustration | Boss in by end of Month 3, 4 weeks to tune. MUST playtest boss by week 10. |
| **5. "Just one more feature"** | Scope creep kills small projects | If it's not in GDD, it's Post-V1. Period. Designer is the scope cop. |

---

## 🅿️ POST-V1 PARKING LOT

*We are NOT building these. But we're writing them down so we stop thinking about them.*

- Mouse aim / twin-stick controls
- Procedural room generation
- Floor 2, Floor 3
- Items / passive pickups
- Weapon variants (shotgun, laser, etc.)
- Multiple playable characters
- Leaderboards / high scores
- Daily challenge runs
- Meta-progression skill tree
- Story / lore / dialogue
- Achievements

---

*Last updated: 2026-02-15*
