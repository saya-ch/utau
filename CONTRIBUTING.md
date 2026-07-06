# Contributing to Voxglass

> 本仓库由「自动化迭代 Agent」+ 协作者共同维护。本指南面向人工协作者，介绍如何本地启动 Godot 4.6.3 工程、跑冒烟测试、按节奏提交。

## 1. 仓库结构（30 秒总览）

```
/workspace
├── ITERATION_GUIDE.md       # Agent 必读；本指南与之互补
├── ROADMAP.md / CHANGELOG.md / REVIEW_LOG.md   # 项目状态三件套
├── STYLE_GUIDE.md / ASSET_REGISTRY.md / RESEARCH.md / INSPIRATION.md
├── README.md / README.zh-CN.md                # 玩家 + 营销
├── project.godot                              # Godot 4.6.3 工程
├── godot/                                     # Godot 二进制（拆分 ZIP + README）
├── data/                                      # 房间 JSON / 成就 / 商店目录
├── assets/                                    # 美术（按 character/enemies/ui/... 分目录）
├── src/
│   ├── autoload/                              # GameState / PlayerStats / SaveSystem / ScreenShake / AudioManagerEnhanced
│   ├── scripts/                               # 玩家 / 敌人 / 能力 / UI 等
│   └── scenes/                                # .tscn 场景
├── tools/                                     # 冒烟测试（test_*.gd）+ 辅助脚本
├── docs/                                      # 截图、Steam 描述
└── CHANGELOG.md / REVIEW_LOG.md               # 历史审计
```

> **状态文件宪法**：每轮迭代后必须更新 `ITERATION_COUNT.txt` / `ROADMAP.md` / `CHANGELOG.md` 三件套；新素材登记到 `ASSET_REGISTRY.md`；风格变更写 `STYLE_GUIDE.md`。

## 2. 首次启动（必做）

### 2.1 拼合 Godot 二进制

仓库内 Godot 4.6.3 headless binary 是拆分 ZIP 格式，**首次拉取后必须拼合**：

```bash
# 方法 A：unzip（标准）
cd /workspace/godot
cat Godot_v4.6.3-stable_linux.z01 \
    Godot_v4.6.3-stable_linux.z02 \
    Godot_v4.6.3-stable_linux.z03 \
    Godot_v4.6.3-stable_linux.z04 \
    Godot_v4.6.3-stable_linux.zip > /tmp/godot_full.zip
unzip -o /tmp/godot_full.zip
chmod +x Godot_v4.6.3-stable_linux.x86_64

# 方法 B-1：unzip -FF 强容错（沙箱 / Python 3.14+ 推荐）
unzip -FF -o /tmp/godot_full.zip

# 方法 B-2：Python zipfile 兜底（**仅 Python ≤ 3.13 有效**）
# ⚠️ Python 3.14+ zipfile 库已无法解压多卷 zip（BadZipFile），用 B-1 替代
python3 -c "import zipfile; zipfile.ZipFile('/tmp/godot_full.zip').extractall('/workspace/godot/')"
```

验证：

```bash
/workspace/godot/Godot_v4.6.3-stable_linux.x86_64 --version
# 期望: 4.6.3.stable.official.7d41c59c4
```

### 2.2 生成 .import 缓存

⚠️ **必须先跑一次 `--import`**，否则 PNG 资源加载失败并级联触发 8+ 个 SCRIPT ERROR：

```bash
timeout 60 /workspace/godot/Godot_v4.6.3-stable_linux.x86_64 \
    --headless --import --path /workspace
```

### 2.2.1 新建 `class_name` 脚本后必须再跑一次 `--import`（#91 F008 经验）

⚠️ **每新建一个带 `class_name` 的脚本（特别是 `extends Node2D` 等用于场景的脚本）后，Godot 必须重新跑一次 `--import` 才能生成有效的 `<script>.gd.uid` 文件。** 否则 `.uid` 会以 0 字节空文件落盘，Godot 4.6.3 加载时产生"无法解析 UID"良性告警，并可能在后续 inspector 中失联。

症状：

```bash
$ ls -la src/scripts/<your_new_windup_vfx>.gd.uid
-rw-r--r-- 1 ... 0 Jun 10 12:00 <your_new_windup_vfx>.gd.uid   # ⚠️ 0 字节！
```

修复（#90 L001 已踩过）：

```bash
rm src/scripts/<your_new_windup_vfx>.gd.uid
timeout 60 /workspace/godot/Godot_v4.6.3-stable_linux.x86_64 \
    --headless --import --path /workspace
# 重测：ls -la <your_new_windup_vfx>.gd.uid  应为 20 字节
# 重测：cat <your_new_windup_vfx>.gd.uid  头部应是 "uid://" 前缀
```

触发场景（按出现频率排序）：

1. **新 `class_name` 脚本**（`bind_windup_vfx.gd` / `echo_windup_vfx.gd` / `wave_windup_vfx.gd` / 任何 VFX / Autoload 候选）— `uid_cache.bin` 还未注册
2. **重命名 `class_name`**（`is_wave_globally_blocking` → `is_action_globally_blocked` T145 #76）— 旧 `.uid` 文件需要重新生成
3. **跨轮迁移 `class_name` 跨多个 .gd 文件**（如 F005 / F006 / F007 系列 refactor）— 多个 `.uid` 同步失效

预防：

- 新建 `class_name` 脚本后，**先跑 `--import`，再 `git add`**
- 提交前 `ls -la src/scripts/*.gd.uid | awk '$5 == 0 {print}'` 扫 0 字节文件
- `check_smoke_consistency.sh` rule ⑥ 会统计 `<50 字节` 的 `.uid`（含 0 字节），可作为 CI 钩子

### 2.3 启动编辑器（可选）

无 GUI 环境跳过此步；本地开发可：

```bash
/workspace/godot/Godot_v4.6.3-stable_linux.x86_64 --path /workspace
```

## 3. 质量自检（提交前必跑）

### 3.1 静态语法检查

```bash
GODOT=/workspace/godot/Godot_v4.6.3-stable_linux.x86_64
timeout 15 $GODOT --headless --quit --path /workspace 2>&1 \
    | grep -E "SCRIPT ERROR|Parse Error|GDScript" \
    | head -10
```

