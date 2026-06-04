# Voxglass — Steam Store Description (EN)

> Source of truth for the live Steam store page text. Steam field → content mapping lives below.
> Maintained in tandem with `docs/steam_page.md` (Chinese positioning doc).

---

## Short Description (Steam short blurb — max 300 chars)

> Restore the voices drowned by the living silence. As Saya, the last voice-mender, glide through a flooded archive and shatter glass bells with sound-waves to return lost names, songs, and farewells to the world.

(297 chars, including punctuation)

---

## About This Game (Long description)

**Voxglass** is a 2D pixel-art action-exploration game about restoring the voices a living silence has swallowed.

Centuries ago, a vast voice archive was drowned beneath the water-table. Every farewell, every lullaby, every spoken name was sealed inside cracked glass bells. Now, something called the Silence has grown a body. It is corroding the bells one by one, and with them, the memories they hold.

You are **Saya** — the last voice-mender. Your throat-shard hums, your sound-box gauntlet pulses, and your cracked-glass cape trails warm waveforms in your wake.

### Three verbs. One voice.

- **Pulse** — A short-ranged shockwave that shatters SilenceMotes, cracks open glass locks, and lights up the room in warm coral and cyan.
- **Bind** — A contracting vortex that pulls an enemy toward you, freezes corrupted chains, and unlocks ability gates.
- **Cut** — A razor-sharp arc that sunders the silence-webs, cleaves projectiles, and rips shields open.

Every danger announces itself with a waveform first. If you fail, you will know exactly why.

### The 30-second loop

Enter a 20–40 second room. Read the rhythm. Solve with sound. Collect a resonance shard. The room brightens, the bell chimes, and a new door opens.

### What's in the build

- **3 handcrafted archive rooms + 1 safe-zone Hub** with 2 NPC dialogue trees
- **3 enemy archetypes** (SilenceMote, NoteWisp, InkWarden elite) with telegraphed attacks
- **Procedural audio** — all SFX and 4 layered BGM themes (title, hub, exploration, boss) are synthesized at runtime
- **8 unlockable Steam-style achievements** with persistent cross-save progress
- **3-slot manual save** + checkpoint lanterns + Continue from Title
- **Full gamepad support** + 4 bus volume mix (Master / Music / SFX / Ambience)
- **Steam Deck verified controls** (mouse + keyboard + gamepad rebinding)

### Why Voxglass

Most metroidvanias ask you to fight. Voxglass asks you to **listen, then return what was taken**. The melancholy is real, but the mood is hopeful — every room you leave is brighter than the one you found.

---

## Tags (Steam store tags, in priority order)

| Priority | Tag |
|---|---|
| 1 | 2D Platformer |
| 2 | Action |
| 3 | Pixel Art |
| 4 | Atmospheric |
| 5 | Metroidvania |
| 6 | Roguelite |
| 7 | Female Protagonist |
| 8 | Exploration |
| 9 | Indie |
| 10 | Singleplayer |
| 11 | Soundtrack |
| 12 | Procedural Audio |

---

## Capsule Art Mapping (live)

| Steam field | Source asset | Aspect |
|---|---|---|
| Header capsule | `assets/marketing/voxglass_capsule_main_616x353.png` (A047) | 616×353 (1.746:1) |
| Small capsule | `assets/marketing/voxglass_capsule_small_460x215.png` (A048) | 460×215 (2.14:1) |
| Main capsule | `assets/marketing/voxglass_capsule_main_616x353.png` (A047) | 616×353 |
| Feature graphic | `assets/marketing/voxglass_capsule_feature_1200x630.png` (A049) | 1200×630 (1.905:1) |
| Library hero | `assets/marketing/voxglass_key_art_no_title.png` (A018) | 1024×1536 |
| Page background | derived from A047 / A049 with dimmer treatment | — |

---

## Screenshot Slot Plan (in carousel order)

| # | Source frame | Subject | Caption hint |
|---|---|---|---|
| 1 | A047 header crop | Saya + Pulse + flooded archive | "Restore what the silence took" |
| 2 | archive_01 mid-gameplay | Pulse击中 SilenceMote | "Three verbs. One voice." |
| 3 | archive_02 room completion | 房间修复后暖色回流 | "Every room you leave is brighter" |
| 4 | archive_03 boss arena | InkWarden 护盾 + 玩家 Cut 破盾 | "Listen, then return what was taken" |
| 5 | Hub 安全区 | NPCs + 三个门 | "3 rooms, 2 NPCs, 1 archive" |
| 6 | Settings / Pause menu polish | 8 宫格成就图标 + 4 bus 滑块 | "Steam-style achievements + 4-bus audio" |

---

## Launch Checklist (for live store page)

- [x] Short description (297 chars, EN)
- [x] Long description (~370 words, EN)
- [x] 10 store tags assigned
- [x] Header / Small / Main / Feature capsules (A047-A049, generated)
- [x] Library hero (A018)
- [ ] 6 real in-game screenshots (placeholders via capsule crops pending)
- [ ] System requirements (min + rec, TBD)
- [ ] Release date (TBD)
- [ ] Price tier (TBD)
- [ ] Trailer 30s teaser (TBD, post-launch candidate)

---

## Localization Notes

- Primary: English (this file).
- Secondary: Simplified Chinese (see `docs/steam_page.md` for the source).
- Japanese / Korean / Russian: post-launch if metrics justify.
- Steam description field is plain-text, no markdown. Strip the `**` markers and table pipes when pasting into the live page.
