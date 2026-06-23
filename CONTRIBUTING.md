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

## 10. 联系方式 / 决策记录

- 大决策（玩法方向 / 风格宪法）→ `ROADMAP.md` 顶部「当前方向」+ `CHANGELOG.md` 段头
- 审查发现问题 → `REVIEW_LOG.md`（严重/一般/轻微/信息 4 类）
- 灵感 / 候选 → `INSPIRATION.md`（- 游戏名《xxx》：机制参考 (链接)）

---

## 11. 14 成就 → 9 BGM 主题 Layering Map（T205 #122 第一半 / F014 商业化解锁听觉化）

> **设计目标**：当 14 个成就之一解锁时，听觉上立即"对位"到一个 BGM 主题的
> 短小 layer 化叠加（chime + 4-8s 主题 motif 淡入 + 回到原 BGM）。
> 让玩家用耳朵就能感知"我的进度跨越了哪个里程碑"，是 Steam demo
> "声音 + 视觉"双重反馈的核心。
>
> **现状 (#122)**：本节只交付 14→9 映射表 + 设计规范。**代码实现**（在
> `AudioManagerEnhanced` 添加 `play_achievement_layering(achievement_id)`
> 方法，订阅 `PlayerStats.achievement_unlocked` 信号）放在 #123 之后，
> 避免 1 轮内触及 6 文件 + 测试基础设施。

### 11.1 14 成就 → 9 BGM 主题映射

> 列序与 `data/achievements.json` 完全一致。BGM 主题 key 与
> `src/scripts/audio_presets.gd:53 MUSIC_PRESETS` 完全一致。

| # | achievement_id        | title_zh         | BGM 主题 (key)        | 选择理由                                                                                                            |
|---|-----------------------|------------------|-----------------------|---------------------------------------------------------------------------------------------------------------------|
| 1 | first_steps           | 第一步          | archive_exploration   | 玩家踏入第一间回声档案馆 = 探索 BGM 主题首次触发的"叙事起点"，直接选探索主题作为 1 号成就的 layer |
| 2 | voice_purifier        | 声音净化者      | archive_exploration   | 净化 5 个敌人 = 探索主题内的"轻量战斗"段落；与 first_steps 同主题但用 0.85× 音量区分（"3 verb 清洁版"）|
| 3 | resonance_collector   | 共鸣收集者      | hub_warm              | 收集 15 枚碎片 = 玩家回到"安全区 / 丰盛"感受，hub_warm 暖色 + 较大 chord 暗示"满"                |
| 4 | triple_voice          | 三声齐鸣        | archive_exploration   | 3 verb 入门 = 探索主题的"三和弦"已经够用，无需引入新主题；layer 化时只升 1 个 arp step              |
| 5 | quadruple_voice       | 四声回响        | archive_storm         | 4 verb = 探索 BGM 已不够"重"；archive_storm 的 108bpm + 较低 pad_volume 体现"紧张"               |
| 6 | quintuple_voice       | 五声回响        | archive_dawn          | 5 verb = 全部 5 声波能力 → archive_dawn（最暖 + 慢 + 大 chord）作为"完整"听觉回报                  |
| 7 | first_cut             | 切断腐蚀        | silence_void          | 切断 = 划破沉默，silence_void 的 0 arp + 22050Hz 低通是"反 arpeggio"语义，与 Cut 动词同源            |
| 8 | warden_slayer         | 墨守终结者      | archive_boss_dual     | 击败 InkWarden → boss 主题变体（dual chord = 击败后"双重缓解"），fade 后回归 archive_exploration     |
| 9 | full_archive          | 完整档案        | archive_dawn          | 完成 3 间 = 跨过中段里程碑；archive_dawn 的"破晓"语义对应"档案馆不再黑"                           |
| 10 | persistent_resonance | 不灭回响        | hub_warm              | 存档 3 次 = 回到 hub 的温暖 = 玩家"安全落地"的听觉奖赏                                            |
| 11 | long_road            | 漫长旅程        | whisper_hollow        | 10min 单次 run = whisper_hollow 的 8.0s 长 loop + 极慢 LFO (0.12Hz) 暗示"时间"                      |
| 12 | archive_master       | 档案大师        | archive_dawn          | 4/4 完成 = 全档案馆的"黎明" → archive_dawn 是"endgame 收束"主题                                    |
| 13 | resonance_hoarder    | 共鸣囤积者      | hub_warm              | 50 碎片 = 极致丰盛 = hub_warm 主题的高音量变体（fade 期间把 pad_volume 临时 +0.05dB）                |
| 14 | silence_hunter       | 寂静猎手        | silence_void          | 20 净化 = silence_void 的"反"使用：上次是"切断沉默"，这次是"把沉默打散成 0"                       |

### 11.2 Layering 实现规范（#123+ 落地时的契约）

1. **触发入口**：`AudioManagerEnhanced.play_achievement_layering(achievement_id: String)`
2. **订阅源**：`PlayerStats.achievement_unlocked`（已在 #83 落地）
3. **叠加策略**：在当前 BGM 之上以 0.7× 音量叠加 4-8s 主题 motif 片段
   - 取 `MUSIC_PRESETS[bgm_key]` 的 `duration` 50% 位置作为 motif 起拍点
   - 0.4s fade-in，0.6s fade-out（参考 FINALE_PHASE2_FADE_MS）
4. **冲突解决**：若 5s 内有多个成就解锁，**取最高优先级 BGM**（11.3 节给出排序）
5. **静音模式**：若 `AudioManagerEnhanced.is_bgm_muted` 为 true，layering 仍然
   播放 chime 但不叠 BGM（视觉反馈不丢）
6. **chime 复用**：复用 F013.A (#103) 的 `play_achievement_chime()` 方法

### 11.3 BGM 主题优先级（成就解锁冲突时）

> 高优先级 → 低优先级
> 1. archive_dawn（endgame 收束：5 voice / 3 archives / master）
> 2. archive_boss_dual（boss 击败后的双缓解）
> 3. silence_void（沉默系：first_cut / silence_hunter）
> 4. archive_storm（紧张系：quadruple_voice）
> 5. archive_exploration（探索系：first_steps / voice_purifier / triple_voice）
> 6. hub_warm（温馨系：resonance_collector / persistent_resonance / resonance_hoarder）
> 7. whisper_hollow（时间系：long_road）

### 11.4 测试覆盖目标（#123+ 接入后）

- [ ] 14 个成就逐一解锁 → 听到对应 BGM layer
- [ ] 5s 内连续解锁 2 个 → 听到优先级更高的 BGM（test_achievement_layering_priority）
- [ ] 静音模式下解锁 → 听到 chime 但不叠 BGM
- [ ] 章节切换时（archive → hub）→ 旧 BGM fade 后新 BGM 继续正常播放

### 11.5 相关代码锚点（#123 落地时直接修改）

| 目标文件                                | 改动                                                                                  |
|------------------------------------------|---------------------------------------------------------------------------------------|
| `src/scripts/audio_manager_enhanced.gd`  | 新增 `play_achievement_layering(id)` 方法 + `_ACHIEVEMENT_BGM_MAP` 常量               |
| `src/scripts/audio_manager_enhanced.gd`  | 在 `_ready()` 订阅 `PlayerStats.achievement_unlocked` → 路由到 `play_achievement_layering` |
| `src/scripts/audio_presets.gd`           | 若需要给 archive_dawn / archive_boss_dual 添加 0.7× 音量版本的 preset                |
| `tests/smoke/test_achievement_layering.gd` | 14 成就 × 1 断言（chime + BGM 切换信号）                                          |

---

> 感谢你愿意为 Voxglass 添砖加瓦。任何「让下一个开发者少花 10 分钟」的文档 / 冒烟测试 / 注释改进都是受欢迎的贡献。
