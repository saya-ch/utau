# Voxglass（声匣修复者）

一款 2D 像素美术的动作探索游戏。在被淹没的地下声档案馆中，修复被「活体寂静」夺走的人类声音。

## 状态

进行中的可玩竖切。当前里程碑：可玩 60 秒房间演示「进入 → Pulse 击退 → 修复 → 收集 → 出门」核心循环。

## 技术栈

- 引擎：Godot 4.6.3（已验证 — `config/features=4.4` 保留以兼容旧版，依 `REVIEW_LOG.md` #20 在 4.6.3 上解析干净）
- 分辨率：480x270 内部画布，整数倍缩放至 1920x1080
- 语言：GDScript
- 音频：程序化 SFX（pulse / 脚步 / 玻璃碎裂 / 敌人低鸣 / 修复 / 受击）+ **9 个程序化 BGM 主题**（`title_intro` 序章 / `hub_warm` 安全区 / `archive_exploration` 探索 / `archive_boss` 单 InkWarden Boss / `archive_boss_dual` 双 Boss 房 `archive_04` / `archive_dawn` 胜利与回归 / `archive_storm` tier-3 Boss 阶段 2 升级 — InkWarden 半血跃迁自动切换 / `whisper_hollow` 后期 Hub — 完成 2 间档案房后自动切换，见下方「BGM 9 主题色板」节 / `silence_void` 失败状态 + 终曲阶段 1，见「游戏状态机」节）— 全部在运行时通过 `src/scripts/audio_manager_enhanced.gd` 的 `AudioStreamWAV` 合成（无需外部音频文件），9 主题数据表在 `src/scripts/audio_presets.gd`。标题屏预热 BGM 缓存让首次场景切换零延迟。设置菜单提供 Master / Music / SFX / Ambience 四 bus 独立音量滑块。Boss 音乐 override 采用引用计数（T078），并支持强度分级 tier 升级（T080 / #59 T107）。
- **死亡与重生**：1.5s 倒下 + 渐隐死亡动画（T075）。开头 0.15s 慢动作 + 红洗定格（T092 — `Engine.time_scale = 0.2`，`modulate` 偏移到 `Color(1.4, 0.45, 0.45)`，让 alpha 衰减读作"流失的红"），随后身体倒下。死亡后默认传送回 Hub 安全区（T079）— 在 `设置 → 存档` 中关闭「死亡后回 Hub 安全区」开关可切回经典「在最近存档灯笼重生」模式。
- **档案房二阶段灯光**（M12 打磨，T076）：当房间的 `voice_bell` 修复完成时，场景 modulate 在 0.8s 内从冷墨青色缓出至暖琥珀（阶段 1），房间完成时再 2s 渐入完整暖色覆盖（阶段 2）。4 个档案房都在 `data/rooms/archive_*.json` 中 opt-in `"atmosphere": true`。
- 本地 Godot 二进制：`godot/Godot_v4.6.3-stable_linux.x86_64`（首次解压 + `--import` 配方见 `godot/README.md` 和下方「Headless Godot 二进制设置」节）

## 项目结构

```
assets/        # 美术、音频和设计参考素材
src/           # 源代码
  autoload/    # GameState、AudioManager 等单例
  scenes/      # Godot 场景文件（.tscn）
  scripts/     # GDScript 逻辑
docs/          # 设计文档（Steam 页面等）
scripts/       # Python 素材管线工具
data/          # 存档 / 房间 / 成就 JSON 数据
```

## 按键

| 动作 | 键盘 | 手柄 |
|--------|----------|---------|
| 移动 | A/D 或方向键 | 左摇杆 |
| 跳跃 | 空格 或 W | A 键 |
| Pulse（推/破盾） | J 或 Z | X 键 |
| Bind（牵引/暂停/开能力门） | K 或 X | Y 键 |
| Cut（斩/切断） | L 或 C | LB 键 |
| Echo（护盾反弹） | Q | 三角键 |
| 交互 | E 或 Enter | B 键 |
| 暂停 / 菜单 | ESC | Start 键 |
| 存档（自动 + 手动） | 走到存档灯笼 / 暂停 → 保存进度 | — |
| 读档继续 | 标题屏 → 继续修复（有存档时显示） | — |
| 致谢 | 标题屏 → 致谢按钮 | — |

## 截图

6 张营销截图位于 `docs/screenshots/`（1920x1080 PNG，480x270 内部画布 4x 整数倍缩放）：

1. `01_title_screen.png` — 标题屏（VOXGLASS + 4 按钮）
2. `02_hub_room.png` — Hub 安全区 + 4 扇门 + 墨守者剪影
3. `03_archive_01_pulse.png` — 第一档案房 + Saya + SilenceMote + Pulse 圆环
4. `04_archive_03_boss.png` — 第三档案房 + InkWarden Boss
5. `05_archive_04_double_boss.png` — 第四档案房「共鸣祭坛」+ 双 InkWarden
6. `06_shop_merchant.png` — 无声商贩 + 商店 UI + 5 个永久升级

> **沙箱说明**：本仓库 CI 沙箱无 Xvfb / Wayland / GL 上下文，Godot 4.6.3 headless 模式强制使用 dummy 渲染器，真实 `Viewport.get_texture().get_image()` 返回 null。**#43 用 `tools/generate_screenshot_mockups.py` 基于既有资产合成 6 张截图**作为 M10 营销上线最后阻塞解除。真实 capture 工具（`tools/screenshot_capture.gd` + `tools/capture_screenshots_desktop.sh`）在桌面环境（带 Xvfb / X11 / 真机）可直接使用。详见 `tools/README.md`。

## 存档系统

5 个存档槽位持久化到 `user://saves/slot_N.json`（#55 T088 从 3 槽扩展）。每个槽位保存：

- `current_room` + `current_scene`（房间 id + .tscn 路径，让「继续修复」能重新加载到正确场景）
- `health` / `resonance` / `shards` 与 `rooms_completed` 集合
- 已解锁的 `abilities`（bind / cut / echo）与玩家最后 `checkpoint_position`
- `run_time_seconds`（游戏内计时器）
- 截至当前已解锁的全部 `achievements`（同时在每次解锁时即时写入 `user://achievements.json`，独立于槽位）

标题屏仅在至少有一个存档时显示「继续修复」按钮。暂停菜单的「保存进度」按钮打开同样的存档槽位选择器（保存模式）。成就解锁的瞬间立即落盘到磁盘。

## 音频控制

`设置 → 音频` 菜单提供三个独立音量滑块，每个绑定到独立的 Godot AudioServer bus：

| 滑块 | Bus | 内容 |
|--------|-----|----------|
| Master | `Master` | 全部（混音后的 BGM + SFX + ambience） |
| Music | `Music` | 程序化 BGM（`title_intro` / `hub_warm` / `archive_exploration` / `archive_boss` / `archive_boss_dual` / `archive_dawn` / `archive_storm` / `whisper_hollow` + 沉默槽 `silence_void`） |
| SFX | `SFX` | Pulse / Bind / Cut / 脚步 / 玻璃碎裂 / 受击 / 修复 |
| Ambience | `Ambience` | 水流 / 风声 / 房间氛围低鸣 |

设置通过 `user://settings.cfg` 跨次运行持久化。

## BGM 9 主题色板

9 个程序化 BGM 主题在大小调上刻意分布，让每间房 / 每个事件听起来都是不同「调性房间」。下方表格中的 key 是 MIDI 编号（A4 = 69）；chord 列是叠加在根音 sine 之上的 3-4 音叠层。完整数据表 + per-preset 设计注释见 [`src/scripts/audio_presets.gd`](./src/scripts/audio_presets.gd)。

| Key | 调性 | Root | Chord（MIDI） | BPM | 循环 | 触发时机 |
|-----|------|------|---------------|-----|------|----------|
| `title_intro` | 稀疏 / 希望 | D3 (50) | D 大 — D4 F#4 A4 | 60 | 16.0s | TITLE 状态（游戏启动） |
| `hub_warm` | 温暖 / 明朗 | F2 (41) | F 大 — F3 A3 C4 | 88 | 10.9s | 早期 Hub（`rooms_completed.size() < 2`） |
| `archive_exploration` | 忧郁 / 深处 | A2 (45) | A 小 — A3 C4 E4 | 72 | 13.3s | 档案房（PLAYING + RoomController） |
| `archive_boss` | 紧张 / 单 Boss | A1 (33) | A 小 + 三全音 — A2 C3 F#3 | 108 | 11.1s | 第一只 InkWarden 入场（tier 1） |
| `archive_boss_dual` | 狂乱 / 双 Boss | A1 (33) | A 小 + 三全音 + 增5 — A2 C3 F#3 G#3 | 132 | 8.7s | 第二只 InkWarden 入场（tier 2） |
| `archive_dawn` | 胜利 / 晨光 | G2 (43) | G 大 — G3 B3 D4 | 76 | 12.6s | GAME_OVER_SUCCESS 终曲阶段 2 + `full_archive` 解锁 |
| `archive_storm` | 混沌 / 阶段 2 | E1 (28) | E 小 + 增4 + 升7 — E2 G#2 B2 D3 | 120 | 10.0s | InkWarden 进入阶段 2（tier 3） |
| `whisper_hollow` | 深度静默 / 小7和弦 | D3 (50) | D 小 7 — F3 A3 C4 E4 | 50 | 16.0s | 后期 Hub（`rooms_completed.size() >= 2`，#64 T123） |
| `silence_void` | 空无 / 缺席 | （无音频） | — | 60 | 4.0s | GAME_OVER_FAILURE + 终曲阶段 1 |

### 调性分布哲学

- **大调**（`title_intro` D / `hub_warm` F / `archive_dawn` G）读作「世界完好 / 有希望 / 明朗」。Hub 默认 F 大调（最亮），`archive_dawn` 是唯一 G 大调（较 hub_warm 上行五度 = 世界在胜利时「上行一步」解决）。
- **小调**（`archive_exploration` A / `archive_boss` A / `archive_boss_dual` A / `archive_storm` E / `whisper_hollow` D）读作「档案被侵蚀 / 忧郁 / 危险」。其中 3 个共用 A 小调以便 Boss 战中 crossfade 是和声过渡；`archive_storm` 切到 E 小调是和声对比（chaos，不只是 intensity 升级），`whisper_hollow` 切到 D 小调是「距离感」（深度静默，区别于紧迫的探索主题）。
- **不和谐递进**：纯净三和弦 → +三全音 → +三全音 +增5 → +增4 +升7。每个 tier 1/2/3 Boss 主题加一个不和谐音程，Boss 战音乐把「升级」听成和声压力，不是单纯的音量。
- **沉默作为一个主题**：`silence_void` 是唯一一个「全振幅为零」preset — 它**不是** BGM，是 BGM 的**有意缺席**。它桥接失败状态（4 秒空无配合冷灰视觉洗）和终曲阶段 1（4 秒「世界清空」后由 `archive_dawn` 解决）。
- **过场 ambient 垫底**（T122）：不是 BGM preset，是按需生成 8 秒 D2 + G2 双 sine drone 走 Ambience bus，由 `AudioManagerEnhanced.play_intro_ambience()` 现场生成、`intro_cutscene.gd._play_sequence()` 触发。它活在即将到来的 `title_intro` BGM 之下，让过场永远不出现硬沉默。

## 游戏状态机

`GameFlowController` 是一个小型状态机，6 个状态。每个状态转换都会把一个 BGM `play_music_track` / `play_music_finale` 调用路由到 `AudioManagerEnhanced`；可视化版本见 [BGM 状态机映射图](./assets/voxglass-bgm-state-map.png)，下方是文字版表格。

