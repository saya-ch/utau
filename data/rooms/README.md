# Room JSON Format

Rooms are defined as JSON files in this directory. Each file describes one playable room.

## Top-Level Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `room_id` | string | `"unknown"` | Unique room identifier |
| `completion_shards` | int | `3` | Shards rewarded on room completion |
| `player_spawn` | [x, y] | `[60, 180]` | Player start position |
| `background` | object | — | Background sprite config |
| `ground` | object | — | Ground collision config |
| `platforms` | array | `[]` | List of platform objects |
| `hazards` | array | `[]` | List of hazard (water) objects |
| `enemies` | array | `[]` | List of enemy objects |
| `interactables` | array | `[]` | List of interactable objects |
| `room_door` | object | — | Exit door config |

## Entity Objects

### Platform
```json
{
  "position": [120, 200],
  "size": [80, 16]
}
```

### Hazard (Water)
```json
{
  "position": [200, 238],
  "size": [120, 24]
}
```

### Enemy

#### silence_mote
```json
{
  "type": "silence_mote",
  "position": [320, 154],
  "patrol_speed": 30,
  "patrol_range": 60,
  "chase_speed": 60,
  "chase_range": 80,
  "health": 1
}
```

#### note_wisp
```json
{
  "type": "note_wisp",
  "position": [200, 120],
  "move_amplitude": 40,
  "move_frequency": 1.5,
  "health": 2
}
```

#### ink_warden
```json
{
  "type": "ink_warden",
  "position": [300, 150],
  "health": 5,
  "shield_health": 3
}
```

### Interactable

#### glass_lock
```json
{
  "type": "glass_lock",
  "position": [440, 116],
  "repair_required": 1
}
```

#### voice_bell
```json
{
  "type": "voice_bell",
  "position": [280, 146],
  "shard_value": 1
}
```

#### ability_gate
```json
{
  "type": "ability_gate",
  "position": [400, 200],
  "required_ability": "bind",
  "block_hint": "需要 Bind 能力"
}
```

#### save_lantern
```json
{
  "type": "save_lantern",
  "position": [120, 190]
}
```

#### silenced_web
```json
{
  "type": "silenced_web",
  "position": [380, 200]
}
```
A corruption web that can only be cut by the Cut ability. Pulse/Bind cannot interact with it. Responding to Cut triggers a slice-open animation and removes the barrier.

### Room Door
```json
{
  "position": [470, 210],
  "target_room_path": "res://src/scenes/room_archive_02.tscn",
  "target_spawn_point": [40, 180]
}
```

### Tutorial Hints (Optional)
```json
{
  "tutorial_hints": [
    {
      "group": "intro_pulse",
      "text": "按 [J] 释放 Pulse 声波 — 它能推开敌人、修复玻璃锁与声匣",
      "delay": 0.8,
      "duration": 5.0
    }
  ]
}
```
Each hint has:
- `group` (string): unique ID to prevent repeat display across rooms/runs
- `text` (string): shown in the bottom hint panel
- `delay` (float, sec): delay before showing
- `duration` (float, sec): how long the hint stays on screen

## Runtime Loading

Use `RoomLoader.load_room(room_id, parent_node)` from GDScript, or instantiate `json_room.tscn` and set its `room_id` export variable.
