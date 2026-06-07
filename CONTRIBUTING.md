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

# 方法 B：Python zipfile 兜底（沙箱 unzip 报 "bad zipfile offset" 时）
python3 -c "import zipfile; zipfile.ZipFile('/tmp/godot_full.zip').extractall('/workspace/godot/')"

# 方法 C：unzip -FF（终极兜底）
unzip -FF -o /tmp/godot_full.zip
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

### 3.3 冒烟测试套件（14 个，1~3 分钟）

本仓库自带 14 个 `test_*.gd` 冒烟测试，覆盖核心系统的回归基线（#66 增 1：T126 Player Profile 页）：

| 测试脚本 | 覆盖 | 来源 |
|---------|------|------|
| `tools/test_echo_smoke.gd` | EchoAbility 类签名 + 9 个 @export | #51 T094 |
| `tools/test_echo_vfx_smoke.gd` | EchoVFX trigger/bounce + 5 帧 _draw | #51 T095 |
| `tools/test_echo_radius_bonus_smoke.gd` | GameState echo_radius_bonus + shop 笔误修复 | #52 T096 |
| `tools/test_t088_save_slots_smoke.gd` | SaveSystem SLOT_COUNT=5 + list/card 视图 | #55 T088 |
| `tools/test_t098_t100_smoke.gd` | 4 动词 flash_color 色域 + PauseMenu Echo row | #53 T098/T100 |
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
| `unzip: bad zipfile offset` | 改用 Python `zipfile` 兜底（见 2.1 方法 B） |
| `ObjectDB instances leaked at exit` | Godot 4.6 已知非致命警告，可忽略 |
| Player 移动但没动画 | `_setup_spriteframes()` 缺资源；查 console `[PlaceHolder sprite missing]` |
| 成就通知不显示 | 检查 `AchievementNotification` 是否在 PauseMenu / Title 屏实例化 |

## 9. 联系方式 / 决策记录

- 大决策（玩法方向 / 风格宪法）→ `ROADMAP.md` 顶部「当前方向」+ `CHANGELOG.md` 段头
- 审查发现问题 → `REVIEW_LOG.md`（严重/一般/轻微/信息 4 类）
- 灵感 / 候选 → `INSPIRATION.md`（- 游戏名《xxx》：机制参考 (链接)）

---

> 感谢你愿意为 Voxglass 添砖加瓦。任何「让下一个开发者少花 10 分钟」的文档 / 冒烟测试 / 注释改进都是受欢迎的贡献。