判定：
- **无输出** → 通过
- **有 ERROR 行** → 必须先修复再继续

### 3.2 运行时冒烟

```bash
timeout 30 $GODOT --headless --path /workspace 2>&1 | tail -10
```

期望：进入 main scene 跑一帧后退；除已知 `ObjectDB / RID leak` 退出提示外无 ERROR / WARNING。

### 3.3 冒烟测试套件（32 个，1~3 分钟）

本仓库自带 32 个 `test_*.gd` 冒烟测试，覆盖核心系统的回归基线（#80 时 32 个，自 #75 增 4 个：T141+T142+T143/T145/T146+T144/T148/T154+T150/T147/T149+T152/T153/T151）：

| 测试脚本 | 覆盖 | 来源 |
|---------|------|------|
| `tools/test_echo_smoke.gd` | EchoAbility 类签名 + 9 个 @export | #51 T094 |
| `tools/test_echo_vfx_smoke.gd` | EchoVFX trigger/bounce + 5 帧 _draw | #51 T095 |
| `tools/test_echo_radius_bonus_smoke.gd` | GameState echo_radius_bonus + shop 笔误修复 | #52 T096 |
| `tools/test_t088_save_slots_smoke.gd` | SaveSystem SLOT_COUNT=5 + list/card 视图 | #55 T088 |
| `tools/test_t098_t100_smoke.gd` | 4 动词 flash_color 色域 + PauseMenu Echo row | #53 T098/T100 |
| `tools/test_t103_resonance_wave_smoke.gd` | ResonanceWave 群体波第一半（5 verb 色域 + 8 @export + 3 signal）28 项 | #73 T103 |
| `tools/test_t103_wave_second_half_smoke.gd` | Wave 5-verb 对称（HUD/settings/pause/shop/成就）10 项 | #74 T103 |
| `tools/test_t105_save_progress_smoke.gd` | SaveLoadMenu 4 房间进度时间线 | #56 T105 |
| `tools/test_t107_archive_storm_smoke.gd` | archive_storm BGM tier-3 preset 字段 + InkWarden phase 2 引用 | #59 T107 |
| `tools/test_t109_achv_timestamp_smoke.gd` | 成就解锁时间戳 + 排序 + 持久化 | #57 T109 |
| `tools/test_t112_respawn_hub_e2e_smoke.gd` | 死亡回 Hub T079 端到端 13 项断言 | #58 T112 |
| `tools/test_t114_t115_t116_death_ux_smoke.gd` | silence_void BGM + 死亡碑文 + InkWarden 残影 | #61 T114-116 |
| `tools/test_t117_finale_smoke.gd` | silence_void → archive_dawn finale 曲式 15 项 | #62 T117 |
| `tools/test_t121_t118_audio_presets_smoke.gd` | audio_presets.gd 重构 + whisper_hollow 13 字段 | #63 T121/T118 |
| `tools/test_t122_t123_t124_smoke.gd` | IntroCutscene ambient + whisper_hollow 路由 + 9-主题色板 | #64 T122-124 |
| `tools/test_t126_player_profile_smoke.gd` | PauseMenu PlayerProfilePanel 节点 + 10 个 @onready + 6 方法 + 8 标签 + 信号连接 + PlayerStats 字段 10 项 | #66 T126 |
| `tools/test_t127_run_history_smoke.gd` | PlayerStats run_number + 4 项 _best_stats + HISTORY_PATH 持久化 + 防御性副本 + 单调更新 12 项 | #67 T127 |
| `tools/test_t128_crc32_smoke.gd` | SaveSystem CRC32 校验和 (IEEE 0xEDB88320) + 包装层 + legacy 兼容 + get_save_integrity 5 状态 10 项 | #67 T128 |
| `tools/test_t129_save_integrity_smoke.gd` | SaveLoadMenu 3 健康度 BBCode 颜色 + corrupted 禁用 LoadBtn | #68 T129 |
| `tools/test_t130_best_achievements_smoke.gd` | PlayerStats best_stat_threshold 4 成就 (long_road / archive_master / resonance_hoarder / silence_hunter) | #68 T130 |
| `tools/test_t131_run_trends_smoke.gd` | PlayerStats _run_history FIFO cap 20 + get_recent_runs + get_recent_runs_average | #69 T131 |
| `tools/test_t132_copy_slot_smoke.gd` | SaveSystem.copy_slot byte-level 备份/恢复 4 边界 + 2 emit | #69 T132 |
| `tools/test_t133_t134_quick_stats_smoke.gd` | PauseMenu Quick Stats 摘要行 (BBCode 三色) + settings 动态 SLOT_COUNT 12 项 | #71 T133/T134 |
| `tools/test_t135_share_smoke.gd` | PauseMenu 分享剪贴板 3 行结构 + DisplayServer 守卫 12 项 | #72 T135 |
| `tools/test_t136_autosave_smoke.gd` | SaveSystem 自动存档 5 常量 + Timer ALWAYS + 6 skip 场景 + 4 状态 12 项 | #72 T136 |
| `tools/test_t137_t138_persistence_smoke.gd` | SaveSystem._last_autosave_unix + QuickLoadButton + PauseMenu HH:MM:SS 17 项 | #73 T137/T138 |
| `tools/test_t141_wave_hit_audio_smoke.gd` | wave hit SFX 1320Hz 基频 + 2.4x 谐波 + 50ms throttle 9 项 | #75 T141 |
| `tools/test_t142_wave_chain_block_smoke.gd` | is_action_globally_blocked() 公开 helper + 4 verb handler + jump buffer 10 项 | #75-76 T142/T145 重命名 |
| `tools/test_t143_t145_t146_smoke.gd` | wave 4 状态提示 + is_action_globally_blocked 重构 + wave_combo 屏震 25 项 | #76 T143/T145/T146 |
| `tools/test_t144_t148_t154_smoke.gd` | wave_focus 4 谐波 + chime tail E6+G#6 + 灯反向闪 26 项 | #78 T144/T148/T154 |
| `tools/test_t150_t147_t149_smoke.gd` | 5 动词 profile + jump UX + Echo parallax 22 项 | #77 T150/T147/T149 |
| `tools/test_t152_t153_t151_smoke.gd` | 0 数灰阶 + 槽位 jingle pentatonic + "最近" badge 19 项 | #79 T152/T153/T151 |

