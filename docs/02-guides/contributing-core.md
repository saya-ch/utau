# 贡献核心指南

> 本文件为 CONTRIBUTING 剔除 §9.6 全段后的核心部分，包含 §1-§9.5 与 §9.7-§11。
> 原 CONTRIBUTING §9.6 已迁移至 handbook/polish-patterns/ 6 个分片。

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
│   ├── autoload/                              # GameState / PlayerStats / SaveSystem / ScreenShake /
AudioManagerEnhanced
│   ├── scripts/                               # 玩家 / 敌人 / 能力 / UI 等
│   └── scenes/                                # .tscn 场景
├── tools/                                     # 冒烟测试（test_*.gd）+ 辅助脚本
├── docs/                                      # 截图、Steam 描述
└── CHANGELOG.md / REVIEW_LOG.md               # 历史审计
```

> **状态文件宪法**：每轮迭代后必须更新 `ITERATION_COUNT.txt` / `ROADMAP.md` / `CHANGELOG.md` 三件套；新素材登记到 `ASSET_REGISTRY.md`；
风格变更写 `STYLE_GUIDE.md`。

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

⚠️ **每新建一个带 `class_name` 的脚本（特别是 `extends Node2D` 等用于场景的脚本）后，Godot 必须重新跑一次 `--import` 才能生成有效的 `<script>.gd.uid` 文件。
** 否则 `.uid` 会以 0 字节空文件落盘，Godot 4.6.3 加载时产生"无法解析 UID"良性告警，并可能在后续 inspector 中失联。

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

1. **新 `class_name` 脚本**（`bind_windup_vfx.gd` / `echo_windup_vfx.gd` / `wave_windup_vfx.gd` / 任何 VFX / Autoload 候选）—
`uid_cache.bin` 还未注册
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

本仓库自带 32 个 `test_*.gd` 冒烟测试，覆盖核心系统的回归基线（#80 时 32 个，
自 #75 增 4 个：T141+T142+T143/T145/T146+T144/T148/T154+T150/T147/T149+T152/T153/T151）：

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
| `tools/test_t126_player_profile_smoke.gd` | PauseMenu PlayerProfilePanel 节点 + 10 个 @onready + 6 方法 + 8 标签 + 信号连接 +
PlayerStats 字段 10 项 | #66 T126 |
| `tools/test_t127_run_history_smoke.gd` | PlayerStats run_number + 4 项 _best_stats + HISTORY_PATH 持久化 + 防御性副本 + 单调更新 12
项 | #67 T127 |
| `tools/test_t128_crc32_smoke.gd` | SaveSystem CRC32 校验和 (IEEE 0xEDB88320) + 包装层 + legacy 兼容 + get_save_integrity 5 状态
10 项 | #67 T128 |
| `tools/test_t129_save_integrity_smoke.gd` | SaveLoadMenu 3 健康度 BBCode 颜色 + corrupted 禁用 LoadBtn | #68 T129 |
| `tools/test_t130_best_achievements_smoke.gd` | PlayerStats best_stat_threshold 4 成就 (long_road / archive_master /
resonance_hoarder / silence_hunter) | #68 T130 |
| `tools/test_t131_run_trends_smoke.gd` | PlayerStats _run_history FIFO cap 20 + get_recent_runs +
get_recent_runs_average | #69 T131 |
| `tools/test_t132_copy_slot_smoke.gd` | SaveSystem.copy_slot byte-level 备份/恢复 4 边界 + 2 emit | #69 T132 |
| `tools/test_t133_t134_quick_stats_smoke.gd` | PauseMenu Quick Stats 摘要行 (BBCode 三色) + settings 动态 SLOT_COUNT 12 项 |
#71 T133/T134 |
| `tools/test_t135_share_smoke.gd` | PauseMenu 分享剪贴板 3 行结构 + DisplayServer 守卫 12 项 | #72 T135 |
| `tools/test_t136_autosave_smoke.gd` | SaveSystem 自动存档 5 常量 + Timer ALWAYS + 6 skip 场景 + 4 状态 12 项 | #72 T136 |
| `tools/test_t137_t138_persistence_smoke.gd` | SaveSystem._last_autosave_unix + QuickLoadButton + PauseMenu HH:MM:SS 17
项 | #73 T137/T138 |
| `tools/test_t141_wave_hit_audio_smoke.gd` | wave hit SFX 1320Hz 基频 + 2.4x 谐波 + 50ms throttle 9 项 | #75 T141 |
| `tools/test_t142_wave_chain_block_smoke.gd` | is_action_globally_blocked() 公开 helper + 4 verb handler + jump buffer 10
项 | #75-76 T142/T145 重命名 |
| `tools/test_t143_t145_t146_smoke.gd` | wave 4 状态提示 + is_action_globally_blocked 重构 + wave_combo 屏震 25 项 |
#76 T143/T145/T146 |
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
3. 使用 `AudioPresets.MUSIC_PRESETS` / `.BOSS_MUSIC_TIER` 运行时访问的测试必须 `const AudioPresets = preload("...audio_presets.gd")`
在文件顶部
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

2. **player.tscn 节点**：在 `[node name="XxxAbility" ...]` 段加 `script = ExtResource(...)` + `cooldown = X.X` + `windup_time
= 0.XX`（5 verb 现役值：Pulse 0.5/0.1, Bind 1.2/0.1, Cut 0.8/0.06, Echo 4.0/0.08, Wave 6.0/0.1）

3. **project.godot Input Map**：新增 `[input] action = { ... }` 与 `echo` / `wave` 不冲突的键位（5 现役：J/K/L/Q/V），建议优先级 ≥ 5 verb

4. **STYLE_GUIDE.md 色板段**：在「5 动词色域」表加一行 `<verb> = <#hex>  <verb 主题色>`（5 现役：Pulse #E86D5A Coral / Bind #65506A Violet /
Cut #F2B66E Amber / Echo #69C7CE Cyan / Wave #B7E6DC Pale Resonance）

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