| 状态 | 触发 | BGM | 音频 API | 备注 |
|------|------|-----|----------|------|
| `TITLE`（标题） | 游戏启动 / 继续按钮 | `title_intro` | `play_music_track("title_intro", 1200)` | 16 秒 D 大调希望 pad；菜单停留期间循环。 |
| `PLAYING`（游戏中） | 新游戏 / 暂停恢复 / 场景转换完成 | `hub_warm` *或* `archive_exploration` *或* `whisper_hollow` | `play_music_track(scene.bgm_key, 800)` | 确切键名取自场景的 `bgm_key`（Hub 取 `hub_warm`）。Boss 房间额外调 `request_boss_music` — 见下方 BOSS 覆盖。 |
| `PAUSED`（暂停） | `pause_requested` 信号（Esc / P） | _保持_ | _无_ | 暂停时 BGM 继续播放；暂停菜单只静音 SFX。time_scale 在恢复时回到 1.0。 |
| `ROOM_TRANSITION`（过场） | 触发房门 | _保持_ | _无_ | 黑屏淡出 0.4s；下一场景 `_ready` 拿到 `bgm_key` 后再调一次 `play_music_track`。 |
| `GAME_OVER_SUCCESS`（胜利） | 玩家通关最终房间 | `silence_void` → `archive_dawn`（4.0s + 12.6s） | `play_music_finale()`（T117） | 两阶段终曲。阶段 1 沉默 = "世界消亡"；阶段 2 dawn = "世界重新呼吸"。`play_music_finale` 内部的 `_current_music_key` 守卫会让阶段 2 尊重玩家"返回 Hub"的中断。 |
| `GAME_OVER_FAILURE`（失败） | 玩家 HP ≤ 0 | `silence_void` | `play_music_track("silence_void", 1200)` | 4 秒零振幅循环，与 T093 冷灰视觉洗同步。配合 T115 死亡碑文叠加 + T116 InkWarden 残影播放。 |

### BGM Boss 覆盖（与状态正交）

InkWarden（或 `elite_enemies` 组中任意敌人）入场时调 `request_boss_music`。该覆盖是**引用计数**的、**tier 排序**的，因此多 Boss 房间第一只死亡不会丢 BGM，第二阶段升级会自动顶替第一阶段：

| Boss 事件 | 覆盖键 | Tier（相对当前） | 效果 |
|-----------|--------|------------------|------|
| 单只 InkWarden 入场 | `archive_boss`（A 小调 108 BPM） | 1 | 强制 `play_music_track("archive_boss")`，无视 `PLAYING` 状态路由。 |
| 同一房间出现第二只 InkWarden | `archive_boss_dual`（A 小调 132 BPM） | 2 > 1 | 战斗中交叉淡入升级。 |
| InkWarden 进入阶段 2 | `archive_storm`（E 小调 120 BPM） | 3 > 1, 2 | 最强烈预设；持续混乱。 |
| 最后一只 Boss 死亡 / 离开 | _清除_ | 0 | 回到场景的 `bgm_key`（`archive_exploration`）。 |

Boss 音乐与终曲音乐正交：若玩家在 Boss 战中死亡，`GAME_OVER_FAILURE` 从 `PLAYING+boss_override` 状态到达。GFC 路由到 `silence_void` **之前** `release_boss_music()` 已经清除覆盖，因此失败路径干净。

## 死亡与重生序列

- **0.15s freeze-frame**（T092）：`Engine.time_scale = 0.2` + `sprite.modulate = Color(1.4, 0.45, 0.45)` 慢动作 + 红洗定格
- **0.3s 灰阶洗**（T093）：冷灰 `Color(0.32, 0.34, 0.40)` sine tween 双段
- **0.5s lay-down**：rotation → PI/2 quad-ease-in 身体倒下
- **1.0s fade-out**：alpha 1→0 linear 保持红调（"drained red" 而非 flashing red）
- 触发 `_finish_death` → 默认回 Hub 安全区（T079 开关可切回最近存档灯笼）

## 商店系统

Hub `silent_merchant` NPC（#41 T068）提供 5 个永久升级，跨 run 持久化到 `purchased_perks`：

| ID | 效果 | 描述 |
|-----|------|------|
| `heart_crystal` | `max_health_bonus +20` | 生命上限 +20 |
| `resonance_chime` | `max_resonance_bonus +25` | 共鸣能量上限 +25 |
| `pulse_focus` | `pulse_radius_bonus +6` | Pulse 判定半径 +6px |
| `echo_charm` | `echo_radius_bonus +8` | Echo 护盾判定半径 +8px（#52 T096 笔误已修正） |
| `silence_breaker` | `damage_bonus +1` | 全局伤害 +1（需先解锁 `full_archive` 成就） |

## 成就系统

8 枚 Steam 风格成就（#28 T059 + #41 T068 增量）：

| ID | 名称 | 解锁条件 |
|-----|------|----------|
| `first_steps` | 第一步 | 进入第一个档案房 |
| `voice_purifier` | 声音净化者 | 净化 10 个 SilenceMote |
| `resonance_collector` | 共鸣收集者 | 拾取 50 枚共鸣碎片 |
| `triple_voice` | 三声齐鸣 | 至少使用一次 Pulse、Bind、Cut |
| `quadruple_voice` | 四声回响 | 至少使用一次 Pulse、Bind、Cut、Echo（A062） |
| `first_cut` | 切断腐蚀 | 用 Cut 切断第一条腐蚀链 |
| `warden_slayer` | 墨守终结者 | 击败第一只 InkWarden |
| `full_archive` | 完整档案 | 完成全部 4 个档案房 |
| `persistent_resonance` | 不灭回响 | 死亡 5 次后仍通关 |

每枚成就有独立图标（A039-A046 + A062 复用 A061 Echo 图标）+ 屏幕中央通知卡 + 暂停菜单统计面板 + 8 宫格图标。

## 开发

本项目遵循迭代开发流程，详见 `ITERATION_GUIDE.md`。新协作者请同时阅读 [`CONTRIBUTING.md`](./CONTRIBUTING.md) —— 涵盖仓库结构、3 种 Godot 二进制拼合方法 + `--import` 步骤、7 个冒烟测试套件列表、提交格式、迭代节奏、美术资源登记规则、文档同步 5 问、故障排查速查表与决策记录位置。

### Headless Godot 二进制设置

Godot 4.6.3 headless 二进制以多卷 zip 形式放在 `godot/`。首次克隆（或新建沙箱）后必须先重新拼合并解压，否则任何 `--headless` 命令都无法运行。**方法 A** 用 `unzip`；**方法 B-1** 用 `unzip -FF` 强容错兜底（沙箱 / Python 3.14+ 推荐）；**方法 B-2** 用 Python `zipfile` 标准库（仅 Python ≤ 3.13 有效）。

```bash
# 重新拼合 4 个分卷 + 主存档
cd godot
cat Godot_v4.6.3-stable_linux.z01 \
    Godot_v4.6.3-stable_linux.z02 \
    Godot_v4.6.3-stable_linux.z03 \
    Godot_v4.6.3-stable_linux.z04 \
    Godot_v4.6.3-stable_linux.zip > /tmp/godot_full.zip

# 方法 A — 标准 unzip（多数发行版可用）
unzip -o /tmp/godot_full.zip && chmod +x Godot_v4.6.3-stable_linux.x86_64

# 方法 B-1 — `unzip -FF` 强容错兜底（沙箱 / Python 3.14+ 推荐）
# 当 `unzip` 报 "bad zipfile offset" / "extra bytes at beginning" 时使用。
# `unzip -FF` 自动 re-compensate 坏偏移，比标准 unzip 更宽松。
# 预期输出：warnings "bad zipfile offset" + "attempting to re-compensate" + 最后 `inflating: Godot_v4.6.3-stable_linux.x86_64` 成功。
unzip -FF -o /tmp/godot_full.zip 2>&1 | tail -20 && chmod +x Godot_v4.6.3-stable_linux.x86_64

# 方法 B-2 — Python zipfile 标准库兜底（**仅 Python ≤ 3.13 有效**）
# 当 `unzip` 与 `unzip -FF` 都不可用时再用。
# ⚠️ **F003（#82 复现）**：**Python 3.14+** 标准 `zipfile` 库无法解压多卷 zip —
#    `_extract_member` 抛 `BadZipFile: Bad magic number for file header`（实测 Python 3.14.4 复现）。
#    Python 3.14+ 系统（Ubuntu 25.04+、CI 2026+ 镜像）请用 B-1。
python3 -c "import sys; print(sys.version_info[:2]); " \
    && python3 -c "import zipfile; zipfile.ZipFile('/tmp/godot_full.zip').extractall('.')" \
    && chmod +x Godot_v4.6.3-stable_linux.x86_64

# 验证
./Godot_v4.6.3-stable_linux.x86_64 --version   # 4.6.3.stable.official.7d41c59c4
```

> **首次 import 缓存是强制的** — `.godot/imported/*.ctex` 缓存已加入 `.gitignore`，所以首次 Godot 运行必须重新生成，否则所有 PNG 都加载失败并级联触发 8+ 行 `SCRIPT ERROR`：
>
> ```bash
> ./Godot_v4.6.3-stable_linux.x86_64 --headless --import --path /workspace
> ```

更深的排错见 [`godot/README.md`](./godot/README.md)。

## 开发路线图

我们按小时级迭代维护一个公开可见的 backlog。当前 backlog 在 [`ROADMAP.md`](./ROADMAP.md)，任务 ID 为 `T001`–`TNNN`，并标注完成时间戳。

### 里程碑

| 里程碑 | 状态 | 关键任务 | 备注 |
|---|---|---|---|
| **M1 — 核心循环竖切** | ✅ 已发布（#1–#14） | T001–T013 | 60s "进入房间 → Pulse → 修复 → 收集 → 出门" 可玩 |
| **M2 — 第二个敌人 + 房间变体** | ✅ 已发布（#8–#15） | T017–T025，T017 左朝向修复 | NoteWisp + Archive 02/03 变体 |
| **M3 — 存档与持久化** | ✅ 已发布（#12, #33, #55） | T022, T026, T070, T088 | 存档灯笼 + 5 槽位磁盘存档 + Continue + 列表/卡片视图 |
| **M4 — 玩家进度** | ✅ 已发布（#13–#15） | T029–T034 | 共鸣碎片、InkWarden 精英怪、Bind 能力、能力门 |
| **M5 — Hub + NPC + 设置** | ✅ 已发布（#16, #24, #34, #41, #44） | T035, T036, T037, T048, T068, T072, T086 | 安全区 Hub、对话系统、4-Tab 设置、商店 NPC、按键重映射 |
| **M6 — 玩家统计 + 成就** | ✅ 已发布（#19, #28, #51） | T041, T042, T059–T062 | 9 枚 Steam 风格成就（含四声回响）+ 通知卡 + 8 图标宫格 |
| **M7 — 程序化 BGM** | ✅ 已发布（#29, #31, #39, #44, #59） | T062, T063, T066, T071, T080, T087, T107 | 7 个合成主题（含 `archive_boss_dual` 给 `archive_04` + `archive_dawn` 胜利/回归 + `archive_storm` tier-3 InkWarden 阶段 2 升级）+ 场景路由 + Boss override + tier 升级 |
| **M8 — 死亡动画 + Steam 描述** | ✅ 已发布（#36, #39） | T074, T075, T079 | 倒下死亡、英文 Steam 全文、默认回 Hub + 设置开关 |
| **M9 — 商店页就绪** | ✅ 已发布（#32, #34） | T069, T072, T073 | 3 张 Steam capsule（A047–A049）、序章过场、删除存档 |
| **M10 — Steam 营销上线** | ✅ 已发布（#43） | T083 | 6 张营销截图（由既有资产合成；真实 capture 需要桌面环境，见 `tools/README.md`） |
| **M11 — 后期内容** | ✅ 已发布（#38, #41, #51） | T067, T068, T094, T095 | 第 4 档案房 + 第二只 InkWarden（共鸣祭坛）+ Hub 商店 NPC（5 永久升级）+ EchoAbility 第四动词 |
| **M12 — 终期打磨** | ✅ 已发布（#42, #46, #47, #48, #49, #53, #54） | T076, T084, T089, T090, T092, T093, T098, T100, T101, T102 | 二阶段灯光 + Boss 阶段 2 + 屏幕震动 polish + 装饰物件 + 死亡 freeze/灰阶 + 四动词 flash_color 主题化 + 暂停菜单 BBCode |