跑全部：

```bash
GODOT=/workspace/godot/Godot_v4.6.3-stable_linux.x86_64
for f in tools/test_*.gd; do
    echo "=== $f ==="
    timeout 30 $GODOT --headless --path /workspace -s "$f" 2>&1 | tail -15
done
```

每条 `=== ... smoke test PASSED ===` 出现即为通过。新增模块时请同步加 1 个 `test_Txxx_*.gd`（模板见任一既有测试）。

### 3.4 冒烟测试一致性检查（#66 引入，10s）

为防止 #63 T121 重构后的类型漂移（D001：4 个测试用旧路径访问 `_MUSIC_PRESETS`），本仓库新增 `tools/check_smoke_consistency.sh` 一致性检查脚本，验证：

1. `src/scripts/audio_presets.gd` 是 `_MUSIC_PRESETS` / `_BOSS_MUSIC_TIER` 的唯一规范源
2. `src/scripts/audio_manager_enhanced.gd` 没有内联 `_MUSIC_PRESETS := {` / `_BOSS_MUSIC_TIER := {` 旧形式
3. 使用 `AudioPresets.MUSIC_PRESETS` / `.BOSS_MUSIC_TIER` 运行时访问的测试必须 `const AudioPresets = preload("...audio_presets.gd")` 在文件顶部
4. 使用 `SRC_PRESETS` 路径常量的测试（T114 形式）仍合法
5. 旧 `ame_script._MUSIC_PRESETS` / `.BOSS_MUSIC_TIER` 访问模式被显式拒绝

跑法：

```bash
tools/check_smoke_consistency.sh
# 期望最后一行: [OK] No consistency errors. (0 warnings)
#             Safe to commit.
# 或         : [FAIL] N consistency error(s) found
```

未来对 `_MUSIC_PRESETS` / `_BOSS_MUSIC_TIER` / `AudioPresets.*` 的任何重构都应**先跑**本脚本，确认 0 错误。

## 4. 提交格式

```bash
git add -A
git commit -m "iteration:<主题> | tasks:<ID> | skills:<列表> | status:<通过/失败>"
```

示例：

```
iteration:T109 玩家成就解锁时间戳 + PauseMenu 排序 | tasks:T109 | skills:frontend-skill | status:通过
```

约束：
- 1~3 个任务 / commit
- 单 commit 改动集清晰可回滚
- 严禁把 Token / API Key 写入仓库

## 5. 迭代节奏

| 节点 | 频率 | 内容 |
|------|------|------|
| 正常迭代 | 每整点 | 选 1~3 个 ROADMAP 任务，执行 + 自检 + 提交 |
| 审查模式 | N%5==0 | 仅做审计（~30min）+ 轻微修复（~25min）；不开发新功能 |
| 新增任务模式 | ROADMAP 全清 | 从 RESEARCH/INSPIRATION/ASSET_REGISTRY 找候选；审查候选 1~2 项落地 |

Agent / 协作者应严格遵守「无状态迭代」：所有上下文来自仓库状态文件，**不依赖对话历史**。

## 6. 美术资源登记

新素材生成后**必须**登记 `ASSET_REGISTRY.md`：

```
| ID | 名称 | 类型 | 风格 | 模型 | Seed | Subject | 状态 | 路径 | 备注 |
```

约束：
- **生成前**：查复用（避免重复）/ 新 seed = `max(existing_seed) + 1` / 继承 prompt 措辞
- **状态**：APPROVED / PLACEHOLDER / REJECTED / DEPRECATED
- **REJECTED 累计 3 次** → 放弃该 seed，换方案或降级

## 7. 文档同步

每次 commit 前自问 5 问：

1. `ROADMAP.md` 中本轮任务已勾选 `- [x]`？
2. `CHANGELOG.md` 顶部追加了新条目（含日期时间、#N、主题、skills、任务ID）？
3. `ITERATION_COUNT.txt` 已 +1？
4. 有新素材 → `ASSET_REGISTRY.md` 追加？
5. 有风格变更 → `STYLE_GUIDE.md` 更新？

漏一项 = 不算完整迭代。

## 8. 故障排查速查

| 症状 | 修复 |
|------|------|
| `No loader found for resource: res://...png` | 跑 `godot --headless --import --path /workspace` |
| 8+ 个 SCRIPT ERROR 在静态检查时冒出 | 通常是 PNG .ctex 缓存缺失 → 同上 |
| `<script>.gd.uid` 0 字节（**L001 #90**）| 新建 class_name 脚本后未跑 `--import`；`rm <uid>` + 重跑 `--import` 修复（详见 §2.2.1） |
| `unzip: bad zipfile offset` | 改用方法 B-1 `unzip -FF` 强容错兜底（见 2.1） |
| `BadZipFile: Bad magic number for file header`（Python 3.14+ zipfile）| 改用方法 B-1 `unzip -FF`，不要用 Python zipfile |
| `ObjectDB instances leaked at exit` | Godot 4.6 已知非致命警告，可忽略 |
| Player 移动但没动画 | `_setup_spriteframes()` 缺资源；查 console `[PlaceHolder sprite missing]` |
| 成就通知不显示 | 检查 `AchievementNotification` 是否在 PauseMenu / Title 屏实例化 |

## 9. 添加第 6 声波能力（F013.D #116 接入路径）

> 5 verb (Pulse / Bind / Cut / Echo / Wave) 全部继承自 `VerbAbilityBase` 父类（#98 D002.B）。
> 第 6 verb 接入路径已**结构化文档化**，避免在 5 处分散修改时漏掉任何一步。

### 9.1 接入步骤（按顺序，9 步）

1. **新 GDScript 文件** `src/scripts/<verb_name>_ability.gd`（参考 `pulse_ability.gd`）：
   ```gdscript
   class_name XxxAbility
   extends "res://src/scripts/_verb_ability_base.gd"
   
   signal xxx_fired(origin: Vector2, radius: float)
   signal xxx_hit(target: Node)
   signal xxx_blocked
   
   @export var xxx_radius: float = 60.0
   @export var xxx_cost: int = 35
   # `cooldown` / `windup_time` 已由 VerbAbilityBase 提供（不要重声明！）
   @export var xxx_active_time: float = 0.15
   @export var xxx_damage: int = 1
   
   func _ready() -> void:
       super._ready()
       # verb-specific perk application（pulse_kill_refund 等）
   
   func _process(delta: float) -> void:
       _process_cooldown(delta, "xxx")  # T181 jingle
   ```

