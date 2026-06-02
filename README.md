# Voxglass

A 2D pixel art action-exploration game about restoring lost voices in a flooded underground archive.

## Status

Work-in-progress vertical slice. Current milestone: playable 60-second room demonstrating "enter -> Pulse -> repair -> collect -> exit" core loop.

## Tech

- Engine: Godot 4.4
- Resolution: 480x270 internal, integer-scale to 1920x1080
- Language: GDScript

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
| Pulse | J or Z | X Button |
| Interact | E or Enter | B Button |

## Development

This project follows an iterative development process. See `ITERATION_GUIDE.md` for the full workflow.
