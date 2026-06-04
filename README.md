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
  autoload/    # GameState, AudioManager singletons
  scenes/      # Godot scene files (.tscn)
  scripts/     # GDScript logic
docs/          # Design docs (Steam page, etc.)
scripts/       # Python asset pipeline tools
```

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
| Save (auto + manual) | (walk onto a Save Lantern / Pause → 保存进度) | — |
| Continue from save | (Title screen → 继续修复, if a save exists) | — |
| Credits | (Title screen → 致谢 button) | — |

## Save System

Three save slots are persisted to `user://saves/slot_N.json`. Each slot captures:

- `current_room` + `current_scene` (room id + .tscn path, so `Continue` reloads the right scene)
- `health` / `resonance` / `shards` and the `rooms_completed` set
- unlocked `abilities` (bind / cut) and the player's last `checkpoint_position`
- `run_time_seconds` (in-game timer)
- All `achievements` unlocked so far (also written-through to `user://achievements.json` on every unlock, independently of slots)

Title screen shows a `继续修复` button only when at least one slot is occupied. The pause menu's `保存进度` button opens the same slot picker in save mode. Achievement unlocks always persist to disk the instant they're earned.

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