2. **player.tscn 节点**：在 `[node name="XxxAbility" ...]` 段加 `script = ExtResource(...)` + `cooldown = X.X` + `windup_time = 0.XX`（5 verb 现役值：Pulse 0.5/0.1, Bind 1.2/0.1, Cut 0.8/0.06, Echo 4.0/0.08, Wave 6.0/0.1）

3. **project.godot Input Map**：新增 `[input] action = { ... }` 与 `echo` / `wave` 不冲突的键位（5 现役：J/K/L/Q/V），建议优先级 ≥ 5 verb

4. **STYLE_GUIDE.md 色板段**：在「5 动词色域」表加一行 `<verb> = <#hex>  <verb 主题色>`（5 现役：Pulse #E86D5A Coral / Bind #65506A Violet / Cut #F2B66E Amber / Echo #69C7CE Cyan / Wave #B7E6DC Pale Resonance）

5. **player.gd _handle_*** + `_on_<verb>_fired` / `_on_<verb>_hit` handler 5 段（参考 `_on_wave_fired` 模式）：
   - 失败：调 `hud.show_<verb>_blocked()`（参考 hud.gd）
   - 成功：spawn vfx (preload vfx_script) + add_child current_scene + ScreenShake.flash_color + ScreenShake.vibrate
   - 命中：add_hit_flash 0.20s 暖色

6. **vfx script + .tscn**：参考 `wave_vfx.gd` / `wave_windup_vfx.gd`，命名 `<verb>_vfx.gd` + `<verb>_windup_vfx.gd`

7. **PlayerStats 6 个字段 + 1 method**：
   - `<verb>_used: int = 0` (autoload 字段)
   - `record_<verb>_used()` (GDScript 增量)
   - get_recent_runs / get_unlocked_achievements 引用新字段
   - achievements.json 加 `<verb>_master` 成就（累计 50 次用 X verb 解锁）

8. **PauseMenu 4 处同步**：
   - `pause_menu.gd::_stat_abilities` / `_profile_abilities` BBCode 5 → 6 动词 row（`[color=<hex>]<Verb> %d[/color]`）
   - `pause_menu.gd::_VERB_HINT_DATA` 数组加第 6 元素（key/name_zh/name_color/cost/cooldown_s/radius_px/desc_zh）
   - `pause_menu.gd::_profile_last_verb` match 段加 `<verb>` 分支
   - `pause_menu.tscn` 节点位置无需变（BBCode 自适应），`bbcode_enabled = true` 已预设

9. **冒烟测试** `tools/test_i025_t199_f013d_smoke.gd`：本轮已提供 5 字段示例（T199 `_VERB_HINT_DATA` 5 verb 元素 + T199 `_build_verb_hint_tooltip` 5 行 + F013.D 接入路径 §9.1 9 步存在）

### 9.2 易错点（按历史回归频率排序）

- **重声明 `cooldown` / `windup_time`**：H001 #99 hotfix 修复的 5 回归点。`VerbAbilityBase` 已声明，subclass 不要 `@export` 同名字段
- **漏调 `super._ready()` / `super._exit_tree()`**：base class 自动 resolve `_player` + 清理 `_windup_vfx`
- **toolbar / pause 漏加新 verb 颜色**：6 处表层（HUD 5+1 冷却条 / 屏震 flash / PauseMenu 5+1 动词行 / 商店 echo_charm / 成就图标 / quintuple_voice 6+1 词）必须全更新
- **不更新 `_VERB_HINT_DATA`**：T199 tooltip 会少一行
- **input action 冲突**：5 现役用 J/K/L/Q/V；第 6 建议 B/N/M/X 之一

### 9.3 验证清单

```bash
# 静态解析
GODOT=/workspace/godot/Godot_v4.6.3-stable_linux.x86_64
timeout 15 $GODOT --headless --quit --path /workspace 2>&1 \
    | grep -E "SCRIPT ERROR|Parse Error|GDScript" | head -10
# 期望: 无输出

# 冒烟测试
tools/test_i025_t199_f013d_smoke.gd  # 含 5 verb 锚点 + 9 步路径断言
```

## 9.5 已知 fragility（避免 polish 期重踩同类坑）

