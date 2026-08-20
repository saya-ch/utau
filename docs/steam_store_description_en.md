# Voxglass — Steam Store Description (EN)

> Draft source text for a future Steam store page. It is not live,
> not submitted, and not release-candidate evidence.
> Steam field → draft content mapping lives below.
> Maintained in tandem with `docs/steam_page.md` (Chinese positioning doc).

---

## Short Description (Steam short blurb — max 300 chars)

> Restore the voices drowned by the living silence. As Saya,
> the last voice-mender, glide through a flooded archive and
> shatter glass bells with sound-waves to return lost names,
> songs, and farewells to the world.

(297 chars, including punctuation)

---

## About This Game (Long description)

**Voxglass** is a 2D pixel-art action-exploration game about
restoring the voices a living silence has swallowed.

Centuries ago, a vast voice archive was drowned beneath the
water-table. Every farewell, every lullaby, every spoken name was
sealed inside cracked glass bells. Now, something called the Silence
has grown a body. It is corroding the bells one by one, and with
them, the memories they hold.

You are **Saya** — the last voice-mender. Your throat-shard hums,
your sound-box gauntlet pulses, and your cracked-glass cape trails
warm waveforms in your wake.

### Six verbs. One voice.

- **Pulse** — A short-ranged shockwave that shatters SilenceMotes,
  cracks open glass locks, and lights up the room in warm coral and cyan.
- **Bind** — A contracting vortex that pulls an enemy toward you,
  freezes corrupted chains, and unlocks ability gates.
- **Cut** — A razor-sharp arc that sunders the silence-webs,
  cleaves projectiles, and rips shields open.
- **Echo** — A resonant shield that catches hostile force and sends it back.
- **Wave** — A broad group-wave that controls space around Saya.
- **Whisper** — A focused silence orb for the archive's late-game threats.

Every danger announces itself with a waveform first. If you fail,
you will know exactly why.

### The 30-second loop

Enter a 20–40 second room. Read the rhythm. Solve with sound.
Collect a resonance shard. The room brightens, the bell chimes,
and a new door opens.

### What's in the build

- **5 playable archive rooms + 1 safe-zone Hub** —
  `archive_01` leads to the Hub; archives 02/03/04 route from and
  back to it; restoring 01–04 unlocks the `archive_05` finale
- **3 enemy archetypes** (SilenceMote, NoteWisp, InkWarden elite)
  with telegraphed attacks
- **Procedural audio** — all SFX and 9 BGM themes are synthesized at runtime
- **15 unlockable achievements** with persistent progress —
  `full_archive` restores four to open the finale, `archive_master`
  restores all five, and `sextuple_voice` uses all six verbs
- **5-slot manual save** + checkpoint lanterns + Continue from Title
- **Keyboard and mapped gamepad controls** + 4 bus volume mix
  (Master / Music / SFX / Ambience)

> Release note: physical gamepad/Steam Deck validation is still
> pending; do not publish a “Steam Deck Verified” claim from this draft.

### Why Voxglass

Most metroidvanias ask you to fight. Voxglass asks you to
**listen, then return what was taken**. The melancholy is real,
but the mood is hopeful — every room you leave is brighter than
the one you found.

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

## Capsule Art Mapping (draft)

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
| 1 | `01_title_screen.png` | Title screen + CN typography | "Restore what the silence took" |
| 2 | `02_hub_room.png` | Hub, NPCs, five-archive wayfinding | "Restore four. Open the final archive." |
| 3 | `03_archive_01_pulse.png` | Saya firing Pulse in archive 01 | "Six verbs. One voice." |
| 4 | `04_archive_03_boss.png` | Archive 03 InkWarden | "Listen, then return what was taken" |
| 5 | `05_archive_04_double_boss.png` | Archive 04 dual InkWarden | "Face the archive at full resonance" |
| 6 | `06_shop_merchant.png` | Opaque scrollable merchant UI | "Prepare for the final archive" |

---

## Store Submission Checklist (draft; not submitted)

- [x] Short description (297 chars, EN)
- [x] Long description (~370 words, EN)
- [x] 10 store tags assigned
- [x] Header / Small / Main / Feature capsules (A047-A049, generated)
- [x] Library hero (A018)
- [ ] Curate and upload 6 store-ready in-game screenshots
  (a strict 6/6 local viewport batch exists; final store selection/copy is pending)
- [ ] System requirements (min + rec, TBD)
- [ ] Release date (TBD)
- [ ] Price tier (TBD)
- [ ] Trailer 30s teaser (future candidate; project is not release-ready)

---

## Localization Notes

- Primary: English (this file).
- Secondary: Simplified Chinese (see `docs/steam_page.md` for the source).
- Japanese / Korean / Russian: future localization candidates if the
  project reaches release readiness and metrics justify them.
- Steam description fields are plain-text. If this draft is approved
  for submission, strip the `**` markers and table pipes before pasting.
