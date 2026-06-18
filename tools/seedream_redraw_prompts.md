# Seedream 5.0 Redraw Prompt Library

> F022 (#108 调度, #109+ 执行) — 21 张 Voxglass 资产重绘 prompt 库
>
> **本文件是** [`tools/seedream_redraw_index.json`](seedream_redraw_index.json) 的 prompt 详解
> **关联**：
> - [STYLE_GUIDE.md](../../STYLE_GUIDE.md) — 视觉宪法 (色板 / 形状 / 像素规格 / 负提示词)
> - [ASSET_REGISTRY.md](../../ASSET_REGISTRY.md) — 资产账本 (A001-A073)
> - [data 目录](../../assets/) — 当前 PNG 实际位置
> - [byted-seedream-image-generate SKILL.md](../../../data/user/skills/byted-seedream-image-generate/SKILL.md) — 模型调用规范
>
> **模型默认**: `doubao-seedream-5-0-260128` (5.0-lite), `output_format=png`, `watermark=false`
> **fallback**: 4.5 / 4.0

---

## §shared-prefix (所有 prompt 前缀)

每个 prompt 都以相同 prefix 开头，确保 21 张图都遵循 Voxglass 视觉宪法：

```
Pixel art, Steam indie quality, 2D platformer asset, Voxglass visual style:
deep ink navy and muted teal flooded underground voice archive, cracked
glass bells, living silence, melancholic but hopeful mood. Color palette
strict: ink navy #081426, archive blue #12334A, deep teal #1D6570, glass
cyan #69C7CE, pale resonance #B7E7DD, muted violet #65506A, coral pulse
#E86D5A, amber voice #F2B66E, warm parchment #E6D5B8. Cold tones 75%,
neutral 15%, warm 10%. Warm only for feedback/danger/reward, never for
large background. Crisp readable silhouette, gameplay-ready, no text,
no logo, no watermark, no photorealism, no 3D render, no fan art, no
glossy AI anime poster aesthetic.
```

---

## §skip-note-A002 (不重绘, REJECTED 废案)

A002 "声匣修复者主角概念 (旧版)" **不重绘**。原 ASSET_REGISTRY 中已标 REJECTED —
主角不够有特色，偏通用 AI 黑斗篷。后续被 A007 Saya 终极设定完全替代。重绘会复活
团队已废弃的设计，违反 _legacy 路径保留 + REJECTED 资产不复用 原则。

如需"旧版主角"参考以对比新旧风格差异，**直接读 A002 现有 PNG** (built-in imagegen 1002) —
它本身已是"10 年前 AI 工具" 的失败样本，本身就是有价值的废案历史。

---

## §tier-1-prompts (5 张营销关键)

### J001 — A001 Voxglass 情绪板 (moodboard_4panel)

**prompt** (sequential_image_generation, max_images=4):

```
[shared-prefix] Four-panel moodboard grid, top-left to bottom-right:

Panel 1 (top-left): Wide flooded underground voice archive hall, multiple
arches receding into deep teal mist, glass voice bells hanging from
vaulted ceiling with warm amber voice glow, shallow water reflection on
stone floor, distant Saya silhouette with cyan strand visible. No text.

Panel 2 (top-right): Silence creature close-up, negative silhouette ink
navy body with muted violet corrosion edges, single warm amber core eye
glaring, coral pulse warning glow ring around body, torn fabric edges.
No text.

Panel 3 (bottom-left): Voxglass color palette as 10 rounded color chips
arranged in 2 rows of 5: row 1 (cold 75%) ink navy / archive blue / deep
teal / glass cyan / pale resonance. row 2 (neutral+warm 25%) muted
violet / coral pulse / amber voice / warm parchment / abyss black.
No text.

Panel 4 (bottom-right): Before/after comparison split vertically. LEFT
half: cracked voice bell on stone pedestal, dim muted violet interior,
glass cyan edges barely glowing, ink navy shadows. RIGHT half: same
bell after repair, warm amber voice glow from within, glass cyan edges
brightly lit, subtle waveform pattern inside, floating resonance
particles. No text.
```

**size**: `1920x1080` (Steam 主页 header 推荐 16:9)
**rationale**: moodboard 是后续每张 concept prompt 的"宪法索引", 4 宫格分别给出
environment / enemy / palette / before-after 4 个 reference point.

---

### J002 — A003 回声档案馆场景概念 (environment_wide)

**prompt**:

```
[shared-prefix] Wide cinematic concept art of flooded underground voice
archive hall, 16:9 horizontal layout, multiple stone arches receding
into deep teal mist, hanging glass voice bells with warm amber voice
glow, shallow water reflection on cracked stone floor, hanging cable
stubs from vaulted ceiling, distant resonance chapel archway glowing
glass cyan in background. Platform hierarchy: foreground stone tile
platform (2 tiles thick), middle-ground elevated arch pedestal with
single voice bell on top, background three-story bell stacks. Lighting:
main light low-intensity cyan-blue ambient from water surface, accent
warm amber voice glow from 3 bells, glass cyan edge highlight on arches
and bells. No characters in foreground, parallax-ready composition
(3 depth layers), no UI, no text, no logo.
```

**size**: `1280x720` (16:9 概念图)
**rationale**: A003 是 archive_01 灵感来源, 平台层次清晰, 后续程序化背景 (A021) 派生.

---

### J003 — A007 Saya 最终主角设定 (character_reference)

**prompt**:

```
[shared-prefix] Anime heroine character reference sheet, full-body
front view, centered, white background, 1:1 portrait. Saya, 18 years
old, short dark ink navy hair with one long cyan strand falling past
shoulder, warm amber voice throat shard, deep teal archive coat with
archive blue collar, cracked glass half-cape over right shoulder,
sound-wave scarf in pale resonance and glass cyan, compact sound-box
gauntlet on her anatomical left forearm (NOT mirrored to right arm) —
glass cyan shell with amber voice core visible through cracks, two
small waveform dials. Eyes pale resonance, calm determined expression.
No weapon in hand. Pixel-art style, clean readable silhouette, no text
labels, no pose variation, single front-view character sheet for
sprite derivative base.
```

**size**: `1024x1024` (1:1 角色三视图参考)
**rationale**: A007 是主角视觉宪法, 左臂声匣严格在解剖学左臂 (非镜像), 所有 spritesheet (A026/A027) 派生.

---

### J004 — A018 无标题 Key Art (key_art_wide)

**prompt**:

```
[shared-prefix] Cinematic key art, 16:9 horizontal hero illustration,
no title text, no logo. Center-left: Saya full-body silhouette facing
away from camera, left-arm sound-box gauntlet raised emitting expanding
Pulse rings in coral + amber + cyan. Foreground: cracked voice bell on
stone pedestal with deep fracture lines glowing glass cyan at edge.
Background: flooded voice archive with multiple stone arches, hanging
glass bells, shallow water reflection layer at bottom. Atmosphere:
melancholic but hopeful, deep teal mist, sparse amber voice glow
accents, ink navy to archive blue vertical gradient. No UI, no
watermark, no game screenshot elements. Composition leaves negative
space on right side for Steam header title overlay.
```

**size**: `1920x1080` (Steam hero art 推荐 16:9)
**rationale**: A018 是 Steam capsule / itch 页面方向参考, 此重绘版将是 A047 (程序化版本) 的 AI 替代品.

---

### J005 — A047 Steam Header Capsule 主胶囊 (capsule_header)

**prompt**:

```
[shared-prefix] Steam header capsule, 616x353 horizontal banner,
compact composition. Center: Saya silhouette with left-arm sound-box
gauntlet mid-pulse, expanding 3 concentric Pulse rings (coral inner /
amber mid / cyan outer). Behind Saya: 1 stone arch with 1 glass voice
bell hanging at top. Foreground: shallow water reflection. Background:
ink navy to archive blue vertical gradient with sparse amber glow
accents. Tight composition, no negative space (Steam capsule fills
edge to edge), no text overlay, no logo, no UI elements, no
characters other than Saya silhouette.
```

**size**: `616x353` (严格 Steam header capsule 规格)
**rationale**: A047 当前是程序化绘制 (Seed 1047), Seedream 5.0 重绘版可更精致.

---

## §tier-2-prompts (7 张生产表)

### J006 — A008 Saya 右朝向动作参考 (character_animation_ref)

**prompt**:

```
[shared-prefix] Anime heroine character animation reference sheet, 4x3
grid of 12 action poses, right-facing (Saya's left side toward camera
showing anatomical left-arm gauntlet prominently). 12 poses: idle 1
(straight) / idle 2 (weight on right leg) / run 1 (right foot forward)
/ run 2 (right knee up) / run 3 (mid-stride) / run 4 (left foot
forward) / run 5 (left knee up) / run 6 (landing) / jump (takeoff) /
jump (apex) / fall (descending) / fall (landing pre-impact). Each pose
in own cell, 256x256 cell, total 1024x768 grid. Saya left-arm sound-box
gauntlet visible in every pose, eyes on screen-right (right-facing).
No text labels, no frame numbers, no action captions.
```

**size**: `1024x768` (4:3 角色动作参考)
**rationale**: A008 是 A026 spritesheet 派生源, 12 动作覆盖 5 verb 战斗 + 移动.

---

### J007 — A009 Saya 左朝向动作参考 (character_animation_ref_left)

**prompt**:

```
[shared-prefix] Anime heroine character animation reference sheet, 4x3
grid of 12 action poses, left-facing (Saya's right side toward camera,
anatomical left-arm gauntlet on screen-left side, eyes on screen-left).
This is NOT a horizontal mirror of the right-facing sheet — poses are
independently drawn. 12 poses: idle 1 / idle 2 / run 1-6 / jump (takeoff)
/ jump (apex) / fall (descending) / fall (landing). Saya left-arm
gauntlet on screen-left in every pose (matches camera-left), eyes on
screen-left. No text, no frame numbers, no captions.
```

**size**: `1024x768` (4:3 角色动作参考)
**rationale**: A009 是 A027 spritesheet 派生源, 严格保持左臂声匣在画面左侧 (非镜像), 这是 STYLE_GUIDE 的硬性规定.

---

### J008 — A010 Saya 头像表情表 (portrait_grid_8)

**prompt**:

```
[shared-prefix] Portrait expressions grid, 8 close-up face portraits in
horizontal row, 256x256 each, total 2048x256. Anime heroine Saya with
short dark hair, one long cyan strand, pale resonance eyes. 8
expressions left-to-right: 1) neutral (calm, soft eyes) 2) smile (gentle,
mouth slightly open) 3) worried (eyebrows raised, slight frown) 4)
resolve (determined, jaw set, eyes forward) 5) surprised (wide eyes,
mouth open) 6) exhausted (half-closed eyes, slight slump) 7) whisper
(one hand near mouth, soft smile, conspiratorial) 8) silenced (mouth
closed, eyes dimmed muted violet overlay, somber). All 8 portraits same
character, same head angle, same lighting. No text labels, no emotion
captions, no frame numbers.
```

**size**: `2048x256` (8 表情横排, 每格 256x256)
**rationale**: A010 是对话系统 + Steam 页面角色展示, 8 表情覆盖所有情绪.

---

### J009 — A011 寂静敌人生产概念表 (enemy_sheet_8)

**prompt**:

```
[shared-prefix] Enemy production concept sheet, 8 distinct enemies in
horizontal row, 256x256 each, total 2048x256. All enemies share
silence-creature visual language: negative silhouette ink navy body
with muted violet corrosion edges, single warm amber core eye, coral
pulse warning glow ring. 8 enemies left-to-right:

1) silence mote: 32x32 small floating ink blob, torn fabric edges,
single tentacle wisp
2) note wisp: 32x32 small floating musical note creature, torn sheet
music body, staff line wings, trailing waveform tail
3) ink leech: 48x32 elongated ink blob with multiple short tentacles
underneath, ground crawler
4) bell stalker: 48x48 tall cloaked figure with cracked glass bell
replacing head, no visible eyes
5) glass moth: 48x48 winged creature with cracked glass wing patterns
in pale resonance, dim amber body
6) husk: 64x32 humanoid-shaped ink mass slumped on ground, no
distinguishing features
7) warden: 64x96 large floating ink blob, long tentacle wisps, single
large amber eye, 4 visible rage cracks (tier 1 base)
8) turret: 48x48 static eye mounted on ink pedestal, no body, slow
projectile spawner

No text labels, no enemy names, no stats.
```

**size**: `2048x256` (8 enemy 横排)
**rationale**: A011 是 enemy 生产参考, 8 enemy 覆盖 #13/#21/#31/#46 T120+ 全部章节.

---

### J010 — A012 档案馆 Tile/模块件概念 (tileset_concept)

**prompt**:

```
[shared-prefix] Tileset concept reference, 4x4 grid of 16 distinct
16x16 pixel tiles scaled to 256x256 each for visibility, total
1024x1024. All tiles share palette (ink navy, archive blue, deep teal,
glass cyan, muted violet accents). 16 tiles labeled by position:

Row 1: stone floor (3 variations: clean / cracked / wet-reflective)
Row 2: stone wall (3 variations: vertical-brick / horizontal-brick /
arched-corner)
Row 3: arches (3 variations: top-arch / side-arch / column-base)
Row 4: water (3 variations: shallow-puddle / deep-pool / water-edge)
plus 4 special: glass-spike (top), cable-stub (side), stairs (right),
resonance-door (closed).

No text labels, no tile names. Pixel grid 16x16 base, seamless
tileable, crisp readable silhouette for 2D platformer gameplay.
```

**size**: `1024x1024` (tile 概念参考)
**rationale**: A012 是 A020 tileset proxy 派生源, 16 tile 覆盖 archive_01-04 全部.

---

### J011 — A013 声档案道具与拾取物 (prop_sheet_8)

**prompt**:

```
[shared-prefix] Prop production concept sheet, 8 distinct props in
horizontal row, 256x256 each, total 2048x256. All props share Voxglass
visual language: glass cyan edge highlights, amber voice glow core,
muted violet shadows. 8 props left-to-right:

1) voice bell (intact, warm amber voice glow, 32x32)
2) resonance shard (small diamond-shaped, amber top, 16x16)
3) silence stain (dark splat on stone floor, muted violet, 32x32)
4) lock (mechanical key-lock with archive blue body, glass cyan
keyhole, 32x32)
5) switch (lever-style archive blue handle, glass cyan highlight,
32x32)
6) relic (ancient glass orb with internal waveform pattern, amber
glow, 32x32)
7) key charm (small hanging trinket, glass cyan + amber, 16x16)
8) save lantern (glass bell-shaped lantern, amber body, dim when
inactive, 24x32)

No text labels, no prop names. Isolated on white background, 1px
black outline where appropriate.
```

**size**: `2048x256` (8 prop 横排)
**rationale**: A013 是 prop 拾取物生产参考, 8 prop 覆盖 save system + 拾取 + 互动.

---

### J012 — A014 共鸣 VFX 帧参考 (vfx_sheet_6)

**prompt**:

```
[shared-prefix] VFX frame reference sheet, 6 distinct effects in
horizontal row, 256x256 each, total 1536x256. All effects on dark ink
navy background to show contrast. 6 effects left-to-right:

1) pulse ring: 3 concentric expanding rings, coral inner, amber mid,
cyan outer, motion blur on outer edge
2) waveform projectile: zig-zag line with sparkles, coral pulse
linear shape with pale resonance trailing particles
3) glass sparkle: cluster of 4-pointed stars in glass cyan and pale
resonance, scattered randomly
4) repair bloom: radial warm amber voice burst, glass cyan radial
rays, sparkle dust
5) smoke: muted violet cloud puff, irregular shape, semi-transparent
6) hit shards: 4 small glass cyan and pale resonance triangular
fragments, scattered angular pattern

No text labels, no effect names. 4-frame animation strip suggested
within each cell (faint vertical divisions).
```

**size**: `1536x256` (6 VFX 横排)
**rationale**: A014 是 T007 程序化/手绘混合特效参考, 6 VFX 覆盖 5 verb + 通用 hit.

---

### J013 — A015 Voxglass HUD/UI 套件 (ui_kit)

**prompt**:

```
[shared-prefix] UI kit reference, 16:9 full-screen layout showing all
HUD components in correct positions, 1280x720 total. All UI uses thin
brass amber top accent line, dark glass background, glass cyan border,
no heavy fantasy frames. Components:

Top-left: health bar (3 glass bell segments, glass cyan filled, pale
resonance glint, 6px height)
Top-center: resonance meter (horizontal bar, amber voice fill, glass
cyan ticks, 8px height)
Top-right: 5 verb icon slots (32x32 each, glass cyan ring, amber voice
core, dark disc background)
Center-left: 4 relic slots (24x32 each, archive blue border, glass
cyan highlight when active)
Bottom: dialog frame (480x70, dark ink navy glass, portrait slot on
left 64x64, text area on right with thin brass amber top accent)
Bottom-right: mini-map (80x80, archive blue background, glass cyan
room markers)

No text labels, no component names. UI ready for direct implementation
in src/scenes/hud.tscn.
```

**size**: `1280x720` (16:9 UI 套件)
**rationale**: A015 是 UI 实现优先参考, 替代 A005 早期 UI 样本, 覆盖 health + resonance + 5 verb + relic + dialog.

---

## §tier-3-prompts (9 张 in-game 资产)

### J014 — A016 Hub NPC 角色表 (npc_sheet_6)

**prompt**:

```
[shared-prefix] NPC character concept sheet, 6 distinct NPCs in
horizontal row, 256x512 each, total 1536x512 (taller format for full
body). All NPCs share Voxglass visual language but distinct silhouettes.
6 NPCs left-to-right:

1) archivist: elderly scholar, white hair bun, round glasses, holding
amber lantern, deep archive blue robe, warm parchment skin
2) lost singer: young woman with torn glass dress, cyan glow in
throat, sad eyes, tattered sound-wave scarf
3) ferryman: tall cloaked figure with wooden pole, hooded face, single
amber eye visible, glass cyan cloak hem
4) tuner automaton: mechanical doll with single gear eye, glass tube
device on back, antenna, cold cyan glow, deep teal metal body
5) rival: teenage girl with cracked sound-box on right arm, smug
expression, archive blue jacket, glass cyan highlights
6) silent merchant: hooded figure with closed eyes, dark cloak, warm
amber scarf glimpse (matches A053 sprite)

No text labels, no NPC names. Full body standing pose each, distinct
silhouettes for instant recognition.
```

**size**: `1536x512` (6 NPC 横排, 每格 256x512)
**rationale**: A016 是 Hub NPC 方向探索, 6 NPC 覆盖 #36/#41/#68+#130 现有 4 个 portrait + 2 个未来扩展位.

---

### J015 — A017 关卡背景组 (background_set_4)

**prompt**:

```
[shared-prefix] 4 distinct level background concepts in horizontal row,
512x512 each, total 2048x512. All backgrounds parallax-ready, no
characters, no UI. Deep ink navy to archive blue gradient dominant.
4 backgrounds left-to-right:

1) drowned entrance hall: stone stairs descending into shallow water,
single broken arch framing distant cyan glow, hanging cable stubs
2) bell archive stacks: towering 3-story bell stacks with glass voice
bells, narrow walkways between, dim warm amber glow from random bells
3) silent waterworks: rusted water wheel mechanism half-submerged,
dripping pipes, glass cyan algae glow on stone, sparse amber emergency
lantern
4) resonance chapel: vaulted ceiling with central cracked glass dome,
beam of pale resonance light piercing through dome center, rows of
silent bells on either side

No text labels, no location names. Atmospheric depth, multiple parallax
layers suggested, no characters.
```

**size**: `2048x512` (4 背景横排, 每格 512x512)
**rationale**: A017 是后续章节视觉参考, 4 背景对应 4 章节, 未来 archive_05+ 用.

---

### J016 — A020 回声档案馆 Tileset Proxy (tileset_pixel_seamless)

**prompt**:

```
[shared-prefix] Seamless tileable pixel art tileset, 512x512 canvas,
16x16 pixel grid (32x32 visible tiles). Voxglass flooded underground
archive tileset: cracked stone floor tiles, wet reflective surfaces,
glass bell fragments, hanging cable stubs, shallow water puddles, deep
ink navy and muted teal palette, sparse amber waveform glow accents.
Tile categories evenly distributed across the 16x16 grid:

- 8 floor tile variations (clean / cracked / wet / corner / edge / T-
joint / cross / center)
- 4 wall tile variations (top / side / corner / arch-base)
- 2 water tile variations (shallow / deep)
- 1 glass spike (top, vertical)
- 1 cable stub (side, hanging)
- 1 stairs tile (right-side ramp)
- 1 resonance door tile (closed arch)

Seamless on all 4 edges, pixel-perfect tile boundaries, 1px black
outline where appropriate.
```

**size**: `512x512` (16x16 像素 grid, seamless tileable)
**rationale**: A020 是 T005 灰盒房间 tileset, 16x16 基础 tile + 17 变体覆盖 archive_01-04 全部.

---

### J017 — A021 回声档案馆房间背景 (room_background)

**prompt**:

```
[shared-prefix] Single-room background, 480x270 (project internal
resolution 16:9), parallax-ready, 3 depth layers. Voxglass flooded
underground archive room:

- Far background (parallax 0.1x): deep teal mist, distant stone arches
fading to silhouette, single hanging voice bell glowing dim amber
- Mid background (parallax 0.3x): cracked stone wall with hanging
cable stubs, 1 broken arch on right side, shallow water reflection on
floor
- Foreground (parallax 0.5x): 1 standing lantern (archive blue
column, amber voice glass, warm parchment wick), 1 hanging bell on
left arch, scattered glass shard fragments on stone floor

No characters, no UI, no text. Lighting: low-intensity cyan-blue
ambient from water surface, accent warm amber glow from lantern and
hanging bell.
```

**size**: `480x270` (项目内部分辨率 16:9)
**rationale**: A021 是 archive_01 房间背景, 匹配项目内部分辨率 + 3 层 parallax.

---

### J018 — A022 Silence Mote 敌人精灵 (enemy_sprite_silence_mote)

**prompt**:

```
[shared-prefix] Single enemy sprite, silence mote, isolated on white
background, 1024x1024 (high-res, will be downsampled to 32x32 and
64x64 in-engine). Small floating ink blob creature, 32x32 gameplay
size scaled up: torn fabric edges, 3 tentacle-like wisps trailing
downward, single warm amber core eye in center, negative silhouette
shape, deep ink navy body with muted violet corrosion edges, sparse
glass cyan edge highlights, coral pulse warning glow ring around body
when agitated. 1px black outline, crisp readable silhouette for 2D
platformer gameplay. Single sprite, no animation frames.
```

**size**: `1024x1024` (高分辨率版, 后续可降采样到 32x32 + 64x64)
**rationale**: A022 是 T013 产出, 32x32 游戏内精灵, 重绘版用 1024x1024 源后降采样更清晰.

---

### J019 — A023 Voice Bell 破损状态 (prop_voice_bell_broken)

**prompt**:

```
[shared-prefix] Single prop sprite, cracked voice bell in broken
state, isolated on white background, 1024x1024 (high-res, will be
downsampled to 32x32 and 64x64 in-engine). Hanging bell-shaped glass
vessel, 32x32 gameplay size scaled up: deep fractures across surface
visible as 4-5 jagged lines, dim muted violet interior visible
through cracks, glass cyan edge barely glowing, ink navy shadows
under bell, simple 4px rope at top attaching to ceiling. 1px black
outline, crisp readable silhouette. Single sprite, no animation.
```

**size**: `1024x1024` (高分辨率版)
**rationale**: A023 是 T013 道具拾取物, 32x32 道具, 与 A024 修复态配对形成完整状态切换.

---

### J020 — A024 Voice Bell 修复后状态 (prop_voice_bell_repaired)

**prompt**:

```
[shared-prefix] Single prop sprite, voice bell in repaired state,
isolated on white background, 1024x1024 (high-res, will be downsampled
to 32x32 and 64x64 in-engine). Hanging bell-shaped glass vessel,
32x32 gameplay size scaled up: NO fracture lines (repaired), warm
amber voice glow from within filling entire bell, glass cyan edges
brightly lit, subtle waveform pattern inside (3 horizontal sine
waves), floating resonance particles (3 small glass cyan dots
orbiting bell), 4px rope at top attaching to ceiling. 1px black
outline, crisp readable silhouette. Single sprite, no animation.

Compared to broken state (A023): same shape, fractures removed, glow
intensity 3x, waveform pattern added, particles added. Direct before/
after visual pair with A023.
```

**size**: `1024x1024` (高分辨率版)
**rationale**: A024 与 A023 配对形成修复前后对比, 直接影响 gameplay 状态切换视觉.

---

## §execution-prerequisites (执行前置条件)

```bash
# 1. 设置 ARK API Key (三选一, 按优先级)
export ARK_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# 或
export MODEL_IMAGE_API_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# 或
export MODEL_AGENT_API_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# 2. (可选) 自定义 API Base URL
export ARK_BASE_URL="https://ark.cn-beijing.volces.com/api/v3"

# 3. 验证环境
python3 -c "import os; assert any(k in os.environ for k in ['ARK_API_KEY', 'MODEL_IMAGE_API_KEY', 'MODEL_AGENT_API_KEY']), 'no API key set'"

# 4. 跑 dryrun 验证 index + prompts 一致
python3 tools/seedream_redraw_dryrun.py

# 5. 跑 tier 1 (营销关键 5 张)
bash tools/seedream_redraw_runner.sh --tier 1

# 6. 跑 tier 2 (生产表 7 张)
bash tools/seedream_redraw_runner.sh --tier 2

# 7. 跑 tier 3 (in-game 资产 9 张, 含 A002 skip)
bash tools/seedream_redraw_runner.sh --tier 3

# 8. 重生 Godot 资源导入
godot --headless --import

# 9. 跑 I020 冒烟测试 (新)
godot --headless --path . --script res://tools/test_i020_f022_seedream_redraw_smoke.gd
```

---

## §cost-estimate (成本估算)

| 模型 | 单图时间 | 21 张总时间 | 适用场景 |
|------|---------|-----------|---------|
| 5.0 (推荐) | 8-12s | 3-5 min | 高质量营销图 (J001-J005, J014-J015) |
| 4.5 | 3-5s | 1.5-2.5 min | 平衡方案, 大部分资产 |
| 4.0 | 1.5-2s | 0.5-1.0 min | 快速验证, 降采样源 |

**推荐 tier 配置**:
- Tier 1 (5 张营销): 全部用 5.0 (8s × 5 = 40s, 顶级质量)
- Tier 2 (7 张生产表): 全部用 4.5 (5s × 7 = 35s, 性价比)
- Tier 3 (9 张 in-game): 全部用 4.0 (2s × 9 = 18s, 快速)

总预算: 40s + 35s + 18s = **93s ≈ 1.5 min** 即可完成全部 21 张重绘.

---

## §revision-history (修订历史)

- **#108 (2026-06-18 23:00)**: F022 提上日程, 创建 prompt 库 21 张 + index + runner + dryrun (本轮)
- **#109+ (待执行)**: 实际跑 Seedream API, 分 3 tier 提交, 落地 I020 冒烟测试