> 本节记录历史上踩过的"polish 加新字段但忘记声明"类 pre-existing parse error。T246 (#163) 修复 `_VERB_ROW_BASE_FONT_COLOR` (T244 #161 残留) 是首个显式记录项，未来同类问题应先查本节。

### 9.5.1 `_VERB_ROW_BASE_FONT_COLOR` 残留（L246 #163 修复）

- **症状**：`src/scripts/pause_menu.gd:1944` (Tween target) 引用 `_VERB_ROW_BASE_FONT_COLOR`，但 T244 (#161) 引入时**只引用不声明**，触发 Godot 4.6.3 静态解析 `Parse Error: Identifier "_VERB_ROW_BASE_FONT_COLOR" not declared in the current scope.`。
- **触发场景**：polish 期给已有 Label 加 `mouse_entered` / `mouse_exited` handler，需要"渐到 base font_color"时直接引用了一个未声明的 const 名字。
- **修复**：在 `src/scripts/pause_menu.gd` line 145 之后加 1 行 const 声明 `const _VERB_ROW_BASE_FONT_COLOR := Color(0.875, 0.835, 0.784, 1.0)` + 注释锚点（Voxglass Warm White 与 pause_menu.tscn StatRows 同源）。
- **预防**：
  1. polish 期加新 const / var 前先在文件头部 const 块集中声明（pause_menu.gd 已有 const 块约定）；
  2. 加完新引用后**必须**跑 `godot --headless --quit --path /workspace 2>&1 | grep -E "SCRIPT ERROR|Parse Error|GDScript"` 静态解析（**注意**：仅跑 `--quit` 不一定 reload autoload scripts，需要 `godot --headless --import --path /workspace` 完整 reload 才会暴露跨类引用问题）；
  3. hover / tooltip handler 类 polish 改动建议同时用 source-grep `_VERB_ROW_` 验证所有引用 const 都已声明。

### 9.5.2 ink_warden.gd 4 处标识符引用 preload 化（T243 #161 落地）

- **症状**：`src/scripts/ink_warden.gd:546/578/603/643` 引用 `RepairVFX` / `DamageNumber` 标识符，**走全局 class_name 解析**。
- **触发场景**：fresh clone 状态下 `.godot/` 缓存可能丢失，class_name 解析偶发 stale 标识符（虽然实际 class_name 都存在，0 SCRIPT ERROR，但 fresh clone hot-reload 鲁棒性 < 100%）。
- **修复**：文件顶部加 `const RepairVFX = preload("res://src/scripts/repair_vfx.gd")` + `const DamageNumber = preload("res://src/scripts/damage_number.gd")`，4 处 method call 引用 0 改。
- **预防**：任何 polish 期或重构期，对 `class_name` 跨类引用**优先**用 `preload` 显式静态解析，仅在 `var x = OtherClass.new()` 类延迟实例化场景保留 `class_name` 引用。

## 9.6 跨类 handler 接通模式（polish 链 VFX 玩家可读性强化段，#169 T251 落地）

> §9.5 记录「polish 加新字段但忘记声明」类 pre-existing parse error。本节记录 6 verb 闭环期间 (T242–T251) 反复出现的「跨类 handler 接通」模式：player.gd → 6 verb VFX 的 `_on_<verb>_hit` 通路。T251 (#169) 是该模式首个完整 5 verb + 1 verb 同源 100% 闭环，未来 polish 任何 verb hit 视觉反馈时先查本节。

### 9.6.1 跨类 handler `is_instance_valid + has_method` 双守卫（T251 #169 落地）

- **症状**：polish 期给已有 `_on_<verb>_hit` handler 加「VFX 命中闪烁」视觉反馈时，最常见的 stale 引用是「VFX 0.15s 后 queue_free，命中回调延迟触发时 `_current_<verb>_vfx` 已无效」或「headless 测试 0 autoload 实例化，handler 调 `.flash_hit()` 抛 `Invalid call. Nonexistent function`」。
- **触发场景**：`player.gd` 5 verb (Pulse / Bind / Cut / Echo / Wave) 既有 `_on_<verb>_hit` 模式 + 6 verb (Whisper) `pass` 占位，polish 期间需要把 `pass` 替换为调 `_current_<verb>_vfx.flash_hit(target.global_position)`。`_current_<verb>_vfx` 在 6 verb VFX 寿命 (0.15–1.0s) 结束后 `queue_free`，命中回调（跨帧）触发时可能遇 stale 引用。
- **修复**：`src/scripts/player.gd:849-851` 6 verb Whisper 接通采用「`is_instance_valid` + `has_method` 双守卫」：
  ```gdscript
  if _current_whisper_vfx and is_instance_valid(_current_whisper_vfx) \
          and _current_whisper_vfx.has_method("flash_hit"):
      _current_whisper_vfx.flash_hit(target.global_position)
  ```
  - `_current_whisper_vfx` truthy 守卫：避免 `null` 引用。
  - `is_instance_valid(_current_whisper_vfx)` 守卫：避免 0.15s `queue_free` 后 stale 引用（`_current_<verb>_vfx = null` 在 `_exit_tree` 兜底前可能有 1 帧 stale 状态）。
  - `has_method("flash_hit")` 守卫：headless 测试 `tools/test_*.gd` 通过 `--script` 直接跑 SceneTree 派生类时 0 autoload 实例化，guard 防止测试期静默抛错。
- **预防**：
  1. 任何 polish 期给 6 verb `_on_<verb>_hit` 加 VFX 视觉反馈时，**必须**用 `is_instance_valid` + `has_method` 双守卫模式，0 简化为 truthy 守卫。
  2. flash_hit 实现端（`whisper_vfx.gd:91-105` / `resonance_wave_vfx.gd:add_hit_flash`）应走 `_hit_flashes` 数组 append → `_process` 老化 → `_draw` 渲染模式（reversed 循环防 `remove_at` 索引错位），而非立即 `queue_redraw` 单帧画（避免 1 cast 命中多敌时 N 重叠闪烁掉帧）。
  3. 新增 verb (7th verb / 8th verb) 接入路径必须先在 F013.E §9.1 6 verb 接入路径扩展到 N verb 接入路径前，确认 `_on_<verb>_hit` handler 在 player.gd 已就位 + 6 verb 同源 guard 三件套已复制。

### 9.6.2 VFX 5 层视觉 (L1–L5) polish 模式（T251 #169 落地）

- **症状**：单个 VFX 类（`whisper_vfx.gd`）的 `_draw` 函数在 polish 期间反复添加新 layer (EDGE_HIGHLIGHT L3, HIT_FLASH L5)，最常见的 fragile 是「layer 添加顺序与 alpha 调制耦合」与「`sin(t * PI)` 起伏时序同步」。
- **触发场景**：6 verb VFX (Whisper constant 球) 5 层视觉 polish 链：
  - L1 OUTER_FILL (F013.E #159 落地, 1.00×R α0.18 球内柔光)
  - L2 SPHERE_RING (F013.E #159 落地, 1.00×R α0.85 球外 2px 描边)
  - **L3 EDGE_HIGHLIGHT (T251 #169 新增, 1.04×R α0.40 球外 1px 描边, 立体感「双层球面」)**
  - L4 CORE_DOT (F013.E #159 落地, 0.20×R αblink 球心)
  - **L5 HIT_FLASH×N (T251 #169 新增, Warm Parchment 2..4px α0.70 0.15s 衰减, 命中闪烁)**
  5 layer 同时存在时 `_draw` 函数中 5 个 `draw_*` 调用的 painter's order + 共享 `sin(t * PI)` 起伏时序必须严格保持一致，**任一 layer 改 alpha 公式会破坏 5 layer 整体节奏**。
- **修复**：`src/scripts/whisper_vfx.gd:108-150` `_draw` 函数中 5 layer 共享 `var t: float = clampf(_lifetime / _max_lifetime, 0.0, 1.0)` + 5 个 `var *_alpha: float = sin(t * PI) * <const>` 派生 alpha，禁止 layer 间直接复用 `ring_alpha`（HIT_FLASH L5 走 1.0 - age/life 而非 sin 起伏，必须独立计算）。
- **预防**：
  1. 任何 VFX `_draw` 函数的 5+ layer polish 必须**集中**在文件顶部 docblock 写明 5 layer 各自的作用 (L1 = ..., L2 = ..., L3 = ..., L4 = ..., L5 = ...) + alpha 公式（与 `sin(t * PI)` 的关系 / 独立公式）。
  2. layer 颜色变量 (`ring_color` / `fill_color` / `edge_color` / `core_color`) 必须**每个 layer 独立声明**，禁止 layer 间共享 color 变量。
  3. 5 layer alpha 公式集中块建议放在 `_draw` 函数体顶部 (~10 行), 下文 `draw_*` 调用直接使用这些 derived color, 0 重复 `Color(...).a = ...`。
  4. 新增 layer (L6/L7) 时必须先扩展顶部 docblock 的「L1-L5 设计」段到「L1-L6 设计」, 然后才能在 `_draw` 中添加新 `draw_*` 调用。

### 9.6.3 6 verb HUD 5+1 verb 7 UI 通道 polish 模式（T247 #164 落地）

> §9.6.1 记录 6 verb VFX 跨类 handler `is_instance_valid + has_method` 双守卫；§9.6.2 记录单个 VFX 类 5 layer 视觉 polish。本节记录 HUD 顶部 6 verb 行的"5+1 verb 7 UI 通道"同步扩 verb 模式 — polish 期接入第 6 verb (Whisper) 到 HUD 时，6 处 1:1 复制 5 verb 既有结构 + iteration list 元素扩到 8 元素，1 漏 1 = parse error 或 1 bar 5 通道颜色不亮。T247 (#164) 是该模式首次完整 5 verb + 1 verb 6 行 6 色色域分工 6 通道 100% 闭环 + reduce_flash 8 element 灰化同源，未来 polish 任何 verb HUD 接入或 reduce_flash 范围扩展时先查本节。

- **症状**：polish 期给 HUD 6 verb 顶部行加新元素 / 接入第 6 verb (Whisper / 7th verb) 时，最常见的 stale 是「(a) `@onready var` 索引错位」— `$MarginContainer/VBoxContainer/<Verb>Row/<Elem>` 多层 path 缺一段 (漏 `WhisperRow/` 段) 触发 `Node not found` runtime 错；「(b) iteration list 漏一个元素」— `_apply_reduced_flash_modulate` 的 8 element list (`[5 verb bar, _whisper_cooldown, _resonance_bar, _health_container]`) 漏 `_whisper_cooldown` 触发 "Whisper bar 在 reduce_flash 模式仍 100% 饱和度"；「(c) glow stylebox 5 verb + 1 verb 6 instance 漏 allocate」— `_whisper_glow_bg` 没在 `_create_verb_glow_stylebox()` 调一次，Whisper bar 仍用 tscn 默认 navy bg (无 verb 主色 border)；「(d) 6 verb 调色六元组违反宪法」— Whisper 主色复用 5 verb 中任一 hex (尤其 Glass Cyan #69C7CE 容易撞 Echo)，破坏 F013.E (#159) 6 verb 调色六元组严格不重叠约束。
- **触发场景**：T247 (#164) 第六 verb Whisper 接入 HUD 时需同步 6 处：
  1. `src/scenes/hud.tscn` — `load_steps` 11→12 + 加 `WhisperRow` (HBoxContainer) + 4 子节点 (`WhisperIcon` TextureRect / `WhisperNameLabel` Label / `WhisperCooldown` ProgressBar / `WhisperCooldownLabel` Label) + `StyleBoxFlat_whisper_fill` (Muted Mauve #C8A4D8 主题色) + ext_resource `whisper_icon.png` 引用。
  2. `src/scripts/hud.gd` — 加 4 个 `@onready var` (`_whisper_cooldown` / `_whisper_cooldown_label` / `_whisper_name_label` / 隐含) + 1 个 `var _whisper_ability` 引用 + 1 个 `_WHISPER_GLOW_COLOR` const (Muted Mauve #C8A4D8 6 verb 调色六元组第 6 行)。
  3. `var _verb_glow_state: Dictionary` — 5 key → 6 key 加 `"whisper": false`。
  4. `_ready()` — 5 步 → 6 步加 `WhisperAbility` `get_node_or_null` 守卫 + `_whisper_glow_bg = _create_verb_glow_stylebox(_WHISPER_GLOW_COLOR)` 分配 + `_whisper_cooldown.add_theme_stylebox_override("background", _whisper_glow_bg)` 替换 tscn 共用 StyleBoxFlat 引用。
  5. `_process()` — 5 步 → 6 步加 `_update_verb_glow_state("whisper", _whisper_glow_bg, _WHISPER_GLOW_COLOR, _whisper_ability)` 调用。
  6. `_apply_reduced_flash_modulate()` — iteration list 7 元素 → 8 元素加 `_whisper_cooldown` (5 verb bar + 1 whisper + 1 resonance + 1 health = 8 元素)。
  6 处 1:1 复制 5 verb 既有结构，1 漏 1 = parse error / runtime 错 / 色域宪法违反。
- **修复**：`src/scripts/hud.gd` 6 处同步完成（T247 #164 落地，0 任何 const 0 触碰 F013.E 6 verb 调色六元组宪法）：
  - 4 `@onready var` — `Whisper` 替换 `<Verb>` 占位 + `$MarginContainer/VBoxContainer/WhisperRow/Whisper<Elem>` path 5 段全链。
  - `_WHISPER_GLOW_COLOR` — `Color(0.784, 0.643, 0.847, 1.0)` (Muted Mauve #C8A4D8) + 注释锚点 (T245 #162 6 verb 调色六元组宪法第 6 行 + T245 STYLE_GUIDE §F009 第 6 行 1:1 对齐)。
  - `_verb_glow_state` — dict 字面量 5 key → 6 key 末尾加 `"whisper": false` + 注释 (6 verb dict 6 key 各自独立, 6 verb 互不干扰)。
  - `_ready()` 6 步 — `get_node_or_null` 守卫 + `StyleBoxFlat.new()` 复制 tscn 默认值 (navy bg + 1px border 全 4 边) + `add_theme_stylebox_override("background", _whisper_glow_bg)` 替换 tscn 共用引用。
  - `_process()` 6 步 — 调 `_update_verb_glow_state("whisper", ...)` 6 verb 6 独立 state-change tween, 0.12s quad-ease-out 与 5 verb 同步 (T231 / T226 / T111 节奏)。
  - `_apply_reduced_flash_modulate` iteration list 8 元素 — `[5 verb bar, _whisper_cooldown, _resonance_bar, _health_container]` (5 verb bar + 1 whisper + 1 resonance + 1 health = 8 元素)，`_health_container.modulate` 继承到所有动态子 bell (1 写 = 全部 bell 灰化)，reduce=true → 7 UI 通道 `_REDUCED_COLOR_MODULATE` 灰化 / reduce=false → `_NORMAL_COLOR_MODULATE` 还原。
- **预防**：
  1. 任何 polish 期接入第 6 verb / 7 verb 到 HUD 时**必须**严格按 6 步骤 1:1 复制既有 verb 模式：tscn 4 子节点 + 4 `@onready var` + 1 ability 引用 + 1 const (6 verb 调色六元组新增 1 行) + 1 stylebox 分配 + dict key 1 行 + iteration list 1 元素 8 处 0 漏。建议先列 checklist 再 code，每完成 1 步在 source-grep 验证（"Whisper" 字符串应出现 ≥ 6 次：4 `@onready var` + 1 ability ref + 1 stylebox var + 1 dict key + 1 iteration list + 1 `_WHISPER_GLOW_COLOR` const + 1 `_update_verb_glow_state` 调用 = 8-10 次，0 触碰 0 漏）。
  2. 6 verb 调色六元组宪法 (F013.E #159 + T245 #162) — 新 verb 主色 hex 必须与既有 6 verb (Coral / Violet / Amber / Cyan / Pale / **Mauve**) 严格不重叠，0 重复。建议在新增 `_WHISPER_GLOW_COLOR` 等 const 时，**先查** STYLE_GUIDE.md §F009 6 verb palette 表 + §6 verb 视觉组连贯段，1 行查表 0 撞色。
  3. `_apply_reduced_flash_modulate` iteration list 扩展时，**必须**在文件顶部 docblock 写明 "8 element 写 = 8 ProgressBar/Container .modulate 属性赋值, O(1) 静态开销, 0 allocation"，下次扩展时先看 docblock 确认 N element 结构。
  4. 6 verb HUD 6 行色域分工 6 通道 100% 闭环后 (T247 #164 落地)，任何"加新 HUD 元素"polish 必须先考虑"是否需要 reduce_flash 灰化"。reduce_flash 范围扩展时**必须**用 source-grep 验证 iteration list 元素 N+1 (5 verb + 1 whisper + 1 new + resonance + health) 1:1 对齐 docblock 文档的 N+1 元素。

### 9.6.4 6 verb 调色六元组 + HUD 6 行 6 色色域分工 6 通道 + 视觉组连贯 tooltip 三闭环宪法 (F013.E #159 + T245 #162 + T247 #164 + T250 #168 落地)

> §9.6.1 记录 6 verb VFX 跨类 handler `is_instance_valid + has_method` 双守卫；§9.6.2 记录单个 VFX 类 5 layer 视觉 polish；§9.6.3 记录 HUD 顶部 6 verb 行的 5+1 verb 7 UI 通道同步扩 verb 模式。本节记录 6 verb (Pulse / Bind / Cut / Echo / Wave / **Whisper**) 跨 4 个任务 (F013.E #159 + T245 #162 + T247 #164 + T250 #168) 反复落地的「三闭环宪法」：
> - **宪法 1**: 6 verb 调色六元组 (F013.E #159 落地 5 行 + T245 #162 增第 6 行) — 6 verb 6 主色 hex 严格不重叠 (Coral #FF7F50 / Violet #8B5CF6 / Amber #FFB347 / Cyan #69C7CE / Pale #B7E7DD / **Mauve #C8A4D8**)。
> - **宪法 2**: 6 verb HUD 6 行 6 色色域分工 6 通道 (T247 #164 落地) — HUD 顶部 6 verb 行的 4 通道 (icon / name label font_color / fill / glow border) + 2 派生通道 (cooldown label / reduce_flash) 6 通道 100% 闭环。
> - **宪法 3**: 6 verb 视觉组连贯 tooltip (T250 #168 落地) — 玩家 hover 6 verb 关联成就 slot (3 verb family + 3 verb achievement path) → 弹 8 行 tooltip 含 6 verb 调色 3 主色 hex + 6 verb 几何 5 动态 + 1 静态 + 6 verb 视觉组连贯短句。
> 未来 polish 任何 6 verb 视觉元素 (icon / fill / glow / name label / hit SFX / tooltip) 时先查本节三闭环宪法，0 触碰 6 verb 调色六元组严格不重叠约束 + 0 破坏 HUD 6 行 6 色色域分工 6 通道 100% 闭环 + 0 破坏 6 verb 视觉组连贯 tooltip 4 段不连贯。

- **症状**：polish 期给 6 verb 中任一 verb 加新视觉元素 (icon / fill / glow / name label / hit SFX / 6 verb 关联成就 tooltip) 时, 最常见的 fragile 是「(a) 6 verb 调色六元组违反宪法」— verb 主色 hex 重复 (尤其 Glass Cyan #69C7CE 容易撞 Echo 主色) 触发 6 verb 视觉组连贯崩塌；「(b) HUD 6 行 6 色色域分工不均」— 4 通道 (icon / name label font_color / fill / glow border) 中任一通道用错 verb 主色 (如 Pulse icon 用 Cyan 主色而非 Coral 主色) 触发玩家扫到 verb 与 verb 视觉组连贯错位；「(c) 6 verb 视觉组连贯 tooltip 缺 1 字段」— `_VERB_ACHV_INFO` 6 字段 dict (achv_id / verb_index / color / color_name / geometry_zh / visual_group) 漏 1 字段, 玩家 hover 6 verb 关联成就 slot 弹 tooltip 缺 1 段 (verb 序号 / 主色 hex / 主色名 / 几何描述 / 视觉组连贯短句) 4 段不连贯。
- **触发场景**：6 verb 闭环期间 (T242–T251) 反复出现 6 verb 调色六元组宪法 + HUD 6 行 6 色色域分工 6 通道 + 视觉组连贯 tooltip 三闭环同步需求：
  1. F013.E #159 落地 5 verb 调色五元组 (Coral / Violet / Amber / Cyan / Pale) → T245 #162 新增 6 verb (Whisper) 调色 6 元组第 6 行 (Muted Mauve #C8A4D8, 0 撞 5 verb 调色)。
  2. T247 #164 HUD 6 verb 顶部行 5+1 verb 同步扩 verb → 6 verb 4 通道 (icon / name label font_color / fill / glow border) + 2 派生通道 (cooldown label / reduce_flash) 6 通道 100% 闭环 (4 步 `_create_verb_glow_stylebox` 0 漏 1 verb + `_verb_glow_state` dict 6 key 0 漏 1 verb + `_apply_reduced_flash_modulate` iteration list 8 元素 0 漏 1 verb)。
  3. T250 #168 6 verb 关联成就 slot tooltip 6 verb 视觉组连贯 → 3 verb family + 3 verb achievement path (8 slot 4 verb + 4 verb) → `_build_verb_achievement_tooltip` 弹 8 行 tooltip 含 6 verb 调色 3 主色 hex (Echo #69C7CE / Wave #B7E7DD / Whisper #C8A4D8) + 6 verb 几何 5 动态 + 1 静态 + 6 verb 视觉组连贯短句。
  6 verb 三闭环宪法 (调色六元组 / HUD 6 行 6 通道 / tooltip 6 字段) 6 处 1:1 复制 5 verb 既有结构, 1 漏 1 = 调色撞色 / HUD 6 行色域错位 / tooltip 4 段不连贯。
- **修复**：
  1. F013.E #159 5 verb 调色五元组 (Coral #FF7F50 / Violet #8B5CF6 / Amber #FFB347 / Cyan #69C7CE / Pale #B7E7DD) + T245 #162 新增 6 verb 第 6 行 (Muted Mauve #C8A4D8) → STYLE_GUIDE.md §F009 6 verb palette 表 6 行 1:1 对齐 + ASSET_REGISTRY A001-A074 0 触碰既有 6 verb 调色。
  2. T247 #164 `_WHISPER_GLOW_COLOR := Color(0.784, 0.643, 0.847, 1.0)` (Muted Mauve #C8A4D8) + StyleBoxFlat_whisper_fill 同色 + `_verb_glow_state` dict 6 key 末尾加 `"whisper": false` + 6 verb HUD 6 行 4 通道 1:1 复制 5 verb 既有结构。
  3. T250 #168 `_VERB_ACHV_INFO := {` 3 entry dict, 每 entry 6 字段 (achv_id / verb_index / color / color_name / geometry_zh / visual_group) 1:1 对齐 STYLE_GUIDE §F009 + ASSET_REGISTRY A071-A074 + 6 verb 几何 (5 verb 全是动态几何 + Whisper 唯一"不扩散" 静态球)。
  3 处修复 0 触碰既有 6 verb 调色六元组, 6 verb 视觉组连贯 100% 闭环。
- **预防**：
  1. 任何 polish 期新增 6 verb 中任一 verb 视觉元素 (icon / fill / glow / name label / hit SFX / 6 verb 关联成就 tooltip) 前**必须**先查 STYLE_GUIDE.md §F009 6 verb palette 表 (6 hex 严格不重叠 0 重) + 6 verb 几何段 (5 verb 动态 + 1 verb 静态球) + 6 verb 视觉组段 (5 verb 全是动态几何 + Whisper 唯一"不扩散" 静态球) + ASSET_REGISTRY.md 0 触碰既有 6 verb 调色, 1 行查表 0 撞色。
  2. 新 verb (7th verb / 8th verb) 接入前**必须**先选 1 个新 hex (0 重叠 6 verb 调色六元组), 加 1 行到 STYLE_GUIDE §F009 + ASSET_REGISTRY 0 触碰既有 6 verb + 加 1 字段到 `_VERB_ACHV_INFO` (8 字段 0 漏) + 加 1 entry 到 `_VERB_ACHV_ICON_HINTS` (3 entry 0 漏 1 verb) + 加 1 entry 到 `_verb_glow_state` dict (6 key 0 漏 1 verb) + 加 1 element 到 `_apply_reduced_flash_modulate` iteration list (8 element 0 漏 1 verb), source-grep 验证 6 处 1:1 复制 0 漏。
  3. 6 verb 视觉组连贯 tooltip (T250 #168) 6 字段 (achv_id / verb_index / color / color_name / geometry_zh / visual_group) **必须**与 STYLE_GUIDE §F009 1:1 对齐, source-grep 验证 `_VERB_ACHV_INFO` 6 字段 0 漏, 11 个非 6 verb 关联 slot tooltip 100% 兼容 (T109 #60 既有 "title + desc + 解锁时间" 3 行 0 改)。
  4. 6 verb HUD 6 行 6 色色域分工 6 通道 100% 闭环后 (T247 #164 落地), 任何"加新 HUD 元素"polish 必须先考虑三闭环宪法: (a) "是否需要 reduce_flash 灰化" (8 element 0 漏) + (b) "是否需要 6 verb 调色六元组宪法同步扩展" (1 通道色 = 1 hex 0 撞 6 verb 调色) + (c) "是否需要 6 verb 视觉组连贯 tooltip 同步扩展" (1 verb = 1 entry 6 字段 0 漏), 三闭环 0 漏 1 处 = 调色撞色 / HUD 色域错位 / tooltip 4 段不连贯。

## 10. 联系方式 / 决策记录

- 大决策（玩法方向 / 风格宪法）→ `ROADMAP.md` 顶部「当前方向」+ `CHANGELOG.md` 段头
- 审查发现问题 → `REVIEW_LOG.md`（严重/一般/轻微/信息 4 类）
- 灵感 / 候选 → `INSPIRATION.md`（- 游戏名《xxx》：机制参考 (链接)）

---

> 感谢你愿意为 Voxglass 添砖加瓦。任何「让下一个开发者少花 10 分钟」的文档 / 冒烟测试 / 注释改进都是受欢迎的贡献。
