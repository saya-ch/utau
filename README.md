# Voxglass

A 2D pixel art action-exploration game about restoring lost voices in a flooded underground archive.

## Status

Work-in-progress vertical slice. Current milestone: playable 60-second room demonstrating "enter -> Pulse -> repair -> collect -> exit" core loop.

## Tech

- Engine: Godot 4.6.3 (verified — `config/features=4.4` retained for backward compat, parses clean on 4.6.3 per `REVIEW_LOG.md` #20)
- Resolution: 480x270 internal, integer-scale to 1920x1080
- Language: GDScript
- Audio: Procedural SFX (pulse / footstep / glass-break / enemy hum / repair / damage) + 4 procedural BGM themes (title_intro / hub_warm / archive_exploration / **archive_boss** for InkWarden encounters) — all generated at runtime via `AudioStreamWAV` synthesis in `src/scripts/audio_manager_enhanced.gd` (no external audio files needed). Title screen pre-warms the BGM cache so the first scene switch is zero-latency. Per-bus volume (Master / Music / SFX / Ambience) configurable in-game via the Settings menu.
- Local Godot binary: `godot/Godot_v4.6.3-stable_linux.x86_64` (see `godot/README.md`)

## Project Structure

```
assets/        # Art, audio, and design reference assets
src/           # Source code
  autoload/    # GameState / PlayerStats / SaveSystem / AudioManager singletons
  scenes/      # Godot scene files (.tscn)
  scripts/     # GDScript logic
docs/          # Design docs (Steam page, etc.)
scripts/       # Python asset pipeline tools
```

## Save System

Saves are persisted to disk as JSON in `user://saves/`:

| File | Origin | Trigger |
|------|--------|---------|
| `slot_0.json` / `slot_1.json` / `slot_2.json` | Manual (player picks in SaveLoadMenu) | Title screen → 继续修复 → choose slot → 载入 |
| `slot_auto.json` | Automatic | Walking onto a Save Lantern in any archive / hub room |

Each save envelope records: `version` (1), `slot_index`, `is_auto`, `timestamp_unix`, `room_count`, `shard_total`, and the full `GameState` snapshot (health / resonance / shards / rooms_completed / current_room / checkpoint_position / abilities). Achievements and lifetime stats live in `PlayerStats` and persist independently across runs. Pressing 继续修复 on a slot that has no data starts a new run from `archive_01`.

## Controls

| Action | Keyboard | Gamepad |
|--------|----------|---------|
| Move | A/D or Arrow Keys | Left Stick |
| Jump | Space or W | A Button |
| Pulse (push/shield-break) | J or Z | X Button |
| Bind (pull / stun / unlock gates) | K or X | Y Button |
| Cut (slice/sunder) | L or C | LB Button |
| Interact | E or Enter | B Button |
| Pause / Menu | ESC | Start Button |
| Save (auto) | (walk onto a Save Lantern) | — |
| Continue Run | (Title screen → 继续修复 button) | — |
| Credits | (Title screen → 致谢 button) | — |

## Audio Controls

`Settings → Audio` menu exposes three independent volume sliders, each bound to its own Godot AudioServer bus:

| Slider | Bus | Contents |
|--------|-----|----------|
| Master | `Master` | Everything (BGM + SFX + ambience summed) |
| Music | `Music` | Procedural BGM (title_intro / hub_warm / archive_exploration / archive_boss) |
| SFX | `SFX` | Pulse / Bind / Cut / footstep / glass-break / damage / repair |
| Ambience | `Ambience` | Water / wind / room atmosphere hum |

Settings persist to `user://settings.cfg` across runs.

## Development

This project follows an iterative development process. See `ITERATION_GUIDE.md` for the full workflow.

## Room Editor (JSON)

Rooms can now be defined in JSON under `data/rooms/`. See `data/rooms/README.md` for the full schema. To test a JSON room, open `src/scenes/json_room.tscn` and set the `room_id` export variable, or call `RoomLoader.load_room(room_id, parent_node)` from GDScript.