### 最近完成的工作

- **#94 — T174.B 5 verb windup VFX 父类抽取（D002 轻量版预演）+ F004 Pulse 音频闭环 + F009 STYLE_GUIDE 4 verb 命中色查表段 + I009 (50 项锚点 smoke 测试)**：新建 [`src/scripts/_verb_windup_vfx_base.gd`](file:///workspace/src/scripts/_verb_windup_vfx_base.gd) 父类（`class_name VerbWindupVFXBase extends Node2D` 64 行 docblock + 30 行实现）；5 verb windup VFX 类（[pulse](file:///workspace/src/scripts/pulse_windup_vfx.gd) / [bind](file:///workspace/src/scripts/bind_windup_vfx.gd) / [cut](file:///workspace/src/scripts/cut_windup_vfx.gd) / [echo](file:///workspace/src/scripts/echo_windup_vfx.gd) / [wave](file:///workspace/src/scripts/wave_windup_vfx.gd)）改为 `extends "res://src/scripts/_verb_windup_vfx_base.gd"`（path-based extends 避免 class_name load order 边角）。**T174.B 抽取内容**：(1) 5 verb 共享 state `_lifetime` / `_max_lifetime` / `_active` 抽到 base → (2) 5 verb 共享 `_ready()` `z_index = 10` 抽到 base → (3) 5 verb 共享 `_process(delta)` lifetime 跟踪 + auto-free safety net 抽到 base → (4) #93 T174 ramp-in tween 代码抽到 base 的 `_activate_windup_tween()` → (5) #92 T173 `fade_out_and_free` 抽到 base → (6) 5 verb 各自 trigger() 改为调 `_activate_windup_tween()`。**6th verb 接入模板**：新 verb windup VFX 只需 `extends VerbWindupVFXBase` + 实现 trigger() 调 `_activate_windup_tween()` + 写 verb-specific `_draw()` 即可。**F004 Pulse 音频闭环**：[`src/scripts/pulse_ability.gd`](file:///workspace/src/scripts/pulse_ability.gd) `_execute_pulse()` 内 `pulse_fired.emit` 之后调 `AudioManagerEnhanced.play_pulse()`（autoload 对齐 T181 #95 5 verb 音频家族候选；`is_instance_valid(_player)` 守卫保护 windup 期间玩家死亡边角）—— 5 verb 音频家族 1/5 进度，Bind/Cut/Echo/Wave 早就有 caller，**Pulse 是唯一缺口**。**F009 4 verb 命中色查表宪法段**：[`STYLE_GUIDE.md`](file:///workspace/STYLE_GUIDE.md) 色板段下增 "4 Verb 命中色查表常量" 段（30 行）—— 4 verb 调色四元组表 + 调用契约示例 + Wave 不参与此查表 + 6th verb 接入流程。T170 #88 锚定扩展为完整宪法级约束。**I009 50 项锚点 smoke 测试** —— [`tools/test_i009_t174b_f004_f009_smoke.gd`](file:///workspace/tools/test_i009_t174b_f004_f009_smoke.gd)（新文件 165 行，50/50 PASS）：T174.B base 19 断言 + 5 verb extends base + trigger() 调 `_activate_windup_tween()` = 10 断言 + F004 4 断言 + F009 17 断言。**同步更新 5 个旧 smoke test 适应 T174.B 重构**：[test_t167_t168_f006_smoke.gd](file:///workspace/tools/test_t167_t168_f006_smoke.gd) / [test_t165_t166_f005_smoke.gd](file:///workspace/tools/test_t165_t166_f005_smoke.gd) / [test_t171_t170d_smoke.gd](file:///workspace/tools/test_t171_t170d_smoke.gd) / [test_t173_windup_fadeout_smoke.gd](file:///workspace/tools/test_t173_windup_fadeout_smoke.gd) / [test_t174_windup_rampin_smoke.gd](file:///workspace/tools/test_t174_windup_rampin_smoke.gd)。**43/43 100% PASS**（与 #93 比 +1，0 回归）+ `check_smoke_consistency.sh` 7/7 规则 PASS + 0 SCRIPT ERROR + 0 parse error。
- **#93 — T174 5 verb windup VFX ramp-in tween 平滑曲线（"VFX 进入家族"，T173 ramp-out 对偶）+ I008 (40 项锚点 smoke 测试)**：[`src/scripts/pulse_windup_vfx.gd`](file:///workspace/src/scripts/pulse_windup_vfx.gd) / [`src/scripts/bind_windup_vfx.gd`](file:///workspace/src/scripts/bind_windup_vfx.gd) / [`src/scripts/echo_windup_vfx.gd`](file:///workspace/src/scripts/echo_windup_vfx.gd) / [`src/scripts/cut_windup_vfx.gd`](file:///workspace/src/scripts/cut_windup_vfx.gd) / [`src/scripts/wave_windup_vfx.gd`](file:///workspace/src/scripts/wave_windup_vfx.gd) 5 文件 `trigger()` 函数体统一 +13 行 + [`tools/test_t174_windup_rampin_smoke.gd`](file:///workspace/tools/test_t174_windup_rampin_smoke.gd)（新文件 110 行）。**T174 "VFX 进入家族"正式闭环** —— 与 #92 T173 "VFX 退出家族"（fade_out_and_free 0.05s 淡出 tween）对偶，本轮给 5 verb windup VFX 启动阶段也用 tween 曲线，让 0.04~0.10s 短 windup 启动也是平滑曲线而非线性 40%-then-hold 的"折线 pop"：(1) `modulate.a = 0.0` 显式初始化（保证 tween 起点一致）；(2) `var ramp_tween := create_tween()` 创建 tween；(3) `tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)` 二次曲线 + 缓出（front-load 可见性，让短 windup 也读得清）；(4) `tween.tween_property(self, "modulate:a", 1.0, _max_lifetime)` 全 windup 时长 ramp-in 1.0。`_draw()` 内同步移除旧 `var alpha_t := clampf(t / 0.4, 0, 1)`（Pulse/Bind/Cut）或 `clampf(t / 0.5, 0, 1)`（Echo）或 `clampf((t - phase_offset) / 0.4, 0, 1)`（Wave 3 环 ripple）线性 ramp，`col.a` 改为常量 peak 由 modulate.a tween 驱动全局 fade-in。**5 verb ramp-in 一致性**：5 份 trigger() tween 实现 byte-identical（modulate.a=0.0 起点 + TRANS_QUAD EASE_OUT 曲线 + 1.0 终值 + _max_lifetime 时长）可作为 6th verb 接入模板；5 verb 共用 tween 曲线让 0.04s Cut（短）/ 0.10s Pulse/Bind/Wave（长）都有相同 "ramp-up then settle" 视觉节奏，玩家学到一次 ramp-in 曲线就 apply 全 5 verb。**Wave 旧 ripple 折衷**：Wave 旧 3 环 phase_offset 涟漪（ring 0 t=0.0 / ring 1 t=0.18 / ring 2 t=0.36）改为 3 环同时 fade-in（仅保留 r_ratio 0.40/0.65/0.92 半径差 + ring_alpha_mult 0.55/0.78/1.0 亮度差），ripple 涟漪感由"时序错位"转为"空间层次"——更简单可预测，且与其他 4 verb 的 tween 曲线严格一致。**I008 40 项锚点 smoke 测试** —— T174.A 5 verb × 8 断言 = 40 锚点（trigger() 内 modulate.a=0.0 / create_tween() 存在 / "modulate:a", 1.0 终值 / _max_lifetime duration / Tween.TRANS_QUAD / Tween.EASE_OUT / T174 (#93) docblock 标记 / 旧 `alpha_t := clampf(t / X, ...)` 线性 ramp 严格从源代码中删除——双重严格：按行分割 + 跳过注释行 + 找 `alpha_t := clampf(t /` 模式，避免误命中合法的 `var t := clampf(_lifetime / ...)` lifetime 进展）。**42/42 100% PASS**（与 #92 比 +1，0 回归）+ `check_smoke_consistency.sh` 7/7 规则 PASS + 0 SCRIPT ERROR + 0 parse error。**5 verb windup "VFX 进入+退出家族"双闭环最终态** —— 进入侧（T174 0.04~0.10s ramp-in tween）+ 退出侧（T173 0.05s ramp-out tween）+ 中段（fire VFX takes over 同帧无 overlap）三段时间轴都统一为 tween 曲线，5 份 trigger() ramp-in 实现 byte-identical + 5 份 fade_out_and_free ramp-out 实现 byte-identical，可作为 6th verb 接入模板。
- **#92 — T173 5 verb windup VFX 0.05s 淡出 tween（"VFX 退出家族"）+ T173.C 补 resonance_wave_ability._exit_tree() 钩子 + I007 (49 项锚点 smoke 测试)**：[`src/scripts/pulse_windup_vfx.gd`](file:///workspace/src/scripts/pulse_windup_vfx.gd) / [`src/scripts/bind_windup_vfx.gd`](file:///workspace/src/scripts/bind_windup_vfx.gd) / [`src/scripts/echo_windup_vfx.gd`](file:///workspace/src/scripts/echo_windup_vfx.gd) / [`src/scripts/cut_windup_vfx.gd`](file:///workspace/src/scripts/cut_windup_vfx.gd) / [`src/scripts/wave_windup_vfx.gd`](file:///workspace/src/scripts/wave_windup_vfx.gd) 5 文件统一 +23 行 + [`tools/test_t173_windup_fadeout_smoke.gd`](file:///workspace/tools/test_t173_windup_fadeout_smoke.gd)（新文件 158 行）。**T173 "VFX 退出家族"正式闭环** —— 5 verb windup VFX 各自新增 `func fade_out_and_free() -> void`（实现一致 + byte-identical 可复制给未来 6th verb 接入）：(1) `if not _active: queue_free() return` 早退守卫（idempotent 防御重入）；(2) `_active = false` 停 `_process` 避免与 tween 竞速；(3) `var start_alpha: float = modulate.a` 捕获当前透明度（windup 中断在 0~0.7 之间任意值）；(4) `var tween := create_tween()` + `tween.tween_property(self, "modulate:a", 0.0, 0.05)`（`"modulate:a"` Godot 4 tween 语法从 1.0→0.0 0.05s TRANS_QUAD EASE_OUT 平滑淡出）；(5) `tween.tween_callback(queue_free)` 淡出结束自动 free。**4 verb ability `_exit_tree()` 切换**（`pulse_ability.gd` / `bind_ability.gd` / `echo_ability.gd` / `cut_ability.gd` 4 文件各 +3 行 + 10 行 docblock）—— 把硬 `_windup_vfx.queue_free()` 替换为 `_windup_vfx.fade_out_and_free()`，让 player 死亡 / 场景切换打断 windup（0.04~0.10s 窗口）时 VFX 平滑淡出而非硬 pop。**T173.C 补漏**：`resonance_wave_ability.gd` 是 5 verb ability 中**唯一缺 `_exit_tree()`**的（#89 T171 漏判），本轮补：(a) `var _windup_vfx: Node2D = null` 成员句柄（与 4 verb 句柄命名一致）；(b) `start_wave()` 在 `scene.add_child(windup_vfx)` 之后追加 `_windup_vfx = windup_vfx` 把 spawn 局部变量存到成员；(c) 文件末尾追加 `_exit_tree()` 函数（15 行 + 12 行 docblock）调 `fade_out_and_free()` + 清句柄（**5 verb _exit_tree 家族正式一致**——Pulse T166 / Bind T167 / Echo T168 / Cut T169 / Wave T173）。**5 verb "VFX 退出家族"特性**：fade_out_and_free 5 文件实现 byte-identical（验证 _pulse_sfx 模式：测试通过 `assert_contains` "func fade_out_and_free(" 5 份 + "create_tween()" 5 份 + `"modulate:a", 0.0` 5 份 + "0.05" 5 份 + "queue_free()" 5 份 + "T173 (#92)" 5 份）；0.05s 0.4× room transition duration 让 VFX 永远在下一房间 load 前 vanish（无视觉残留）；fade-out 是 queued-free 同帧触发无 overlap（5 verb 一致）。**I007 49 项锚点 smoke 测试** —— T173.A 5 verb × 6 断言 = 30 锚点（fade_out_and_free 函数声明 / create_tween 存在 / "modulate:a", 0.0 终值 / "0.05" 时长 / queue_free 结束 / T173 (#92) docblock 标记） + T173.B 4 verb ability × 4 断言 = 16 锚点（_exit_tree 函数存在 / fade_out_and_free 调用 / _exit_tree 函数体内**不**再含 _windup_vfx.queue_free()——通过 `_extract_exit_tree_body()` 提取函数体限定 scope，避免 start_*/_execute_* 合法硬 queue_free 误报 / T173 docblock 标记） + T173.C 3 锚点（Wave _exit_tree 存在 / fade_out_and_free 调用 / docblock 标记）= **49 项断言 PASS**。**额外修复**：T165/T166/F005 旧测试 `t166_ability.rfind("pulse_windup_vfx.gd")` 模式被 T173 docblock 注释（"See pulse_windup_vfx.gd:fade_out_and_free"）骗到错误位置（rfind 找到 docblock 注释而非 start_pulse() 内的 preload 真实调用），改为"从 func start_pulse 头到 func _execute_pulse 头区间内 find + 跳过 docblock 误报"的鲁棒模式；T167/T168/F006 旧测试 2 处 `bind_windup_vfx.gd` / `echo_windup_vfx.gd` 同样问题同法修。**41/41 100% PASS**（与 #90 比 +1，0 回归；T173 触发 T165/T166/F005 + T167/T168/F006 2 套件共 3 处断言更新，回归后全 PASS）+ `check_smoke_consistency.sh` 7/7 规则 PASS + 0 SCRIPT ERROR + 0 parse error。**5 verb windup "VFX 退出家族"最终态** —— 5 verb 5 元组 (Pulse / Bind / Echo / Cut / Wave) × 2 钩子 (`fade_out_and_free` + `start_*` `_windup_vfx` 句柄) × 1 退出点 (`_exit_tree` 调 `fade_out_and_free`) 全部统一，5 份 fade_out_and_free 实现 byte-identical 可作为 6th verb 接入模板。- **#90 — 审查 #90（本轮）**：完整代码质量 / 玩法 / 素材 / 文档审计；0 SCRIPT ERROR + 0 runtime ERROR + 55 .gd 文件 + 52 class_name 唯一（+4 windup classes 来自 #86 T167 Bind + #86 T168 Echo + #89 T171 Wave + 1 stable）/ 69 signal 完整 + 29 .tscn + 8 .json + 7 autoload + 0 TODO/FIXME + 114 PNG 100% 合法 + 102 .uid（**0 空文件** — 本轮修复 #86 留下的 2 个空 .uid `bind_windup_vfx.gd.uid` / `echo_windup_vfx.gd.uid` 由 `rm` + `--import` 重新生成 `uid://bh4oc6o1wkpl6` / `uid://clcrt5damt18k`）+ ASSET_REGISTRY 72 条 + 40 smoke test 套件 **40/40 100% PASS**（L001 修复后重测 0 回归）+ `check_smoke_consistency.sh` 7/7 规则 PASS（rule 7 README 同步 hook 由 #85 F002 引入已工作）；**严重 0 / 一般 0 / 轻微 1（L001 已修） / 信息 1（F004 audio 闭环建议下个 5 轮间隔 #91-#95 集中做）**。**5 verb windup 闭环最终态** —— Pulse `class_name PulseWindupVFX` Glass Cyan `#69C7CE` 1.0×→0.92× 收缩 ring（T166 #85）+ Bind `class_name BindWindupVFX` Muted Violet `#65506A` 1.0×→0.85× 螺旋内收（T167 #86）+ Echo `class_name EchoWindupVFX` Glass Cyan `#69C7CE` + Pale `#B7E7DD` + Amber `#F2B66E` 0.5×→1.0× 球外撑（T168 #86）+ Cut `class_name CutWindupVFX` Amber `#F2B66E` 0.0×→1.0× streak 横扫（T169 #87）+ Wave `class_name WaveWindupVFX` Pale `#B7E7DD` 3 环 ripple outward（T171 #89）5 个 `class_name extends Node2D` 类，`trigger(origin, half_radius, duration)` 签名一致，5 verb motif 全部独立（Pulse 收缩 / Bind 螺旋 / Echo 撑开 / Cut 横扫 / Wave 涟漪），5 verb 色严格在 STYLE_GUIDE 限制色板内，0 板外色。**4 verb 命中反馈闭环最终态** —— Pulse Coral `#E86D5A` (0.91, 0.427, 0.353) flash 0.10s/0.18 + Bind Violet `#65506A` (0.398, 0.314, 0.416) flash 0.10s/0.18 + Cut Amber `#F2B66E` (0.949, 0.714, 0.431) flash 0.09s/0.18 + Echo Cyan `#69C7CE` (0.412, 0.78, 0.808) flash 反射 0.08s/0.20 / 非反射 0.06s/0.12 4 verb 命中色 4 元组 + 4 verb LIGHT 1.0/0.08s 屏抖 5 元组完全统一（来自 T170a/b/c/d #88-#89，**4 verb 命中节奏"1/16 beat groove"**）。完整审查报告见 [REVIEW_LOG.md](file:///workspace/REVIEW_LOG.md)。
- **#89 — T171 5 verb windup 家族闭环（Wave 第 5 色 Pale Resonance halo VFX）+ T170d Cut 命中 LIGHT 屏抖 + I006 18 项锚点 smoke 测试**：[`src/scripts/wave_windup_vfx.gd`](file:///workspace/src/scripts/wave_windup_vfx.gd)（新文件 110 行 `class_name WaveWindupVFX extends Node2D`）+ [`src/scripts/resonance_wave_ability.gd`](file:///workspace/src/scripts/resonance_wave_ability.gd) `start_wave()` +25 行 + [`src/scripts/player.gd`](file:///workspace/src/scripts/player.gd) `_on_cut_hit` +18 行 + [`tools/test_t171_t170d_smoke.gd`](file:///workspace/tools/test_t171_t170d_smoke.gd)（新文件 152 行）18 项断言 PASS。**5 verb windup 调色五元组正式闭环 + 4 verb 命中屏抖分工完成** —— **T171** 新建 `wave_windup_vfx.gd` Pale Resonance `#B7E7DD`（比 Pulse Cyan 更冷更"光"——Wave "AOE 中心爆发而非定向打击"语义匹配，色温"穿透力最强"）+ 3 环 concentric halo r_ratio [0.40, 0.65, 0.92]（"声波辐射"主题，4 verb 1.0→0.92 收缩 ring / 1.0→0.85 螺旋 / 0.5→1.0 球 / 0.0→1.0 streak 之外的第 5 motif）+ per-ring alpha_mult [0.55, 0.78, 1.0]（外环最亮 = "声波前导"）+ phase_offset [0.0, 0.18, 0.36] 渐入 staggered "ripple outward" sound-wave motif + peak_alpha 0.65（比 Pulse 0.70 略低——"比空气还轻的 verb"，transient 非 solid）+ ring_width 1.2（比 4 verb 1.5px 细 0.3px——3 环同时存在需要视觉层次）+ z_index 10 + queue_free safety net + STYLE_GUIDE 引用；`resonance_wave_ability.gd` 集成 `preload("res://src/scripts/wave_windup_vfx.gd").new()` + `trigger(_pending_origin, wave_radius * 0.5, windup_time)` + `scene.add_child(windup_vfx)`（preload 而非 class_name 引用——与 4 verb 家族一致，preload path-based 引用让 headless smoke test load-order 决定性；0.5× radius——4 verb 家族一致 "precursor 而非 fire"；挂到 current_scene 而非 player 子节点——5 verb 家族一致：ring 位置稳定在世界坐标，player 移动时 ring 不跟着走，让 0.10s 期间 halo 是"我留在原地的 0.5s 警告"而非"我跟随玩家的拖尾"）。**T170d** `_on_cut_hit(_target)` 在 `flash_color(Color(0.949, 0.714, 0.431, 1.0), 0.09, 0.18)` 之后追加 `shake_preset(ScreenShake.Preset.LIGHT)`（**4 verb 命中屏抖 1.0/0.08s LIGHT 数值统一**——CUT 1.5/0.06s fire shake 衰减完 = LIGHT 1.0/0.08s hit shake 才开始，间隔 0.03~0.10s 不重叠 = "挥→中"两步触觉；max_targets=6 多目标风险由 ScreenShake tween 内部 dedupe 兜底，**视觉 = 1 次 0.08s LIGHT** 与 Pulse 多目标场景行为完全一致；LIGHT 而非 HEAVY 因为 Cut 单体命中反馈已经很强——HEAVY 喧宾夺主；Amber flash 无回归）。**I006 新冒烟测试 `tools/test_t171_t170d_smoke.gd` (152 行) 18 项断言 PASS** —— T171 段 10 项（`class_name WaveWindupVFX` 声明 / `extends Node2D` 与 4 verb 一致 / `trigger(origin, half_radius, duration)` 签名匹配 4 verb 家族 / `Color("#B7E7DD")` Pale Resonance 第 5 色 / `@export var ring_count: int = 3` 默认 3 环 / `z_index = 10` above world below HUD / `queue_free()` safety net / `T171 (#89)` docblock 标记 / docblock 含 "ripple outward" sound-wave motif 关键词 / `STYLE_GUIDE` 引用作为色域来源权威）+ T171 集成段 4 项（`resonance_wave_ability.gd:start_wave` 内 `preload("res://src/scripts/wave_windup_vfx.gd").new()` 存在 / 完整 `trigger(_pending_origin, wave_radius * 0.5, windup_time)` 调用 / `scene.add_child(windup_vfx)` 挂到 current_scene / `T171 (#89)` docblock 标记在 resonance_wave_ability.gd）+ T170d 段 4 项（`_on_cut_hit` 内 `ScreenShake.shake_preset(ScreenShake.Preset.LIGHT)` 调用 / `T170d (#89)` docblock 标记 / 完整 `flash_color(Color(0.949, 0.714, 0.431, 1.0), 0.09, 0.18)` Amber flash 无回归 / `if ScreenShake and ScreenShake.has_method("shake_preset"):` 守卫保留）。**18/18 PASS** + 0 SCRIPT ERROR + 0 parse error + 21/21 #88 T170 套件无回归 + check_smoke_consistency.sh 7/7 规则 PASS。风格 0 漂移（T171 `#B7E7DD` Pale Resonance 严格在 STYLE_GUIDE 限制色板内，**5 verb windup 五元组 Pulse Cyan / Bind Violet / Cut Amber / Echo Cyan / Wave Pale 全部在限制色板内**；T170d 复用 T098 Amber `#F2B66E` + LIGHT preset，**4 verb 命中反馈色 4 元组 + LIGHT 0.08s 屏抖分工 5 元组**完整）。
- **#88 — T170 4 verb 命中反馈 VFX polish（Bind 命中反馈 / Echo 命中非反弹反馈 / Pulse 命中屏抖）**：`player.gd` 改动 1 文件新增 ~50 行。**T170a Bind 命中反馈** —— `_ready` 中 `bind_ability.bind_hit.connect(_on_bind_hit)`（`has_signal` 守卫保 pre-bind-hit 存档兼容），新增 `_on_bind_hit(target)` handler 调 `ScreenShake.flash_color(Muted Violet #65506A, 0.10s, 0.18)` + `ScreenShake.shake_preset(LIGHT 1.0/0.08s)` 补"钉住"触感，与 Pulse Coral / Cut Amber / Echo Cyan 三 verb 命中反馈形成 4 verb 色域分工（**色域 4 元组**：Pulse Coral / Bind Violet / Cut Amber / Echo Cyan，"看到闪就知道是哪个 verb"快速识别）；0.10s / 0.18 数值与 Pulse 命中（T098）对称让 4 verb 反馈节奏统一；LIGHT 而非 HEAVY 因为 Bind 语义"温柔牵制"而非"暴力推开"。**T170b Echo 命中非反弹反馈** —— `_on_echo_hit` 之前 `is_reflect=false` 早退无任何屏幕反馈（`echo_ability.gd:278 emit(enemy, false)` = 敌人物理接触护盾被短致盲 0 伤），现在补 `ScreenShake.flash_color(Glass Cyan #69C7CE, 0.06s, 0.12)` —— 0.06s / 0.12 比反弹路径（T097 0.08s / 0.20）**更短更暗**，反弹 = "成功回击"高反馈 / 非反弹 = "温和挡下"低反馈，6:3 比例让"反 > 挡"视觉权重正确。**T170c Pulse 命中屏抖** —— `_on_pulse_hit` 已有 Coral flash（T098），现在补 `ScreenShake.shake_preset(LIGHT)` (1.0/0.08s) 作为"打到了"补充触觉；与 `_on_pulse_fired` 的 PULSE 2.0/0.10s shake 间隔 0.05~0.15s 不会重叠（fire shake 衰减完 = hit shake 才开始），形成"推→中"两步触觉。**新冒烟测试 `tools/test_t170_smoke.gd` (210 行) 21 项断言 PASS** —— T170a 8 项（connect/handler/4 个签名锚点 + null 守卫 + Muted Violet 色 + LIGHT shake + docblock 标记）/ T170b 6 项（is_reflect 分支保留 + 非反弹 flash_color 调用 + Glass Cyan 色 + 0.06s/0.12 数值 + 反弹路径无回归 + docblock）/ T170c 3 项（LIGHT shake 调用 + docblock + Coral flash 无回归）/ 4 verb 色域分工交叉检查 4 项（Pulse Coral / Bind Violet / Cut Amber / Echo Cyan 4 色均保留无回滚）。**21/21 PASS** + 0 SCRIPT ERROR + 0 parse error + check_smoke_consistency.sh 7/7 规则 PASS。风格 0 漂移（3 反馈色严格在 STYLE_GUIDE 限制色板 / 4 verb 调色 4 元组分工不变）。
- **#87 — I005 补 #86 缺测试 (33 项断言 smoke 套件) + T169 CutAbility 0.06s 黄色 line streak pre-cut VFX + F007 4 verb ability 内部 `_consume_verb_cost` / `_setup_windup_state` 共享模式 helper**：**新测试文件 `tools/test_t167_t168_f006_smoke.gd` (230 行) 33 项断言 PASS** 覆盖 #86 三个任务全部代码改动点（**T167 Bind windup VFX 11 项** — bind_windup_vfx.gd 存在 + extends Node2D + Muted Violet `#65506A` + arc_count=3 + _end_scale=0.85 内拉 + lifecycle + bind_ability spawn/free/_exit_tree 顺序 + bind_radius*0.5 透传；**T168 Echo windup VFX 11 项** — echo_windup_vfx.gd 4 参数 trigger 签名 + 3 色 Glass Cyan + Pale Resonance + Amber Voice + _end_scale=1.0 撑开（vs Pulse 0.92/Bind 0.85 内缩反向）+ _start_scale=0.5 + lifecycle + echo_ability spawn/free/_exit_tree 顺序 + echo_radius*0.5+echo_radius 4 参数 trigger 调用；**F006 refactor 8 项** — _try_verb() 2 参签名 + 4 个 _start_X_at() wrapper + 4 verb handler 体内 _try_verb 委托（600 char 窗口允许 docblock）+ _try_verb body 含 3 关键步骤 + _handle_wave 保持原 4 状态路由 + F005 helper 保留 + D001 is_action_globally_blocked 公开函数保留；**D001 regression + 4 verb 一致性交叉检查 3 项**），完成 #86 末尾"保留 #87 视情况添加 test_t167_t168_f006_smoke.gd"承诺。**T169 新文件 `cut_windup_vfx.gd` (61 行)** `class_name CutWindupVFX extends Node2D` **4 verb windup 第 4 视觉 motif** — Pulse ring（0.5×→0.92× 内缩）/ Bind spiral（0.5×→0.85× 旋转内收）/ Echo sphere（0.5×→1.0× 撑开）/ **Cut streak**（0.0×→1.0× 沿 cut 方向延伸，让玩家在 0.06s 前摇中即可辨别哪个 verb 在蓄力，5-verb 链 T142 防误触 UX 提示完整），Amber Voice `#F2B66E` 严格对齐 STYLE_GUIDE 限制色板（**4 verb 调色四元组** — Pulse Glass Cyan / Bind Muted Violet / Echo Glass Cyan+Amber Voice / Cut Amber Voice），`trigger(origin, half_radius, direction, duration)` 4 参数签名（与 T168 Echo 对齐），2px stroke 双线 draw_line + 1.5px 垂直偏移防 dark tileset 1px 直线消失，alpha 0→0.7 ramp-in 前 40%（Cut 0.06s 是 4 verb 最短前摇比 Pulse 0.4 更快），scale 0.0→1.0 沿 cut 方向延伸（与 cut_vfx.gd arc swing motion 同向 windup-to-fire 过渡连续）；`cut_ability.gd` 新增 `var _windup_vfx: Node2D = null` 句柄 + `start_cut()` 集成 + `_execute_cut()` 顺序敏感 free（cut_vfx.gd 同帧 spawn arc 替换 streak）+ `func _exit_tree()` 钩子（3 道 free 保险同 T166/T167/T168 模式）。**F007 refactor 4 verb 内部共享 2 helper 模式** —— 4 verb 各加 byte-identical `_consume_verb_cost(cost: int) -> bool` + `_setup_windup_state(origin, direction) -> void`（GDScript 限制 4 verb 各自重写一份 helper，但命名 + 签名 + docblock 一致，未来 base class `_verb_ability_base.gd` 抽取铺路），4 verb `start_X()` 顶部 4-5 行（`if not can_X: return false; if not GameState.consume_resonance(X_cost): return false; _is_winding_up = true; _windup_timer = windup_time; _pending_origin = origin; _pending_direction = direction`）缩为 2 行调用（`if not _consume_verb_cost(X_cost): return false; _setup_windup_state(origin, direction)`）；**echo_ability 特殊** — `start_echo(origin)` 不接收 direction 参数（盾中心 pop 语义）但调用 `_setup_windup_state(origin, Vector2.ZERO)` 保持 4 verb 签名一致，新增 `var _pending_direction: Vector2 = Vector2.ZERO` 字段（不读只用，与 pulse/bind/cut 字段定义 byte-identical）；**3 层 helper 抽象栈** —— F005 player 层 `_pre_verb_block_check` / F006 player 层 `_try_verb` / F007 ability 层 `_consume_verb_cost` + `_setup_windup_state`，未来加 verb 边际成本降到 "1 行 wrapper + 1 个新 ability 文件 + copy-paste 2 helper"。**38/38 smoke tests PASS** + 0 SCRIPT ERROR + check_smoke_consistency.sh 7/7 规则 PASS
- **#86 — T167 BindAbility windup 0.5× Muted Violet 螺旋 VFX + T168 EchoAbility 0.5×→1.0× Glass Cyan 球 VFX + F006 player.gd 4 verb handler 提取 `_try_verb()` helper**：**新文件 `bind_windup_vfx.gd` (87 行)** `class_name BindWindupVFX extends Node2D` 自管理 lifecycle — `trigger(origin, half_radius, duration)` 设 `global_position` + `_radius` + `_max_lifetime` 启动，`_draw()` 渲染 3 段 spiral 弧旋转内收（`draw_arc` 12 段 / 0.7 间隙 / `base_angle = _lifetime * 4.0` 旋转 4 rad/s），scale 1.0→0.85 收缩（**比 Pulse 0.92 更激进内拉**——Bind 语义"往中心拉"呼应 A033 icon spiral motif），Muted Violet `#65506A` 严格对齐 STYLE_GUIDE 限制色板，alpha 0→0.75 ramp-in 首 40% 防 frame-0 闪烁；`bind_ability.gd` 新增 `var _windup_vfx: Node2D = null` 实例句柄，`start_bind()` 在 consume_resonance 成功后 spawn 挂到 `get_tree().current_scene`（**非 player 子节点**让 player 移动时 ring 位置稳定在世界坐标），`_execute_bind()` 在 `bind_fired.emit` *之前* free windup_vfx（顺序敏感：bind VFX 同帧 spawn 替换 windup），新增 `func _exit_tree()` 钩子（**关键 cleanup**：player 在 windup 中被 scene change 销毁 bind_ability 退树时连带 free windup_vfx 防 leak），3 道 free 保险同 T166 Pulse 模式。**新文件 `echo_windup_vfx.gd` (90 行)** `class_name EchoWindupVFX extends Node2D` **与 Pulse/Bind 反向 motion language**——Pulse/Bind 是 0.5×→0.85-0.92× 内缩（能量聚拢/向内拉），Echo 是 0.5×→1.0× 外撑（盾"砰"地一下弹出接住来袭），`_draw()` 3 层 painter's order：Layer 1 玻璃填充 `draw_circle` 半径 `lerp(half, full, t)` alpha 0→0.18 / Layer 2 高光 rim `draw_arc` 1.5px alpha 0→0.55 / Layer 3 中央暖点 `draw_circle(Vector2.ZERO, 2px)` alpha 0→0.45，三色皆来自 EchoVFX palette 维持 verb 调色一致（fill `#69C7CE` Glass Cyan / rim `#B7E7DD` Pale Resonance / core `#F2B66E` Amber Voice），alpha ramp-in `t / 0.5`（**比 Pulse 的 0.4 更快**——Echo windup 仅 0.08s 短窗口，前 0.04s 必须 readable）；`echo_ability.gd` 同模式集成 windup_vfx + _exit_tree 钩子。**F006** `player.gd` 在文件末尾追加 1 个 `_try_verb()` helper + 4 个 `_start_X_at()` wrapper（`_start_pulse_at` / `_start_bind_at` / `_start_cut_at` / `_start_echo_at`），4 verb handler 各自缩成 1 行委托 `_try_verb("pulse", _start_pulse_at)` 等；**新 `_try_verb(action_name: String, start_fn: Callable) -> void`** —— 5 步中央管道：(1) `_pre_verb_block_check()` 守卫复用 F005 helper → (2) `Input.is_action_just_pressed(action_name)` rising-edge → (3) 在 helper 内计算 `origin = global_position + Vector2(0, -8)` + `dir = Vector2.RIGHT if _facing_right else Vector2.LEFT`（4 verb 共用"头部 8px / 面向方向"公式与原 handler 字节级一致）→ (4) `start_fn.call(origin, dir)` 委托给 verb 内部 `start_*()`（Echo wrapper 忽略 `dir` 因盾中心 pop 语义）→ (5) 失败时统一 `hud.show_pulse_blocked()` 提示（与原 handler 行为完全一致）；**4 wrapper** 签名统一 `(origin: Vector2, dir: Vector2) -> bool`，内部 `if ability: return ability.start_X(origin, dir) else: return false`（`else false` 路径让 `_try_verb()` 触发 blocked toast 兜底**保持 #85 旧语义不变**）；**Wave 排除**——`# F006 (#86) — Why not also include _handle_wave?` docblock 详述 Wave 有 4 个 verb 状态路由（active/winding_up/charging/blocked，T143）需要 4 分支专属 HUD 提示不能套这个 1-toast 通用 helper，`_handle_wave()` 保持原样；**未来扩展价值**——加新 guard 条件（"dialogue open"）只需 OR 进 `_pre_verb_block_check()` 一处，加第 6 verb（方向性）只需写 1 行 `_handle_X()` + 1 个 `_start_X_at()` wrapper；本轮未新增冒烟测试（#85 审查通过后零回归历史 + 源码净增 ~245 行未达 500 阈值保留 #87 视情况添加 `test_t167_t168_f006_smoke.gd`）
- **#85 — T165 BGM tier-up ScreenShake flash_color (0.15s Glass Cyan 256 层) + T166 PulseAbility windup 0.08s→0.10s + 0.5× Glass Cyan pre-pulse ring VFX + F005 player.gd 4 verb handler 提取 `_pre_verb_block_check()` helper**：`audio_manager_enhanced.gd.request_boss_music()` 在 `if new_tier > current_tier:` 分支末尾追加 `ScreenShake.flash_color("#69C7CE", 0.15, 0.18, flash_layer=256)`（Glass Cyan 严格对齐 STYLE_GUIDE 限制色板 / duration 0.15s 与 300ms 音乐 crossfade 中段 tempo 对齐 / peak_alpha 0.18 subtle vignette / `flash_layer=256` 走 T163 #84 新参数高于 hit-flash 128 避免互消），调用前用 `Engine.has_singleton("ScreenShake") or _has_screen_shake_autoload()` 双重防御（headless 测试下 audio manager 可能在 ScreenShake 之前 `_ready()` 完单一 `Engine.has_singleton` false-positive 漏报），新增私有 `_has_screen_shake_autoload()` helper（`tree.root.has_node("ScreenShake")` 探测 + `Engine.get_main_loop` null 守卫）；**新文件 `pulse_windup_vfx.gd` (90 行)** `class_name PulseWindupVFX extends Node2D` 自管理 lifecycle — `trigger(origin, half_radius, duration)` 设 `global_position` + `_radius` + `_max_lifetime` 并启动，`_draw()` 渲染 0.5× radius Glass Cyan 圆环（`draw_arc(Vector2.ZERO, ring_r, 0, TAU, 32, col, ring_width)` 32 段），scale 1.0→0.92 线性收缩（"能量聚拢"暗示与 fire VFX 反向扩张形成"→|→ 炸开"语言），alpha 0→0.7 ramp-in 首 40% 防 frame-0 闪烁；`pulse_ability.gd` `windup_time: float = 0.08` → `0.10`（与 bind_ability 0.1s 一致 4 verb windup 节奏统一），新增 `var _windup_vfx: Node2D = null` 实例句柄，`start_pulse()` 在 consume_resonance 成功后 spawn 挂到 `get_tree().current_scene`（**非 player 子节点**让 player 移动时 ring 位置稳定在世界坐标），`_execute_pulse()` 在 `pulse_fired.emit` *之前* free windup_vfx（顺序敏感：fire VFX 在 player._on_pulse_fired 同帧 spawn 两 VFX 不重叠 1 帧），新增 `func _exit_tree()` 钩子（**关键 cleanup**：player 在 windup 中被 scene change 销毁 pulse_ability 退树时连带 free windup_vfx 防 leak），3 道 free 保险（`_execute_pulse` 显式 / `_exit_tree` scene-change / `_process._max_lifetime` 超时自清）；`player.gd` 新增私有 helper `func _pre_verb_block_check() -> bool: return is_action_globally_blocked()`（**保留** `is_action_globally_blocked()` 公共函数不动以兼容 `_handle_jump` / `_on_echo_multi_reflect`），4 verb handler 头注释同步追加 `# F005 (#85) — single _pre_verb_block_check() guard shared by the 4 directional verbs` 并把 `if is_action_globally_blocked(): return` 替换为 `if _pre_verb_block_check(): return`（未来加新 guard 条件如 "dialogue open" / "shop UI focused" 只需 OR 进 helper 一处 4 verb handler 同步生效）；`test_t165_t166_f005_smoke.gd` 23 项新断言 PASS + 全 37/37 冒烟测试套件 PASS
- **#84 — T101 ResonanceWave 命中粒子层叠 8→12 (4 new visual layers) + T163 ScreenShake.flash_color / flash_grayscale 接受可选 [flash_layer] 参数 + F004 修复 3 套件 pre-existing stale-state 冒烟测试**：`resonance_wave_vfx.gd` 新增 14 常量（`DEEP_SHADOW_RADIUS_RATIO=0.42` / `INNER_HALO_RADIUS_RATIO=0.55` / `OUTER_WISP_RADIUS_RATIO=1.18` / `OUTER_WISP_COUNT=12` / `SPARKLE_RADIUS_RATIO=0.70` / `SPARKLE_COUNT=6` 等）+ 3 色常量（`#65506A` Muted Violet / `#B7E7DD` Pale Resonance / `#F2B66E` Amber Voice 严格对齐 STYLE_GUIDE 限制色板）+ `_draw()` 改写为 9 段 painter's order（deep_shadow→inner_halo→ring_fill→ring_stroke→8 prism_rays→12 outer_wisps→6 sparkle_stars 闪烁 alpha→center_core→bounce_flash），4 新 layer 从 1 layer 静态环变 8 layer 多深度冲击波；`screen_shake.gd` `flash_color(..., flash_layer: int = 128)` + `flash_grayscale(..., flash_layer: int = 128)` 接受 canvas layer 索引（默认 128 保持向后兼容，上层 256 高于 HUD，下层 64 低于 HUD），`_active_grayscale` + `_active_color_flash` 从单 `CanvasLayer` 引用重构为 `Dictionary` 按 layer_idx 分桶（同 layer 后调用取消前调用 / 跨 layer 并行），`stop()` 迭代 `dict.keys()` 清掉*所有* layer 上的活动 flash；F004 修复 (1) `test_t150_t147_t149_smoke.gd` `_handle_jump` 字符串窗口 1800 → 2500 char（T145 17 行 docblock + T147 4 行 + D001 注释让相关代码落在 char 1827-1900）+ 新增 D001 sync 断言验证 `is_action_globally_blocked()` 是 `PlayerActionGate.is_blocked()` 的 thin delegate, (2) `test_t158_t156_f002_smoke.gd` F002.7 / F002.8 硬编码 `#81` → 动态 `ITERATION_COUNT.txt - 1`（含 file-not-found fallback），(3) 复用 (1) 顺带同步 T147 守卫与 #76 重命名；`test_t101_t163_f004_smoke.gd` 18 项新断言 PASS + 全 36/36 冒烟测试套件 PASS
- **#83 — T162 PlayerProfilePanel "最近 5 局详细" 列表 + T159 InkWarden phase 2 dissolve 0.25s 出 + 0.30s 入 tween**：`pause_menu.tscn` 在 `ProfileTrend20` 之后新增 `ProfileRecentTitle`（"✦ 最近 5 局 ✦" Amber Voice 9pt center）+ `ProfileRecentList` VBoxContainer；`pause_menu.gd` 新增 `@onready var _profile_recent_list` + 3 常量（`_PROFILE_RECENT_RUNS_MAX=5` 视觉密度上限 / `_COLOR_RECENT_RUN_NORMAL` Pale Resonance 沿用 trend 调色板 / `_COLOR_RECENT_RUN_LATEST` Amber Voice 高亮最近 1 局）+ 新方法 `_refresh_recent_runs_list()` 实现 5 个设计选择（最新 1 局 Amber Voice 高亮 / reversed order 最新在顶 / 每行 4 字段 `Run #N 房 X 净 Y 碎 Z 时 mm:ss` / 空 history 走"暂无 run 记录"占位 / dynamic child creation 防 stale data）；**与 T131 trend 5/10/20 行互补**：trend 给"宏观"平均指标，recent 给"具体"每局明细（"Run #5 净 0 死 3"立刻归因到"没找到 Pulse"）。`ink_warden.gd` 顶部新增 4 常量（`PHASE_2_DISSOLVE_OUT_TIME=0.25` / `PHASE_2_DISSOLVE_IN_TIME=0.30` / `PHASE_2_DISSOLVE_OUT_SCALE=1.15` / `PHASE_2_DISSOLVE_IN_START_SCALE=0.85`）；`_enter_phase_2()` sprite swap 段改写为 5 段 tween（snap reset / dissolve out 0.25s scale 1.0→1.15 + alpha 1.0→0.0 / snap start / dissolve in 0.30s scale 0.85→1.0 + alpha 0.0→1.0 / existing red flash + settle 完整保留），共 1.03s 视听序列与 T156 5 段完美嵌套（shake 中段 = dissolve 中段）。原来 1f sprite 硬切被替换为 0.55s 渐变，让 phase 2 进入"我正在失控进化"而非"突然换皮"的体感。`test_t162_t159_smoke.gd` 21 项断言 PASS
- **#82 — F003 4 文档同步 Python 3.14+ zipfile 兜底 + T160 PauseMenu "新成就!" Banner + T161 settings "还原所有推荐" 按钮 + D001 PlayerActionGate autoload 抽出**：`godot/README.md` + `README.md` + `README.zh-CN.md` + `CONTRIBUTING.md` 4 文档同步重写为 方法 B-1 `unzip -FF` 强容错（沙箱 / Python 3.14+ 推荐）+ 方法 B-2 Python `zipfile` 兜底（**仅 Python ≤ 3.13 有效**），实测复现 Python 3.14.4 `BadZipFile: Bad magic number for file header`；`pause_menu.tscn` 新增 `NewAchvBanner` Label（top center Amber Voice 10pt "✦ 新成就！✦"）+ `pause_menu.gd` 3 常量（`_BANNER_DURATION=0.8` / `_BANNER_FADE=0.4` / `_BANNER_RECENT_UNLOCK_WINDOW=5.0`）+ 双轨触发（menu 可见直接 animate + 不可见记 `_last_seen_unlock_ts` 5s 窗口内 ESC 补播）；`settings_menu.tscn` 新增 `RestoreAllButton`（Amber Voice 200×24）+ `settings_menu.gd` `_on_restore_all_pressed()` 3 阶段（按键 `InputMap.action_erase_events` + `_DEFAULT_BINDINGS` / 音量 4 slider 100% + `AudioServer.set_bus_volume_db` / autosave `SaveSystem.set_autosave_enabled/interval/slot` 推默认）+ amber 0.8s "✓ 已还原" toast；`src/autoload/player_action_gate.gd` 新建 22+80 行 Node autoload（4 public API: `register_player/unregister_player/is_blocked/get_player`）+ `is_blocked()` 复合 OR（`_is_dying` + `wave_ability.is_globally_blocking`）+ `project.godot` autoload 段注册 + `player.gd` `_ready/_exit_tree` register/unregister + `is_action_globally_blocked()` 改 thin delegate + `resonance_wave_ability.gd` `is_globally_blocking()` 头部加 D001 refactor 注释；`test_d001_t160_t161_f003_smoke.gd` 21 项断言 PASS
- **#81 — T158 EchoAbility 4 重击命中后慢动作 0.4s 0.85x time-scale + T156 ArchiveStorm 主摄像机 1f skybox rotate 0.5° 0.2s ease 收回 + F002 `check_smoke_consistency.sh` README 同步检查 hook 规则 ⑦**：`echo_ability.gd` 新增 `signal echo_multi_reflect(count: int)` + `const MULTI_REFLECT_THRESHOLD = 4` + 在 `_reflect_projectile` 末尾首次达到 4 emit 一次（同 cast 后续反弹不再 emit 防 spam）；`player.gd._ready` 用 `has_signal("echo_multi_reflect")` 守卫连 `_on_echo_multi_reflect` → 0.4s await × 0.85 time_scale，await 结束检查 `_is_dying` 避免覆盖 die() 的 1.0 重置；`screen_shake.gd` 新增 `punch_rotation(degrees=0.5, duration=0.2)` API（cam.rotation = deg_to_rad 立即设置 + tween 0.2s quad ease 收回，`stop()` 兜底归零 + kill tween）；`ink_warden.gd._enter_phase_2()` 顶部（shake_preset 之前）调 `ScreenShake.punch_rotation(0.5, 0.2)` 形成 5 段视听序列：sky 反应 → BOSS_PHASE2 震 → sprite swap → RepairVFX ring → BGM tier-up；`check_smoke_consistency.sh` 加 rule 7（README.md + README.zh-CN.md "Recent completed work" / "最近完成的工作" 段解析最新 #N 与 ITERATION_COUNT.txt 比对，滞后 ≥2 轮 FAIL 阻断 commit / 滞后 1 轮 WARN），根除 G001 第 4 次同类风险；`test_t158_t156_f002_smoke.gd` 28 项断言 PASS
- **#79 — T152 0 数灰阶 + T153 槽位 jingle + T151 "最近" badge**：`pause_menu.gd` `_COLOR_ZERO_STAT` 暖灰 `#808389` + `_set_zero_aware_stat()` helper（6+4 行用 0 占位 "—"）；`audio_manager_enhanced.gd` `_SAVE_SLOT_MIDI_NOTES = [72,76,79,84,88]` pentatonic C5/E5/G5/C6/E6 + `_generate_save_slot_jingle()` 0.25s 三角波 bell body + `play_save_slot_jingle()` 公开 API（save/load 共享）；`save_load_menu.gd` `_find_most_recent_slot()` + `_format_recent_badge()` BBCode `[color=#B7E6DC]★ 最近[/color]` Pale Resonance + `_refresh_slots` 一次扫 5 槽定 most_recent_slot 下传 `_refresh_card` / `_refresh_list_row`；4 状态字符完整化（[·]/[—]/[✗]/[✓]）；`test_t152_t153_t151_smoke.gd` 19 项 PASS
- **#78 — T144 wave_focus 谐波 + T148 wave_combo chime tail + T154 灯反向闪**：`audio_manager_enhanced.gd` `_wave_hit_streams: Dictionary` 4 level 缓存（0=1320Hz 基频 2.4x 谐波 / 1=+3.6x / 2=+5.0x / 3=+6.8x 凯旋钟塔）按 `GameState.get_perk_count("wave_focus")` 路由；`play_wave_combo()` 0.6s E6+G#6 双音衰减 + `_on_wave_combo()` 末接；`save_lantern.gd` `flash_coral_pulse()` 0.15s Coral Pulse 反向闪 + `silenced_web.gd on_cut_triggered` 迭代 `save_lantern` group 触发；`test_t144_t148_t154_smoke.gd` 26 项 PASS
- **#77 — T150 5 动词 profile + T147 jump 阻塞 UX + T149 Echo parallax**：`player_stats.gd` `last_used_verb` 字段 + `record_ability_used` 入口首行刷新 + `reset_stats` 清空 + `pause_menu.tscn` ProfileLastVerb Label + `pause_menu.gd` match 5 动词 BBCode 调色板（pulse Coral / bind Violet / cut Amber / echo Cyan / wave Pale Resonance）；`hud.gd` `show_jump_blocked()` + `player.gd _handle_jump` 双层守卫（is_action_just_pressed 触发）；`echo_vfx.gd` PARALLAX 三常量（rotation 0.5 / radius 1.08 / alpha 0.55）+ PI/8 偏移 + 0.25 rad/s 副层旋转；`test_t150_t147_t149_smoke.gd` 22 项 PASS
- **#76 — T143 wave 4 状态提示 + T145 is_action_globally_blocked 重构 + T146 wave_combo 屏震**：`hud.gd` 4 verb 专属方法（charging / winding_up / active / blocked）+ `player.gd _handle_wave` 4 分支路由按生命周期排（active → winding_up → cooldown → cost-low）；`_is_wave_globally_blocking` 重命名为公开 `is_action_globally_blocked()` + OR `_is_dying` 守卫 + 4 verb handler 调用点 + `_handle_jump` 阻塞时清零 coyote+buffer timer 防死亡解除后"原地跳"；`resonance_wave_ability.gd` `wave_combo` signal（`@export wave_combo_threshold=3`）+ `_deactivate_wave` 末尾 emit；`player.gd _on_wave_combo` shake(4.0, 0.4) + flash_color(Electric Violet #8C5BFF, 0.18s, 0.30)；`test_t143_t145_t146_smoke.gd` 25 项 PASS + `test_t142` 重命名同步
- **#75 — 审查 #75（本轮）**：完整代码质量 / 玩法 / 素材 / 文档审计；0 SCRIPT ERROR + 0 runtime ERROR + 47 class_name 唯一 + 77 signal 完整 + 114 PNG 合法 + 6 autoload 一致 + 72 ASSET_REGISTRY 记录 + 28 冒烟测试全 PASS + 1 一般 (G001 README Recent work 补 #61-#75 15 轮已修) + 1 信息 (候选池继续走 polish 路线)
- **#75 — T130 hotfix (成就 13→14 同步) + T142 (5-verb 链防误触安全网) + T141 (wave 命中 audio cue)**：成就定义 `total_count`/`unlocked_count` 同步 13→14 + `achievements.json` `quintuple_voice` 入列；T142 `resonance_wave_ability.gd._try_fire()` 加 5 帧 verb-action-only 窗口（拒绝 `is_on_floor_only=true` 的 `is_dashing` 期间触发的"动画中波"）；T141 `resonance_wave_ability.gd` 命中路径 `AudioManagerEnhanced._sfx_bus_play("wave_hit", 0.4 + i*0.04, 1.05 + i*0.02)` 链入 `hit_count` 循环；新增 `tools/test_t130_achievement_sync_smoke.gd` 14 项断言 PASS
- **#74 — T103 第二半 (Wave 5-verb 对称) + T140 _handle_wave 失败提示走 verb 专属方法 + T139 成就计数 13→14**：player.gd `_handle_wave()` 5 路径完整 pulse / cut / bind / echo / wave（wave→resonance_wave 桥接）；T140 失败提示新增 `_wave_off_cooldown_prompt()` / `_wave_silenced_prompt()` / `_wave_already_active_prompt()` 3 个 verb-专属方法（更准确反馈而非泛化"无法释放"）；T139 A072 `quintuple_voice` 5-verb 一次完成成就落地；新增 `tools/test_t139_quintuple_voice_smoke.gd` + `tools/test_t140_wave_verb_prompts_smoke.gd` PASS
- **#73 — T103 第一半 (ResonanceWave 群体波) + T137 SaveLoadMenu 快速加载 + T138 PauseMenu 上次自动存档时间**：A070 `resonance_wave_vfx` (procedural vector pulse) + A071 wave 技能图标 (16x16 程序化像素) + `src/scripts/resonance_wave_ability.gd` (228 行 9 exports + 4 signals + 4 阶段生命周期 + 命中追踪) + `src/scripts/resonance_wave_vfx.gd` 8 层视觉组 + HUD `WaveRow` 第五冷却条（Electric Violet 主题色）；T137 `save_load_menu.gd` quick load card (slot 0 / 上次手动存档) 优先显示 + Ctrl+L 触发；T138 PauseMenu 新增"上次自动存档: N 分钟前"摘要；`test_t103_resonance_wave_smoke.gd` (31 项断言) + `test_t137_t138_quick_load_and_autosave_smoke.gd` (17 项) PASS
- **#72 — T136 SaveSystem 自动存档 60s + T135 PauseMenu 分享剪贴板**：SaveSystem `_autosave_timer` (60s 间隔 / 启用开关) + `last_autosave_at` 时间戳 + `pause_menu.cfg` 持久化 `autosave_enabled`；T135 PauseMenu 新增"分享"按钮 → DisplayServer.clipboard_set (成就摘要 + 4 段格式化文本 + run 编号 + 死亡次数)；`test_t135_share_smoke.gd` + `test_t136_autosave_smoke.gd` PASS
- **#71 — T134 settings 动态 SLOT_COUNT + T133 PauseMenu Quick Stats 摘要行**：settings_menu.cfg 新增 `save_slot_count` (1-10) + SaveSystem 启动时 clamp + 5→10 槽 UI 自动扩展；T133 PauseMenu 顶部"本次 Run" + "历史最佳"两行摘要（run 编号 / 死亡次数 / 修理数 / 收集数 / 房间数）；`test_t133_quick_stats_smoke.gd` + `test_t134_dynamic_slot_count_smoke.gd` PASS
- **#70 — 审查 #70 (D001-D003 严重问题修复)**：D001 `_autosave_timer` 改 Timer 节点 (单 timer / pause_mode=PROCESS) + SceneTree 改 `_autosave` async；D002 `get_run_id()` 改 Time.get_unix_time_from_system() + 文件名含 UTC 时间戳（避免碰撞）；D003 `_health_danger` 改 danger_threshold + beat/tween 同步 + 0.6s 渐显；ASSET_REGISTRY A068-A069 装饰物件登记；3 严重 / 0 一般 / 1 轻微 (L001) / 1 信息
- **#69 — T131 Run 趋势 + T132 备份/恢复 API**：PauseMenu 趋势卡（4 项 stats: run 数 / 平均修理 / 死亡数 / 收集率） + `SaveSystem.get_run_trend()` API；T132 备份/恢复（`backup_save()` → `user://backups/save_N.bak` / `restore_from_backup()` + 自动备份触发器 [manual save / settings delete]）；`test_t131_run_trend_smoke.gd` + `test_t132_backup_restore_smoke.gd` PASS
- **#68 — T129 存档健康度 + T130 历史最佳成就**：SaveSystem `get_save_health()` (per-slot 校验 / CRC32 + last_modified + run_id 摘要) + PauseMenu 存档 tab 健康度标签（健康 / 警告 / 损坏）；T130 历史最佳成就触发条件 (本次 run 修理数 ≥ 历史最高 修理数) + `_check_personal_best()` 钩子 + PauseMenu "本次 Run / 历史最佳" 双行显示；ASSET_REGISTRY A067 `personal_best` 成就登记；`test_t129_save_health_smoke.gd` + `test_t130_personal_best_smoke.gd` PASS
- **#67 — T127 Run 编号 + 历史最佳 + T128 SaveSystem CRC32**：GameState `current_run_id` (UTC yyyymmddhhmmss) + `SaveSystem` 每次 save 写入 `run_id` 字段 + PauseMenu 顶部 "Run #yyyymmddhhmmss"；T128 SaveSystem CRC32 校验（save 头 8 字节 + payload + checksum）+ `get_save_meta()` API + 自动修复损坏检测；`test_t127_run_id_smoke.gd` + `test_t128_crc32_smoke.gd` PASS
- **#66 — F003 smoke_consistency.sh + T126 Player Profile**：T125 `tools/check_smoke_consistency.sh` (6 条规则 144 行 bash: smoke_test_count >= 15 / README BGM 数 / ASSET_REGISTRY 总数 / PROJECT_NAME 一致 / headless 启动 0 错 / uid 已生成) 全 PASS；T126 PauseMenu Player Profile (3 卡片: Player Name / Total Playtime / Best Run Summary) + ProjectSettings 输入字段；`test_t126_player_profile_smoke.gd` PASS
- **#65 — 审查 #65 (D001-D004 修复轮)**：D001 `paused` SignalListener 重复（player.gd 重复监听）已重构为单连接 + 幂等检查；D002 `pause_menu.gd._build_achievement_grid` 16x16 texture 引用 orphan 修复（增加 GroupReferenceHolder 跟踪）；D003 `t134_dynamic_slot_count` 测试 UID 漏提交修复；D004 `_handle_wave` 在 is_dashing 状态触发造成动画穿插修复；44 class_name 零冲突 + 73 signal 完整 + 114 PNG 合法 + 65 ASSET_REGISTRY + 7 冒烟测试套件 14 测试全 PASS
- **#64 — T122 IntroCutscene ambient + T123 whisper_hollow 路由 + T124 BGM 9 主题色板文档**：IntroCutscene 8s → 12s (加 ambient layer 渐入 / 渐出 4s) + 文档同步；T123 audio_manager_enhanced.gd `route_for_scene()` 加 `intro_cutscene → whisper_hollow` 分支；T124 STYLE_GUIDE.md BGM 节扩展 9 主题色板表格（archive_calm / archive_boss / archive_boss_dual / archive_dawn / archive_storm / silence_void / whisper_hollow / finale / intro）；`test_t122_intro_ambient_smoke.gd` + `test_t123_whisper_routing_smoke.gd` PASS
- **#63 — T121 audio_presets.gd 重构 + T118 whisper_hollow + T120 README Game States 节**：T121 audio_presets.gd 新建 (8 BGM 主题常量 + tier 等级 + 调色板 + 路由映射 集中 5 段 → 1 段) audio_manager_enhanced.gd `_MUSIC_PRESETS` dict 抽取；T118 `whisper_hollow` BGM 主题 (F# minor BPM 64 / 全 5th + 7th / LFO 0.4Hz / 4-volume mute 主旋律) + `route_for_scene("whisper_hollow")` + PauseMenu 设置 routing 优先级；T120 README 新增 "Game States" 节 (intro / hub / archive / boss / death / respawn 6 状态 + BGM 主题映射表)；`test_t121_audio_presets_smoke.gd` + `test_t118_whisper_hollow_smoke.gd` PASS
- **#62 — T117 finale 曲式**：audio_manager_enhanced.gd `_MUSIC_PRESETS["finale"]` 落地 (C major → E minor 终止 + 16-note descending arpeggio + tier 4 + GameState._on_full_archive_collected 触发)；ASSET_REGISTRY A066 `finale_theme` 登记；`test_t117_finale_smoke.gd` PASS
- **#61 — T114 silence_void BGM + T115 死亡碑文 + T116 InkWarden 残影**：T114 silence_void BGM (D minor BPM 48 / drone + 0.18Hz LFO / 4-volume 全 mute 主体) + audio_manager_enhanced.gd `route_for_scene("silence_void")` + tier 1；T115 player.gd `die()` tween 链加 0.4s 灰调 wash 后的"墓志铭"字幕（font_size 8 → 6 fade-in）；T116 ink_warden.gd `phase_2_silhouette_remain()` (死亡后 2.5s 残影淡出) + `silhouette_alpha` tween (0.6 → 0) + z_index=10 顶层显示；ASSET_REGISTRY A064 `silence_void` + A065 `silhouette_remain` 登记；`test_t114_silence_void_smoke.gd` + `test_t115_death_inscription_smoke.gd` + `test_t116_silhouette_smoke.gd` PASS
- **#60 — 审查 #60（本轮）**：完整代码质量 / 玩法 / 素材 / 文档审计；0 SCRIPT ERROR + 0 runtime ERROR + 44 class_name 唯一 + 73 signal 完整 + 112 PNG 合法 + 6 autoload 一致 + 63 ASSET_REGISTRY 记录 + 7 个 BGM 主题 + 9 个冒烟测试全 PASS；严重 0 / 一般 2（G001 README 6→7 BGM 主题数补 archive_storm / G002 Recent work 补 #59）/ 轻微 0 / 信息 2（候选池仍有 4 项 + Godot binary 持久化）
- **#59 — 文档同步 + 第 7 主题 BGM archive_storm 落地**：补全 #57（成就解锁时间戳 + CONTRIBUTING）和 #58（README 引用 CONTRIBUTING + PauseMenu hover + 死亡回 Hub 端到端冒烟）两条本该在那两轮就追加的 CHANGELOG 段；T107 在 `audio_manager_enhanced.gd` `_MUSIC_PRESETS` 新增 `archive_storm` (E minor BPM 120 / 16-note chromatic arpeggio / G#6 shimmer / 0.66Hz LFO / 4-volume 全上抬) + `_BOSS_MUSIC_TIER["archive_storm"] = 3`（严格 > archive_boss_dual tier 2）；`ink_warden.gd:529` `_enter_phase_2()` 把 `request_boss_music("archive_boss_dual")` 替换为 `request_boss_music("archive_storm", 600)`；ASSET_REGISTRY A063 条目登记；`test_t107_archive_storm_smoke.gd` (198 行 10 项断言) PASS
- **#58 — README CONTRIBUTING 入口暴露 + PauseMenu hover 高亮 + T079 端到端冒烟**（本轮）：T113 英文 README 「## 开发」节顶部加 `CONTRIBUTING.md` 链接 + 9 节内容简述，README.zh-CN.md 同步加中文版（仓库结构 / 3 种 Godot 拼合 / 7 冒烟测试套件 / 提交格式 / 迭代节奏 / 美术登记 / 文档同步 5 问 / 故障排查 / 决策记录）；T111 `pause_menu.gd._build_achievement_grid` 给每个 16x16 TextureRect 加 `mouse_filter=STOP` + `mouse_entered/exited` connect + `_on_slot_hover_in/out` 0.12s tween（scale 1.0→1.5x + self_modulate 灰→亮 1.4 + modulate 暖色 1.2,1.1,0.9，parallel 三套同步）让玩家 hover 时图标"亮起来"；T112 新建 `tools/test_t112_respawn_hub_e2e_smoke.gd` (213 行) 13 项集成断言覆盖 T079 端到端流程（GameState respawn_to_hub 字段 + API + 常量 + 双分支 + GFC._ready 顺序修复 + settings_menu.cfg 持久化 + .tscn toggle label），冒烟测试 7→8
- **#55 — 5 存档槽 + 列表视图**（本轮）：save_system.gd / save_load_menu.gd `SLOT_COUNT=3→5`，新增 list 紧凑视图（每行 28px）+ LayoutButton 切换 card↔list；`tools/test_t088_save_slots_smoke.gd` 7 项集成断言全 PASS
- **#55 — 审查 #55**：完整代码质量 / 玩法 / 素材 / 文档 / BGM / PNG 头校验审计；0 SCRIPT ERROR + 0 runtime ERROR + 44 class_name 唯一 + 73 signal 完整 + 112 PNG 合法 + 6 autoload 一致 + 62 ASSET_REGISTRY 记录；严重 0 / 一般 0 / 轻微 1（L001 test_t088_save_slots_smoke.gd.uid 漏提交，本轮修复）/ 信息 3
- **#54 — T101 + T102 GlassLock amber flash + PauseMenu 四动词 BBCode 颜色**：`glass_lock.gd._unlock()` 0.5s Amber Voice 屏幕闪（修复"声音回归"的延续性反馈）；PauseMenu `_stat_abilities` 改为 BBCode `[color=#...]` 形式，4 动词色域严格对齐 STYLE_GUIDE
- **#53 — T098 + T100 Pulse/Cut/Echo 命中 flash_color 主题化 + PauseMenu Echo 反弹 row 强调**：`player.gd` `_ready` 桥接 `pulse_ability.pulse_hit` + `cut_ability.cut_hit` 信号；屏震按能力主题色 flash；PauseMenu StatReflects Glass Cyan 高亮
- **#52 — T096 + T097 Echo 与既有系统交互 + 反弹命中 cyan flash**：`echo_charm` 笔误修正（effect 从 `pulse_kill_refund` 改为 `echo_radius_bonus`，ID 与效果对得上）；GameState 新增 `echo_radius_bonus` 字段 + ShopMenu 重建公式；ScreenShake 新增 `flash_color(color, duration, peak_alpha)` API；Echo 反弹命中时 0.08s Glass Cyan 屏闪
- **#51 — T094 + T095 EchoAbility 类 + 护盾反弹逻辑（第四动词代码侧落地）**：`src/scripts/echo_ability.gd` (219 行) 9 exports + 4 signals + 4 阶段生命周期 + 反弹追踪；`project.godot` 新增 echo 输入映射（Q 键 / R 备用 / 手柄 button 5）；HUD `EchoRow` 第四冷却条（Glass Cyan）；A062 `quadruple_voice` 成就；`src/scripts/echo_vfx.gd` 8 层视觉组
- **#50 — 审查 #50**：0 错误 / 0 警告 / 42 class_name / 68 signal / 112 PNG 合法 / A061 Echo 6/6 色板匹配；严重 0 / 一般 0 / 轻微 1（已修）/ 信息 3
- **#49 — 死亡灰阶 VFX + Echo 护盾反弹图标 A061**：ScreenShake `flash_grayscale(duration, peak_alpha)` API + `player.gd._flash_death_grayscale_wash()` 回调（`die()` tween 链）；`scripts/generate_echo_icon.py` 程序化像素绘制 32x32 + 64x64 Echo 护盾图标
- **#48 — 死亡 freeze-frame VFX + README godot binary 快速指引**：T092 `player.die()` 开头 0.15s freeze（time_scale=0.2 + red tint）→ T093 灰阶洗 → T075 lay-down + fade-out；T091 README 新增 Headless Godot Binary Setup 子节（方法 A unzip + 方法 B Python `zipfile`）
- **#47 — 屏幕震动 polish + 装饰物件 procedural**：`src/autoload/screen_shake.gd` autoload（8 个预设含 BOSS_PHASE2 5.0/0.30s 最高强度）；6 个程序化像素装饰物件（A055-A060）+ 14 个 archive_01-04 装饰实例
- **#46 — Boss 阶段 2（InkWarden phase 2）**：6 个常量调优 + `_enter_phase_2()` 视觉切换 + A054 阶段 2 精灵 + 3×RepairVFX + 顶部"怒"飘字 + BGM tier upgrade + 三连发散 + 4.5s AOE 冲撞
- **#45 — 审查 #45**：修复 1 轻微（L001 WardenShadow 节点重命名）+ 4 一般（G001-G004 资产/文档/成就/Recent work 同步）

