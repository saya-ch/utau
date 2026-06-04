# Voxglass

A 2D pixel art action-exploration game about restoring lost voices in a flooded underground archive.

## Status

Work-in-progress vertical slice. Current milestone: playable 60-second room demonstrating "enter -> Pulse -> repair -> collect -> exit" core loop.

## Tech

- Engine: Godot 4.6.3 (verified — `config/features=4.4` retained for backward compat, parses clean on 4.6.3 per `REVIEW_LOG.md` #20)
- Resolution: 480x270 internal, integer-scale to 1920x1080
- Language: GDScript
- Audio: Procedural SFX (pulse / footstep / glass-break / enemy hum / repair / damage) + 3 procedural BGM themes (title_intro / hub_warm / archive_exploration) — all generated at runtime via `AudioStreamWAV` synthesis in `src/scripts/audio_manager_enhanced.gd` (no external audio files needed)
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

## Development

This project follows an iterative development process. See `ITERATION_GUIDE.md` for the full workflow.

## Room Editor (JSON)

Rooms can now be defined in JSON under `data/rooms/`. See `data/rooms/README.md` for the full schema. To test a JSON room, open `src/scenes/json_room.tscn` and set the `room_id` export variable, or call `RoomLoader.load_room(room_id, parent_node)` from GDScript.
