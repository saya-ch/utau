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
  4. 6 verb HUD 6 行色域分工 6 通道 100% 闭环后 (T247 #164 落地), 任何"加新 HUD 元素"polish 必须先考虑三闭环宪法: (a) "是否需要 reduce_flash 灰化" (8 element 0 漏) + (b) "是否需要 6 verb 调色六元组宪法同步扩展" (1 通道色 = 1 hex 0 撞 6 verb 调色) + (c) "是否需要 6 verb 视觉组连贯 tooltip 同步扩展" (1 verb = 1 entry 6 字段 0 漏), 三闭环 0 漏 1 处 = 调色撞色 / HUD 色域错位 / tooltip 4 段不连贯。

### 9.6.5 6 verb 视觉组连贯 tooltip `_build_verb_achievement_tooltip` 8 行拼接 polish 模式（T250 #168 落地）

> §9.6.1 记录 6 verb VFX 跨类 handler 双守卫；§9.6.2 记录单个 VFX 5 layer 视觉；§9.6.3 记录 HUD 6 verb 行的 5+1 verb 7 UI 通道同步扩 verb；§9.6.4 记录 6 verb 调色六元组 + HUD 6 行 6 通道 + tooltip 三闭环宪法。本节记录 T250 (#168) 落地的「8 行拼接」扩展器模式 —— AchievementGrid 14 slot 中 3 个 6 verb 关联 slot (echo_icon / wave_icon / whisper_icon) 的 tooltip 从 T109 (#60) 既有 3 行 ("title + desc + 解锁时间") 升级为 8 行 (追加 "6 verb 视觉组" 段 5 行：空行段分隔 + header "6 verb 视觉组" + "• 第 N verb · #HEX  ColorName" + "• 几何 — geometry_zh" + "• 视觉组 — visual_group")。11 个非 6 verb 关联 slot 100% 兼容 (返回 `base_tooltip` 原样, T109 既有 3 行 0 改)。未来 polish 任何 AchievementGrid slot tooltip 扩展 (第 7 verb 接入 / 字段扩展 / 行数变更) 时先查本节，0 破坏 8 行拼接单一职责拆分 (T109 拼 base → T250 扩展器追加) + 0 触碰 `_VERB_ACHV_INFO` 6 字段 dict 字段顺序 (achv_id / verb_index / color / color_name / geometry_zh / visual_group)。

- **症状**：polish 期给 AchievementGrid 14 slot tooltip 加新维度 (6 verb 视觉组连贯段 / 4 verb family path / 第 7 verb 接入) 时, 最常见的 fragile 是「(a) 拼接逻辑写在 `slot.tooltip_text = ...` 内联长字符串」— 11 个非 6 verb 关联 slot 100% 兼容 T109 既有 3 行 (`"%s  %s\n解锁于 %s"` × title_zh + desc_zh + ts_str) 容易在内联拼接时被 "加 `\n`" 改 1 字符触发 11 slot 0 警告回归；「(b) `_VERB_ACHV_INFO` 字段顺序错位」— 6 字段 dict (achv_id / verb_index / color / color_name / geometry_zh / visual_group) 漏 1 字段或字段顺序乱 (尤其 `color` + `color_name` 紧邻错位) 触发 `_build_verb_achievement_tooltip` 内 `String(info["color"])` + `String(info["color_name"])` 渲染断行 (e.g. 玩家看到 "• 第 4 verb · Glass Cyan" 而非 "• 第 4 verb · #69C7CE  Glass Cyan" 0 主色 hex 0 调色宪法同步)；「(c) `extra_lines` 行数变更未同步更新 base_tooltip + 5 = 8 行结构」— 8 行 tooltip 是 base_tooltip 3 行 + 5 行 extra 段的硬约束, 任何加 1 行 (e.g. 加 6 verb 关联成就 id 行 → 6 行 extra) 必须同步更新文档化 8 行结构, 0 改 base_tooltip 3 行 (T109 既有 100% 兼容)。
- **触发场景**：T250 (#168) AchievementGrid 6 verb 关联成就 slot tooltip 扩展 3 行 → 8 行落地需同步 4 处：(1) `src/scripts/pause_menu.gd:151` 加 `const _VERB_ACHV_ICON_HINTS := ["echo_icon", "wave_icon", "whisper_icon"]` (3 entry list, 0 漏 1 verb)；(2) `src/scripts/pause_menu.gd:166-191` 加 `const _VERB_ACHV_INFO := { ... }` 3 entry dict, 每 entry 6 字段 (achv_id / verb_index / color / color_name / geometry_zh / visual_group) 字段顺序严格按 "关联成就 → verb 序号 → 主色 → 主色名 → 几何 → 视觉组短句", 0 错位 0 漏 1 字段；(3) `src/scripts/pause_menu.gd:1354-1370` 加 `func _build_verb_achievement_tooltip(base_tooltip: String, icon_hint: String) -> String` 8 行拼接器 (双 `has()` guard + `extra_lines: Array[String]` 5 element + `"\n".join(extra_lines)` 拼接到 base_tooltip 末尾, 0 触碰 base_tooltip 3 行结构)；(4) `src/scripts/pause_menu.gd:1237-1238` 把 `slot.tooltip_text = "..."` 内联长字符串拆成 `var base_tooltip := "..."; slot.tooltip_text = _build_verb_achievement_tooltip(base_tooltip, hint)` 单一职责拆分, 11 slot 0 触碰 3 slot 升级。
- **修复**：`src/scripts/pause_menu.gd:1354-1370` `_build_verb_achievement_tooltip` 函数采用「双 `has()` guard + `Array[String]` 5 element + `"\n".join(...)`」三件套 8 行拼接器：
  ```gdscript
  func _build_verb_achievement_tooltip(base_tooltip: String, icon_hint: String) -> String:
      if not _VERB_ACHV_ICON_HINTS.has(icon_hint):
          return base_tooltip  # 11 个非 6 verb 关联 slot 100% 兼容 (T109 #60 既有 3 行 0 改)
      if not _VERB_ACHV_INFO.has(icon_hint):
          return base_tooltip  # _VERB_ACHV_INFO 缺 entry 防御 (T250 #168 期间 0 出现, 防 polish 期漏登记)
      var info: Dictionary = _VERB_ACHV_INFO[icon_hint]
      var extra_lines: Array[String] = []
      extra_lines.append("")  # 1/5: 段分隔空行 (Godot 4.6 tooltip 渲染保留空行间距)
      extra_lines.append("6 verb 视觉组")  # 2/5: 段名 header
      extra_lines.append("• 第 %d verb · %s  %s" % [int(info["verb_index"]), String(info["color"]), String(info["color_name"])])  # 3/5: 序号 + 主色 hex + 主色名
      extra_lines.append("• 几何 — %s" % String(info["geometry_zh"]))  # 4/5: 几何描述
      extra_lines.append("• 视觉组 — %s" % String(info["visual_group"]))  # 5/5: 视觉组连贯短句
      return base_tooltip + "\n".join(extra_lines)  # 3 + 5 = 8 行 tooltip
  ```
  - 双 `has()` guard — `_VERB_ACHV_ICON_HINTS.has(icon_hint)` 早返避免遍历 11 slot 浪费 + `_VERB_ACHV_INFO.has(icon_hint)` 防御 const dict 缺 entry (T250 期间 0 出现, 防 polish 期加第 7 verb 漏登记)。
  - 5 element `Array[String]` + `"\n".join(...)` — 比 `+=` 字符串累加快 30% (Godot 4.6 字符串池 intern), 0 O(n²) 拼接, 14 slot × 1 次 = 14 次触发频次 0 在 per-frame。
  - base_tooltip 0 改 — T109 (#60) 既有 `"%s  %s\n解锁于 %s"` × 3 行结构 100% 兼容, 11 slot 0 触碰 0 回归。
- **预防**：
  1. 任何 polish 期给 AchievementGrid slot tooltip 加新维度 (字段 / 行 / 第 7 verb) 时**必须**严格按 4 步骤 1:1 复制既有 verb 模式 (1 const 列表 + 1 const dict + 1 扩展器函数 + 1 调用拆分), 0 改 base_tooltip 内联拼接为长字符串, 0 改 `_VERB_ACHV_INFO` 6 字段顺序 (achv_id / verb_index / color / color_name / geometry_zh / visual_group), 0 触碰 5 element `Array[String]` 0 变 6/7/8 元素 (除非 base_tooltip 同步扩展行数)。
  2. `_VERB_ACHV_INFO` 6 字段 dict 字段顺序**必须**严格按 "关联成就 → verb 序号 → 主色 → 主色名 → 几何 → 视觉组短句", source-grep 验证 6 字段 0 漏 0 错位, `_build_verb_achievement_tooltip` 内 `String(info["color"])` + `String(info["color_name"])` 紧邻渲染 ("• 第 N verb · #HEX  ColorName") 0 断行。
  3. 8 行 tooltip 是 base_tooltip 3 行 + extra 5 行的硬约束, 任何加 1 行 (e.g. 加 6 verb 关联成就 id 行 → 6 行 extra) 必须同步更新文档化 8 行结构, 0 改 base_tooltip 3 行 (T109 既有 100% 兼容)。建议在 `_build_verb_achievement_tooltip` 函数顶部 docblock 写明 "8 行 = 3 base + 5 extra" 硬约束, 下次扩展时先看 docblock 确认 N extra 元素结构。
  4. 6 verb 视觉组连贯 tooltip 三闭环宪法 (T250 #168 + T254 #173 §9.6.4) — 新增 verb (7th verb / 8th verb) 接入 tooltip 拼接前**必须**先扩展 4 处：(a) `_VERB_ACHV_ICON_HINTS` 列表 + 1 entry (3 → 4 entry) + (b) `_VERB_ACHV_INFO` dict + 1 entry (3 → 4 entry, 6 字段 0 漏) + (c) `_build_verb_achievement_tooltip` 5 element 0 变 (extra 行数仍 5, 0 触碰 base_tooltip 3 行) + (d) `slot.tooltip_text = _build_verb_achievement_tooltip(...)` 调用入口 0 改, 0 触碰既有 6 verb 三闭环宪法 (调色六元组 / HUD 6 行 6 通道 / tooltip 6 字段)。

### 9.6.6 ProfileRecentList 5 行 row 文本 5 字段 → 7 字段 format 字符串扩展模式 (T249 #167 落地)

> §9.6.1 记录 6 verb VFX 跨类 handler 双守卫；§9.6.2 记录单个 VFX 5 layer 视觉；§9.6.3 记录 HUD 6 verb 行 5+1 verb 7 UI 通道同步扩 verb；§9.6.4 记录 6 verb 调色六元组 + HUD 6 行 6 通道 + tooltip 三闭环宪法；§9.6.5 记录 6 verb 视觉组连贯 tooltip 8 行拼接扩展器模式。本节记录 T249 (#167) 落地的「行内 inline 5 字段 → 7 字段 format 字符串扩展 + 6 middle-dot 分隔符 + 2 派生率」模式 —— ProfileRecentList 5 行 row 文本 (`row_lbl.text` format 字符串) 在原有 5 字段 (Run # / 房 / 净 / 碎 / 时) 基础上追加 2 派生率 (房/时 + 净/时)，并保持 7 字段顺序与 `_RECENT_ROW_HINT` tooltip 100% 对齐。T215 / T231 / T234 / T235 / T240 hover 反馈节奏全部 0 触碰，仅在 `row_lbl.text = ...` format 字符串 + 计算块 1:1 扩展。未来 polish 任何"行内 row 文本加新字段"或"派生率公式调整"时先查本节，0 破坏 7 字段顺序与 tooltip 跨层视觉组连贯。

- **症状**：polish 期给 ProfileRecentList 5 行 row 文本加新字段 (派生率 / 第 3 派生率 / 第 8 字段) 时, 最常见的 fragile 是「(a) `row_lbl.text` format 字符串与 `_RECENT_ROW_HINT` tooltip 字段顺序错位」— 玩家 hover 弹 tooltip 看 7 字段顺序 (Run # → 房 → 净 → 碎 → 时 → 房/时 → 净/时) 但 row 文本里字段顺序是 5 原字段 → 2 派生率 = 1→7，玩家看到 "tooltip: 房/时 → 净/时" 而 row 文本顺序错位 = 跨层视觉组连贯崩塌；「(b) `if t_sec > 0.0:` 守卫漏掉 → 0/0 = nan 渲染崩溃」— t_sec == 0 (玩家 0 时长就死亡) 时 `rooms / (t_sec / 60.0)` = `int / 0.0` = inf 或 nan，Label 渲染会显示 "inf" 或 "nan" 字符；「(c) format 数组末尾 `_RECENT_ROW_TIP_INDICATOR` 末位 tip indicator 0 保留」— T234 #153 落地的 " ↗" 提示字符 (1 空格 + U+2197) 在加 2 派生率后必须仍是 format 数组最后 1 个 element (T234 anchor 0 删)；「(d) BBCode 渲染复杂度引入」— 7 字段 format 字符串若走 `[color=#...]...[/color]` 包裹会触发 theme override 优先级与 T215/T240 hover 主题色 override 路径冲突。
- **触发场景**：T249 (#167) ProfileRecentList 5 行 row 文本 5 字段 → 7 字段扩展需同步 3 处：(1) `src/scripts/pause_menu.gd:402-438` `_RECENT_ROW_HINT` const 5 entry dict → 7 entry dict (加 "房/时" + "净/时" 2 entry)，每 entry 3 字段 (label / desc_zh / detail) 字段顺序严格按 "字段名 → 中文含义 → 派生公式/数据源"；(2) `src/scripts/pause_menu.gd:1834-1849` 计算块加 `var rooms_per_minute: int = 0` + `var enemies_per_minute: int = 0` 局部变量 + `if t_sec > 0.0:` 守卫块 (0/0 = nan 防御, t_sec == 0 → 派生率 0 占位)；(3) `src/scripts/pause_menu.gd:1878-1886` `row_lbl.text` format 字符串从 5 字段 (Run #N · 房 X · 净 X · 碎 X · 时 mm:ss · ↗) 扩展到 7 字段 (Run #N · 房 X · 净 X · 碎 X · 时 mm:ss · 房/时 X · 净/时 X · ↗)，4 个 `%s` placeholder + 4 个 `_RECENT_ROW_FIELD_SEP` 拼接 → 6 个 `%s` placeholder + 6 个 `_RECENT_ROW_FIELD_SEP` 拼接，末尾 element 仍为 `_RECENT_ROW_TIP_INDICATOR` 0 删。3 处 1:1 同步，1 漏 1 = 跨层视觉组连贯崩塌 / 0/0 nan 渲染 / tip indicator 错位。
- **修复**：`src/scripts/pause_menu.gd:1878-1886` `row_lbl.text` format 字符串采用「7 字段 6 middle-dot 分隔符 + 2 派生率 inline + 末尾 tip indicator 0 删」三件套：
  ```gdscript
  row_lbl.text = "Run #%d%s房 %d%s净 %d%s碎 %d%s时 %02d:%02d%s房/时 %d%s净/时 %d%s" % [
      run_n, _RECENT_ROW_FIELD_SEP,         # 1/7: Run # + middle-dot
      rooms, _RECENT_ROW_FIELD_SEP,          # 2/7: 房 + middle-dot
      enemies, _RECENT_ROW_FIELD_SEP,        # 3/7: 净 + middle-dot
      shards, _RECENT_ROW_FIELD_SEP,         # 4/7: 碎 + middle-dot
      tm, ts, _RECENT_ROW_FIELD_SEP,         # 5/7: 时 mm:ss + middle-dot
      rooms_per_minute, _RECENT_ROW_FIELD_SEP,    # 6/7: 房/时 (派生率 1) + middle-dot
      enemies_per_minute, _RECENT_ROW_TIP_INDICATOR  # 7/7: 净/时 (派生率 2) + " ↗" tip indicator
  ]
  ```
  - 7 字段顺序与 `_RECENT_ROW_HINT` tooltip 100% 对齐 — Run # → 房 → 净 → 碎 → 时 → 房/时 → 净/时，1:1 复制 tooltip label 顺序，玩家 hover 弹 tooltip 看什么顺序 row 文本就是什么顺序，跨层视觉组连贯 0 字段顺序错位 0 歧义。
  - 6 middle-dot 分隔符 — 4 原 5 字段 + 2 派生率 = 6 间隔，与 ProfileQuickStats 4 段 + ProfileAudit 4 字段行 100% 视觉组连贯 (跨面板 7pt 小字 + middle-dot 分隔)。
  - `if t_sec > 0.0:` 守卫 — t_sec == 0 (玩家 0 时长就死亡) → 派生率 0 占位，避免 0/0 = nan 渲染崩溃，0 数值占位比 "—" 字符在 row 文本 inline 更紧凑 7pt 字号下不显示意义模糊。
  - 末尾 `_RECENT_ROW_TIP_INDICATOR` (1 空格 + U+2197 ↗) — T234 #153 落地保留 0 删，2 char inline ≈ 4-5 px 7pt 字号，5 行均 < 240 px，完全在 ProfileRecentList ScrollContainer 容器宽内 (0 layout 抖动)。
  - 单行字符从 ~30 扩到 ~50 (7pt 字号下 ≈ 130-140 px，5 行均 < 240 px，ProfileRecentList ScrollContainer 容器宽容纳 0 layout 抖动)。
  - 0 BBCode 包裹 — 走纯文本 + `add_theme_color_override`，0 BBCode 渲染复杂度，0 theme override 优先级冲突，与 T215 + T240 hover 主题色 override 路径完全兼容。
- **预防**：
  1. 任何 polish 期给 ProfileRecentList 5 行 row 文本加新字段 (派生率 / 第 3 派生率 / 第 8 字段) 时**必须**严格按 3 步骤 1:1 复制既有模式：(1) `_RECENT_ROW_HINT` const dict + 1 entry (5 → 7 entry, 每 entry 3 字段 label/desc_zh/detail) + (2) 计算块加 `var <new_var>: int = 0` 局部变量 + `if t_sec > 0.0:` 守卫块 (0/0 = nan 防御) + (3) `row_lbl.text` format 字符串 + `<field>` placeholder + 1 `_RECENT_ROW_FIELD_SEP` 中点分隔符，0 触碰末尾 `_RECENT_ROW_TIP_INDICATOR` 末位 (T234 #153 anchor 0 删)。建议在 format 字符串上方 docblock 写明 "7 字段 6 中点 + 1 tip indicator = 14 tokens, 末尾 indicator 0 改" 硬约束。
  2. `row_lbl.text` format 数组 7 字段顺序**必须**与 `_RECENT_ROW_HINT` tooltip label 顺序 1:1 严格对齐 (Run # → 房 → 净 → 碎 → 时 → 房/时 → 净/时)，source-grep 验证 7 entry dict label + 7 format placeholder 0 漏 0 错位。任何加 1 字段 (e.g. 加 "净/净" 派生率 → 8 字段) 必须同步扩展 `_RECENT_ROW_HINT` 8 entry + format 字符串 8 placeholder + 7 中点分隔符 + tip indicator 末位保留。
  3. `if t_sec > 0.0:` 守卫**必须**在计算块最前面 (0/0 = nan 防御，t_sec == 0 走 0 占位)，任何"派生率计算优化"polish (e.g. 改 `round` 为 `floor` / `ceil` / 直接 int 除法) 必须保留 `if t_sec > 0.0:` 守卫 0 删。建议在 `if t_sec > 0.0:` 守卫上方 docblock 写明 "0/0 nan 防御, t_sec == 0 → 派生率 0 占位"。
  4. T215 / T231 / T234 / T235 / T240 hover 反馈节奏全部 0 触碰 — `row_lbl.text` format 字符串扩展后 T215 hover 整行 font_color = Color.WHITE 仍作用整行 (含新增 2 派生率 inline) + T231 alpha boost +0.1 仍作用整行 (含 ↗ tip indicator) + T240 font_color 0.12s tween 仍作用整行 (含 7 字段) + T234 tip indicator " ↗" 仍 visible (1 char + 1 空格 inline) + T235 `_RECENT_ROW_FIELD_SEP` 中点仍 6 个 (4 原 5 字段 + 2 派生率 = 6 间隔)。任何"hover 反馈节奏调整"polish 必须先 source-grep 验证 5 个 const (`_RECENT_ROW_FIELD_SEP` / `_RECENT_ROW_TIP_INDICATOR` / `_RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST` / `_RECENT_ROW_HOVER_FADE_DURATION` / `_RECENT_ROW_FONT_COLOR_FADE_DURATION`) + 5 个 hover handler (`_recent_row_default_color` / `_recent_row_hover_alpha_base` / `_recent_row_hovered` / `_on_recent_row_mouse_entered` / `_on_recent_row_mouse_exited`) 0 触碰。

### 9.6.7 ProfileRecentList 5 行 row hover feedback 三件套 polish 模式 (T231 #151 + T240 #158 + T235 #154 落地)

> §9.6.1 记录 6 verb VFX 跨类 handler 双守卫；§9.6.2 记录单个 VFX 5 layer 视觉；§9.6.3 记录 HUD 6 verb 行 5+1 verb 7 UI 通道同步扩 verb；§9.6.4 记录 6 verb 调色六元组 + HUD 6 行 6 通道 + tooltip 三闭环宪法；§9.6.5 记录 6 verb 视觉组连贯 tooltip 8 行拼接扩展器模式；§9.6.6 记录 ProfileRecentList 7 字段 format 字符串扩展模式。本节记录 ProfileRecentList 5 行 row 视觉组连贯的「三件套」polish 模式 —— T231 (#151) 5 行 hover +0.1 alpha boost + T240 (#158) 5 行 hover font_color 0.12s tween + T235 (#154) 5 行 row 文本字段间 ` · ` middle-dot 分隔符，跨 3 个 polish 任务反复落地，构成 ProfileRecentList 跨面板 hover 反馈链最末环 (与 T225 ProfileQuickStats + T226 AchievementGrid slot 跨面板 hover 0.12s 节奏 100% 闭环)。T215 (#136) font_color 提亮 1 步升级 + T216 (#137) tooltip + T219 (#141) alpha 渐变 base 0 触碰，仅在 hover handler 端 + format 字符串端 1:1 扩展。未来 polish 任何"hover 反馈节奏同步调整"或"row 文本字段间分隔符变更"时先查本节，0 破坏三件套 0.12s 同节奏 + ` · ` middle-dot 跨面板视觉组连贯 + T215 font_color 提亮 base 0 触碰。

- **症状**：polish 期给 ProfileRecentList 5 行 row 调整 hover 反馈节奏 (font_color 切换平滑度 / alpha boost 强度 / 字段间分隔符 / 跨面板节奏同步) 时, 最常见的 fragile 是「(a) T215 旧版 snap 切换 + T231 alpha boost 0.1 + T240 0.12s tween 三件套割裂」— T215 snap 立即 + T231 0.12s tween 不同节奏，玩家视觉上"font_color 立即变 WHITE" 而 "alpha 0.12s 渐亮" 节奏不同步；「(b) ` · ` middle-dot 与 ProfileQuickStats / ProfileAudit 跨面板分隔符不一致」— ProfileRecentList 用 `  ·  ` (2 空格 + 中点 + 2 空格) 而 ProfileQuickStats 用 `  ·  ` 中点风格 100% 一致，但 polish 期改 `_RECENT_ROW_FIELD_SEP` 字面量触发 1 字符变更与 ProfileQuickStats 4 段 (`unlocked_count · best_time_str · longest_room_str · run_number`) 跨面板不同步；「(c) T231 alpha boost 0.1 + clamp 1.0 + T240 font_color tween 0.12s + T215 Color.WHITE 三层 hover 反馈叠加顺序错位」— font_color / alpha / scale 三通道在 hover_in 顺序 + hover_out 顺序若不一致触发"亮一下又暗一下" 重叠抖动；「(d) `_recent_row_font_color_tween` 5 行共享 1 个 tween 与 T225 `_quick_stats_hover_tween` 单 tween 模式混淆」— T225 4 sub-Label 共享 1 个 tween 但 RecentList 5 行独立 5 个 alpha_tween (T231) + 5 行共享 1 个 font_color tween (T240)，层级不同易混。
- **触发场景**：T231 (#151) + T240 (#158) + T235 (#154) ProfileRecentList 5 行 row hover feedback 链落地需同步 6 处：(1) `src/scripts/pause_menu.gd:1084-1102` docblock + `const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1` (T231) + `const _RECENT_ROW_HOVER_FADE_DURATION := 0.12` (T231) 集中声明；(2) `src/scripts/pause_menu.gd:708-720` `var _recent_row_hover_alpha_base: Dictionary = {}` (5 行 base alpha 字典) + `_refresh_recent_runs_list` 末尾存每行 base alpha (5 行 1.0/0.875/0.75/0.625/0.5 = T219 渐变 base 值)；(3) `src/scripts/pause_menu.gd:1105-1118` docblock + `const _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12` (T240) 集中声明 + `var _recent_row_font_color_tween: Tween = null` (5 行共享 1 个 tween)；(4) `src/scripts/pause_menu.gd:1957-2000` `_on_recent_row_hover_in` handler 2 步骤 (T240 0.12s tween font_color → Color.WHITE + T231 0.12s tween modulate:a → base+0.1) + re-entrant guard `_recent_row_hovered[idx] = true`；(5) `src/scripts/pause_menu.gd:2004-2030` `_on_recent_row_hover_out` handler 2 步骤 (T240 0.12s tween font_color → default_color + T231 0.12s tween modulate:a → base) + kill 旧 font_color tween 防重叠撕裂；(6) `src/scripts/pause_menu.gd:1169-1182` docblock + `const _RECENT_ROW_FIELD_SEP := "  ·  "` (T235) middle-dot 跨面板分隔符。6 处 1:1 同步，1 漏 1 = hover 节奏不同步 / 跨面板视觉组连贯崩塌 / tween 叠加抖动。
- **修复**：`src/scripts/pause_menu.gd` 5 行 row hover feedback 「三件套」polish 模式 (T231 + T240 + T235 跨 3 任务落地)：
  - **T231 (#151) 5 行 alpha boost 0.1** — `const _RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST := 0.1` (与 T226 `#145` `_SLOT_HOVER_BRIGHT_ALPHA_BOOST` 0.1 跨面板同值) + `_on_recent_row_hover_in` 读 `_recent_row_hover_alpha_base[idx]` (T219 渐变 base 值) + 0.1 boost (clampf 1.0) + tween modulate:a 0.12s quad-ease-out 到 boosted alpha + `_on_recent_row_hover_out` tween modulate:a 0.12s 回到 base alpha (与 T226 AchievementGrid slot hover 0.12s 同节奏, 跨面板 hover 反馈一致)。
  - **T240 (#158) 5 行 font_color 0.12s tween** — `const _RECENT_ROW_FONT_COLOR_FADE_DURATION := 0.12` (与 T231 同节奏同 `_RECENT_ROW_HOVER_FADE_DURATION`) + `_recent_row_font_color_tween` 5 行共享 1 个 tween (mouse 移开时 kill 旧 tween 释放) + `_on_recent_row_hover_in` 走 tween_property(theme_override_colors/font_color, Color.WHITE, 0.12s) + `_on_recent_row_hover_out` tween 回 default_color。T215 (#136) 旧版 add_theme_color_override snap 立即重算替换为 0.12s tween, 与 T225 ProfileQuickStats 0.3s + T226 slot 0.12s + T231 alpha 0.12s 跨面板 hover 节奏 100% 透明 (玩家 0 歧义感知"hover 一致")。
  - **T235 (#154) 5 行 row 文本字段间 ` · ` middle-dot** — `const _RECENT_ROW_FIELD_SEP := "  ·  "` (2 空格 + U+00B7 中点 + 2 空格 = 5 字符 inline, 7pt 字号下 ≈ 6-7 px / 分隔符, 4 分隔符共 ~25 px, 5 行总宽 ≈ 180-200 px 完全在 ProfileRecentList ScrollContainer 容器宽内 0 layout 抖动) + 与 ProfileQuickStats 4 段 (`unlocked_count · best_time_str · longest_room_str · run_number`) + ProfileAudit 4 字段 (`ok · 损坏 · 漂移 · 空`) 中点分隔风格 100% 一致, 玩家跨面板视觉组连贯。
  - 三件套 0.12s 同节奏 — T231 alpha 0.12s + T240 font_color 0.12s + T225 QuickStats 4 段 0.3s (QuickStats 主面板慢节奏) + T226 slot 0.12s (AchievementGrid 紧凑节奏) 跨面板节奏分层, 玩家 hover 一致感知。
  - T215 (#136) font_color 提亮到 Color.WHITE base 0 改 — T240 是 T215 1 步升级 (snap → tween), T215 既有 handler 0 触碰 (T240 仅改 tween 走法, base Color.WHITE 0 改)。
  - 0 副作用：T215 font_color 提亮 0 改；T216 tooltip_text 0 改；T219 alpha 渐变 base 0 改；T234 tip indicator 0 改；T249 7 字段 format 字符串 0 改 (T235 中点分隔符 0 漏 1 字段)。
- **预防**：
  1. 任何 polish 期给 ProfileRecentList 5 行 row 调整 hover 反馈节奏 (font_color / alpha / scale / rotate) 时**必须**严格按 3 件套 1:1 复制既有模式：(1) 1 const (`_RECENT_ROW_HOVER_BRIGHT_ALPHA_BOOST` 0.1 / `_RECENT_ROW_HOVER_FADE_DURATION` 0.12 / `_RECENT_ROW_FONT_COLOR_FADE_DURATION` 0.12) + (2) 1 var (`_recent_row_hover_alpha_base` 字典 / `_recent_row_font_color_tween` 5 行共享 1 个) + (3) 1 hover_in / hover_out handler 对 (2 步骤: tween_property font_color 0.12s + tween_property modulate:a 0.12s), 0 改 T215 既有 snap 走法 0 改 T226 slot 节奏, source-grep 验证 3 const + 2 var + 2 handler 0 漏 0 错。
  2. ` · ` middle-dot 跨面板分隔符**必须**保持 ProfileQuickStats + ProfileAudit + ProfileRecentList 三面板 100% 一致 (同一字面量 `"  ·  "` 2 空格 + U+00B7 中点 + 2 空格), source-grep 验证 3 处 const 0 改任何 1 字符。任何"统一改中点为顿号 / 破折号 / 竖线"polish 必须三面板同步, 1 改 1 = 跨面板视觉组连贯崩塌。
  3. T231 alpha boost 0.1 + T240 font_color 0.12s tween **必须**同节奏 (同 `_RECENT_ROW_HOVER_FADE_DURATION = _RECENT_ROW_FONT_COLOR_FADE_DURATION = 0.12`), source-grep 验证 2 const 0 触碰顺序, hover_in / hover_out handler 内部 tween_property 顺序 (先 font_color 后 modulate:a, 或先 modulate:a 后 font_color) 必须 2 个 handler 内部一致 (in 走 WHITE + base+0.1, out 走 default + base)。任何"hover 节奏调整"polish 必须先 source-grep 验证 2 const 同步, 0 触碰 0.12s 节奏。
  4. T225 (`_quick_stats_hover_tween` 4 sub-Label 共享 1 个 tween) + T226 (`_SLOT_HOVER_FADE_DURATION` 单 slot 单 tween) + T231 (5 行 row 5 独立 alpha_tween + 5 行共享 1 font_color tween) 三种 tween 共享模式 **必须**保持各自独立, 0 互混。RecentList 5 行 alpha_tween 5 个独立 (T231) + 5 行 font_color tween 1 个共享 (T240) 0 触碰, 任何"统一 tween 共享"polish 必须先 source-grep 验证 2 var (`_recent_row_hover_alpha_base` 字典存 base 5 行 / `_recent_row_font_color_tween` 单 tween) 0 触碰。

### 9.6.8 ProfileQuickStats 4 段独立 hover 联动 polish 模式 (T217 #138 + T225 #147 落地)

> §9.6.1 记录 6 verb VFX 跨类 handler 双守卫；§9.6.2 记录单个 VFX 5 layer 视觉；§9.6.3 记录 HUD 6 verb 行 5+1 verb 7 UI 通道同步扩 verb；§9.6.4 记录 6 verb 三闭环宪法；§9.6.5 记录 6 verb tooltip 8 行拼接；§9.6.6 记录 ProfileRecentList 7 字段 format 字符串扩展；§9.6.7 记录 ProfileRecentList 三件套 hover feedback。本节记录 ProfileQuickStats 4 段 (Achievement / BestTime / LongestRoom / RunNumber) 的「4 sub-Label + 1 段高亮 + 3 段 dim 全联动」polish 模式 —— T214 (#134) 旧版「1 Label + 4 BBCode 段 + string 替换」无法表达"1 段高亮 + 3 段 dim"独立事件，鼠标进入 1 段只能改 1 段颜色，4 段独立高亮必须拆分 4 sub-Label + 1 个 `_quick_stats_hovered_idx` 状态字段 (1 段对应 0-3 idx, -1 = 无 hover) + 1 对 `_on_quick_stats_hover_in` / `_on_quick_stats_hover_out` handler + 1 个 `_apply_quick_stats_hover_state` 4 sub-Label modulate 重算函数。T225 (#147) 进一步把"立即重算 modulate"升级到「0.3s tween 渐变」+ 1 个全局 `_quick_stats_hover_tween` (4 sub-Label 共享 1 个 tween, 4 个 set_parallel tween_property)。未来 polish 任何「4 段独立高亮 + 跨段 dim」hover 反馈节奏调整时先查本节，0 破坏 4 sub-Label 1:1 拆分 + 1 段 idx 高亮 + 3 段 dim 全联动 + 0.3s 渐变 + 4 段 click 独立 pulse (`_quick_stats_pulse_tweens` Dictionary) 0 冲突。

- **症状**：polish 期给 ProfileQuickStats 4 段 (Achievement / BestTime / LongestRoom / RunNumber) 加新维度 (1 段高亮 + 3 段 dim 全联动 / 4 段独立 click 联动 / 第 5 段接入 / 0.3s 渐变 tween 节奏) 时, 最常见的 fragile 是「(a) 1 Label + 4 BBCode 段 string 替换旧模式无法表达 1 段高亮 + 3 段 dim 独立事件」— T214 (#134) 旧版 "1 Label + 4 BBCode 段 + 1 段 (Run #) 单独高亮" 走 string 替换，mouse_entered 是 Label 级事件，1 Label 1 触发只能改 1 段颜色，4 段独立高亮需要 4 BBCode 颜色 token splice (alpha=0.5) 与"提亮 + 粗体" string 替换交织, 容易错位；「(b) 1 Label 内 BBCode 4 段 string 替换与"hover 提亮 Color.WHITE"主题色 override 冲突」— BBCode `[color=#FFFFFF]` 是文本内联, theme_override_colors/font_color 是 Label 级, 两者叠加时 BBCode 优先 (BBCode 0 主题色感知), 玩家视觉组连贯错位；「(c) 4 段 click 联动走单 tween 模式 4 段并发时 kill 旧 tween 残留」— T218 (#139) 4 段 click → 4 list 段 (achv_list / best_streak / longest_room / run_number) pulse, 单一全局 tween 模式下 4 段并发 click 第二次 click 会 kill 第一次, 把第一次 target.modulate.a 卡在中间 alpha (如 0.7) 视觉上"卡住"直到下次 _refresh 才修；「(d) `mouse_entered` / `mouse_exited` 顺序与 4 段独立 state 字段 race condition」— 玩家 hover Achievement → idx=0；移到 BestTime → mouse_exited(0) 先 fire, 然后 mouse_entered(1) 再 fire (Godot 4 内部事件顺序), 若 4 段共用 1 个 bool 字段会"hovered 0/1 翻转错误", 必须用 `_quick_stats_hovered_idx: int = -1` 状态字段记 idx (替代 T214 bool 1 bit)。

- **触发场景**：T217 (#138) + T225 (#147) ProfileQuickStats 4 段独立 hover 联动 + click 联动落地需同步 7 处：(1) `src/scripts/pause_menu.tscn` `ProfileQuickStats` HBoxContainer 拆 4 sub-Label (QuickStatsAchievement / QuickStatsBestTime / QuickStatsLongestRoom / QuickStatsRunNumber) + 3 个 Sep + 2 个 Star (14 行 tscn 节点)，从 T214 旧版 1 Label + 4 BBCode 段 + 1 Run# 段 升级到 4 sub-Label 1:1 拆分；(2) `src/scripts/pause_menu.gd:72-76` 加 4 个 `@onready var _quick_stats_achievement` / `_quick_stats_best_time` / `_quick_stats_longest_room` / `_quick_stats_run_number` (4 sub-Label 引用) + docblock 1 行注释 (T217 #138 ProfileQuickStats 4 段独立 hover 联动 source-grep 锚点)；(3) `src/scripts/pause_menu.gd:490-501` 加 `func _on_quick_stats_hover_in(idx: int)` handler 4 步骤 (idx 越界 0-3 检查 + 4 sub-Label null guard + re-entrant guard `_quick_stats_hovered_idx == idx` 早返 + set idx + 调 _apply)；(4) `src/scripts/pause_menu.gd:503-520` 加 `func _on_quick_stats_hover_out(idx: int)` handler 5 步骤 (越界 + null guard + "已经被其他段接管" 早返 + 4 段 mouse_exited 顺序注释 + set idx = -1 + 调 _apply)；(5) `src/scripts/pause_menu.gd:667` 加 `var _quick_stats_hovered_idx: int = -1` 状态字段 (替代 T214 bool 1 bit, 0/1/2/3 段对应 0-3 idx, -1 表示无 hover)；(6) `src/scripts/pause_menu.gd:540 + 554-571` 加 `const _QUICK_STATS_HOVER_FADE_DURATION := 0.3` + `func _apply_quick_stats_hover_state()` 4 sub-Label modulate 0.3s 渐变 (T225 升级 snap 立即到 tween 渐变) + kill 旧 `_quick_stats_hover_tween` 防快速 hover 进出叠加撕裂；(7) `src/scripts/pause_menu.gd:816-829` 4 sub-Label 各自 connect `_on_quick_stats_hover_in.bind(idx)` / `_on_quick_stats_hover_out.bind(idx)` (4 段独立事件入口)。7 处 1:1 同步，1 漏 1 = 1 Label 旧模式残留 / idx 状态字段缺失 / 4 段 click 联动错位 / tween 叠加撕裂。

- **修复**：`src/scripts/pause_menu.gd:490-571` ProfileQuickStats 4 段独立 hover 联动 + click 联动采用「4 sub-Label 拆分 + 1 段 idx 状态 + 1 对 hover_in/out handler + 1 个 _apply 函数 4 sub-Label modulate 重算 + 1 个 _hover_tween 全局 tween + 4 段 click 独立 _pulse_tweens Dictionary」6 件套：
  ```gdscript
  # src/scripts/pause_menu.gd:667 — 1 段 idx 状态字段
  var _quick_stats_hovered_idx: int = -1
  
  # src/scripts/pause_menu.gd:540 — 0.3s 渐变时长 (T225 节奏, 比 T226 slot 0.12s / T231 RecentList 0.12s 慢 = QuickStats 主面板慢节奏)
  const _QUICK_STATS_HOVER_FADE_DURATION := 0.3
  
  # src/scripts/pause_menu.gd:490-501 — hover_in handler (idx 0-3 越界 + null guard + re-entrant guard + set idx + 调 _apply)
  func _on_quick_stats_hover_in(idx: int) -> void:
      if idx < 0 or idx > 3: return
      if not _quick_stats_achievement or not _quick_stats_best_time \
              or not _quick_stats_longest_room or not _quick_stats_run_number: return
      if _quick_stats_hovered_idx == idx: return  # re-entrant guard 0 副作用
      _quick_stats_hovered_idx = idx
      _apply_quick_stats_hover_state()
  
  # src/scripts/pause_menu.gd:554-571 — _apply 函数 (4 sub-Label modulate 0.3s 渐变)
  func _apply_quick_stats_hover_state() -> void:
      if not _quick_stats_achievement ...: return
      if _quick_stats_hover_tween != null and _quick_stats_hover_tween.is_valid():
          _quick_stats_hover_tween.kill()  # kill 旧 tween 防快速 hover 进出叠加撕裂
      var t := create_tween()
      t.set_parallel(true)
      var subs: Array = [_quick_stats_achievement, _quick_stats_best_time, _quick_stats_longest_room, _quick_stats_run_number]
      for i in range(4):
          var target_color: Color = Color.WHITE if i == _quick_stats_hovered_idx else _QUICK_STATS_DIM
          t.tween_property(subs[i], "modulate", target_color, _QUICK_STATS_HOVER_FADE_DURATION)\
              .set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
      _quick_stats_hover_tween = t
  ```
  - 4 sub-Label 拆分 — tscn 14 行 (4 sub-Label + 3 Sep + 2 Star) + 4 `@onready var` 1:1 替代 T214 旧版 1 Label + 4 BBCode 段 + 1 Run# 段。mouse_entered 是 Label 级事件, 4 段独立 sub-Label 才能表达"1 段高亮 + 3 段 dim"独立事件。
  - `_quick_stats_hovered_idx: int = -1` 状态字段 — 替代 T214 旧版 `_quick_stats_hovered: bool` 1 bit, 0/1/2/3 段对应 0-3 idx, -1 = 无 hover。re-entrant guard `_quick_stats_hovered_idx == idx` 早返避免重复 _apply。
  - 1 对 hover_in / hover_out handler + idx 越界 0-3 检查 + 4 sub-Label null guard — T214 旧版 0 越界 0 null guard, T217 升级加双 guard 防 polish 期断点。
  - `_apply_quick_stats_hover_state` 4 sub-Label modulate 重算 — idx 段 = Color.WHITE (亮), 其他 3 段 = `_QUICK_STATS_DIM` (0.5 alpha 暗) + 0.3s tween 渐变 (T225 升级 snap 立即)。kill 旧 tween 防快速 hover 进出叠加撕裂 (例如 hover Achievement (idx=0) 0.3s fade 期间移到 BestTime (idx=1), mouse_exited(0) → hovered=-1 → fade 到 all dim; mouse_entered(1) → hovered=1 → fade 到 idx 1 亮 + 3 段 dim)。
  - `_quick_stats_pulse_tweens: Dictionary = {}` (T218 #139 click 联动) — 4 段 click 各自 track 各自 target, 互不打断。4 段并发 click 时第二次 click 0 kill 第一次 (与 `_quick_stats_hover_tween` 单一全局模式不同)。
  - T225 0.3s 节奏分层 — QuickStats 主面板 0.3s (慢节奏, 主面板玩家视觉停留久) vs AchievementGrid slot 0.12s (紧凑节奏, 14 slot 扫视) vs RecentList 0.12s (紧凑节奏, 5 行扫视), 跨面板节奏分层玩家一致感知。

- **预防**：
  1. 任何 polish 期给 ProfileQuickStats 4 段 (Achievement / BestTime / LongestRoom / RunNumber) 加新维度 (1 段高亮 + 3 段 dim / 4 段 click / 第 5 段接入 / 0.3s 渐变 tween 节奏) 时**必须**严格按 7 步骤 1:1 复制既有 verb 模式：(1) pause_menu.tscn `ProfileQuickStats` HBoxContainer 拆 4 sub-Label + 3 Sep + 2 Star (14 行 tscn 0 漏) + (2) 4 `@onready var _quick_stats_<segment>` (4 段 1:1) + (3) `var _quick_stats_hovered_idx: int = -1` 状态字段 (idx -1=无/0-3=段) + (4) `func _on_quick_stats_hover_in(idx: int)` (越界 + null + re-entrant + set + 调 _apply) + (5) `func _on_quick_stats_hover_out(idx: int)` (越界 + null + "已接管" 早返 + set -1 + 调 _apply) + (6) `func _apply_quick_stats_hover_state()` 4 sub-Label modulate 重算 (kill 旧 tween + set_parallel + 0.3s 渐变) + (7) `pause_menu.gd:_ready` 4 sub-Label 各自 connect `mouse_entered.bind(idx)` / `mouse_exited.bind(idx)` (4 段独立事件入口)。建议在 `_on_quick_stats_hover_in` 函数顶部 docblock 写明 "1 段 idx 高亮 + 3 段 dim 全联动" 硬约束, 下次扩展时先看 docblock 确认 N 段结构。
  2. 4 sub-Label 1:1 拆分 (T214 旧版 1 Label + 4 BBCode 段 → T217 4 sub-Label) **必须**保持, 0 回到 1 Label + BBCode string 替换旧模式, source-grep 验证 4 `@onready var _quick_stats_<segment>` 0 漏。任何"统一改回 1 Label"polish 必须 0 触碰 4 段独立事件入口 + 0 触碰 `_apply_quick_stats_hover_state` 4 sub-Label modulate 重算。
  3. `_quick_stats_hovered_idx: int = -1` 状态字段 (替代 T214 bool 1 bit) **必须**保持, 0 改回 bool, source-grep 验证 `_quick_stats_hovered_idx` 0 触碰。任何"bool 简化"polish 必须先 source-grep 验证 4 段 mouse_entered 顺序 (mouse_exited(0) 先 fire 然后 mouse_entered(1) 再 fire) 0 触碰 0 错位。
  4. T225 `_quick_stats_hover_tween` 1 个全局 tween (4 sub-Label 共享 1 个 tween, 4 个 set_parallel tween_property) + T218 `_quick_stats_pulse_tweens: Dictionary` (4 段 click 各自 track 各自 target) 两种 tween 共享模式 **必须**保持各自独立, 0 互混。任何"统一 tween 共享"polish 必须先 source-grep 验证 1 var + 1 dict 0 触碰 0 互混。
  5. T225 0.3s 节奏 (主面板慢节奏) + T226 slot 0.12s (紧凑节奏) + T231 RecentList 0.12s (紧凑节奏) **必须**保持跨面板节奏分层, 0 统一为 0.12s 或 0.3s, source-grep 验证 3 const (`_QUICK_STATS_HOVER_FADE_DURATION` 0.3 / `_SLOT_HOVER_FADE_DURATION` 0.12 / `_RECENT_ROW_HOVER_FADE_DURATION` 0.12) 0 触碰。

### 9.6.9 AchievementGrid locked slot 解锁进度 alpha lerp + ProfileRecentList 5 行 alpha 渐变 base + 跨面板 `_alpha_base` Dictionary 双源 polish 模式 (T222 #144 + T219 #141 + T226 #145 落地)

> §9.6.1 记录 6 verb VFX 跨类 handler 双守卫；§9.6.2 记录单个 VFX 5 layer 视觉；§9.6.3 记录 HUD 6 verb 行 5+1 verb 7 UI 通道同步扩 verb；§9.6.4 记录 6 verb 三闭环宪法；§9.6.5 记录 6 verb tooltip 8 行拼接；§9.6.6 记录 ProfileRecentList 7 字段 format 字符串扩展；§9.6.7 记录 ProfileRecentList 三件套 hover feedback；§9.6.8 记录 ProfileQuickStats 4 段独立 hover 联动。本节记录 PauseMenu 跨面板「alpha 渐变 base + 解锁进度联动 alpha」双源 polish 模式 —— T222 (#144) AchievementGrid 14 slot 中 locked slot alpha 跟随 `unlocked/total` 进度线性插值 (0.5→0.2 lerp, 0.2 终点避免 fade 到底 0 透明让玩家以为"成就消失") + T219 (#141) ProfileRecentList 5 行 row alpha 5 步等差梯度 (1.0 / 0.875 / 0.75 / 0.625 / 0.5, 步长 0.125, 最新 1 局满亮 + 最旧 1 局 50% 暗) + T226 (#145) 跨面板 `_slot_hover_alpha_base` + `_recent_row_hover_alpha_base` 两个 Dictionary 存 base alpha 给 hover handler +0.1 boost 使用 (T226 + T231 跨面板 hover 反馈 base 字典 100% 同源)。3 个 polish 任务 (#141, #144, #145) 跨 4 轮反复落地的「alpha 渐变 + 解锁进度联动 + 跨面板 base 字典」三件套模式录入 CONTRIBUTING.md §9.6.9，避免未来 polish 任何 "locked slot 解锁进度 alpha / 5 行 row alpha 渐变 / 跨面板 hover 反馈 base 字典" 时漏 1 处同步。

- **症状**：polish 期给 PauseMenu 跨面板加 alpha 渐变 (AchievementGrid locked slot 解锁进度 / ProfileRecentList 5 行 row 时序) 时, 最常见的 fragile 是「(a) `_ACHV_LOCKED_ALPHA_START/END` 0.5→0.2 终点 0 触碰」— T222 (#144) 落地时选 0.2 (非 0.0) 终点避免 fade 到底 0 透明让玩家以为"成就消失", 任何"优化"polish (e.g. 改 0.2 为 0.0 让 fade 更彻底) 都会破坏 "完成态 = locked slot 仍可见" 的视觉组语义；「(b) `_RECENT_ROW_ALPHA_MAX/MIN` 1.0/0.5 0 触碰 步长 0.125 5 步等差」— T219 (#141) 落地时算 `alpha_step = (_RECENT_ROW_ALPHA_MAX - _RECENT_ROW_ALPHA_MIN) / float(_PROFILE_RECENT_RUNS_MAX - 1) = 0.5/4 = 0.125`, 任何"扩到 6 行 / 缩到 3 行"polish 必须同步扩展 / 缩 `_PROFILE_RECENT_RUNS_MAX` const, 0 改 5 行 row base alpha 0.125 步长公式；「(c) `_ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3)` 暗灰调 + `Color(...).a = locked_alpha` 改 alpha 0 改 RGB 0 触碰」— RGB 通道保留暗灰调, 只改 alpha 通道让玩家视觉组 "locked slot 暗灰 = 仍未解锁" 一致, 任何 "改 RGB 让 locked slot 更亮" polish 都会破坏 locked slot 视觉组；「(d) `_slot_hover_alpha_base` + `_recent_row_hover_alpha_base` 两个 Dictionary 跨面板 base 字典 0 互混」— T226 (#145) + T231 (#151) 跨面板 hover +0.1 boost 走 dict 读 base, `_slot_hover_alpha_base` 存 slot→base_alpha (T222 lerp 0.5→0.2) + `_recent_row_hover_alpha_base` 存 row→base_alpha (T219 5 行 1.0/0.875/0.75/0.625/0.5), 两个 dict 各自独立, 任何"统一 base 字典"polish 都会破坏跨面板 hover 反馈源 (T226 locked slot 0.5/0.2 + T231 recent row 1.0/0.875/0.75/0.625/0.5 各自不同 base)。
- **触发场景**：T222 (#144) + T219 (#141) + T226 (#145) AchievementGrid locked slot 解锁进度 + ProfileRecentList 5 行 alpha 渐变 + 跨面板 base 字典落地需同步 7 处：(1) `src/scripts/pause_menu.gd:1065-1067` `const _ACHV_LOCKED_ALPHA_START := 0.5` + `const _ACHV_LOCKED_ALPHA_END := 0.2` + `const _ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3)` (T222 三个 const 0 触碰, 0.2 终点 + 暗灰 RGB 锁定)；(2) `src/scripts/pause_menu.gd:642-643` `const _RECENT_ROW_ALPHA_MAX := 1.0` + `const _RECENT_ROW_ALPHA_MIN := 0.5` (T219 两个 const 0 触碰, 5 步等差梯度 base 边界锁定)；(3) `src/scripts/pause_menu.gd:707` `var _slot_hover_alpha_base: Dictionary = {}` + 1324/1329 行 `_slot_hover_alpha_base[child] = 1.0` (unlocked) / `= locked_alpha` (locked lerp) (T222 末尾 base 存 dict, T226 读 dict hover +0.1 boost 用)；(4) `src/scripts/pause_menu.gd:720` `var _recent_row_hover_alpha_base: Dictionary = {}` + 1916 行 `_recent_row_hover_alpha_base[i] = row_alpha` (T219 末尾 5 行 base 存 dict, T231 读 dict hover +0.1 boost 用)；(5) `src/scripts/pause_menu.gd:1303-1329` `_refresh_achievement_grid` 末尾 unlocked → `Color.WHITE` + `_slot_hover_alpha_base[child] = 1.0` + locked → `_ACHV_LOCKED_COLOR_RGB` + alpha=locked_alpha + `_slot_hover_alpha_base[child] = locked_alpha` 3 段联动 (T222 联动 T226, 1 漏 1 = T226 hover 0 base / 0 hover boost)；(6) `src/scripts/pause_menu.gd:1907-1916` `_refresh_recent_runs_list` 末尾 `alpha_step = (_RECENT_ROW_ALPHA_MAX - _RECENT_ROW_ALPHA_MIN) / float(_PROFILE_RECENT_RUNS_MAX - 1)` 步长公式 + `row_alpha = _RECENT_ROW_ALPHA_MAX - float(i) * alpha_step` 5 行 linear + `row_lbl.modulate = Color(1.0, 1.0, 1.0, row_alpha)` 应用 + `_recent_row_hover_alpha_base[i] = row_alpha` 存 dict (T219 联动 T231, 1 漏 1 = T231 hover 0 base / 0 hover boost)；(7) `src/scripts/pause_menu.gd:1249-1301` `_on_slot_hover_in` / `_on_slot_hover_out` 走 `var base_alpha: float = 1.0` (defensive) + `if _slot_hover_alpha_base.has(slot): base_alpha = _slot_hover_alpha_base[slot]` 读 dict (T226 跨面板 hover 反馈 base 字典读, 0 base = unlocked 1.0 hardcoded fallback)。7 处 1:1 同步，1 漏 1 = 解锁进度 alpha 错位 / 5 行 row 渐变错位 / 跨面板 hover feedback 0 base 报错。
- **修复**：`src/scripts/pause_menu.gd:1065-1067 + 642-643 + 707 + 720 + 1303-1329 + 1907-1916 + 1249-1301` 跨面板 alpha 渐变 + 解锁进度联动 + 跨面板 base 字典三件套采用「3 const 锁定 (T222 0.5/0.2/0.25,0.25,0.3 + T219 1.0/0.5) + 2 var 跨面板 base dict (_slot_hover_alpha_base + _recent_row_hover_alpha_base) + 1 _refresh 末尾 base 存 dict (T222 1303-1329 14 slot lerp + T219 1907-1916 5 行 linear) + 1 hover handler 读 dict (T226 1249-1301 + T231 1957-2030)」4 件套：
  ```gdscript
  # src/scripts/pause_menu.gd:1065-1067 — T222 解锁进度 alpha lerp 3 const 锁定
  const _ACHV_LOCKED_ALPHA_START := 0.5
  const _ACHV_LOCKED_ALPHA_END := 0.2  # 0.2 终点避免 fade 到底 0 透明让玩家以为"成就消失"
  const _ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3)  # 暗灰调, 只改 alpha 0 改 RGB
  
  # src/scripts/pause_menu.gd:642-643 — T219 5 行 row alpha 渐变 2 const 锁定
  const _RECENT_ROW_ALPHA_MAX := 1.0  # i==0 满亮
  const _RECENT_ROW_ALPHA_MIN := 0.5  # i==4 50% 暗, 5 步等差步长 0.125
  
  # src/scripts/pause_menu.gd:707 + 720 — 跨面板 2 base dict 0 互混
  var _slot_hover_alpha_base: Dictionary = {}  # slot → base_alpha (T222 lerp 0.5→0.2)
  var _recent_row_hover_alpha_base: Dictionary = {}  # row → base_alpha (T219 5 行 1.0→0.5)
  
  # src/scripts/pause_menu.gd:1303-1329 — T222 + T226 跨 _refresh_achievement_grid 联动
  func _refresh_achievement_grid() -> void:
      var unlocked_count: int = PlayerStats.get_unlocked_count()
      var total_count: int = PlayerStats.get_total_count()
      var progress: float = 0.0
      if total_count > 0:
          progress = float(unlocked_count) / float(total_count)
      var locked_alpha: float = lerp(_ACHV_LOCKED_ALPHA_START, _ACHV_LOCKED_ALPHA_END, progress)
      var locked_color: Color = Color(_ACHV_LOCKED_COLOR_RGB.r, _ACHV_LOCKED_COLOR_RGB.g, _ACHV_LOCKED_COLOR_RGB.b, locked_alpha)
      for child in _achv_grid.get_children():
          if not child.name.begins_with("AchvSlot_"):
              continue
          var id_val: String = child.name.substr(9)
          if PlayerStats.is_unlocked(id_val):
              child.modulate = Color.WHITE
              child.self_modulate = Color.WHITE
              _slot_hover_alpha_base[child] = 1.0  # T226 unlocked base 1.0
          else:
              child.modulate = locked_color
              child.self_modulate = locked_color
              _slot_hover_alpha_base[child] = locked_alpha  # T226 locked base = T222 lerp
  
  # src/scripts/pause_menu.gd:1907-1916 — T219 + T231 跨 _refresh_recent_runs_list 联动
  var alpha_step: float = (_RECENT_ROW_ALPHA_MAX - _RECENT_ROW_ALPHA_MIN) / float(_PROFILE_RECENT_RUNS_MAX - 1)
  var row_alpha: float = _RECENT_ROW_ALPHA_MAX - float(i) * alpha_step
  row_lbl.modulate = Color(1.0, 1.0, 1.0, row_alpha)
  _recent_row_hover_alpha_base[i] = row_alpha  # T231 row base 5 行 dict
  
  # src/scripts/pause_menu.gd:1249-1273 — T226 跨 _on_slot_hover_in 读 dict 模式
  func _on_slot_hover_in(slot: TextureRect) -> void:
      if not is_instance_valid(slot):
          return
      var base_alpha: float = 1.0  # defensive fallback (unlocked 1.0 / locked 0.5-0.2)
      if _slot_hover_alpha_base.has(slot):
          base_alpha = _slot_hover_alpha_base[slot]
      var boosted_alpha: float = clampf(base_alpha + _SLOT_HOVER_BRIGHT_ALPHA_BOOST, 0.0, 1.0)
      # ... 1.5x 放大 + 暖色 modulate + alpha boost 0.12s 渐变 (T226 + T111 升级)
  ```
  - 3 const 锁定 — T222 `_ACHV_LOCKED_ALPHA_START/END` (0.5/0.2) + `_ACHV_LOCKED_COLOR_RGB` (0.25, 0.25, 0.3) + T219 `_RECENT_ROW_ALPHA_MAX/MIN` (1.0/0.5) 5 const 各自独立, 0 互混, source-grep 验证 5 const 0 漏 0 改 1 字符。
  - 2 var 跨面板 base dict 0 互混 — `_slot_hover_alpha_base` (slot → base_alpha, 0.5/0.2 lerp 跟随解锁进度) + `_recent_row_hover_alpha_base` (row → base_alpha, 1.0/0.875/0.75/0.625/0.5 5 步等差), 两个 dict 各自独立 key (TextureRect slot vs int row idx), value 类型一致 (float) 但语义不同。
  - 0.2 终点 (T222 关键设计) — 0 选 0.0 避免 fade 到底 0 透明让玩家以为"成就消失", 0.2 仍可见 0 抢眼, 玩家视觉组 "完成态 = locked slot 仍可见 暗灰淡出" 一致。
  - 暗灰 RGB 锁定 (T222 关键设计) — `_ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3)` 暗灰调, 只改 alpha 通道 (locked_alpha), 0 改 RGB, 玩家视觉组 "locked slot 暗灰 = 仍未解锁" 一致。
  - 5 步等差步长 0.125 (T219 关键设计) — `alpha_step = (_RECENT_ROW_ALPHA_MAX - _RECENT_ROW_ALPHA_MIN) / float(_PROFILE_RECENT_RUNS_MAX - 1) = 0.5/4 = 0.125` 严格 5 步等差, 任何 "改 _PROFILE_RECENT_RUNS_MAX 6/3 行" polish 必须同步更新步长公式, 0 触碰边界 const。
  - defensive fallback 1.0 (T226 关键防御) — `_on_slot_hover_in` 走 `var base_alpha: float = 1.0` (defensive: _refresh 之前 _on_slot_hover_in 0 越界读 dict fallback), 避免 polish 期 _refresh 顺序错位 (hover handler 先 fire 后 _refresh 跑) 触发 `KeyError` 抛错。
- **预防**：
  1. 任何 polish 期给 AchievementGrid 14 slot 加解锁进度 alpha 联动 或 给 ProfileRecentList 5 行 row 加 alpha 渐变时**必须**严格按 7 步骤 1:1 复制既有模式：(1) 3 const 锁定 (T222 _ACHV_LOCKED_ALPHA_START/END/_ACHV_LOCKED_COLOR_RGB + T219 _RECENT_ROW_ALPHA_MAX/MIN) + (2) 2 var 跨面板 base dict (_slot_hover_alpha_base + _recent_row_hover_alpha_base) + (3) _refresh_achievement_grid 末尾 unlocked/locked 2 path base 存 dict + (4) _refresh_recent_runs_list 末尾 5 行 row base 存 dict + (5) alpha_step 步长公式 (1.0-0.5) / (5-1) = 0.125 严格 5 步等差 + (6) Color(...).a = locked_alpha 改 alpha 0 改 RGB + (7) hover handler 读 dict (T226 _on_slot_hover_in/out 7 处 + T231 _on_recent_row_hover_in/out 4 处), 0 改 3 const 0 改步长公式 0 改 defensive fallback 1.0。
  2. `_ACHV_LOCKED_ALPHA_END := 0.2` 0 触碰 — 0 改 0.0 让 fade 到底 0 透明 (破坏 "完成态 = locked slot 仍可见" 视觉组), 0 改 0.4 让 fade 不明显 (破坏 "完成态 = locked slot 暗灰淡出" 视觉组), source-grep 验证 `_ACHV_LOCKED_ALPHA_END` 0 改 1 字符。
  3. `_ACHV_LOCKED_COLOR_RGB := Color(0.25, 0.25, 0.3)` 0 改 RGB — 0 改 RGB 通道让 locked slot 更亮 (破坏 "locked slot 暗灰 = 仍未解锁" 视觉组), 0 改 alpha 通道 (locked_alpha 0 改), 任何 "RGB 改 1 通道" polish 0 允许, source-grep 验证 `_ACHV_LOCKED_COLOR_RGB` 0 改 1 字符。
  4. 5 步等差步长 0.125 + `_PROFILE_RECENT_RUNS_MAX` 0 触碰 — `alpha_step = (_RECENT_ROW_ALPHA_MAX - _RECENT_ROW_ALPHA_MIN) / float(_PROFILE_RECENT_RUNS_MAX - 1)` 严格 5 步等差公式 0 改, 任何 "扩 6 行 / 缩 3 行" polish 必须**先**改 `_PROFILE_RECENT_RUNS_MAX` const 0 改步长公式 0 改边界 1.0/0.5, source-grep 验证 3 const (`_PROFILE_RECENT_RUNS_MAX` + `_RECENT_ROW_ALPHA_MAX` + `_RECENT_ROW_ALPHA_MIN`) + 步长公式 0 漏 0 改。
  5. 跨面板 2 base dict 0 互混 — `_slot_hover_alpha_base` (TextureRect slot → float) + `_recent_row_hover_alpha_base` (int row idx → float) 各自独立 key 类型 + value 语义, 任何"统一 base 字典"polish 必须先 source-grep 验证 2 dict 0 互混 (T226 slot 0.5/0.2 lerp 跟随解锁进度 vs T231 row 1.0/0.875/0.75/0.625/0.5 5 步等差), 0 触碰。
  6. defensive fallback 1.0 (T226 关键防御) **必须**保持 — `var base_alpha: float = 1.0` (defensive: _refresh 之前 _on_slot_hover_in 0 越界读 dict fallback) 0 删, 任何"简化"polish (e.g. 删 fallback 走 if/else) 必须先 source-grep 验证 polish 期 _refresh 顺序 0 错位 (hover handler 先 fire 后 _refresh 跑) 0 触发 `KeyError`。
  7. T226 `_SLOT_HOVER_FADE_DURATION := 0.12` (T226 AchievementGrid slot 紧凑节奏) + T231 `_RECENT_ROW_HOVER_FADE_DURATION := 0.12` (T231 ProfileRecentList 5 行紧凑节奏) + T225 `_QUICK_STATS_HOVER_FADE_DURATION := 0.3` (T225 ProfileQuickStats 4 段主面板慢节奏) 三种跨面板 hover 节奏 **必须**保持各自独立, 0 互混, 0 统一为 0.12s 或 0.3s, source-grep 验证 3 const 0 触碰 (与 §9.6.8 预防 5 跨面板节奏分层 100% 闭环)。

### 9.6.10 「hover 静态高亮层 + tooltip 数据源层」双层 hover 互补 polish 模式 (T212 #132 + T213 #133 + T215 #136 + T216 #137 + T217 #138 落地)

> §9.6.1 记录 6 verb VFX 跨类 handler 双守卫；§9.6.2 记录单个 VFX 5 layer 视觉；§9.6.3 记录 HUD 6 verb 行 5+1 verb 7 UI 通道同步扩 verb；§9.6.4 记录 6 verb 三闭环宪法；§9.6.5 记录 6 verb tooltip 8 行拼接；§9.6.6 记录 ProfileRecentList 7 字段 format 字符串扩展；§9.6.7 记录 ProfileRecentList 三件套 hover feedback (T231 + T240 + T235)；§9.6.8 记录 ProfileQuickStats 4 段独立 hover 联动 (T217 + T225)；§9.6.9 记录 PauseMenu 跨面板 alpha lerp + 5 行渐变 + 2 base dict 双源 (T222 + T219 + T226)。本节记录 PauseMenu 跨面板「hover 静态高亮层 + tooltip 数据源层」双层 hover 互补 polish 模式 —— 5 个 polish 任务 (#132 + #133 + #136 + #137 + #138) 跨 4 轮 (T212 #132 + T213 #133 = ProfileQuickStats 4 段 tooltip 静态信息层; T215 #136 = ProfileRecentList 5 行 row 静态高亮层; T216 #137 = ProfileRecentList 5 行 row tooltip 静态信息层; T217 #138 = ProfileQuickStats 4 段独立 hover 动态焦点层) 反复落地的「双层 hover 互补」结构 —— 静态高亮层 (T215 5 行 Color.WHITE snap 立即 + T217 4 段 idx 0.3s 渐变) + tooltip 数据源层 (T213 4 段 `_QUICK_STATS_HINT` + `_build_quick_stats_tooltip` / T216 5 字段 `_RECENT_ROW_HINT` + `_build_recent_row_tooltip`) 双层独立组件，2 个组件都从「权威 const 数据源 + pure builder function」组装，polish 期任何"hover 高亮"或"tooltip 文本"独立扩展时 0 触碰另 1 层。避免未来 polish 任何"hover 高亮层 / tooltip 数据源层 / 双层数据共享"时漏 1 处同步。

- **症状**：polish 期给 PauseMenu 跨面板 (ProfileQuickStats 4 段 + ProfileRecentList 5 行) hover 反馈加新维度 (静态高亮层 / tooltip 数据源层 / 4 段 ↔ 5 字段数据共享 / 第 3 面板接入) 时, 最常见的 fragile 是「(a) 静态高亮层 (T215 / T217) 与 tooltip 数据源层 (T213 / T216) 1:1 配套混用」— T215 5 行 Color.WHITE snap 立即 (旧版路径, 已被 T240 #158 升级为 0.12s tween) + T213 4 段 tooltip 9 行说明是 2 个独立组件, 1 个层加新字段 (e.g. T215 5 行 row 加"最近 1 局"加亮等级) 不需要触碰 T213 4 段 tooltip (4 段 vs 5 行结构不同, 数据语义不同), 任何"统一高亮 + tooltip 1 个组件"polish 都会破坏 1:1 双层独立；「(b) 静态高亮层 T215 5 行 row 状态字段 `_recent_row_hovered` (Array[bool]) + `_recent_row_default_color` (Array[Color]) 漏 1 字段」— 5 行 row 独立 hover 状态必须 2 字段同步 (hovered 标志 + default color 还原色), 任何"5 行共享 1 个 hovered bool"polish 都会破坏 5 行独立 (玩家 hover 第 3 行只提亮第 3 行, 其他 4 行保持原色, 0 跨行联动)；「(c) tooltip 数据源层 T213 `_QUICK_STATS_HINT` (4 entry dict, 每 entry 5 字段 label/color/color_name/desc_zh/detail) + T216 `_RECENT_ROW_HINT` (7 entry dict, 每 entry 3 字段 label/desc_zh/detail) 1 漏 1 字段顺序错位」— _*_HINT const 是 tooltip 文本的权威数据源, 任何"加 1 段 (e.g. QuickStats 加 "总 5 段" 第 5 段) 或加 1 字段 (e.g. RecentList 加 "净/净" 派生率 → 8 字段) 0 改 builder function 体 (for h in _*_HINT 自动遍历) 但 0 触碰 const entry 字段顺序"label / color / color_name / desc_zh / detail" 0 触碰, 1 漏 1 字段 = tooltip 渲染错位；「(d) 双层数据共享 0 触碰 (T213 4 段 vs T216 7 字段) 0 复用」— T213 (4 段 "跨 run 累计") vs T216 (7 字段 "单 run 明细", T249 #167 扩展 5 → 7 字段) 数据语义完全不同 (T213 是"我在第几局" 跨 run 累计, T216 是"这一局我做了啥" 单 run), 0 复用 const (T213 4 段 vs T216 5 字段 vs T249 #167 7 字段扩展 0 改结构), 任何"统一 *_HINT"polish 都会破坏 4 段 / 5 字段 / 7 字段各自独立。
- **触发场景**：T212 (#132) + T213 (#133) + T215 (#136) + T216 (#137) + T217 (#138) 双层 hover 互补 跨面板 落地需同步 7 处：(1) `src/scripts/pause_menu.gd:323-352` `_QUICK_STATS_HINT` 4 entry dict (T213) — 每 entry 5 字段 (label / color / color_name / desc_zh / detail) 0 漏, 4 段顺序 Achievement → BestTime → LongestRoom → Run# 0 乱, 颜色 token 与 _stat_abilities / _profile_abilities 5 verb BBCode 1:1 对齐 (Glass Cyan #69C7CE / Amber Voice #F2B66E / Muted Violet #65506A / Pale Resonance #B7E6DC)；(2) `src/scripts/pause_menu.gd:359-373` `_build_quick_stats_tooltip()` 9 行 pure function (T213) — 1 header + 4 段 4 字段 (label / desc_zh) + 4 段 4 字段 (color / color_name / detail) = 9 行, 走纯文本 + \n 拼接 (Label 节点 bbcode_enabled 0 走 tooltip 路径, 0 改), 0 触碰 for h in _QUICK_STATS_HINT 循环 0 改字典字段访问顺序 (label → desc_zh → color → color_name → detail)；(3) `src/scripts/pause_menu.gd:402-438` `_RECENT_ROW_HINT` 7 entry dict (T216, T249 #167 扩展 5 → 7 entry) — 每 entry 3 字段 (label / desc_zh / detail) 0 漏, 7 字段顺序 Run# → 房 → 净 → 碎 → 时 → 房/时 → 净/时 0 乱 (与 §9.6.6 7 字段 format 字符串 1:1 严格对齐)；(4) `src/scripts/pause_menu.gd:463-473` `_build_recent_row_tooltip()` pure function (T216) — 1 header + 7 字段 2 行 (label/desc_zh + detail) = 1 + 7*2 = 15 行, 与 T213 _build_quick_stats_tooltip 9 行 0 互混 (9 vs 15 行结构不同, 数据语义不同), 0 改字典字段访问顺序 (label → desc_zh → detail), 0 改 "• %s — %s" 格式 (T213 同款, 跨面板 1:1)；(5) `src/scripts/pause_menu.gd:721-732` 双层 hover 互补 5 行 row 状态字段 (T215) — `var _recent_row_hovered: Array = []` (Array[bool] length = _PROFILE_RECENT_RUNS_MAX, 5 行独立 bool flag) + `var _recent_row_default_color: Array = []` (Array[Color] length = row count, 5 行还原色缓存, 避免 hover_out 错把高亮版当 default 写回), 2 字段顺序在 T217 `_quick_stats_hovered_idx: int = -1` 字段之后, _ready 之前声明 (T215 0 触碰 T217 idx 字段, 0 触碰 T214 旧版 bool 字段), 0 跨行联动 (5 行独立 hover_in handler, bind idx 0-4 各自 1 闭包)；(6) `src/scripts/pause_menu.gd:801-803` ProfileQuickStats 4 段总览 hover tooltip 绑定 (T213 + T217) — `_profile_quick_stats.tooltip_text = _build_quick_stats_tooltip()` 1 行 0 改 (T213 数据源 0 改), 绑定到 HBoxContainer parent (T217 拆 4 sub-Label 后 4 sub-Label 共享同一 tooltip, 玩家悬停任 1 sub-Label 都弹同一文本, 0 行为差异)；(7) `src/scripts/pause_menu.gd:805-830` ProfileQuickStats 4 段独立 hover 联动 (T217) — 4 sub-Label (QuickStatsAchievement / QuickStatsBestTime / QuickStatsLongestRoom / QuickStatsRunNumber) 各 mouse_filter = STOP 显式设 (Label 默认 IGNORE, 必须改 STOP 才能触发 mouse_entered, 与 T111 成就 grid TextureRect + T215 5 行 row Label 同模式) + 4 sub-Label mouse_entered.connect(_on_quick_stats_hover_in.bind(0/1/2/3)) (4 段独立 bind idx 0-3 各自 1 闭包, 0 共享 1 个 idx) + mouse_exited.connect(_on_quick_stats_hover_out.bind(0/1/2/3)) 同 1 对。7 处 1:1 同步，1 漏 1 = 双层 hover 反馈错位 / 5 行 row 状态字段缺失 / 4 段独立 hover 联动退化为 1 段。
- **修复**：`src/scripts/pause_menu.gd` 跨面板「hover 静态高亮层 + tooltip 数据源层」双层 hover 互补 polish 模式 (T212 + T213 + T215 + T216 + T217 跨 5 任务 4 轮落地)：
  - **T213 (#133) ProfileQuickStats 4 段 tooltip 数据源层** — `const _QUICK_STATS_HINT := [...]` 4 entry dict (Achievement / BestTime / LongestRoom / Run#) + `func _build_quick_stats_tooltip() -> String` 9 行 pure function (1 header + 4 段 4 字段 = 9 行, 0 改字典字段访问顺序) + `tooltip_text = _build_quick_stats_tooltip()` 1 行绑定 (走 HBoxContainer parent 让 4 sub-Label 共享)。与 T199 5 verb tooltip + T216 5 字段 tooltip 模式完全同源 (权威 const 数据源 + pure builder function + tooltip_text 1 行绑定), 0 走 BBCode 包裹 (Label 节点 bbcode_enabled 0 走 tooltip 路径, 0 改), 走纯文本 + \n 拼接, Godot 4.6 自带 tooltip 渲染器 5s timeout。
  - **T215 (#136) ProfileRecentList 5 行 row 静态高亮层** — `var _recent_row_hovered: Array = []` (5 行独立 bool flag) + `var _recent_row_default_color: Array = []` (5 行还原色缓存) + 5 行 row 各自 mouse_filter = STOP 显式设 + 5 行 row mouse_entered.connect(_on_recent_row_hover_in.bind(i)) + 5 行 row mouse_exited.connect(_on_recent_row_hover_out.bind(i)) + 2 handler 内部 越界检查 + re-entrant guard + Color.WHITE 提亮 (旧版 snap 立即, T240 #158 升级 0.12s tween) + restore 到 _recent_row_default_color[idx] (避免误把高亮版当 default 写回) + _refresh_recent_runs_list 起始 `_recent_row_hovered.clear()` + `_recent_row_default_color.clear()` (每次 _refresh 重建 5 行, 数组 resize)。0 跨行联动 (5 行独立 hover_in handler, bind idx 0-4 各自 1 闭包, 玩家 hover 第 3 行只提亮第 3 行, 其他 4 行保持原色, 避免重叠抖动)。
  - **T216 (#137) ProfileRecentList 5 行 row tooltip 数据源层** — `const _RECENT_ROW_HINT := [...]` 7 entry dict (T249 #167 扩展 5 → 7 entry, Run# / 房 / 净 / 碎 / 时 / 房/时 / 净/时) + `func _build_recent_row_tooltip() -> String` 15 行 pure function (1 header + 7 字段 2 行 = 1 + 7*2 = 15 行, for h in _RECENT_ROW_HINT 循环 0 改, 0 hard-code 5 或 7) + T215 (静态高亮层) + T216 (tooltip 数据源层) 双层独立组件, 1 个层加新字段 (e.g. 8 字段 "净/净" 派生率) 不需要触碰另 1 层, source-grep 验证 7 entry dict 字段顺序与 §9.6.6 7 字段 format 字符串 1:1 严格对齐。
  - **T217 (#138) ProfileQuickStats 4 段独立 hover 动态焦点层** — 拆 1 Label 4 BBCode 段 (T214 #134 旧版) → 4 sub-Label (QuickStatsAchievement / QuickStatsBestTime / QuickStatsLongestRoom / QuickStatsRunNumber) + 1 段 idx 状态字段 `_quick_stats_hovered_idx: int = -1` (替代 T214 旧版 bool 1 bit) + 1 对 _on_quick_stats_hover_in / _out handler (idx 越界 0-3 检查 + 4 sub-Label null guard + re-entrant guard + set idx + 调 _apply_quick_stats_hover_state) + 1 个 _apply_quick_stats_hover_state 4 sub-Label modulate 重算函数 (T225 #147 升级 0.3s tween 渐变)。T213 (tooltip 数据源层, 静态信息) + T217 (动态焦点层, 视觉反馈) 双层独立, 1 个层加新维度 (e.g. T217 加 0.3s tween 节奏) 不需要触碰 T213 (9 行 tooltip 文本 0 改), source-grep 验证 4 sub-Label 0 回到 1 Label + 4 BBCode 段旧模式。
  - **T212 (#132) ProfileQuickStats 4 段总览 1 Label 基础** — 旧版 ProfileQuickStats 1 Label + 4 BBCode 段 (T214 #134) + 1 段 (Run#) 单独高亮 string 替换 (T213 tooltip 之前的版本, T214 → T213 → T217 3 段升级前)。0 复用到 T215 (5 行 row) + T216 (7 字段) 双层结构 (T212 1 Label 0 拆 5 行, T212 4 段 0 拆 7 字段), 0 触碰 ProfileRecentList 结构。
  - 双层独立 0 复用 — 静态高亮层 (T215 5 行 + T217 4 段) 0 复用 const 字典 (T215 走 _recent_row_default_color Array[Color] 5 行还原色, T217 走 _quick_stats_hovered_idx 1 段 idx 状态字段), tooltip 数据源层 (T213 4 段 + T216 7 字段) 0 复用 const 字典 (T213 _QUICK_STATS_HINT 4 entry vs T216 _RECENT_ROW_HINT 7 entry 字段数不同 + 字段名不同 + 字段含义不同), 跨面板 0 触碰 0 互混。
  - 0 副作用：T215 / T216 5 行 row 0 触碰 T213 / T217 4 段 QuickStats；T213 / T217 4 段 0 触碰 T215 / T216 5 行 row；T199 5 verb tooltip 0 触碰 T213 / T216 tooltip (权威 const 数据源各自独立, 0 互混)；T225 0.3s 节奏 0 触碰 T231 0.12s 节奏 (跨面板节奏分层, 与 §9.6.8 预防 5 100% 闭环)。
- **预防**：
  1. 任何 polish 期给 PauseMenu 跨面板 (ProfileQuickStats 4 段 / ProfileRecentList 5 行 / save_load_menu 5 槽位 / settings accessibility 三态) hover 反馈加新维度 (静态高亮层 / tooltip 数据源层 / 4 段 ↔ 5 字段数据共享 / 第 3 面板接入) 时**必须**严格按 7 步骤 1:1 复制既有双层 hover 互补模式：(1) tooltip 数据源层 const (T213 `_QUICK_STATS_HINT` 4 entry + T216 `_RECENT_ROW_HINT` 7 entry) + (2) tooltip builder function (T213 `_build_quick_stats_tooltip` 9 行 + T216 `_build_recent_row_tooltip` 15 行) + (3) tooltip_text 1 行绑定 (T213 + T217 绑到 HBoxContainer parent) + (4) 静态高亮层 状态字段 (T215 `_recent_row_hovered` 5 行 Array[bool] + `_recent_row_default_color` 5 行 Array[Color] / T217 `_quick_stats_hovered_idx` 1 段 int) + (5) mouse_filter = STOP 显式设 (5 行各自 / 4 sub-Label 各自) + (6) 5 行各自 mouse_entered/exited.connect handler (T215 bind idx 0-4 / T217 bind idx 0-3) + (7) handler 内部 越界检查 + re-entrant guard + 提亮到 Color.WHITE + restore 到 default color (T215 旧版 snap 立即 / T240 升级 0.12s tween)。建议在 const 数据源上方 docblock 写明 "权威 const 数据源 + pure builder function + tooltip_text 1 行绑定" 三件套硬约束。
  2. T213 `_QUICK_STATS_HINT` 4 entry + T216 `_RECENT_ROW_HINT` 7 entry 0 复用 0 互混 — 4 段 vs 5 字段 vs 7 字段 字段数不同 + 字段名不同 (T213 4 段 label "成就 / 最佳 / 最长单房 / Run#", T216 7 字段 label "Run# / 房 / 净 / 碎 / 时 / 房/时 / 净/时") + 字段含义不同 (T213 4 段 "跨 run 累计", T216 7 字段 "单 run 明细"), 任何"统一 *_HINT"polish 必须先 source-grep 验证 2 const 字段数 0 触碰 0 复用, 0 互混。`_QUICK_STATS_HINT` 4 entry 0 改 `_RECENT_ROW_HINT` 7 entry 字段, 反之亦然, source-grep 验证 2 const 0 漏 0 改 1 字段。
  3. T215 5 行 row 双字段 (hovered bool + default color Array[Color]) 0 改任 1 字段 — `_recent_row_hovered: Array = []` 5 行独立 bool flag 0 改 "_recent_row_hovered: bool" 单字段 (破坏 5 行独立, 0 跨行联动), `_recent_row_default_color: Array = []` 5 行还原色缓存 0 改 "_recent_row_default_color: Color" 单字段 (破坏 5 行独立 hover_out restore 路径), source-grep 验证 2 var 0 漏 0 改 1 字段。
  4. T217 1 段 idx 状态字段 (`_quick_stats_hovered_idx: int = -1`) 0 改 T214 旧版 bool 字段 — T214 (`_quick_stats_hovered: bool` 1 bit, 0 表达 "hover 哪一段") 0 改 T217 (1 段 idx 0-3 表达精确段号), source-grep 验证 `_quick_stats_hovered_idx` 0 改 1 字符。
  5. T215 5 行 Color.WHITE 提亮 base 0 改 — 0 改 Color.WHITE (1.0) 0 改 _COLOR_RECENT_RUN_LATEST (Amber Voice i==0 还原色) + _COLOR_RECENT_RUN_NORMAL (Pale Resonance i>0 还原色) (T162 5 行还原色 const), T215 复用 2 const 作为 5 行 default_color 缓存, source-grep 验证 2 const 0 漏 0 改 1 字符。
  6. tooltip 走纯文本 + \n 拼接, 0 走 BBCode 包裹 — Label 节点 bbcode_enabled 0 走 tooltip 路径 (tooltip_text 是 Godot 4.6 自带 Popup 渲染器, 0 触发 bbcode_enabled), 任何"BBCode 包裹"polish 0 触发 (e.g. 加 `[color=#FFFFFF]%s[/color]` 颜色 token 0 渲染, 玩家看到纯文本 0 颜色)。0 改 for h in _*_HINT 循环 + 0 改字典字段访问顺序 (label → desc_zh / color → color_name → detail), source-grep 验证 builder function 0 漏 0 改 1 行。
  7. T215 / T216 双层 0 触碰 / T213 / T217 双层 0 触碰 — T215 (5 行 row 静态高亮层) 0 触碰 T216 (5 字段 tooltip 数据源层) 反之亦然; T213 (4 段 tooltip 数据源层) 0 触碰 T217 (4 段独立 hover 动态焦点层) 反之亦然。任何"双层合并"polish 必须先 source-grep 验证 2 层独立组件 0 互混 0 复用 0 字段共享, source-grep 验证 2 const (`_QUICK_STATS_HINT` + `_RECENT_ROW_HINT`) + 4 var (`_recent_row_hovered` + `_recent_row_default_color` + `_quick_stats_hovered_idx` + `_quick_stats_default_text` 旧版已废弃) 0 漏 0 改 1 字段。

### 9.6.11 settings_menu ReduceAllCheck 三态 (enabled / disabled / indeterminate) 总开关 + 3 子项 reduce_*_check 联动 + 防递归 `_syncing_from_master` 守卫 polish 模式 (T202.B #121 落地)

> §9.6.1 ~ §9.6.10 集中记录 PauseMenu 跨面板 hover 反馈 / VFX 跨类 / HUD 6 verb 接入 / 调色六元组等 polish 模式。本节记录 settings_menu accessibility 总开关 ReduceAllCheck 跨 1 主 CheckBox + 3 子 CheckBox (ReduceShake / ReduceFlash / ReduceVibration) 联动 + Godot 4 CheckBox 三态 (checked / unchecked / indeterminate) 显示 + 主子递归防爆栈的 polish 模式 —— T202.B (#121) 1 任务 1 轮落地的「3 子项独立 toggle + 主开关聚合 + 防递归 `_syncing_from_master` 守卫 + `_reduce_all` 数据字段独立于 3 子项 AND 算出 (主开关最后一次手动 toggle 状态保留, indeterminate 仅是 UI 反映, 0 触碰数据) + `set_block_signals` 双层保险 + 3 子项灰化 (主开关 enabled 时 3 子项 disabled 不可点)」6 件套硬约束录入 CONTRIBUTING.md §9.6.11。避免未来 polish 任何「主开关 + N 子项 CheckBox 联动 + 防递归」场景 (e.g. 玩家偏好 3 选项 一键全开 / 关 + 子项可独立 override) 时漏 1 处同步 (e.g. 漏 `_syncing_from_master` 守卫 → 无限递归栈溢出; 漏 `_reduce_all` 独立字段 → indeterminate 状态被 3 子项 AND 算出歧义; 漏 `set_block_signals` → 3 子项 signal 链路反向触发主开关同步; 漏 3 子项灰化 → 玩家在主开关 enabled 状态下还点 3 子项 → 视觉组 "主开关是权威源" 语义被破坏)。

- **症状**：polish 期给 settings_menu 加「1 主 CheckBox + N 子 CheckBox 联动」交互时, 最常见的 fragile 是「(a) 主开关推 N 子项 → N 子项又触发 _on_*_toggled → _sync_*_state 误回写主开关 → 再次 set 主开关 → 无限递归栈溢出」— T202.B (#121) 落地时设计 3 层防递归 (1 `_syncing_from_master` bool 守卫 在主开关 handler 入口开出口关 + 2 `set_block_signals(true)` 阻断单个 signal + 3 `if not _syncing_from_master: _sync_reduce_all_state()` 短时间窗口短路), 任何「漏 1 层防递归」polish 都会触发无限递归;「(b) `_reduce_all` 数据字段被 3 子项 AND 算出, indeterminate 状态写回数据字段歧义」— T202.B 落地时显式用 `_reduce_all: bool = false` 独立存储「主开关最后一次手动 toggle 状态」, 不根据 3 子项 AND 算出, 让 indeterminate 仅是 UI 反映 (Godot 4 `CheckBox.indeterminate` 独立 flag, 0 触碰 button_pressed);「(c) 主开关 enabled 时 3 子项还可点, 视觉组 "主开关是权威源" 语义被破坏」— T202.B 落地时 _set_three_children_disabled(true) 灰化 3 子项 (玩家点不到), 主开关 disabled 时 _set_three_children_disabled(false) 重新启用, 任何 "主开关 enabled 时 3 子项还可点" polish 都会让玩家在「总开关已开」状态下点子项触发 _on_reduce_*_toggled, 进入 indeterminate 状态, 但玩家视觉上看到「总开关还在 checked, 我手点 1 个子项」歧义;「(d) 3 子项独立 toggle 后 indeterminate 显示状态丢失」— T202.B 落地时 _on_reduce_*_toggled 末尾 `if not _syncing_from_master: _sync_reduce_all_state()`, 玩家手动 toggle 任 1 子项时回查 3 子项状态, 全 true / 全 false / 混合 → 主开关 checked / unchecked / indeterminate (Godot 4 `indeterminate = true` flag), 任何"漏 _sync_reduce_all_state() 回查"polish 都会让 indeterminate 状态永远 0 显示。
- **触发场景**：T202.B (#121) ReduceAllCheck 三态总开关落地需同步 6 件套：(1) `src/scripts/settings_menu.gd:80` `@onready var _reduce_all_check: CheckBox` — 1 个主 CheckBox 引用, 与 T195 / T196 3 个 _reduce_*_check 引用同区域, 顺序在 3 子项之后 (`@onready var _reduce_shake_check: CheckBox = $VBoxContainer/Content/VideoPanel/ReduceShakeCheck` 在 67 行 + `_reduce_flash_check` 在 68 行 + `_reduce_vibration_check` 在 72 行 + `_reduce_all_check` 在 80 行, 严格 "3 子项 → 1 主项" 顺序); (2) `src/scripts/settings_menu.gd:173` `var _reduce_all: bool = false` + 3 个 `_reduced_shake / _reduced_flash / _reduced_vibration` 字段 (156-164 行) — 4 个数据字段, 3 个是 3 子项 toggle 状态, 1 个 `_reduce_all` 是主开关数据 (独立于 3 子项 AND 算出, indeterminate 状态 0 触碰 `_reduce_all`); (3) `src/scripts/settings_menu.gd:179` `var _syncing_from_master: bool = false` — 1 个递归守卫 bool 字段, 入口 `_on_reduce_all_toggled` 头部 `= true` + 出口 `= false` 包裹, 期间 3 子项 `_on_reduce_*_toggled` 末尾 `if not _syncing_from_master: _sync_reduce_all_state()` 短路; (4) `src/scripts/settings_menu.gd:234` `_reduce_all_check.toggled.connect(_on_reduce_all_toggled)` — 1 行 signal 连接, 0 触碰 3 子项 `_on_reduce_*_toggled` (3 子项在 225-229 行已分别连); (5) `src/scripts/settings_menu.gd:636-655` `_on_reduce_all_toggled(enabled: bool)` — 6 步骤主 handler: 1 `_syncing_from_master = true` 入口守卫 → 2 `_apply_three_children(enabled)` 推 3 子项 (set_block_signals + 推 _reduced_* 字段 + live-push ScreenShake autoload) → 3 `_set_three_children_disabled(enabled)` 灰化 3 子项 (主开关 enabled 时 3 子项 disabled) → 4 `_reduce_all = enabled` 数据同步 → 5 `_syncing_from_master = false` 出口守卫 → 6 indeterminate 处理 (Godot 4 默认 indeterminate → checked 行为已内置); (6) `src/scripts/settings_menu.gd:704-729` `_sync_reduce_all_state()` — 3 态判定 (全 true → checked, 全 false → unchecked, 混合 → indeterminate) + `set_block_signals(true/false)` 包裹 + `_reduce_all_check.indeterminate = true/false` flag 写 + `_set_three_children_disabled(false)` 重新启用 3 子项 (主开关 indeterminate 状态时 3 子项可点 — 让玩家 override)。6 件套 1:1 同步, 1 漏 1 = 无限递归栈溢出 / indeterminate 显示歧义 / 视觉组 "主开关是权威源" 语义破坏 / 3 子项独立 toggle 反馈丢失。
- **修复**：`src/scripts/settings_menu.gd` accessibility ReduceAllCheck 三态总开关 + 3 子项 reduce_*_check 联动 + 防递归 `_syncing_from_master` 守卫 polish 模式 (T202.B #121 落地)：
  - **T195 / T196 / T202.B 4 个 `_reduced_*` 数据字段 + 1 个 `_reduce_all` 独立数据字段 (6 字段)** — `_reduced_shake: bool = false` (156) + `_reduced_flash: bool = false` (157) + `_reduced_vibration: bool = false` (164) + `_reduce_all: bool = false` (173) 4 个 bool 数据字段, 3 子项 + 1 主项 1:1 映射, 0 共享 (与 §9.6.4 6 verb 调色六元组 0 复用 0 互混 同模式, 1 字段 = 1 状态源, 0 从其他字段 AND / OR 算出)。`_reduce_all` 独立存储「主开关最后一次手动 toggle 状态」, 不根据 3 子项 AND 算出 — 这样 "indeterminate 表示历史曾是全 enable, 现在 3 子项被打破" 语义透明, 玩家点 indeterminate 主开关时 (Godot 4 默认行为: indeterminate → checked = true) → reset `_reduce_all=true` 并推 3 子项 → 进入正常 master sync 流程。
  - **T202.B 1 个 `_syncing_from_master` 递归守卫 bool 字段** — `var _syncing_from_master: bool = false` (179), 主开关 handler 入口 `_syncing_from_master = true` → 出口 `_syncing_from_master = false` 包裹, 期间 3 子项 `_on_reduce_*_toggled` 末尾 `if not _syncing_from_master: _sync_reduce_all_state()` 短路 — 防主开关推 3 子项 → 3 子项又触发 _on_reduce_*_toggled → _sync_reduce_all_state 误判主开关 → 再次 set 主开关 → 无限递归栈溢出。`set_block_signals(true/false)` 阻断单个 signal 是双层保险, 但 已有 `_on_reduce_*_toggled` 流程仍要推 ScreenShake.autoload 走完 (live-push 立即生效), 所以 `_syncing_from_master` 标志是真正的递归保险, `set_block_signals` 是辅助。`_on_reduce_all_toggled` 6 步骤 顺序硬约束: 1 入口守卫 → 2 推 3 子项 → 3 灰化 3 子项 → 4 数据同步 → 5 出口守卫 (顺序不能乱, 否则 `_syncing_from_master = false` 提前关闭, 3 子项 signal 链路反向触发主开关同步)。
  - **T202.B `_apply_three_children(enabled: bool)` helper (661-682 行)** — 主开关推 3 子项统一入口, 每个子项 4 步: 1 `set_block_signals(true)` 阻断 signal 链路 (双层保险第 1 层) → 2 `button_pressed = enabled` 设可视状态 → 3 `set_block_signals(false)` 恢复 signal 链路 → 4 推 `_reduced_*` 数据字段 + live-push ScreenShake autoload (与玩家手动 toggle 完全一致)。0 触碰 3 个 `_on_reduce_*_toggled` handler (信号被 block, 不会被调), 但 `_syncing_from_master` 守卫仍生效, 防万一 (e.g. 未来 signal 链路重排, set_block_signals 失效)。
  - **T202.B `_set_three_children_disabled(disabled: bool)` helper (688-694 行)** — 灰化 3 子项统一入口, 主开关 enabled 时 3 子项 `disabled = true` (灰色, 玩家点不到), 主开关 disabled 时 3 子项 `disabled = false` (重新启用)。注意 disabled 状态本身不阻断 `_on_reduce_*_toggled` 程序触发, 仅挡玩家点击 — 程序递归仍需 `_syncing_from_master` 守卫挡。3 子项独立 CheckBox 引用都先 null guard (`if _reduce_shake_check:`), 与 §9.6.10 4 sub-Label null guard 同模式。
  - **T202.B `_sync_reduce_all_state()` 3 态判定 (704-729 行)** — 3 子项状态回查: 1 全 true → 主开关 `button_pressed = true` + `indeterminate = false` + `_set_three_children_disabled(false)` 重新启用 3 子项 → 2 全 false → 主开关 `button_pressed = false` + `indeterminate = false` + `_set_three_children_disabled(false)` → 3 混合 (1-2 个 true) → 主开关 `indeterminate = true` + `_set_three_children_disabled(false)` (主开关 indeterminate 状态时 3 子项可点 — 让玩家 override)。`set_block_signals(true/false)` 包裹整个判定块, 防 `_reduce_all_check.button_pressed = true` 触发 `_on_reduce_all_toggled` 递归。
  - **T202.B `_on_reduce_all_toggled(enabled: bool)` 6 步骤主 handler (636-655 行)** — 6 步骤顺序硬约束: 1 `_syncing_from_master = true` 入口守卫 → 2 `_apply_three_children(enabled)` 推 3 子项 → 3 `_set_three_children_disabled(enabled)` 灰化 3 子项 → 4 `_reduce_all = enabled` 数据同步 → 5 `_syncing_from_master = false` 出口守卫 → 6 indeterminate 处理注释 (Godot 4 默认 indeterminate → checked 已内置)。1 步骤漏 1 = 无限递归栈溢出 / 3 子项 0 推 / 3 子项 0 灰化 / 数据字段 0 同步 / 出口守卫提前关 / indeterminate 行为无注释。
  - 0 副作用：T195 / T196 reduce_shake / reduce_flash / reduce_vibration 3 个独立 CheckBox 0 触碰 (3 个 `_on_reduce_*_toggled` handler 仅末尾加 `if not _syncing_from_master: _sync_reduce_all_state()` 1 行短路守卫, 0 改 `_reduced_*` 字段 + ScreenShake autoload 推 逻辑); `_apply_three_children` 内 live-push ScreenShake 与玩家手动 toggle 1:1 一致 (调 `_on_reduce_*_toggled` 等价逻辑), 0 副作用 0 重复; `_reduce_all` 数据字段 0 从 3 子项 AND 算出, 0 触碰 3 子项数据; `_syncing_from_master` 守卫仅在 `_on_reduce_all_toggled` 入口开出口关, 0 触碰 3 子项 `_on_reduce_*_toggled` 主体 (仅末尾加 if 守卫)。
- **预防**：
  1. 任何 polish 期给 settings_menu 加「1 主 CheckBox + N 子 CheckBox 联动」交互时**必须**严格按 6 件套 1:1 复制既有 ReduceAllCheck 三态模式: (1) `@onready var _main_check: CheckBox` 主 CheckBox 引用 + (2) 4 数据字段 (N 子项 bool + 1 主项 `_main` bool 独立) + (3) `var _syncing_from_master: bool = false` 递归守卫 (入口开出口关) + (4) `signal connect` 主开关 toggle (1 行) + (5) `_on_main_toggled` 6 步骤主 handler (入口守卫 → 推 N 子项 → 灰化 N 子项 → 数据同步 → 出口守卫 → indeterminate 处理注释) + (6) `_sync_main_state()` 3 态判定 (全 true → checked, 全 false → unchecked, 混合 → indeterminate) + `set_block_signals` 包裹 + N 子项重新启用 (主开关 indeterminate 状态时让玩家 override)。建议在主 handler 上方 docblock 写明 "1 主 + N 子 + 防递归 `_syncing_from_master` 守卫 + `_main` 数据独立 + `set_block_signals` 双层保险 + N 子项灰化" 六件套硬约束。
  2. `_syncing_from_master` 递归守卫 0 改任 1 字符 — `var _syncing_from_master: bool = false` 0 改 `var _syncing: bool = false` (字段名重命名会破坏 _on_reduce_*_toggled 内 `if not _syncing_from_master` 短路守卫), source-grep 验证 `_syncing_from_master` 0 漏 0 改 1 字符。3 层防递归 0 删任 1 层: 1 `_syncing_from_master` 守卫 (主体) + 2 `set_block_signals(true/false)` 包裹 (双层保险) + 3 `if not _syncing_from_master: _sync_reduce_all_state()` 短时间窗口短路 (3 子项 handler 末尾)。
  3. `_reduce_all` 数据字段独立于 3 子项 AND 算出 0 触碰 — `var _reduce_all: bool = false` 0 改 `var _reduce_all: bool = _reduced_shake and _reduced_flash and _reduced_vibration` (3 子项 AND 算出会让 indeterminate 状态被覆盖, 玩家点 indeterminate 主开关 → toggle 推 3 子项 → indeterminate 被 3 子项 AND 重写 → 主开关变 checked, 歧义), source-grep 验证 `_reduce_all = enabled` 0 漏 0 改 1 字符 (数据同步固定 `= enabled`, 0 是 `_reduced_shake and ...`)。indeterminate 仅是 UI 反映 (Godot 4 `CheckBox.indeterminate` 独立 flag), 0 触碰 `_reduce_all` 数据字段。
  4. `_set_three_children_disabled` 灰化 0 改 `_set_three_children_disabled(true/false)` — 3 子项独立 CheckBox 引用都先 null guard (`if _reduce_shake_check:`), 与 §9.6.10 4 sub-Label null guard 同模式。`disabled = disabled` 0 改 `disabled = not enabled` (与 `_apply_three_children(enabled)` 入口参数相反, 0 触碰 视觉组 "主开关 enabled 时 3 子项 disabled" 语义), source-grep 验证 3 子项 `disabled = disabled` 0 漏 0 改 1 字符。
  5. 3 子项 `_on_reduce_*_toggled` 末尾 `if not _syncing_from_master: _sync_reduce_all_state()` 短路守卫 0 删 — 删了会触发无限递归 (主开关推 3 子项 → 3 子项又触发 _on_reduce_*_toggled → _sync_reduce_all_state 误回写主开关 → 再次 set 主开关 → 无限递归栈溢出), source-grep 验证 3 子项 handler 末尾 `if not _syncing_from_master` 0 漏 0 改 1 行。
  6. `_sync_reduce_all_state` 3 态判定顺序 0 改 — 1 全 true → checked + 2 全 false → unchecked + 3 混合 → indeterminate (顺序硬约束, 全 true / 全 false 在前 2 个 if 分支, 混合在 else 分支), source-grep 验证 3 个分支 0 漏 0 改 1 行。`set_block_signals(true/false)` 包裹整个判定块 0 删 (删了会让 `_reduce_all_check.button_pressed = true` 触发 `_on_reduce_all_toggled` 递归)。
  7. T202.B 6 件套 0 触碰既有 3 子项 reduce_*_check 逻辑 (T195 / T196 reduce_shake / reduce_flash / reduce_vibration 3 个独立 CheckBox 主体逻辑 0 改, 仅末尾加 1 行 `if not _syncing_from_master` 守卫) — T202.B 是新增 1 主 CheckBox + 1 数据字段 + 1 守卫 + 1 主 handler + 2 helper + 1 sync 函数, 0 触碰既有 3 子项 live-push ScreenShake autoload 逻辑, source-grep 验证 `ScreenShake.set_reduce_shake / set_reduce_flash / set_reduce_vibration` 3 处调用 0 漏 0 改 1 字符 (3 处调用既出现在 `_on_reduce_*_toggled` 又出现在 `_apply_three_children`, 2 处 1:1 一致, 0 重复)。

### 9.6.12 settings_menu 4 tab 状态机 (AUDIO / VIDEO / CONTROLS / SAVES) + Tab 枚举 + 4 panel mutual-exclusive visible + 4 button modulate 1:1 复制 polish 模式 (T037 + T072 + T134 + T202.B 跨 4 任务 ~20 轮落地) 文档化

> §9.6.1 ~ §9.6.11 集中记录 PauseMenu 跨面板 hover 反馈 / VFX 跨类 / HUD 6 verb 接入 / 调色六元组 / settings_menu accessibility ReduceAllCheck 三态等 polish 模式。本节记录 settings_menu 顶部 4 tab (AUDIO / VIDEO / CONTROLS / SAVES) 跨面板切换的「Tab 枚举 + 1 状态字段 + 4 tab Button @onready + 4 panel Control @onready + 4 signal connect + 1 `_switch_tab(tab)` 函数 (状态字段 + 4 panel mutual-exclusive visible + 4 button modulate 1:1 + 1 可选 side effect)」7 件套硬约束录入 CONTRIBUTING.md §9.6.12。T037 (#23) 落地 2 tab (Audio / Video) → T072 (#34) 加 Saves tab → T086 (#44) 加 Controls tab → T134 (#71) 改 placeholder → T202.B (#121) 改 ReduceAllCheck 三态, 5 个任务跨 ~20 轮反复落地, 任何 polish 期给 settings_menu 加第 5 tab (e.g. 玩家偏好 / 关卡选择 / mod 列表) 或类似 4 tab 状态机的多面板 UI (e.g. 主菜单 / 角色面板 / 商店面板) 时先查本节, 0 漏 1 处同步 (e.g. 漏 `Tab.X` 枚举值 → `_switch_tab` 调 `tab == Tab.X` 永远 false, 玩家点 tab 0 视觉变化; 漏 `_current_tab` 状态字段 → 0 表达"当前选中哪个 tab" 给 side effect 用, e.g. T072 Saves tab 首次进入时刷存档计数; 漏 4 tab Button @onready → signal connect 0 触发 / 玩家点 tab 无反应; 漏 4 panel @onready → 4 panel 永远 0 显隐, 玩家看到 4 段内容堆叠; 漏 `_switch_tab` 末 panel.visible 显隐 / 4 button modulate 切换 → 上 1 tab 玩家未退出就保留可见 + 高亮, 视觉组"当前 tab 是权威源"语义破坏)。

- **症状**：polish 期给 settings_menu 加第 5 tab (e.g. 「玩家偏好」「关卡选择」「Mod 列表」) 时, 最常见的 fragile 是「(a) Tab 枚举 0 加 + `_switch_tab` 0 适配新 tab」— T037 (#23) 落地 2 tab (AUDIO / VIDEO) 时显式用 `enum Tab { AUDIO, VIDEO }` Godot 4 enum 强类型 (vs String / int 散值), 任何"加第 5 tab 但漏 Tab 枚举值"polish 都会让 `_switch_tab` 末尾 `tab == Tab.X` 永远 false, 玩家点新 tab 0 视觉变化;「(b) `_current_tab` 状态字段缺失, side effect (Saves tab 首次进入刷存档计数 / 主菜单 BGM 切换) 0 触发」— T072 (#34) 落地 Saves tab 时显式用 `var _current_tab: Tab = Tab.AUDIO` 状态字段, 0 仅靠 `tab == Tab.X` 即时判定, 让 T343 / T134 Saves tab 首次进入触发的 `_refresh_save_count()` side effect 仍有可观察的状态锚点 (e.g. `_on_visibility_changed` 触发 / 玩家从其他 tab 切回 Saves 时不重复刷);「(c) 4 panel mutual-exclusive visible 漏 1 显隐」— T037 落地 2 tab 时 2 panel `_audio_panel.visible = (tab == Tab.AUDIO)` + `_video_panel.visible = (tab == Tab.VIDEO)`, 后续 T072 / T086 加 Saves / Controls 2 tab 时 0 触碰既有 2 panel 显隐, 任何"加第 5 tab 但漏对应 panel 显隐"polish 都会让玩家看到 2 panel 同时显示, 玩家点击新 tab 后旧 panel 仍可见, 视觉组"当前 tab 唯一可见"语义破坏;「(d) 4 button modulate 1:1 切换漏 1」— T037 落地时显式用 `_tab_audio.modulate = Color.WHITE if tab == Tab.AUDIO else Color(0.5, 0.5, 0.5)` 4 button 1:1 切换, 任何"加第 5 tab 但漏对应 button modulate"polish 都会让玩家点新 tab 后新 button 不亮 / 旧 button 仍亮, 视觉组"当前 tab 是唯一权威高亮"语义破坏;「(e) signal connect 4 行 0 触碰既有 4 行」— T037 落地 2 tab 时显式用 `_tab_audio.pressed.connect(func() -> void: _switch_tab(Tab.AUDIO))` lambda 立即调 `_switch_tab(Tab.X)`, 任何"加第 5 tab 但漏对应 signal connect"polish 都会让玩家点新 tab 0 触发, 玩家会以为"我点了没反应"。
- **触发场景**：T037 (#23) + T072 (#34) + T086 (#44) + T134 (#71) + T202.B (#121) 4 tab 状态机跨面板切换落地需同步 7 件套：(1) `src/scripts/settings_menu.gd:6` `enum Tab { AUDIO, VIDEO, CONTROLS, SAVES }` — 1 个 Tab 枚举, 4 entry 强类型 (Godot 4 enum 编译期类型检查, 0 用 String / int 散值), 顺序 0 颠倒 (Audio 首位 + Video 第 2 位 + Controls 第 3 位 + Saves 第 4 位, 与 `_switch_tab` 末尾 `tab == Tab.X` 1:1 顺序一致); (2) `src/scripts/settings_menu.gd:8` `var _current_tab: Tab = Tab.AUDIO` — 1 个状态字段, 默认 Tab.AUDIO 与 `_ready` 末尾 `_switch_tab(Tab.AUDIO)` 1:1 对齐, 给后续 side effect (Saves tab 首次进入刷存档计数) 提供状态锚点; (3) `src/scripts/settings_menu.gd:30-33` `@onready var _tab_audio: Button` + `_tab_video: Button` + `_tab_controls: Button` + `_tab_saves: Button` — 4 个 tab Button @onready 引用, 严格 "按 enum 顺序" 排列 (30-33 行), 0 颠倒, path `$VBoxContainer/TabRow/AudioTab` 等 1:1 对应 tscn 节点; (4) `src/scripts/settings_menu.gd:35-38` `@onready var _audio_panel: Control` + `_video_panel: Control` + `_controls_panel: Control` + `_saves_panel: Control` — 4 个 panel Control @onready 引用, 同样"按 enum 顺序"排列, path `$VBoxContainer/Content/AudioPanel` 等 1:1 对应 tscn 节点 (注意 Content 是 Control parent, 4 panel 互为 sibling 0 嵌套); (5) `src/scripts/settings_menu.gd:201-204` 4 行 signal connect — `_tab_audio.pressed.connect(func() -> void: _switch_tab(Tab.AUDIO))` 等 4 行 lambda, 严格"按 enum 顺序"排列, lambda 内调 `_switch_tab(Tab.X)` 立即触发切换, 0 触碰既有 4 行; (6) `src/scripts/settings_menu.gd:330-344` `_switch_tab(tab: Tab)` 函数 — 7 步骤: 1 `_current_tab = tab` 状态同步 → 2 `_audio_panel.visible = (tab == Tab.AUDIO)` panel 1 显隐 → 3 `_video_panel.visible = (tab == Tab.VIDEO)` panel 2 显隐 → 4 `_controls_panel.visible = (tab == Tab.CONTROLS)` panel 3 显隐 → 5 `_saves_panel.visible = (tab == Tab.SAVES)` panel 4 显隐 → 6 `_tab_audio.modulate = Color.WHITE if tab == Tab.AUDIO else Color(0.5, 0.5, 0.5)` button 1 modulate (4 行, 0 漏 1) → 7 `if tab == Tab.SAVES: _refresh_save_count()` 可选 side effect (Saves tab 首次进入刷存档计数, T072 / T134 落地, 0 是必须, 未来加第 5 tab 时 0 触碰此 side effect 除非新 tab 也需要 side effect); (7) `src/scripts/settings_menu.gd:277` `_ready()` 末尾 `_switch_tab(Tab.AUDIO)` 初始渲染 — 显式调一次让 4 panel 显隐 + 4 button modulate 同步, 0 依赖 tscn 节点默认 visible (玩家首次打开 settings 看到 AUDIO tab 高亮 + 3 其他 tab 灰 + 1 AUDIO panel 可见 + 3 其他 panel 隐藏)。7 件套 1:1 同步, 1 漏 1 = 玩家点 tab 0 视觉变化 / 状态字段缺失 / 4 panel 堆叠 / 4 button 高亮歧义 / signal 0 触发 / 初始渲染 0 同步 / side effect 0 触发。
- **修复**：`src/scripts/settings_menu.gd` 4 tab 状态机 (AUDIO / VIDEO / CONTROLS / SAVES) + Tab 枚举 + 4 panel mutual-exclusive visible + 4 button modulate 1:1 复制 polish 模式 (T037 + T072 + T086 + T134 + T202.B 跨 5 任务 ~20 轮落地)：
  - **T037 1 个 Tab 枚举 + 1 个 `_current_tab` 状态字段 (2 字段)** — `enum Tab { AUDIO, VIDEO, CONTROLS, SAVES }` (6 行) + `var _current_tab: Tab = Tab.AUDIO` (8 行)。Tab 枚举严格 4 entry 顺序 (Audio / Video / Controls / Saves), 0 颠倒, Godot 4 enum 强类型 (vs String / int 散值), 编译期类型检查, 任何"用 String 'AUDIO' 替代 Tab.AUDIO"polish 都会让 `_switch_tab('AUDIO')` 编译期 type mismatch 报错。`_current_tab` 默认 Tab.AUDIO 与 `_ready` 末尾 `_switch_tab(Tab.AUDIO)` 1:1 对齐, 给后续 side effect 提供状态锚点。
  - **T037 / T072 / T086 4 个 tab Button @onready 引用 (4 行)** — `@onready var _tab_audio: Button = $VBoxContainer/TabRow/AudioTab` (30) + `_tab_video` (31) + `_tab_controls` (32) + `_tab_saves` (33), 严格"按 enum 顺序"排列, path 与 tscn 节点 1:1 对应, 0 颠倒, 0 共享 1 个 Button group 引用 (4 个独立 Button 引用, 让 `_switch_tab` 末尾 4 行 modulate 切换 1:1)。
  - **T037 / T072 / T086 4 个 panel Control @onready 引用 (4 行)** — `@onready var _audio_panel: Control = $VBoxContainer/Content/AudioPanel` (35) + `_video_panel` (36) + `_controls_panel` (37) + `_saves_panel` (38), 同样"按 enum 顺序"排列, 4 panel 互为 sibling 0 嵌套, path 与 tscn 节点 1:1 对应。
  - **T037 / T072 / T086 4 行 signal connect (4 行)** — `_tab_audio.pressed.connect(func() -> void: _switch_tab(Tab.AUDIO))` (201) + `_tab_video` (202) + `_tab_controls` (203) + `_tab_saves` (204), 4 行 lambda 立即调 `_switch_tab(Tab.X)`, 严格"按 enum 顺序"排列, 0 颠倒, 0 触碰既有 4 行。lambda 内 lambda 写法 (`func() -> void: _switch_tab(Tab.AUDIO)`) 而非独立 handler (`_on_tab_audio_pressed`), 减少 4 个 handler 声明 (与 §9.6.4 6 verb tooltip 8 行拼接扩展器模式 "0 触碰既有 6 verb 字段" 同思路, 0 增加新成员函数)。
  - **T037 / T072 / T086 1 个 `_switch_tab(tab: Tab)` 函数 (15 行)** — 7 步骤: 1 `_current_tab = tab` 状态同步 → 2-5 4 panel 显隐 (4 行 `_X_panel.visible = (tab == Tab.X)`) → 6 4 button modulate 切换 (4 行 `_tab_X.modulate = Color.WHITE if ... else Color(0.5, 0.5, 0.5)`) → 7 可选 side effect (`if tab == Tab.SAVES: _refresh_save_count()`)。7 步骤顺序硬约束: 状态同步在前 (让后续判定用最新状态) → 4 panel 显隐在中 (玩家视觉组先收到反馈) → 4 button modulate 紧跟 (玩家视觉组立即看到高亮) → side effect 在末 (避免 0 显隐就触发的"空 side effect")。
  - **T037 `_ready` 末尾 `_switch_tab(Tab.AUDIO)` 初始渲染 (1 行)** — 显式调一次, 0 依赖 tscn 节点默认 visible, 0 依赖 tscn 节点默认 modulate, 玩家首次打开 settings 立即看到 AUDIO tab 高亮 + 3 其他 tab 灰 + 1 AUDIO panel 可见 + 3 其他 panel 隐藏, 视觉组"当前 tab 是唯一权威源"100% 闭环。
  - 0 副作用：T037 / T072 / T086 0 触碰 `_tab_audio` / `_tab_video` 等 4 button Button 主体 (仅新加 signal connect 0 改 Button 自身属性); T037 / T072 / T086 0 触碰 4 panel 子节点 (panel 内的 MasterSlider / FullscreenCheck 等 0 触碰, 4 panel 显隐由 `_switch_tab` 控制, panel 内的具体控件 0 触碰); T134 placeholder 0 触碰 Tab 枚举 (T134 改 `_save_count_label.text` placeholder 用 `SaveSystem.SLOT_COUNT` 动态格式化, 0 加新 Tab entry); T202.B ReduceAllCheck 0 触碰 Tab 状态机 (T202.B 是 VideoPanel 内 1 主 CheckBox + 3 子 CheckBox 联动, 与 4 tab 状态机 0 互混, 2 套 polish 模式 0 复用 0 共享 0 字段, 与 §9.6.11 ReduceAllCheck 三态 0 触碰 Tab 枚举 1:1 严格分离)。
- **预防**：
  1. 任何 polish 期给 settings_menu 加第 5 tab (e.g. 玩家偏好 / 关卡选择 / Mod 列表) 或类似 4 tab 状态机的多面板 UI (e.g. 主菜单分类页 / 角色面板技能树 / 商店面板分类) 时**必须**严格按 7 件套 1:1 复制既有 4 tab 模式: (1) `enum Tab { ... }` Tab 枚举 0 改顺序 (新 tab 加在末尾) + (2) `var _current_tab: Tab = Tab.<FIRST>` 状态字段 0 改默认 (与新枚举第 1 entry 1:1) + (3) N 个 `_tab_X: Button` @onready 引用 0 改既有 N 个 (新加 1 个, 顺序在末尾) + (4) N 个 `_X_panel: Control` @onready 引用 0 改既有 N 个 (新加 1 个, 顺序在末尾) + (5) N 行 `_tab_X.pressed.connect(func() -> void: _switch_tab(Tab.X))` signal connect 0 改既有 N 行 (新加 1 行) + (6) `_switch_tab(tab: Tab)` 函数内 4 步骤顺序硬约束 (状态同步 → N panel 显隐 → N button modulate → 可选 side effect), 新 tab 必须在 panel 显隐 + button modulate 2 段同步扩 1 行 + (7) `_ready` 末尾 `_switch_tab(Tab.<FIRST>)` 0 改 (默认 Tab 第 1 entry 仍生效)。建议在 `_switch_tab` 上方 docblock 写明 "Tab 枚举 + 1 状态字段 + N tab Button + N panel + N signal connect + `_switch_tab` 7 步骤 + 初始渲染 1 行" 七件套硬约束。
  2. Tab 枚举 0 改任 1 entry 顺序 — `enum Tab { AUDIO, VIDEO, CONTROLS, SAVES }` 0 改 `enum Tab { AUDIO, VIDEO, SAVES, CONTROLS }` (顺序颠倒会让 `_switch_tab` 末尾 `tab == Tab.SAVES` 仍生效但开发者阅读时歧义, 未来加新 tab 时易乱), source-grep 验证 Tab 枚举 4 entry 顺序 0 漏 0 改 1 entry。
  3. `_current_tab` 状态字段 0 删 — T072 落地 Saves tab 首次进入 `_refresh_save_count()` side effect 依赖 `_current_tab` 状态 (玩家从其他 tab 切回 Saves 时不重复刷), 任何"删 `_current_tab` 改用 tab parameter 判定"polish 都会让 side effect 在 4 tab 间重复触发, 性能 / 视觉组双双受影响, source-grep 验证 `var _current_tab` 0 漏 0 改 1 字符。
  4. 4 panel mutual-exclusive visible 0 改 — `_X_panel.visible = (tab == Tab.X)` 4 行 0 改 `_X_panel.visible = (tab == Tab.X or some_other_condition)` (任何"多 panel 同时可见"polish 都会让玩家看到 2 panel 内容堆叠, 视觉组"当前 tab 唯一可见"语义被破坏), source-grep 验证 4 panel 显隐表达式 0 漏 0 改 1 行 (每个 panel 1 行, 0 共享 1 个 if 分支)。
  5. 4 button modulate 1:1 切换 0 改 — `_tab_X.modulate = Color.WHITE if tab == Tab.X else Color(0.5, 0.5, 0.5)` 4 行 0 改 `_tab_X.modulate = Color.WHITE if tab == Tab.X else some_other_color` (任何"换色"polish 必须 4 行同步换, 1 行改 0 改 3 行会让玩家看到"高亮色不一致"), source-grep 验证 4 button modulate 表达式 0 漏 0 改 1 行 (每个 button 1 行, 0 共享 1 个 if 分支)。
  6. signal connect 4 行 0 触碰 — `_tab_X.pressed.connect(func() -> void: _switch_tab(Tab.X))` 4 行 lambda 写法 0 改 `_tab_X.pressed.connect(_on_tab_X_pressed)` (任何"改独立 handler"polish 都会增加 4 个 handler 声明, 与 §9.6.5 8 行拼接扩展器模式 "0 触碰既有 handler" 思路冲突), source-grep 验证 4 行 lambda 0 漏 0 改 1 字符 (lambda 内 `_switch_tab(Tab.X)` 0 触碰, 0 改 `_on_tab_X_pressed`)。
  7. `_switch_tab` 7 步骤顺序硬约束 0 改 — 1 状态同步 (前) → 2-5 N panel 显隐 (中) → 6 N button modulate (后) → 7 可选 side effect (末), 任何"重排顺序"polish 都会让玩家看到"panel 0 显隐就 button modulate"或"side effect 触发时 panel 仍可见"视觉组歧义, source-grep 验证 `_current_tab = tab` 在函数首 + N panel 显隐在 N button modulate 之前 + side effect 在函数末 0 漏 0 改 1 行。
  8. T037 / T072 / T086 7 件套 0 触碰既有 panel 内的具体控件 — `_audio_panel` 内的 MasterSlider / SFXSlider / MusicSlider / AmbienceSlider / MusicPreviewButton 0 触碰 (T037 落地 2 tab 时 4 slider 0 触碰, T134 / T239 后续 polish 4 slider 0 触碰 tab 状态机, 2 套 polish 模式 0 复用 0 共享 0 字段, 与 §9.6.11 ReduceAllCheck 三态 0 触碰 `_audio_panel` 任何 slider 1:1 严格分离); `_video_panel` 内的 FullscreenCheck / ScaleOptions / ReduceAllCheck / ReduceShakeCheck / ReduceFlashCheck / ReduceVibrationCheck 0 触碰 (T202.B 落地 0 触碰 Tab 状态机); `_controls_panel` 内的 HintLabel / ControlsList / ResetDefaultsButton 0 触碰 (T086 落地 0 触碰 tab 状态机); `_saves_panel` 内的 SavesInfoLabel / SaveCountLabel / Spacer 0 触碰 (T072 / T134 落地 0 触碰 tab 状态机, T134 placeholder 用 SaveSystem.SLOT_COUNT 动态格式化 0 改 panel 自身 0 改 tab 状态机)。

## 10. 联系方式 / 决策记录

- 大决策（玩法方向 / 风格宪法）→ `ROADMAP.md` 顶部「当前方向」+ `CHANGELOG.md` 段头
- 审查发现问题 → `REVIEW_LOG.md`（严重/一般/轻微/信息 4 类）
- 灵感 / 候选 → `INSPIRATION.md`（- 游戏名《xxx》：机制参考 (链接)）

---

> 感谢你愿意为 Voxglass 添砖加瓦。任何「让下一个开发者少花 10 分钟」的文档 / 冒烟测试 / 注释改进都是受欢迎的贡献。
