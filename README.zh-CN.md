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
