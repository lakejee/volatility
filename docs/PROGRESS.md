# ⚡ VOLATILITY — Progress Log

*Last updated: 2026-02-15*

---

## 📊 Overall Status

| Phase | Status | Completion |
|-------|--------|------------|
| Month 1: Core Loop | ✅ DONE | 100% |
| Month 2: Room Flow | ✅ DONE | 100% |
| Month 3: Polish + Meta | 🔜 TODO | 0% |
| Month 4: Juice + Ship | 🔜 TODO | 0% |

---

## ✅ Month 1: Core Loop (COMPLETE)

- [x] Player movement (WASD)
- [x] 4-direction shooting (Arrow keys)
- [x] Projectile system
- [x] Crawler enemy (chase + contact damage)
- [x] Shard drops on enemy death
- [x] Volatility system (V1.1)
  - [x] Incremental conversion (hold Space)
  - [x] 4% per shard
  - [x] Decay 0.1/sec
  - [x] Kill pause 1.5s stacking
  - [x] Player scaling (+40%/+25%/+20%)
  - [x] Enemy scaling (+20%/+10%)
- [x] Basic HUD (Volatility, Shards, HP, Room)
- [x] Single room playable

---

## ✅ Month 2: Room Flow (COMPLETE)

- [x] Room transitions (door → next room)
- [x] Door lock/unlock (lock on entry, unlock when cleared)
- [x] Spitter enemy (stationary, ranged, aims at player)
- [x] Dasher enemy (charges when aligned, telegraph)
- [x] 4 rooms with varied compositions
  - Room 1: 5 Crawlers (intro)
  - Room 2: 4 Crawlers + 3 Spitters
  - Room 3: 4 Crawlers + 2 Spitters + 3 Dashers
  - Room 4: Boss
- [x] Player death → Game Over screen
- [x] Boss: The Accumulator
  - Phase 1: 3-projectile spread
  - Phase 2: Spawns Crawlers + shooting
  - Phase 3: Faster shooting
- [x] Victory screen + restart

---

## 🔜 Month 3: Polish + Meta (TODO)

- [ ] 4 more rooms (total 8 + boss)
- [ ] Varied room layouts
- [ ] Meta progression
  - [ ] Shard banking after victory
  - [ ] Persistent currency
  - [ ] 3 upgrades (+HP, +Damage, +Kill Pause)
- [ ] Visual polish
  - [ ] Enemy hit flash
  - [ ] Death particles
  - [ ] Screen shake
  - [ ] Muzzle flash
- [ ] Audio
  - [ ] Shoot SFX
  - [ ] Hit SFX
  - [ ] Death SFX
  - [ ] Boss music
- [ ] Balance pass

---

## 🔜 Month 4: Juice + Ship (TODO)

- [ ] 2-4 more rooms (total 10-12)
- [ ] Difficulty curve tuning
- [ ] Start menu (New Run, Upgrades, Quit)
- [ ] Pause menu
- [ ] Playtesting (5+ full runs)
- [ ] Bug fixing
- [ ] Final balance
- [ ] Export builds (Windows/Mac)

---

## 🐛 Known Issues

*(Track bugs here)*

- None currently blocking

---

## 📝 Session Log

### 2026-02-15
- Completed Phase 1 (Core Loop)
- Completed Phase 2 (Room Flow)
- All 3 enemy types implemented
- Boss fight working
- Full playable run: Room 1 → Boss → Victory