9. **冒烟测试** `tools/test_i025_t199_f013d_smoke.gd`：本轮已提供 5 字段示例（T199 `_VERB_HINT_DATA` 5 verb 元素 + T199
`_build_verb_hint_tooltip` 5 行 + F013.D 接入路径 §9.1 9 步存在）

### 9.2 易错点（按历史回归频率排序）

- **重声明 `cooldown` / `windup_time`**：H001 #99 hotfix 修复的 5 回归点。`VerbAbilityBase` 已声明，subclass 不要 `@export` 同名字段
- **漏调 `super._ready()` / `super._exit_tree()`**：base class 自动 resolve `_player` + 清理 `_windup_vfx`
- **toolbar / pause 漏加新 verb 颜色**：6 处表层（HUD 5+1 冷却条 / 屏震 flash / PauseMenu 5+1 动词行 / 商店 echo_charm / 成就图标 /
quintuple_voice 6+1 词）必须全更新
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

> 本节记录历史上踩过的"polish 加新字段但忘记声明"类 pre-existing parse error。
T246 (#163) 修复 `_VERB_ROW_BASE_FONT_COLOR` (T244 #161 残留) 是首个显式记录项，未来同类问题应先查本节。

### 9.5.1 `_VERB_ROW_BASE_FONT_COLOR` 残留（L246 #163 修复）

- **症状**：`src/scripts/pause_menu.gd:1944` (Tween target) 引用 `_VERB_ROW_BASE_FONT_COLOR`，但 T244 (#161) 引入时**只引用不声明**，
触发 Godot 4.6.3 静态解析 `Parse Error: Identifier "_VERB_ROW_BASE_FONT_COLOR" not declared in the current scope.`。
- **触发场景**：polish 期给已有 Label 加 `mouse_entered` / `mouse_exited` handler，需要"渐到 base font_color"时直接引用了一个未声明的 const 名字。
- **修复**：在 `src/scripts/pause_menu.gd` line 145 之后加 1 行 const 声明 `const _VERB_ROW_BASE_FONT_COLOR := Color(0.875, 0.835,
0.784, 1.0)` + 注释锚点（Voxglass Warm White 与 pause_menu.tscn StatRows 同源）。
- **预防**：
  1. polish 期加新 const / var 前先在文件头部 const 块集中声明（pause_menu.gd 已有 const 块约定）；
  2. 加完新引用后**必须**跑 `godot --headless --quit --path /workspace 2>&1 | grep -E "SCRIPT ERROR|Parse Error|
GDScript"` 静态解析（**注意**：仅跑 `--quit` 不一定 reload autoload scripts，
需要 `godot --headless --import --path /workspace` 完整 reload 才会暴露跨类引用问题）；
  3. hover / tooltip handler 类 polish 改动建议同时用 source-grep `_VERB_ROW_` 验证所有引用 const 都已声明。

### 9.5.2 ink_warden.gd 4 处标识符引用 preload 化（T243 #161 落地）

- **症状**：`src/scripts/ink_warden.gd:546/578/603/643` 引用 `RepairVFX` / `DamageNumber` 标识符，**走全局 class_name 解析**。
- **触发场景**：fresh clone 状态下 `.godot/` 缓存可能丢失，class_name 解析偶发 stale 标识符（虽然实际 class_name 都存在，0 SCRIPT ERROR，
但 fresh clone hot-reload 鲁棒性 < 100%）。
- **修复**：文件顶部加 `const RepairVFX = preload("res://src/scripts/repair_vfx.gd")` + `const DamageNumber =
preload("res://src/scripts/damage_number.gd")`，4 处 method call 引用 0 改。
- **预防**：任何 polish 期或重构期，对 `class_name` 跨类引用**优先**用 `preload` 显式静态解析，
仅在 `var x = OtherClass.new()` 类延迟实例化场景保留 `class_name` 引用。

## 10. 联系方式 / 决策记录

- 大决策（玩法方向 / 风格宪法）→ `ROADMAP.md` 顶部「当前方向」+ `CHANGELOG.md` 段头
- 审查发现问题 → `REVIEW_LOG.md`（严重/一般/轻微/信息 4 类）
- 灵感 / 候选 → `INSPIRATION.md`（- 游戏名《xxx》：机制参考 (链接)）

## 11. F002 self-test commit hook 集成 (T265 落地, 防止 commit 漏更新 README 类问题回归)

> T265 (#186) 把 F002 self-test (设计本意: "prove the hook would block if README missing #N-1 entry") 从「审查阶段检测」提前到「commit
阶段检测」, 防止 #183 commit 时漏更新 README.md + README.zh-CN.md 「Recent completed work」/「最近完成的工作」段类问题再次出现. 落地后任何 "commit 漏更新
README" 类问题在 commit 阶段即被捕获, 0 漂到审查阶段. 涉及 3 件套 (Python 解析器 + pre-commit 检查脚本 + hook installer).

### 11.1 设计本意 (T265 落地动机)

T265 (#186) 的核心动机是 **F002 self-test 设计本意是 "在 commit 阶段阻断",
但落地时只在审查阶段检测** —— #80 (#80 F002 self-test 设计本意: "prove the hook would block if README missing #N-1 entry") 设计时把 F002
写成"hook", 实际 #80 落地时只在审查阶段检测, 不是真正的 commit hook. #185 审查时检测出 #183 commit 时漏更新 README, #185 FIX-#185-1 修复了 #183 段,
但 F002 self-test 仍未集成到 commit 阶段, "commit 漏更新 README" 类 regression vector 仍存在. T265 (#186) 把 F002.7 + F002.8 校验提前到
commit 阶段: commit 前自动跑测 README 同步状态, 缺失 → 阻断 commit (exit 1). 落地后任何 "commit 漏更新 README" 类问题在 commit 阶段即被捕获,
0 漂到审查阶段. 设计原则: (1) 0 触碰游戏代码 (T265 仅 0 触碰 .gd / .tscn / 任何 gameplay code,
仅新加 3 个工具链文件: tools/pre_commit_f002_check.sh + tools/install_hooks.sh + tools/_parse_recent_section.py);
(2) 0 强制 (hook 是 .git/hooks/pre-commit 不入仓, 开发者可拒绝安装, 拒绝安装时仅失去 "commit 阶段检测" 能力, 审查时仍检测);
(3) 0 覆盖用户自定义 hook (install_hooks.sh 用 F002_MARKER 检测是否已安装, 已安装则跳过; 用户有自定义 pre-commit hook 时 append 而非 overwrite);
(4) 0 漂动 check_smoke_consistency.sh (T265 复用 Rule 7 的解析逻辑但用 Python 替代 awk, 0 改 Rule 7 既有逻辑, 仅新增独立工具链);
(5) 0 触碰 §10 决策记录流程 (F002 self-test 是 1 个独立工具链, 与 §10 联系方式 / 决策记录流程 0 互混).

### 11.2 工具链 3 件套 (T265 落地产物)

T265 (#186) 落地 3 件套工具链, 任何 polish 期给工具链加新 1 文件 (e.g. F003 self-test / F004 lint / F005 格式化 / F006 静态分析) 时**必须**严格按 3 件套
1:1 复制既有模式:

1. **Python 解析器** (`tools/_parse_recent_section.py`, 落地 T265) —— F002.7 + F002.8 解析逻辑的 Python 实现,
替代 awk (awk 解析在 `### Recent completed work` 后紧跟 `## #N` 段时 flag 重置导致空输出). 解析规则: (1) section 起始: `^#{2,
3}\s+(Recent completed work|最近完成的工作)\s*$`; (2) section 包含 `## #N` 标题行本身 (每个 `## #N` 标题是 1 个 #N entry);
(3) section 结束: 下一个非 `## #N` 的 `## ` 标题, 或下一个 `### ` 标题 (sub-section);
(4) section 内的文本叙述中的 #N 引用全部忽略 (避免 "下一轮（#186, 186%5==1 普通模式）" 类 prose 提到未来 #N 值时的 false positive). 任何"加新 1 README 段"
(e.g. T262 启用的 "Decisions" 段 / T260 启用的 "Open Items" 段) 时**必须**在 `_parse_recent_section.py` 加 1 个新段名 + 在
`pre_commit_f002_check.sh` 加 1 行 `for rf in "新段名" ...` 同步 (0 漏 1 边).
2. **pre-commit 检查脚本** (`tools/pre_commit_f002_check.sh`, 落地 T265) —— F002.7 + F002.8 校验脚本,
commit 前自动跑测 README + README.zh-CN.md 同步状态. 流程: (1) `set -uo pipefail` 1 行;
(2) 解析脚本路径 + repo root + 4 个变量 (README_FILE / README_ZH / ITER_COUNT_FILE / PARSER) 4 行;
(3) sanity check 3 件套 (ITER_COUNT_FILE 存在 + ITER_COUNT 非空 + PARSER 存在 + python3 可用) 4 块;
(4) 推导 PREV_ITER = ITER_COUNT - 1 (最少 1) 2 行; (5) `for rf in "$README_FILE" "$README_ZH"` 循环 9 行 (parse + diff +
FAIL/PASS 3 分支); (6) 退出码 0/1/2 (PASS / FAIL / warning). 任何"加新 1 检查" (e.g. CHANGELOG 同步 / ROADMAP 顶部时间戳 /
ITERATION_COUNT.txt 同步) 时**必须**在循环内加 1 个新分支 (0 漏 0 改 1 字符).
3. **hook installer** (`tools/install_hooks.sh`, 落地 T265) —— 复制 `tools/pre_commit_f002_check.sh` 到
`.git/hooks/pre-commit` 的一次性安装脚本. 流程: (1) 解析脚本路径 + repo root + 4 个变量 (HOOKS_DIR / PRE_COMMIT_HOOK / SOURCE_SCRIPT /
F002_MARKER) 4 行; (2) sanity check 2 件套 (.git/hooks 存在 + SOURCE_SCRIPT 存在) 2 块;
(3) `--uninstall` 模式单独处理 (4 个分支: 0 hook / 0 F002 hook / 纯 F002 hook / 用户自定义 hook); (4) install 模式 3 个分支 (无 hook → 创建;
有 F002 hook → 跳过; 有用户自定义 hook → append F002_MARKER + 调用);
(5) chmod +x 0 漏. 任何"加新 1 hook 类型" (e.g. pre-push F002 check / commit-msg lint / post-merge F002 sync) 时**必须**在
installer 加 1 个新分支 (0 漏 0 改 1 字符).

### 11.3 使用流程 (开发者本地一次性安装)

```bash
# 1. 进入 repo root
cd /workspace

# 2. 安装 pre-commit hook (一次性, 不入仓, 仅本地)
bash tools/install_hooks.sh

# 3. 测试 (允许空 commit, 走完 hook 流程)
git commit --allow-empty -m "test F002 hook"

# 4. 卸载 (如需)
bash tools/install_hooks.sh --uninstall
```

任何"开发者拒绝安装 hook"的情况: 0 强制裁, 0 触碰游戏代码, 0 触碰 CI 流程, 仅失去"commit 阶段检测"能力,
审查阶段仍会检测 (F002 self-test 仍是 `tools/check_smoke_consistency.sh` Rule 7 + `tools/test_t158_t156_f002_smoke.gd`
F002.7/F002.8). 落地后 0 漂动: T265 0 触碰 Rule 7 既有 awk 解析逻辑 (仅新加 Python 解析器作为独立工具链, 两者并存),
0 触碰 `test_t158_t156_f002_smoke.gd` F002.7/F002.8 (F002 self-test 仍是审查时跑测).

### 11.4 T265 落地边界 (0 触碰清单)

- 0 触碰游戏代码 (T265 0 改任何 .gd / .tscn / 任何 gameplay code, 仅新加 3 个工具链文件)
- 0 触碰 .git/hooks (hook 是不入仓的, install_hooks.sh 仅是 installer, 不入仓)
- 0 触碰 check_smoke_consistency.sh Rule 7 (T265 0 改 Rule 7 既有 awk 解析逻辑, 仅新加 Python 解析器作为独立工具链)
- 0 触碰 test_t158_t156_f002_smoke.gd F002.7/F002.8 (F002 self-test 仍是审查时跑测, T265 0 改 F002 self-test 既有逻辑)
- 0 触碰 §9.6 / §9.7 任何 fragility 章节 (T265 是工具链任务, §9.6 / §9.7 是 game code fragility, 0 互混)
- 0 触碰 §10 决策记录流程 (F002 self-test 是 1 个独立工具链, 与 §10 联系方式 / 决策记录流程 0 互混)
- 0 触碰 README.md / README.zh-CN.md 内容 (T265 仅校验 README 同步状态, 0 改任何 README 内容)
- 0 触碰 ITERATION_COUNT.txt / CHANGELOG.md / ROADMAP.md 内容 (T265 仅校验 CHANGELOG + ROADMAP 同步状态, 0 改任何内容)

### 11.5 预防 (避免后续 polish 漂动)

1. 任何 polish 期给工具链加新 1 文件 (e.g. F003 self-test / F004 lint / F005 格式化 / F006 静态分析) 时**必须**严格按 3 件套 1:1 复制既有 T265 模式: (1)
Python 解析器 (或独立可调用逻辑) 1 个新文件 + (2) pre-commit 检查脚本 (或 commit-time 检查) 1 个新文件 + (3) hook installer (或新工具链安装器) 1 个新文件. 0 漏
1 件 = 该工具链的 commit-time 检测能力 0 闭环, 漂到审查阶段才检测 (与 T265 落地前 F002 self-test 同模式). source-grep 验证 `tools/` 目录下 3 件套 0 漏 0 改 1
字符.
2. `tools/_parse_recent_section.py` 0 改解析逻辑 (T265 落地时的 4 条规则 0 改 0 删 0 重排) —— 任何"加新 1 README 段" (e.g. T262 启用的
"Decisions" 段 / T260 启用的 "Open Items" 段) 时**必须**在 `_parse_recent_section.py` 加 1 个新段名 + 在 `pre_commit_f002_check.sh` 加 1
行 `for rf in "新段名" ...` 同步, source-grep 验证 0 漏 1 边.
3. `tools/pre_commit_f002_check.sh` 0 改 sanity check 3 件套 (T265 落地时的 ITER_COUNT_FILE 存在 + ITER_COUNT 非空 + PARSER 存在 +
python3 可用 4 块 0 改 0 删 0 重排) —— 任何"加新 1 sanity check"时**必须**严格按既有 4 块 1:1 复制 (sanity check 失败 → exit 1),
source-grep 验证 sanity check 4 块 0 漏 0 改 1 字符.
4. `tools/install_hooks.sh` 0 改 install / uninstall 2 模式 0 触碰既有逻辑 (T265 落地时的 4 个分支: 0 hook / 0 F002 hook / 纯 F002 hook /
用户自定义 hook 0 改 0 删 0 重排) —— 任何"加新 1 hook 类型"时**必须**严格按既有 4 分支 1:1 复制 (F002_MARKER 检测 + chmod +x 0 漏),
source-grep 验证 install / uninstall 2 模式 0 漏 0 改 1 字符.
5. F002_MARKER 0 改 (T265 落地时显式用 `# T265 F002 self-test commit hook (do not remove — see tools/pre_commit_f002_check.sh)`
marker 区分 F265 落地的 hook 和开发者自定义 hook) —— 任何"改 marker 字符串"polish 都会让 `install_hooks.sh` 检测失败 (重复安装时 0 跳过, 误判为新安装),
source-grep 验证 F002_MARKER 字符串 0 漏 0 改 1 字符.
6. 0 强制安装 (T265 落地时显式 0 强制开发者安装 hook, 0 触碰 `git config core.hooksPath`, 0 触碰 CI / 审查流程) —— 任何"强制安装"polish 都会让开发者拒绝入仓,
反而失去 commit-time 检测能力, source-grep 验证 `tools/install_hooks.sh` 0 触碰 `core.hooksPath` 0 触碰 CI 流程 0 触碰审查流程.

---


> 感谢你愿意为 Voxglass 添砖加瓦。任何「让下一个开发者少花 10 分钟」的文档 / 冒烟测试 / 注释改进都是受欢迎的贡献。