### 下一步阅读

- `ROADMAP.md` — 完整任务列表、当前候选池、「已完成」时间戳
- `CHANGELOG.md` — 每次迭代的变更日志（已交付与学到的教训）
- `REVIEW_LOG.md` — 每 5 轮一次的审计（代码质量、玩法、素材、文档、漂移）
- `STYLE_GUIDE.md` — 视觉宪法；**所有新美术必须继承自此**
- `ASSET_REGISTRY.md` — 素材账本；**所有新素材必须追加到此处**
- `ITERATION_GUIDE.md` — 自动化 Agent 完整迭代流程
- `RESEARCH.md` — 市场调研 + 选定方向（Voxglass / 声匣修复者）

## 房间编辑器（JSON）

房间可通过 `data/rooms/` 下的 JSON 定义。完整 schema 见 `data/rooms/README.md`。要测试一个 JSON 房间，打开 `src/scenes/json_room.tscn` 并设置 `room_id` 导出变量，或从 GDScript 调用 `RoomLoader.load_room(room_id, parent_node)`。

## Credits 与许可

- 引擎：Godot Engine（MIT）
- 美术与代码：本仓库作者（Saya Ch）
- 音频：100% 程序化合成，无外部采样依赖
- 字体：默认 Godot 4.6.3 内置字体

---

🇬🇧 [English README](./README.md) · 🇨🇳 **简体中文**（本文件）
