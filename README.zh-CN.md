# Voxglass（声匣修复者）

一款 2D 像素美术的动作探索游戏。在被淹没的地下声档案馆中，修复被「活体寂静」夺走的人类声音。

## 状态

进行中的可玩竖切。当前里程碑：可玩 60 秒房间演示「进入 → Pulse 击退 → 修复 → 收集 → 出门」核心循环。

## 技术栈

- 引擎：Godot 4.6.3（已验证 — `config/features=4.4` 保留以兼容旧版，依 `REVIEW_LOG.md` #20 在 4.6.3 上解析干净）
- 分辨率：480x270 内部画布，整数倍缩放至 1920x1080
- 语言：GDScript
- 音频：程序化 SFX（pulse / 脚步 / 玻璃碎裂 / 敌人低鸣 / 修复 / 受击）+ 7 个程序化 BGM 主题（`title_intro` 序章 / `hub_warm` 安全区 / `archive_exploration` 探索 / `archive_boss` 单 InkWarden Boss / `archive_boss_dual` 双 Boss 房 `archive_04` / `archive_dawn` 胜利与回归 / `archive_storm` tier-3 Boss 阶段 2 升级 — InkWarden 半血跃迁自动切换）— 全部在运行时通过 `src/scripts/audio_manager_enhanced.gd` 的 `AudioStreamWAV` 合成（无需外部音频文件）。标题屏预热 BGM 缓存让首次场景切换零延迟。设置菜单提供 Master / Music / SFX / Ambience 四 bus 独立音量滑块。Boss 音乐 override 采用引用计数（T078），并支持强度分级 tier 升级（T080 / #59 T107）。
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

Godot 4.6.3 headless 二进制以多卷 zip 形式放在 `godot/`。首次克隆（或新建沙箱）后必须先重新拼合并解压，否则任何 `--headless` 命令都无法运行。**方法 A** 用 `unzip`；**方法 B** 用 Python `zipfile` 兜底（当 `unzip` 报 `bad zipfile offset` 时使用，常见于容器化沙箱中多卷 zip 偏移解析器与数据不一致的情况）。

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

# 方法 B — Python zipfile 兜底（沙箱环境）
# 当 `unzip` 打印 "bad zipfile offset" / "extra bytes at beginning" 时使用。
# Python 标准库对多卷布局处理更宽松。
python3 -c "import zipfile; zipfile.ZipFile('/tmp/godot_full.zip').extractall('.')" \
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
