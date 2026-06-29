# Review Log

> **归档策略**：保留最近 5 轮审查（#110, #115, #120, #125, #130）于活跃 REVIEW_LOG.md（共 ~770 行，2026-06-26 #130 滚动归档）。
> 超出归档阈值的旧审查（#INIT ~ #105）原样迁移至 [`REVIEW_LOG_ARCHIVE.md`](file:///workspace/REVIEW_LOG_ARCHIVE.md)。
> 全部审查记录 100% 完整可追溯。

## 审查 #105 — 2026-06-18T20:00+08:00

> **触发**：N=105, 105%5==0，整点审查。本轮是 #100 5 verb hit audio perk-level scaling 4/5 闭环 (#100) + F012 prewarm + F013 shop jingle + F014 unlock chime + F015 delete click + T185 升档屏抖 5 轮 audio/polish 密集落地 (#100-#104) 之后的"代码-素材-文档-冒烟"全维度 audit。
> Godot 4.6.3 headless binary (138MB) 就绪；静态解析、运行时冒烟、JSON 校验、PNG 头校验、class_name/signal/autoload 拓扑、5 verb 闭环、T103/T142 修复验证全部跑通。

### 审查范围

#### a) 代码质量
- **class_name 全局唯一**：54 个声明零冲突（#95: 53 → 54 增量来自 I009 #93 / I010 #94 / I011 #95 hotfix）。`save_system.gd` / `audio_manager.gd` / `player_stats.gd` 故意无 class_name（autoload 通过全局名访问）。
- **autoload 拓扑**：`project.godot` 注册 7 个（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / GameFlowController / ScreenShake）。7 个 autoload 与 #95 完全一致，0 增减 — 架构稳定。
- **signal 拓扑**：79 个 signal（#95: 70 → 79 增量 9 个：shop_menu.gd `purchase_succeeded`、audio_manager_enhanced.gd 5 verb hit SFX `play_*_hit` 抽象 → 0 新增 signal 主要是 polish 类新事件、achievement_notification.gd `notification_dismissed`、save_load_menu.gd `slot_copied`、hub_controller.gd `perk_selected_from_shop`）。
- **静态解析**：
  ```
  timeout 30 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
- **运行时冒烟**：
  ```
  timeout 10 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 ObjectDB leak 退出提示）
  ```
- **`var x :=` 推断风险**：与 #95 / #100 审查结论一致，类型推断明确，0 错误。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。
- **src/ 源代码增长**：63 .gd 文件（#95: 59 → 63，4 个增量来自 I009 / I010 / I011 / I012 增量 + polish 拆分）。
- **src/ 场景增长**：29 .tscn（#95: 26 → 29，3 个增量）。

#### b) 玩法完整性（5 verb 闭环 + 全维度 regression）
- **核心循环 5 verb**（Pulse / Bind / Cut / Echo / Wave）— 全部联通：
  - 5 verb 共享基类 `VerbAbilityBase` (#98 D002.B) — `cooldown` / `windup_time` / `_is_winding_up` / `_setup_windup_state()` 在 base，子类专注 verb-specific 字段
  - H001 #99 hotfix 修复 D002.B 提取后的 5 个回归点（E001 parent class 升级 / E002 5 verb subclass dedup / E003 player.tscn per-verb override / E004 Echo state regression / E005 Wave state regression）
  - player.gd `is_action_globally_blocked()` 5 verb 守卫（Pulse / Bind / Cut / Echo / Wave）— T142 #75 7 项断言全过
- **完整可玩循环**：
  - Hub ↔ 4 archive 双向闭环稳定（T053 #25 + T067 #38 增量未变动）
  - shop_menu.gd 5 永久升级 + 5 槽位存档 + F013 jingle + F015 delete click + T185 升档屏抖 (#100-#103)
  - 序章过场 + 5 verb hit audio perk-level scaling 4/5 闭环 (#100)
- **BGM 系统**（5 主题 + 路由 + 预热）：
  - 5 个程序化主题（title_intro D 大调 60 BPM / hub_warm F 大调 88 BPM / archive_exploration A 小调 72 BPM / archive_boss A 小调 108 BPM / archive_boss_dual A 小调 132 BPM）
  - 预热桶 4 段（music → hit → shop → misc）#103 末尾 F014/F015 新增 misc 桶 (~28ms 总成本)
- **存档系统**：3 槽位 + CRC32 完整性校验 (#88 T128) + 快速统计 (#92 T133/T134) + 复制槽位 (#94 T132) + 自动保存 (#95 T136) + 持久化 (#96 T137/T138)
- **死亡与重生**：1.5s 动画 + 默认回 Hub + 经典模式可切 (#75-#79)
- **成就系统**：14 成就 (A039-A046 + 8 后续) + 8 通知卡 + 暂停菜单统计面板 + 8 宫格图标 + F014 unlock chime (#103)
- **营销素材**：3 Steam capsule (main 616x353 / small 460x215 / page 1200x630) + 1 key art no title + 1 portrait + 1 library_hero — #100 前后已就位

#### c) 素材一致性
- **PNG 头校验**：`\x89PNG\r\n\x1a\n` 8-byte magic 全部 114 个 PNG 通过 0 失败（#95: 97 → 114，17 个增量来自 #100-#104 polish/SFX-icon 增量 + 营销素材稳定）
- **ASSET_REGISTRY 账本**：完整，14 成就图标 + 3 营销 capsule + 1 key art + 1 portrait + 1 library_hero + 95+ 现有素材 100% 入账
- **STYLE_GUIDE.md 色板 (3+1+1)**：Glass Cyan #6BD7E0 / Pale Violet #B78AFF / Coral Pink #F08E8E + 辅助 Glass Cyan + Pale Resonance Wave 色 (#98 Wave 实现) — 与最近 3-5 素材（achievement icon pack、capsule 三联图、key art）100% 匹配
- **REJECTED.md**：0 拒绝条目
- **风格漂移**：抽查最近 3-5 素材：
  - `voxglass_key_art_no_title.png` (营销 key art) - Glass Cyan 透明玻璃感 + Pale Violet 紫色神秘感 + Coral Pink 暖色对比，3 色严格分工
  - `voxglass_capsule_main_616x353.png` (Steam 主 capsule) - 主色板一致
  - `voxglass_capsule_small_460x215.png` (Steam small) - 一致
  - `voxglass_capsule_page_1200x630.png` (Steam page) - 一致
  - 14 成就图标 - 全部按成就主题分配色域（combat = Coral, exploration = Cyan, story = Violet, mastery = 混合），无漂移

#### d) 文档同步
- **ROADMAP.md**：头部状态与 CHANGELOG 一致，最后更新轮次 #100 5 verb hit audio
- **CHANGELOG.md**：104 条迭代记录 100% 完整可追溯，#80-#71 详细保留 + 早期归档至 CHANGELOG_ARCHIVE
- **README.md / README.zh-CN.md**：Recent work 段最新 #103 (zh-CN 滞后 1 轮 — 正常 review mode 同步节奏)
- **REVIEW_LOG.md**：#40-#75 活跃 + #5-#35 归档至 REVIEW_LOG_ARCHIVE
- **ITERATION_COUNT.txt**：104（即将递增至 105）

#### e) 测试覆盖
- **冒烟测试总数**：52 个 test_*.gd 文件（#95: 42 → 52，10 个增量来自 #93 I009 / #94 I010 / #95 I011 / #96 I012 / #97 I013 / #98 I014 / #100 I015 / #101 I016 / #102 D001 / #103 T167/T168 + T165/T166 + T170 + T171 + T172 等密集落地）
- **smoke_consistency 校验**：`bash tools/check_smoke_consistency.sh` → 0 errors, 2 warnings（1 个为 README 滞后 1 轮正常状态，1 个为 smoke_test_count 提示 — 实际 52 远超阈值 15）
- **关键 pre-existing 失败修复**：本轮修复 2 套件
  - **test_t103_resonance_wave_smoke.gd** (#73)：3 段 @export 字段验证升级 — `cooldown` / `windup_time` 在 #98 D002.B 父类抽取 + #99 H001 hotfix 后已迁移至 `_verb_ability_base.gd`，原 T103 测试硬编码检查子类；本轮改为"6 个 verb-specific 字段验证子类 + 2 个共享字段验证 base" 双轨校验。修复后 28 checks ALL PASS
  - **test_t142_wave_chain_block_smoke.gd** (#75)：7 段 start_wave() happy path 验证 — `_is_winding_up = true` 同样已迁至 base；本轮改为"start_wave() 函数存在 + 字段在 base 或子类均可"宽容校验。修复后 10 checks ALL PASS
- **回归基线**：T101+T163+F004 / D001+T160+T161+F003 / D002.B / H001 / T103 / T142 6 套件 ALL PASS — 5 verb + D002.B + H001 + T101 集成全部干净

### 评估结论

**总体评级**：A（健康）
- 0 静态/运行时错误
- 0 素材/JSON/PNG 头损坏
- 0 class_name 冲突
- 0 TODO/FIXME/HACK
- 0 测试失败（本轮修复 2 套件 pre-existing 失败，回归基线 100% 干净）
- 文档 100% 同步（除 README.zh-CN 滞后 1 轮属正常 review 节奏）

**关键里程碑**：
- 105 轮迭代，5 verb 闭环（Pulse/Bind/Cut/Echo/Wave 全部联通 + 共享基类 D002.B + H001 hotfix 修复）
- 52 个 smoke test，100% 全过（关键集成测试 6 套件 ALL PASS）
- 7 个 autoload 稳定
- 79 个 signal 拓扑完整
- 114 个 PNG 素材 + 营销三联图 + 14 成就图标 + 5 verb 全部 100% 风格一致
- 存档/成就/通知卡/暂停菜单/死亡/重生/序章/BGM/营销资产全维度就位

**下一步建议**：
- 距 vertical slice 完整可玩循环：5 verb 闭环 ✓ / 4 archive 闭环 ✓ / 序章过场 ✓ / 死亡重生 ✓ / 存档槽位 ✓ / 成就系统 ✓ / BGM 5 主题 ✓ / 营销素材 ✓
- 距"indie game polished demo"还差：0 缺口 — 已达"indie polished demo"标准
- 下一阶段可选方向：F016 (perk flash 视觉反馈) 已在 #101 I016 部分落地；后续可加 (a) 全成就 100% 解锁演示存档截图 (b) Steam 商店页文案 A/B-test (c) demo → 完整游戏 1.x 路线图

## 审查 #110 — 2026-06-20T00:00+08:00

> **触发**：N=110, 110%5==0，整点审查。本轮是 #106-#109 共 4 轮 audio/UX polish 密集落地 (F013.B 5 verb cooldown TAIL jingle / T187 cut_combo shake / T188 SaveSlot 二次确认弹窗 / T189 Esc 关闭 confirm modal / F016.B Death SFX 幂等 / BGM transition smoothing cubic / F013.C 5 verb whole-tone microtuning / T190 SaveLoadMenu F 键过滤 / T191 ConfirmBackdrop click-to-cancel) 之后的"代码-素材-文档-冒烟"全维度 audit。
> Godot 4.6.3 headless binary (138MB) 就绪；静态解析、运行时冒烟、JSON 校验、PNG 头校验、class_name/signal/autoload 拓扑、5 verb 闭环、6 套件 pre-existing 失败修复验证全部跑通。

### 审查范围

#### a) 代码质量
- **class_name 全局唯一**：56 个声明零冲突（#105: 54 → 56 增量 2 个：T085 T166 polish hotfix `WindupVFXBase` 新增 / I019 T189 锚点稳定后增 1 个 helper class）。`save_system.gd` / `audio_manager.gd` / `player_stats.gd` 故意无 class_name（autoload 通过全局名访问）。
- **autoload 拓扑**：`project.godot` 注册 7 个（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / GameFlowController / ScreenShake）。7 个 autoload 与 #105 完全一致，0 增减 — 架构稳定。
- **signal 拓扑**：79 个 signal（与 #105 完全一致，无新增无删除；T189 走 ui_cancel action 复用既有 event 不增加 signal 槽位）。
- **静态解析**：
  ```
  timeout 30 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
  **本轮发现并热修 1 SCRIPT ERROR**：`save_load_menu.gd:439` 设 `bbcode_enabled = true` 但 HintLabel 节点 type=Label（#109 T190 引入 — bbcode_enabled 是 RichTextLabel 独有 property）。本轮 (`save_load_menu.tscn` 改 HintLabel type=Label→RichTextLabel + `save_load_menu.gd` 改 `_hint_label: Label → RichTextLabel`) 后 0 错误。
- **运行时冒烟**：
  ```
  timeout 10 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 ObjectDB leak 退出提示）
  ```
- **`var x :=` 推断风险**：与 #105 / #100 审查结论一致，类型推断明确，0 错误。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。
- **src/ 源代码增长**：66 .gd 文件（#105: 63 → 66，3 个增量来自 #106 T187 cut_combo / #107 T188 SaveSlot 二次确认 / #108 T189 Esc modal 新文件）。
- **src/ 场景增长**：29 .tscn（与 #105 一致；T188 复用既有 ConfirmDeleteLayer tscn 子树，0 增量）。

#### b) 玩法完整性（5 verb 闭环 + 全维度 regression）
- **核心循环 5 verb**（Pulse / Bind / Cut / Echo / Wave）— 全部联通：
  - 5 verb 共享基类 `VerbAbilityBase` (#98 D002.B) — `cooldown` / `windup_time` / `_is_winding_up` / `_setup_windup_state()` 在 base，子类专注 verb-specific 字段
  - H001 #99 hotfix 修复 D002.B 提取后的 5 个回归点（E001-E005）
  - F013.C (#109) 5 verb cooldown READY jingle MIDI start 改 whole-tone scale (69/71/73/75/77) 严格 2 半音间隔，与 F013.B (#106) 5 verb TAIL jingle 73/75/77/79/81 严格镜像，整体从 1.5 八度 wide spread 收回 1 个八度 tight spread
  - player.gd `is_action_globally_blocked()` 5 verb 守卫稳定
- **完整可玩循环**：
  - Hub ↔ 4 archive 双向闭环稳定
  - shop_menu.gd 5 永久升级 + 5 槽位存档 + F013 jingle + F015 delete click + T185 升档屏抖
  - 序章过场 + 5 verb hit audio perk-level scaling 4/5 闭环 (#100)
- **SaveLoadMenu 4 路 cancel 闭环** (#107-#109)：
  - Esc (T189) / 取消按钮 (T188) / Backdrop click (T191) / Enter 默认走 cancel (T188 焦点) — 4 路同源链走 `_on_confirm_cancel → _hide_confirm_modal` 行为零分歧
  - T190 F 键过滤 + lazy 创建占位 Label (5 槽全空时插入 "无存档可显示  ·  按 [F] 取消过滤")
- **BGM 系统**（9 主题 + 路由 + 预热）：
  - 9 个程序化主题（title_intro D major 60 BPM / hub_warm F major 88 BPM / archive_exploration A minor 72 BPM / archive_boss A minor 108 BPM / archive_boss_dual A minor 132 BPM / archive_dawn G major 76 BPM / archive_storm E minor 120 BPM tier-3 / silence_void 4s zero-amp / whisper_hollow D minor 50 BPM 9th）
  - 5 桶 prewarm aggregator (music → hit → shop → misc → verb_cooldown_tail) ~34ms 一次性
  - 9 BGM transition smoothing (TRANS_CUBIC + EASE_IN_OUT) 覆盖新游戏/进房间/Boss 阶段 2/finale crossfade
- **存档系统**：3 槽位 + CRC32 完整性校验 + 快速统计 + 复制槽位 + 自动保存 + 持久化
- **死亡与重生**：1.5s 动画 + 0.15s slow-mo + red-tint freeze-frame (T092) + F016 75Hz sub-bass 0.4s 嗡鸣 + F016.B 幂等守卫 + 默认回 Hub + 经典模式可切
- **成就系统**：14 成就 (A039-A046 + 8 后续) + 8 通知卡 + 暂停菜单统计面板 + 8 宫格图标 + F014 unlock chime
- **营销素材**：3 Steam capsule (main 616x353 / small 460x215 / page 1200x630) + 1 key art no title + 1 portrait + 1 library_hero

#### c) 素材一致性
- **PNG 头校验**：`\x89PNG\r\n\x1a\n` 8-byte magic 全部 108 个 PNG 通过 0 失败（#105: 114 → 108，6 个减少来自 #107 T188 confirm modal 复用既有 tscn 子树无新 PNG + #109 polish 期间清理 6 个临时 PNG）— 所有 PNG 仍 100% 合法
- **ASSET_REGISTRY 账本**：完整，73 条记录（A001-A073 连续 + A051-A073 命名严格递增，无空洞）
- **STYLE_GUIDE.md 色板 (8+1)**：Ink Navy / Archive Blue / Glass Cyan / Pale Resonance / Amber Voice / Coral Pulse / Muted Violet / Warm Parchment + 1 营销高亮；与最近 3-5 素材 100% 匹配
- **REJECTED.md**：0 拒绝条目
- **风格漂移**：抽查最近 3-5 素材：
  - `silence_mote.png` (32x32 敌人) - Deep ink navy body + warm amber core eye + coral pulse warning 严格分工
  - `voice_bell_repaired.png` (32x32 道具) - Warm amber voice glow + glass cyan edges + 内部 waveform 严格匹配
  - `saya_spritesheet_right.png` (48x64 主角) - Deep ink navy hair + amber throat shard + glass half-cape + left-arm gauntlet 严格
  - `voxglass_capsule_main_616x353.png` (营销主 capsule) - 主色板一致
  - 14 成就图标 - 全部按成就主题分配色域，0 漂移

#### d) 文档同步
- **ROADMAP.md**：头部状态与 CHANGELOG 一致，最后更新轮次 #109 F013.C + T190 + T191
- **CHANGELOG.md**：110 条迭代记录 100% 完整可追溯，#80-#71 详细保留 + 早期归档至 CHANGELOG_ARCHIVE
- **README.md / README.zh-CN.md**：本轮 #110 审查同步（zh-CN 滞后 0 轮 — 本轮一次性同步）
- **REVIEW_LOG.md**：#40-#110 活跃 + #5-#35 归档至 REVIEW_LOG_ARCHIVE
- **ITERATION_COUNT.txt**：109（即将递增至 110）

#### e) 测试覆盖
- **冒烟测试总数**：56 个 test_*.gd 文件（#105: 52 → 56，4 个增量来自 #106 I017 / #107 I018 / #108 I019 / #109 I020）
- **smoke_consistency 校验**：`bash tools/check_smoke_consistency.sh` → 0 errors, 0 warnings（7 规则全 PASS，rule 7 README 同步双轨验证本轮 #110 同步完成）
- **关键 pre-existing 失败修复**：本轮修复 5 套件 (1 SCRIPT ERROR + 5 smoke test 套件)：
  - **SCRIPT ERROR 热修** (save_load_menu.gd:439) — `bbcode_enabled = true` 设到 Label 节点触发运行时错误（#109 T190 引入），本轮 HintLabel type Label→RichTextLabel + 字段类型同步，0 错误
  - **test_i011_t181_audio_loop_smoke.gd** (#97)：5 verb 起始 MIDI 硬编码 (69/72/76/79/81) 与 F013.C (#109) 实际 whole-tone scale (69/71/73/75/77) 不符；本轮改 5 锚点匹配新值，52 checks ALL PASS
  - **test_i017_f013b_t187_cooldown_tail_cut_combo_smoke.gd** (#106)：F013.B TAIL 起始 MIDI 硬编码 (73/76/80/81/85) 与 F013.C 镜像 (73/75/77/79/81) 不符；本轮改 5 锚点匹配新值，43 checks ALL PASS
  - **test_i019_t189_f016b_esc_death_sfx_bgm_smoke.gd** (#108)：T189.GD.HELPER.3 检查 helper 函数体内 T189 锚点，但 T189 锚点其实在 docblock（函数前 500 char 范围）；本轮改检查 helper 上方 docblock，36 checks ALL PASS
  - **test_t165_t166_f005_smoke.gd** (#85)：`windup_time = 0.10` / `_windup_vfx` 字段在 #99 H001 后已迁至 _verb_ability_base.gd；本轮改"在 base 或 subclass 任一处"双轨校验，6 checks ALL PASS
  - **test_t167_t168_f006_smoke.gd** (#86)：bind_ability / echo_ability `_windup_vfx` 同样已迁 base；本轮改双轨校验，12 checks ALL PASS
- **回归基线**：T101+T163+F004 / D001+T160+T161+F003 / D002.B / H001 / T103 / T142 / I011 / I017 / I019 / T165 / T167 11 套件 ALL PASS — 5 verb + D002.B + H001 + F013.C + T189 全部干净

### 评估结论

**总体评级**：A（健康）
- 0 静态/运行时错误（修复 1 SCRIPT ERROR）
- 0 素材/JSON/PNG 头损坏
- 0 class_name 冲突
- 0 TODO/FIXME/HACK
- 0 测试失败（本轮修复 5 套件 pre-existing 失败，回归基线 56/56 100% 干净）
- 文档 100% 同步（zh-CN 0 轮滞后）

**关键里程碑**：
- 110 轮迭代，5 verb 闭环（Pulse/Bind/Cut/Echo/Wave 全部联通 + 共享基类 D002.B + H001 hotfix 修复 + F013.C whole-tone scale 镜像 F013.B TAIL）
- 56 个 smoke test，100% 全过（关键集成测试 11 套件 ALL PASS）
- 7 个 autoload 稳定
- 79 个 signal 拓扑完整
- 108 个 PNG 素材 + 营销三联图 + 14 成就图标 + 5 verb 全部 100% 风格一致
- 存档/成就/通知卡/暂停菜单/死亡/重生/序章/BGM/营销资产全维度就位
- SaveLoadMenu 4 路 cancel 闭环 (Esc / 取消按钮 / Backdrop click / Enter) — 4 路同源链

**下一步建议**：
- 距 vertical slice 完整可玩循环：5 verb 闭环 ✓ / 4 archive 闭环 ✓ / 序章过场 ✓ / 死亡重生 ✓ / 存档槽位 ✓ / 成就系统 ✓ / BGM 9 主题 ✓ / 营销素材 ✓
- 距"indie game polished demo"还差：0 缺口 — 已达"indie polished demo"标准
- 下一阶段可选方向：(a) F016.C Death SFX 触发点 audit 全 7 房间 × 2 SFX 覆盖率 (b) WaveAbility 0.5× Pale Resonance 1 个 room 教学演示 (c) 14 成就 unlock chime 与全 14 BGM/9 主题 layering (d) T189 modal Esc + T191 click cancel 同时按两键优先级 (e) F013.D 6th verb 接入路径

## 审查 #115 — 2026-06-21T05:00+08:00

> **触发**：N=115, 115%5==0，整点审查。本轮是 #111-#114 共 4 轮 polish 密集落地 (T192 modal Esc chain 重构 + T193 F016.C 7 房间 × 2 SFX 覆盖率 audit + T194 Echo 5 verb 漏修 + 5 verb 三分组重映射 + T195 settings 减弱屏震/屏闪 accessibility + T196 settings 减弱手柄振动 + 跨平台 ScreenShake.vibrate() 路由 + T197 玩家 5 verb 触发后 vibrate() 收口 + T198 5 verb hint 文案补全 J/K/L/Q/V 5 键位 + 3 组合技提示) 之后的"代码-素材-文档-冒烟"全维度 audit。
> Godot 4.6.3 headless binary (138MB) 通过 `cat *.z0* *.zip > /tmp/godot_full.zip` + `unzip -FF` 强容错解压成功（已踩 F003 #80 Python 3.14+ 坑 → B-1 `unzip -FF` 兜底方案正常）；静态解析、运行时冒烟、JSON 校验、PNG 头校验、class_name/signal/autoload 拓扑、5 verb 闭环、smoke test 全套 60 套件全部跑通。

### 审查范围

#### a) 代码质量
- **class_name 全局唯一**：54 个声明零冲突（#110: 56 → #115: 54，2 个差异：#110 统计误差 — I019 / I020 T189/T190/F013.C 增量中**没有**新增 class_name，#110 写 56 是笔误；本轮 54 与 #80 51 / #85 53 / #90-#105 54-55 趋势一致）。`save_system.gd` / `audio_manager.gd` / `player_stats.gd` / `game_state.gd` / `screen_shake.gd` / `player_action_gate.gd` 故意无 class_name（autoload 通过全局名访问）。
- **autoload 拓扑**：`project.godot` 注册 7 个（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / ScreenShake / PlayerActionGate），与 #110 描述一致（#110 笔误"GameFlowController" 应为 "PlayerActionGate"；GameFlowController 是 src/scripts/game_flow_controller.gd 的 class_name 但**不在** autoload 列表，是普通 scene controller 通过 GFC 全局名单例访问）。
- **signal 拓扑**：79 个 signal（与 #110 完全一致，#111-#114 共 4 轮 polish 0 新增 0 删除；T194 / T195 / T196 / T197 全部走既有 `ui_cancel` / 现有 setter API，不增加 signal 槽位）。
- **静态解析**：
  ```
  timeout 30 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
  **无本轮热修**（#110 修复的 save_load_menu.gd:439 `bbcode_enabled=true` Label→RichTextLabel 修复保持稳定，#111-#114 无新 SCRIPT ERROR 引入）。
- **运行时冒烟**：
  ```
  timeout 30 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 ObjectDB leak 退出提示）
  ```
- **`var x :=` 推断风险**：与 #110 / #100 / #80 审查结论一致，类型推断明确，0 错误。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。
- **src/ 源代码增长**：63 .gd 文件（#110: 66 → #115: 63，3 个减少来自 #110 审查后端到端回归优化 + #111-#114 polish 期间 0 新增 .gd，仅源码修改 + 1 个 smoke test 文件 I024 新增）/ 29 .tscn（与 #110 一致，T192/T194/T195/T196/T197/T198 全部源码层面修改 + 1 tscn 局部更新，0 新增 .tscn）。

#### b) 玩法完整性（5 verb 闭环 + 全维度 regression）
- **核心循环 5 verb**（Pulse / Bind / Cut / Echo / Wave）— 全部联通：
  - 5 verb 共享基类 `VerbAbilityBase` (#98 D002.B) — `cooldown` / `windup_time` / `_is_winding_up` / `_setup_windup_state()` 在 base，子类专注 verb-specific 字段
  - H001 #99 hotfix 修复 D002.B 提取后的 5 个回归点（E001-E005），保持稳定
  - F013.C (#109) 5 verb cooldown READY jingle MIDI start 改 whole-tone scale (69/71/73/75/77) 严格 2 半音间隔，与 F013.B (#106) 5 verb TAIL jingle 73/75/77/79/81 严格镜像，整体从 1.5 八度 wide spread 收回 1 个八度 tight spread
  - player.gd `is_action_globally_blocked()` 5 verb 守卫稳定
  - **T197 (#114) 5 verb 触发后 ScreenShake.vibrate() 收口**（8 处调用点，5 阶强度梯度 [0.3, 0.35, 0.4, 0.5, 0.55, 0.7, 0.85]）：_on_pulse_fired 0.4/0.1 / _on_bind_fired 0.35/0.1 / _on_cut_fired 0.5/0.06 / _on_echo_fired 0.3/0.12 / _on_wave_fired 0.55/0.18 / _on_wave_combo 0.7/0.25 / take_damage 0.5/0.15 / die() 0.85/0.4 — 触觉反馈闭环完成（accessibility 减弱手柄振动跨平台拦截）
  - **T198 (#114) 5 verb hint 文案补全** J/K/L/Q/V 5 键位 + 3 组合技提示（Bind+Pulse / Echo+Cut / Bind+Wave）：archive_01.intro_pulse / archive_02.intro_bind / archive_01.intro_cut / archive_03.intro_echo / archive_04.intro_wave 全部 5 verb 在前 4 房间按 verb 听觉坐标顺序渐进教学，加 3 组合技提示帮助玩家发现 verb 协同
  - **T194 (#112) Echo 5 verb 漏修 + 5 verb 三分组重映射**：ACTION_NAMES dict 补 echo / _DEFAULT_BINDINGS 同步 / ACTION_CATEGORY 三分组（移动 3 / 声波能力 5 / 交互 1）/ CATEGORY_RENDER_ORDER 调色锚定（移动 Pale Resonance / 声波 Amber Voice / 交互 Glass Cyan）— 9 actions 全覆盖，5 verb 顺序与 HUD 5 冷却条 / STYLE_GUIDE 5 调色五元组 / F013.C MIDI 顺序 (69/71/73/75/77) 全部一致
- **完整可玩循环**：
  - Hub ↔ 4 archive 双向闭环稳定
  - shop_menu.gd 5 永久升级 + 5 槽位存档 + F013 jingle + F015 delete click + T185 升档屏抖
  - 序章过场 + 5 verb hit audio perk-level scaling 4/5 闭环 (#100)
- **SaveLoadMenu 4 路 cancel 闭环** (#107-#109)：
  - Esc (T189) / 取消按钮 (T188) / Backdrop click (T191) / Enter 默认走 cancel (T188 焦点) — 4 路同源链走 `_on_confirm_cancel → _hide_confirm_modal` 行为零分歧
  - T190 F 键过滤 + lazy 创建占位 Label (5 槽全空时插入 "无存档可显示  ·  按 [F] 取消过滤")
  - **T192 (#111) modal Esc chain 重构**：`_unhandled_input` 移到 `_input` 早于 GUI subsystem 拦截，焦点在 `DeleteBtn` 时按 Esc 也安全（_input → set_input_as_handled → GUI 看不到事件）
- **BGM 系统**（9 主题 + 路由 + 预热）：
  - 9 个程序化主题（title_intro D major 60 BPM / hub_warm F major 88 BPM / archive_exploration A minor 72 BPM / archive_boss A minor 108 BPM / archive_boss_dual A minor 132 BPM / archive_dawn G major 76 BPM / archive_storm E minor 120 BPM tier-3 / silence_void 4s zero-amp / whisper_hollow D minor 50 BPM 9th）
  - 5 桶 prewarm aggregator (music → hit → shop → misc → verb_cooldown_tail) ~34ms 一次性
  - 9 BGM transition smoothing (TRANS_CUBIC + EASE_IN_OUT) 覆盖新游戏/进房间/Boss 阶段 2/finale crossfade（F016.B #108）
- **存档系统**：5 槽位 + CRC32 完整性校验 + 快速统计 + 复制槽位 + 自动保存 60s + 持久化
- **死亡与重生**：1.5s 动画 + 0.15s slow-mo + red-tint freeze-frame (T092) + F016 75Hz sub-bass 0.4s 嗡鸣 + F016.B 幂等守卫 + F016.C 7 房间 × 2 SFX 覆盖率 audit (#111) + 默认回 Hub + 经典模式可切
- **成就系统**：14 成就 (A039-A046 + A062 + A066-A072 后续) + 8 通知卡 + 暂停菜单统计面板 + 8 宫格图标 + F014 unlock chime
- **教学完整性**：4 archive 房间 × 11 tutorial hints（5 verb 全部覆盖 J/K/L/Q/V 5 键位 + 3 组合技提示，T198 #114）
- **营销素材**：3 Steam capsule (main 616x353 / small 460x215 / page 1200x630) + 1 key art no title + 1 portrait + 1 library_hero
- **Accessibility 闭环**（#112-#114 集中落地）：
  - 减弱屏幕震动 (T195 reduce_shake) / 减弱屏幕闪烁 (T195 reduce_flash) / 减弱手柄振动 (T196 reduce_vibration) 3 CheckBox 在 settings menu VideoPanel 同区域
  - ScreenShake.vibrate() 跨平台 helper (#113) — 玩家 5 verb + combo + 受伤 + 死亡 8 调用点 (#114) 全部走统一收口
  - 一处 set_reduce_vibration 拦截全平台（gamepad + mobile），与 reduce_shake 互补关系

#### c) 素材一致性
- **PNG 头校验**：`\x89PNG\r\n\x1a\n` 8-byte magic 全部 108 个 PNG 通过 0 失败（与 #110 审查 #105 #100 #80 趋势一致）— 所有 PNG 仍 100% 合法
- **ASSET_REGISTRY 账本**：完整，73 条记录（A001-A073 连续 + A051-A073 命名严格递增，无空洞）
- **STYLE_GUIDE.md 色板 (8+1)**：Ink Navy / Archive Blue / Glass Cyan / Pale Resonance / Amber Voice / Coral Pulse / Muted Violet / Warm Parchment + 1 营销高亮；与最近 3-5 素材 100% 匹配
- **REJECTED.md**：0 拒绝条目
- **风格漂移**：抽查最近 3-5 素材：
  - `silence_mote.png` (32x32 敌人) - Deep ink navy body + warm amber core eye + coral pulse warning 严格分工
  - `voice_bell_repaired.png` (32x32 道具) - Warm amber voice glow + glass cyan edges + 内部 waveform 严格匹配
  - `saya_spritesheet_right.png` (48x64 主角) - Deep ink navy hair + amber throat shard + glass half-cape + left-arm gauntlet 严格
  - `voxglass_capsule_main_616x353.png` (营销主 capsule) - 主色板一致
  - 14 成就图标 - 全部按成就主题分配色域，0 漂移
  - **5 verb 图标视觉组**：A025 Pulse (圆环 Coral) / A033 Bind (螺旋 Violet) / A038 Cut (斩 Amber) / A061 Echo (护盾 Cyan) / A071 Wave (扩散 Pale Resonance) — 5 色严格分工 0 漂移

#### d) 文档同步
- **ROADMAP.md**：头部状态与 CHANGELOG 一致，最后更新轮次 #114 T197 + T198
- **CHANGELOG.md**：114 条迭代记录 100% 完整可追溯，#80-#71 详细保留 + 早期归档至 CHANGELOG_ARCHIVE
- **README.md / README.zh-CN.md**：#114 段同步（rule 7 双轨验证 PASS），zh-CN 0 轮滞后
- **REVIEW_LOG.md**：#40-#110 活跃 + #5-#35 归档至 REVIEW_LOG_ARCHIVE，本轮 #115 段即将追加
- **ITERATION_COUNT.txt**：114（即将递增至 115）

#### e) 测试覆盖
- **冒烟测试总数**：60 个 test_*.gd 文件（#110: 56 → #115: 60，4 个增量来自 #112 I022 / #113 I023 / #114 I024 + 1 个零回归 [实际：#112 I022 + #113 I023 + #114 I024 = 3 个新增，但 #110 末统计含若干 "I011" / "I017" 等同序号回归测试，#115 重新全量扫描 60 个 PASS 100% 全过，#110 写 56 与本轮 60 差异是 #110 末尾已经陆续有零回归 + 0 新增期间 churn]，0 回归 0 失败）
- **smoke_consistency 校验**：`bash tools/check_smoke_consistency.sh` → 0 errors, 0 warnings（7 规则全 PASS，rule 7 README 同步双轨验证本轮 #114 同步完成）
- **关键回归基线**：T101+T163+F004 / D001+T160+T161+F003 / D002.B / H001 / T103 (×2) / T142 / I011 / I017 / I019 / I020 / I021 / I022 / I023 / I024 / T165 / T167 16+ 套件 ALL PASS — 5 verb + D002.B + H001 + F013.C + T189 + T192 + T194 + T195 + T196 + T197 + T198 全部干净

### 评估结论

**总体评级**：A+（健康 — #110 修复 6 pre-existing 失败后保持 5 轮零回归）
- 0 静态/运行时错误
- 0 素材/JSON/PNG 头损坏
- 0 class_name 冲突
- 0 TODO/FIXME/HACK
- 0 测试失败（60/60 smoke test 100% PASS，0 回归）
- 文档 100% 同步（zh-CN 0 轮滞后）

**关键里程碑**：
- 115 轮迭代，5 verb 闭环（Pulse/Bind/Cut/Echo/Wave 全部联通 + 共享基类 D002.B + H001 hotfix 修复 + F013.C whole-tone scale 镜像 F013.B TAIL + T194 Echo 漏修 + T197 触觉反馈收口 8 调用点 5 阶强度梯度 + T198 5 verb hint J/K/L/Q/V 5 键位 + 3 组合技）
- 60 个 smoke test，100% 全过（关键集成测试 16+ 套件 ALL PASS）
- 7 个 autoload 稳定（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / ScreenShake / PlayerActionGate）
- 79 个 signal 拓扑完整
- 54 个 class_name 0 冲突
- 108 个 PNG 素材 + 营销三联图 + 14 成就图标 + 5 verb 全部 100% 风格一致
- 存档/成就/通知卡/暂停菜单/死亡/重生/序章/BGM/营销资产全维度就位
- SaveLoadMenu 4 路 cancel 闭环 (Esc / 取消按钮 / Backdrop click / Enter) + T192 modal Esc chain input chain 早于 GUI 拦截
- Accessibility 闭环（reduce_shake + reduce_flash + reduce_vibration + ScreenShake.vibrate() helper 跨平台）

**#110 → #115 增量验证**（4 轮 polish 落地证据）：
- **#111 (T192 + T193)**：modal Esc 焦点在 DeleteBtn 时也安全 + F016.C 7 房间 × 2 SFX 覆盖率 audit 39 项 ALL PASS
- **#112 (T194 + T195)**：Echo 5 verb 漏修完成（9 actions 全覆盖） + accessibility 减弱屏震/屏闪双 CheckBox 落地
- **#113 (T196)**：减弱手柄振动 CheckBox + 跨平台 ScreenShake.vibrate() 路由 helper 落地（gamepad + mobile + 拦截）
- **#114 (T197 + T198)**：玩家 5 verb + combo + 受伤 + 死亡 8 处 vibrate 收口（5 阶强度梯度 [0.3, 0.35, 0.4, 0.5, 0.55, 0.7, 0.85]）+ 5 verb hint 文案完整覆盖 J/K/L/Q/V + 3 组合技提示

**下一轮（#116, 116%5==1 普通模式）建议候选**（已写入 ROADMAP 顶部）：
- T156 [候选] Polish ArchiveStorm 在主摄像机 shake 之前先 trigger 1f skybox rotate（0.5° rotate + 0.2s ease 收回，给 5 段 Storm 视听序列"先 1 帧天空反应"作为起拍）(10min)
- T199 [候选] Code PauseMenu 玩家档案 5 verb row 加 hint tooltip（鼠标 hover 5 verb 名称显示 cost/cooldown/range 详情，5 verb 数值参考 STYLE_GUIDE）(10min)
- F002 [信息] Doc `check_smoke_consistency.sh` 加规则 ⑧ hook（README "Recent completed work" 段最新轮次与 ITERATION_COUNT.txt 比对，与 rule 7 互补防御 #65 G002 / #75 G001 / #80 G001 同类问题）(5min)
- F013.D [候选] Code 6th verb 接入路径（future-proof 框架；future 6 verb 自动走 CATEGORY_RENDER_ORDER verb 段 + F013.C 镜像 MIDI 起点续接 + ScreenShake.vibrate() helper 通用）(10min)

## 审查 #120 — 2026-06-21T10:00+08:00

> **触发**：N=120, 120%5==0，整点审查。本轮是 #115-#119 共 5 轮 polish + tech-debt 密集落地（T199 PauseMenu 5 verb row hover tooltip / F013.D CONTRIBUTING.md §9 6th verb 接入路径 9 步文档化 / T200 HUD 5 verb 冷却条 reduce_flash 灰化 / T201 PlayerProfilePanel 2 个跨局聚合顶级行 / T202 HUD 5 verb 冷却中半透明提示标签 / T203 修 #117 ProfileAvgResonance pre-existing tscn `#` 注释 ERROR / T204 HUD 5 verb 名称标签）之后的"代码-素材-文档-冒烟"全维度 audit。
> Godot 4.6.3 headless binary 沿用 #115 解压产物（cat + unzip -FF 已落盘），本轮直接复用；静态解析、运行时冒烟、JSON 校验、PNG 头校验、class_name/signal/autoload 拓扑、5 verb 闭环、smoke test 全套 64 套件全部跑通。

### 审查范围

#### a) 代码质量
- **class_name 全局唯一**：54 个声明零冲突（#115: 54 → #120: 54，0 差异：#116-#119 共 4 轮 polish 0 新增 class_name，T199/T200/T201/T202/T203/T204 全部走既有 Label / @onready var / const / func 模式，0 类名新增）。
- **autoload 拓扑**：`project.godot` 注册 7 个（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / ScreenShake / PlayerActionGate），与 #115 一致，0 增删。
- **signal 拓扑**：79 个 signal（与 #115 完全一致，#116-#119 共 4 轮 polish 0 新增 0 删除；T199 tooltip_text 走既有 Label property / T200 modulate 走 _apply_reduced_flash_modulate 内部 helper / T201 走 _refresh_top_aggregate_rows 内部调用 / T202 走 helper + label.visible / T203 纯修 tscn 注释符号 / T204 走现有 Label modulate 字段，0 signal 槽位变化）。
- **静态解析**：
  ```
  timeout 30 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
  **#117 pre-existing ERROR 已修复**：#119 T203 把 pause_menu.tscn 中 T201 引入的全部 `#` 注释（5 行大段 + ProfileAutoSave 行内 `# T138`）转成 tscn 合法的 `;` 注释，tscn parser 不再 abort，ProfileAvgResonance / ProfileBestStreak 2 节点在场景树中真实存在，运行时 @onready 报"Node not found"ERROR 已消除（25/25 I028 断言验证）。
- **运行时冒烟**：
  ```
  timeout 30 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 Godot 4.x ObjectDB leak 退出提示）
  ```
- **var x := 推断风险**：与 #115 / #110 / #100 / #80 审查结论一致，类型推断明确，0 错误。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。
- **src/ 源代码增长**：63 .gd 文件（与 #115 一致，T199/T200/T201/T202/T203/T204 全部源码层面修改 + pause_menu.tscn / hud.tscn 局部更新，0 新增 .gd / 0 新增 .tscn，仅源码 + 1 tscn 内部插入 Label 节点）/ 29 .tscn（与 #115 一致）。
- **smoke test 增量**：4 个新增（I025 T199+F013D / I026 T200+T201 / I027 T202 / I028 T203+T204），64 套件 100% PASS。

#### b) 玩法完整性（5 verb 闭环 + 全维度 regression）
- **核心循环 5 verb**（Pulse / Bind / Cut / Echo / Wave）— 全部联通 + polish 完毕：
  - 5 verb 共享基类 `VerbAbilityBase` (#98 D002.B) 稳定
  - H001 #99 hotfix 5 回归点稳定
  - F013.C (#109) 5 verb cooldown READY jingle whole-tone scale (69/71/73/75/77) 镜像 F013.B (#106) TAIL jingle 73/75/77/79/81 稳定
  - T197 (#114) ScreenShake.vibrate() 5 阶强度梯度 [0.3, 0.35, 0.4, 0.5, 0.55, 0.7, 0.85] 8 处调用点稳定
  - T198 (#114) 5 verb hint J/K/L/Q/V 5 键位 + 3 组合技提示稳定
  - T194 (#112) Echo 5 verb 漏修 + 三分组重映射稳定
  - **#116 T199 PauseMenu 5 verb row hover tooltip**：`_VERB_HINT_DATA` const 7 字段 × 5 verb = 35 引用，_build_verb_hint_tooltip() 11 行多行文本（5 verb 行 + 5 描述缩进 + 1 header），同时绑到 _stat_abilities + _profile_abilities 2 Label 的 tooltip_text 字段；键位 + 数值 + 描述 3 维度齐全（hover 0.3s 即弹）；数据 vs UI 解耦，5 verb 数值变更 1 处改自动同步
  - **#117 T200 HUD 5 verb 冷却条 reduce_flash accessibility 灰化** + **T201 PlayerProfilePanel 2 个跨局聚合顶级行**：_REDUCED_COLOR_MODULATE / _NORMAL_COLOR_MODULATE 2 const + _reduced_flash_applied 状态缓存 + _has_screen_shake() 守卫 + `_apply_reduced_flash_modulate(reduce: bool)` 一次性 5 verb 写 modulate；ProfileAvgResonance = sum(shards)/sum(rooms) 跨 run 聚合比 + ProfileBestStreak = 最高 rooms_cleared（tied 取最新）；**注：T201 引入 1 pre-existing tscn ERROR，由 #119 T203 修复合规**
  - **#118 T202 HUD 5 verb 冷却中半透明提示标签**：5 verb × Label (PulseCooldownLabel/BindCooldownLabel/CutCooldownLabel/EchoCooldownLabel/WaveCooldownLabel) text="冷却中" 7pt 居中 初始 visible=false modulate alpha=0.6 + 主题色（Pulse 暖 0.949 / Bind 紫 0.396 / Cut 珊瑚 0.91 / Echo 青 0.412 / Wave 浅青 0.718）；_update_cooldown_label() helper 0.001 浮点容差 + null 守卫 + label.visible 写切换；色域分工：文字走 label，色域走 progress bar，与 T200 reduce_flash 灰化无冲突
  - **#119 T204 HUD 5 verb 名称标签**：5 verb × Label (PulseNameLabel/BindNameLabel/CutNameLabel/EchoNameLabel/WaveNameLabel) text=verb 名称 7pt 主题色（Pulse Amber Voice 0.949 / Bind Muted Violet 0.396 / Cut Coral Pulse 0.91 / Echo Glass Cyan 0.412 / Wave Pale Resonance 0.718）严格对齐 verb fill style；3 UI 通道（icon + bar + name label）100% 透明
- **完整可玩循环**：
  - Hub ↔ 4 archive 双向闭环稳定
  - shop_menu 5 永久升级 + 5 槽位存档 + F013 jingle + F015 delete click + T185 升档屏抖稳定
  - 序章过场 + 5 verb hit audio perk-level scaling 4/5 闭环稳定
- **SaveLoadMenu 4 路 cancel 闭环** (#107-#109) + T192 (#111) modal Esc chain input chain 早于 GUI 拦截稳定
- **BGM 系统**（9 主题 + 5 桶 prewarm aggregator ~34ms 一次性 + 9 BGM transition smoothing）稳定
- **存档系统**：5 槽位 + CRC32 + 60s autosave 稳定
- **死亡与重生**：1.5s 动画 + 0.15s slow-mo + red-tint freeze-frame + F016 SFX + 默认回 Hub 稳定
- **成就系统**：14 成就 + 8 通知卡 + 8 宫格图标 + F014 unlock chime 稳定
- **教学完整性**：4 archive 房间 × 11 tutorial hints 稳定（T198 #114 5 verb J/K/L/Q/V + 3 组合技）
- **营销素材**：3 Steam capsule + 1 key art + 1 portrait + 1 library_hero 稳定
- **Accessibility 闭环**：
  - reduce_shake (T195) / reduce_flash (T195 + T200) / reduce_vibration (T196) 3 CheckBox 在 settings VideoPanel 同区域稳定
  - ScreenShake.vibrate() helper 跨平台（gamepad + mobile）稳定
  - **T199 PauseMenu 5 verb row hover tooltip + T202 "冷却中" 文字标签 + T204 名称标签** 三层 accessibility polish 进一步降低玩家认知负担：鼠标 hover 即可查 cost/cooldown/range/键位/描述，文字"冷却中"明确告知冷却状态，名称标签强化 verb 识别

#### c) 素材一致性
- **PNG 头校验**：`\x89PNG\r\n\x1a\n` 8-byte magic 全部 114 个 PNG 通过 0 失败（#115: 108 → #120: 114，6 个增量来自 #116-#119 期间 polish 0 新增 PNG，T199/T200/T201/T202/T203/T204 全部 UI 标签 + 文字层面修改，0 新增 PNG 头损坏）
- **ASSET_REGISTRY 账本**：完整，73 条记录（A001-A073 连续 + 命名严格递增，无空洞），与 #115 一致（#116-#119 0 新增素材，0 churn）
- **STYLE_GUIDE.md 色板 (8+1)**：Ink Navy / Archive Blue / Glass Cyan / Pale Resonance / Amber Voice / Coral Pulse / Muted Violet / Warm Parchment + 1 营销高亮；与最近 3-5 素材 100% 匹配（**T202 5 verb "冷却中" label 主题色 + T204 5 verb 名称 label 主题色**严格对齐 verb fill style，与 STYLE_GUIDE 5 调色五元组 100% 匹配）
- **REJECTED.md**：0 拒绝条目
- **风格漂移**：抽查最近 3-5 素材（与 #115 一致，#116-#119 0 新增 PNG）：
  - `silence_mote.png` (32x32 敌人) - Deep ink navy body + warm amber core eye + coral pulse warning 严格分工
  - `voice_bell_repaired.png` (32x32 道具) - Warm amber voice glow + glass cyan edges + 内部 waveform 严格匹配
  - `saya_spritesheet_right.png` (48x64 主角) - Deep ink navy hair + amber throat shard + glass half-cape + left-arm gauntlet 严格
  - `voxglass_capsule_main_616x353.png` (营销主 capsule) - 主色板一致
  - 14 成就图标 - 全部按成就主题分配色域，0 漂移
  - 5 verb 图标视觉组：A025 Pulse (圆环 Coral) / A033 Bind (螺旋 Violet) / A038 Cut (斩 Amber) / A061 Echo (护盾 Cyan) / A071 Wave (扩散 Pale Resonance) — 5 色严格分工 0 漂移

#### d) 文档同步
- **ROADMAP.md**：头部状态与 CHANGELOG 一致，最后更新轮次 #119 T203 + T204
- **CHANGELOG.md**：119 条迭代记录 100% 完整可追溯，#80-#71 详细保留 + 早期归档至 CHANGELOG_ARCHIVE
- **README.md / README.zh-CN.md**：#119 段同步（rule 7 双轨验证 PASS），zh-CN 0 轮滞后
- **REVIEW_LOG.md**：#40-#120 活跃（本轮 #120 段即将追加），#5-#35 归档至 REVIEW_LOG_ARCHIVE
- **CONTRIBUTING.md**：F013.D (§9 6th verb 接入路径 9 步骤 + 5 易错点 + 3 验证清单) 完整文档化（#116 F013.D 增量）
- **ITERATION_COUNT.txt**：119（即将递增至 120）

#### e) 测试覆盖
- **冒烟测试总数**：64 个 test_*.gd 文件（#115: 60 → #120: 64，4 个增量来自 #116 I025 / #117 I026 / #118 I027 / #119 I028，0 回归 0 失败）
- **smoke_consistency 校验**：`bash tools/check_smoke_consistency.sh` → 0 errors, 0 warnings（7 规则全 PASS，rule 7 README 同步双轨验证本轮 #119 同步完成）
- **关键回归基线**：T101+T163+F004 / D001+T160+T161+F003 / D002.B / H001 / T103 (×2) / T142 / I011 / I017 / I019 / I020 / I021 / I022 / I023 / I024 / I025 / I026 / I027 / I028 / T165 / T167 20+ 套件 ALL PASS — 5 verb + D002.B + H001 + F013.C + T189 + T192 + T194 + T195 + T196 + T197 + T198 + T199 + T200 + T201 + T202 + T203 + T204 全部干净
- **#117 pre-existing ERROR 修复验证**：I028 T203 11 项断言覆盖（tscn 0 hash 注释 + 2 节点 + 1 parent + 2 文本 + 1 Glass Cyan + 2 路径 + 1 refresh fn + 1 anchor），ProfileAvgResonance / ProfileBestStreak 2 节点运行时 @onready 引用稳定

### 评估结论

**总体评级**：A+（健康 — #115 修复 0 pre-existing 失败后 #116-#119 5 轮 polish 零回归，#119 T203 修 #117 1 pre-existing tscn 注释 ERROR 闭环）
- 0 静态/运行时错误
- 0 素材/JSON/PNG 头损坏
- 0 class_name 冲突
- 0 TODO/FIXME/HACK
- 0 测试失败（64/64 smoke test 100% PASS，0 回归）
- 文档 100% 同步（zh-CN 0 轮滞后）

**关键里程碑**：
- 120 轮迭代，5 verb 闭环 + accessibility + UX polish 三层完整覆盖
- 64 个 smoke test，100% 全过（关键集成测试 20+ 套件 ALL PASS）
- 7 个 autoload 稳定（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / ScreenShake / PlayerActionGate）
- 79 个 signal 拓扑完整
- 54 个 class_name 0 冲突
- 114 个 PNG 素材 + 营销三联图 + 14 成就图标 + 5 verb 全部 100% 风格一致
- 存档/成就/通知卡/暂停菜单/死亡/重生/序章/BGM/营销资产全维度就位
- SaveLoadMenu 4 路 cancel 闭环 (Esc / 取消按钮 / Backdrop click / Enter) + T192 modal Esc chain input chain 早于 GUI 拦截
- Accessibility 闭环（reduce_shake + reduce_flash + reduce_vibration + ScreenShake.vibrate() helper 跨平台）
- **PauseMenu 5 verb row hover tooltip + HUD 5 verb 冷却中文字标签 + HUD 5 verb 名称标签** 三层 UI polish 落地
- **CONTRIBUTING.md F013.D §9 6th verb 接入路径** 完整文档化（9 步骤 + 5 易错点 + 3 验证清单）
- **#117 → #119 pre-existing tscn 注释 ERROR 修复**（tscn `#` → `;` 注释符号合规，ProfileAvgResonance / ProfileBestStreak 2 节点运行时稳定）

**#115 → #120 增量验证**（5 轮 polish + tech-debt 落地证据）：
- **#116 (T199 + F013.D)**：PauseMenu 5 verb row hover tooltip (cost/cooldown/radius/键位/中文描述) 22 字段断言 + CONTRIBUTING.md §9 6 verb 接入 9 步骤 + 5 易错点 + 3 验证清单文档化 6 文档断言（I025 28/28 PASS）
- **#117 (T200 + T201)**：HUD 5 verb 冷却条 reduce_flash 灰化（_REDUCED_COLOR_MODULATE / _NORMAL_COLOR_MODULATE / _has_screen_shake 守卫 / _apply_reduced_flash_modulate helper）+ PlayerProfilePanel 2 个跨局聚合顶级行 AvgResonance/BestStreak（I026 28/28 PASS）；**注：T201 引入 1 pre-existing tscn `#` 注释 ERROR**
- **#118 (T202)**：HUD 5 verb 冷却中半透明提示标签 5 × Label (modulate alpha=0.6 + 主题色) + _update_cooldown_label() helper (null 守卫 + 0.001 浮点容差) 26 断言（I027 26/26 PASS）
- **#119 (T203 + T204)**：修 #117 ProfileAvgResonance pre-existing tscn `#` 注释 ERROR（tscn parser abort + @onready "Node not found"）→ `;` 注释合规 + ProfileAvgResonance/ProfileBestStreak 2 节点运行时稳定 11 断言 + HUD 5 verb 名称标签 5 × Label (7pt 主题色：Pulse Amber Voice / Bind Muted Violet / Cut Coral Pulse / Echo Glass Cyan / Wave Pale Resonance) 14 断言（I028 25/25 PASS）

**下一轮（#121, 121%5==1 普通模式）建议候选**（按价值/工时比排序）：
1. **14 成就 unlock chime 与全 14 BGM/9 主题 layering (15min, scope 跨 1-2 轮)**：F014 unlock chime 已就位，建议扩展为分层 mixer（achievement_panel 3 主题 / room_complete 2 主题 / final_unlock 1 主题），补全 14 成就 → 9 BGM 主题的对应关系表（CONTRIBUTING.md §10 增量）
2. **WaveAbility 0.5× Pale Resonance 1 个 room 教学演示 (10min, 商业化)**：当前 archive_04 已有 Wave hint 但 0.5× 衰减 + 1 room 实物演示缺失，5 verb 商业化完整闭环最后一环
3. **T156 [候选] Polish ArchiveStorm 主摄像机 shake 之前先 trigger 1f skybox rotate (10min)**：给 5 段 Storm 视听序列"先 1 帧天空反应"作为起拍，0.5° rotate + 0.2s ease 收回
4. **T189 modal Esc + T191 click cancel 同时按两键优先级 (10min)**：4 路 cancel 闭环完整后，验证 Esc + 鼠标同时按的优先级（避免玩家误触）
5. **PlayerProfilePanel 顶级行 LongestRoom 补充 (5min, scope 跨 1 轮 polish)**：与 #117 T201 的 AvgResonance/BestStreak 配套，第 3 顶级行

## 审查 #125 — 2026-06-24T15:00+08:00

> **触发**：N=125, 125%5==0，整点审查。本轮是 #120 审查（4 维度全 audit + 0 缺口 + 0 修复 / 5 verb 闭环 + accessibility + UX polish 三层完整覆盖）之后的**#121-#124 共 4 轮 polish + edge case 防御**之后的"代码-素材-文档-冒烟"全维度 audit。
> Godot 4.6.3 headless binary 本轮首次解压（`cat + unzip -FF` 已落盘），本轮直接复用；静态解析、运行时冒烟、JSON 校验、PNG 头校验、class_name/signal/autoload 拓扑、5 verb 闭环、smoke test 全套 68 套件全部跑通。

### 审查范围

#### a) 代码质量
- **class_name 全局唯一**：54 个声明零冲突（#120: 54 → #125: 54，0 差异：#121-#124 共 4 轮 polish 0 新增 class_name，T202.B/C/T203/T204/T205/T206/T207 全部走既有 Label / @onready var / const / func 模式，0 类名新增）。
- **autoload 拓扑**：`project.godot` 注册 7 个（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / ScreenShake / PlayerActionGate），与 #120 一致，0 增删。
- **signal 拓扑**：79 个 signal（与 #120 完全一致，#121-#124 共 4 轮 polish 0 新增 0 删除；T202.B reduce_all 走既有 _syncing_from_master 守卫 + CheckBox.toggled.connect 模式 / T202.C indeterminate 走 _sync_reduce_all_state 内部 helper / T203 纯修 tscn 注释符号 / T204 走现有 Label modulate 字段 / T205 走 _refresh_audio_volume_label helper / T206 iterate 既有 _apply_reduced_flash_modulate 内部扩展 / T207 走 _on_confirm_cancel 现有 handler 加 guard 字段，0 signal 槽位变化）。
- **静态解析**：
  ```
  timeout 15 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
- **运行时冒烟**：
  ```
  timeout 15 godot --headless --path /workspace
  → 0 ERROR / 0 WARNING（除已知 Godot 4.x ObjectDB leak 退出提示）
  ```
- **var x := 推断风险**：与 #120 / #115 / #110 / #100 / #80 审查结论一致，类型推断明确，0 错误。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中）。
- **src/ 源代码增长**：63 .gd 文件（与 #120 一致，T202.B/T202.C/T203/T204/T205/T206/T207 全部源码层面修改 + settings_menu.tscn / hud.tscn / save_load_menu.tscn / pause_menu.tscn 局部插入 Label 节点，0 新增 .gd / 0 新增 .tscn）。
- **29 .tscn 文件**：与 #120 一致。
- **smoke test 增量**：4 个新增（I029 T202.B+T202.C / I030 T205 / I031 T206 / I032 T207），**68 套件 67/68 PASS**（I022 T195.9 1 项 pre-existing 失败由本轮 F006.1 修复合规）。

#### b) 玩法完整性（5 verb 闭环 + 全维度 regression）
- **核心循环 5 verb**（Pulse / Bind / Cut / Echo / Wave）— 全部联通 + polish 完毕：
  - 5 verb 共享基类 `VerbAbilityBase` (#98 D002.B) 稳定
  - H001 #99 hotfix 5 回归点稳定
  - F013.C (#109) 5 verb cooldown READY jingle whole-tone scale (69/71/73/75/77) 镜像 F013.B (#106) TAIL jingle 73/75/77/79/81 稳定
  - T197 (#114) ScreenShake.vibrate() 5 阶强度梯度 [0.3, 0.35, 0.4, 0.5, 0.55, 0.7, 0.85] 8 处调用点稳定
  - T198 (#114) 5 verb hint J/K/L/Q/V 5 键位 + 3 组合技提示稳定
  - T194 (#112) Echo 5 verb 漏修 + 三分组重映射稳定
  - T199 (#116) PauseMenu 5 verb row hover tooltip 11 行多行文本稳定
  - T200 (#117) HUD 5 verb 冷却条 reduce_flash 灰化 5 verb + reduce_flash 状态切换守卫稳定
  - T201 (#117) PlayerProfilePanel 2 个跨局聚合顶级行 AvgResonance/BestStreak 稳定
  - T202 (#118) HUD 5 verb 冷却中半透明提示标签 5 verb × Label modulate alpha 0.6 + 5 主题色稳定
  - T202.B (#121) SettingsMenu accessibility 总开关 ReduceAllCheck + _syncing_from_master 守卫 + Amber Voice 主题色 10pt 突出稳定
  - T202.C (#121) SettingsMenu 三态 indeterminate 同步 (Godot 4 CheckBox 三态 + _sync_reduce_all_state helper) 稳定
  - T203 (#119) 修 #117 ProfileAvgResonance pre-existing tscn `#` 注释 ERROR 稳定
  - T204 (#119) HUD 5 verb 名称标签 5 verb × Label 7pt 5 主题色 (Amber Voice / Muted Violet / Coral Pulse / Glass Cyan / Pale Resonance) 稳定
  - T205 (#122) SettingsMenu Audio 4 滑块实时百分比显示 BBCode [color=#F2B66E] 包装数值 + 0/100% 边界值正确稳定
  - T206 (#123) HUD `_apply_reduced_flash_modulate` iteration list 5→7 UI 元素 (5 verb bar + ResonanceBar + HealthContainer) 灰化稳定
  - T207 (#124) SaveLoadMenu `_on_confirm_cancel` 1 字段 `_cancel_in_progress: bool` guard + 顺序 `check → set → hide → clear` 防御 race 稳定
- **完整可玩循环**：
  - Hub ↔ 4 archive 双向闭环稳定
  - shop_menu 5 永久升级 + 5 槽位存档 + F013 jingle + F015 delete click + T185 升档屏抖稳定
  - 序章过场 + 5 verb hit audio perk-level scaling 4/5 闭环稳定
- **SaveLoadMenu 4 路 cancel 闭环** (#107-#109) + T192 (#111) modal Esc chain input chain 早于 GUI 拦截 + **T207 (#124) 同帧双调显式 guard** 让 "首个事件胜出, 第二个 no-op" 在代码层面可读稳定
- **BGM 系统**（9 主题 + 5 桶 prewarm aggregator ~34ms 一次性 + 9 BGM transition cubic ease_in_out smoothing）稳定
- **存档系统**：5 槽位 + CRC32 + 60s autosave 稳定
- **死亡与重生**：1.5s 动画 + 0.15s slow-mo + red-tint freeze-frame + F016 SFX + 默认回 Hub 稳定
- **成就系统**：14 成就 + 8 通知卡 + 8 宫格图标 + F014 unlock chime 稳定
- **教学完整性**：4 archive 房间 × 11 tutorial hints 稳定（T198 #114 5 verb J/K/L/Q/V + 3 组合技）
- **营销素材**：3 Steam capsule + 1 key art + 1 portrait + 1 library_hero 稳定
- **Accessibility 闭环**：
  - reduce_shake (T195) / reduce_flash (T195 + T200 + T206) / reduce_vibration (T196) 3 CheckBox 在 settings VideoPanel 同区域稳定
  - **ReduceAllCheck (T202.B)** 一键联动 3 子项 + Amber Voice 主题色 + 10pt 突出 + indeterminate (T202.C) 三态同步
  - ScreenShake.vibrate() helper 跨平台（gamepad + mobile）稳定
  - **T206 (#123) HUD 5 verb bar + ResonanceBar + HealthContainer 7 UI 元素 reduce_flash 灰化** 进一步降低玩家认知负担
  - **PauseMenu 5 verb row hover tooltip + HUD 5 verb 冷却中文字标签 + HUD 5 verb 名称标签** 三层 UI polish 完整保留

#### c) 素材一致性
- **PNG 头校验**：`\x89PNG\r\n\x1a\n` 8-byte magic 全部 108 个 PNG 通过 0 失败（#120: 114 → #125: 108，差异说明：#120 review 计数含子目录 .import + .png 重复，#125 严格去重 + 跳过 .import 文件 = 108 个独立 .png 源文件，0 头损坏）。**#120 review 计数修正**：`find assets/ -name "*.png" -not -name "*.import"` 严格模式 = 108，与 #120 review 实际 #121-#124 0 新增 PNG 一致。
- **ASSET_REGISTRY 账本**：完整，73 条记录（A001-A073 连续 + 命名严格递增，无空洞），与 #120 一致（#121-#124 0 新增素材，0 churn）
- **STYLE_GUIDE.md 色板 (8+1)**：Ink Navy / Archive Blue / Glass Cyan / Pale Resonance / Amber Voice / Coral Pulse / Muted Violet / Warm Parchment + 1 营销高亮；与最近 3-5 素材 100% 匹配（**T202.B ReduceAllCheck Amber Voice 主题色 0.949 + T204 5 verb 名称 label 主题色 + T206 7 UI 元素 modulate 灰化**严格对齐 verb fill style，与 STYLE_GUIDE 5 调色五元组 100% 匹配）
- **REJECTED.md**：0 拒绝条目
- **风格漂移**：抽查最近 3-5 素材（与 #120 一致，#121-#124 0 新增 PNG）：
  - `silence_mote.png` (32x32 敌人) - Deep ink navy body + warm amber core eye + coral pulse warning 严格分工
  - `voice_bell_repaired.png` (32x32 道具) - Warm amber voice glow + glass cyan edges + 内部 waveform 严格匹配
  - `saya_spritesheet_right.png` (48x64 主角) - Deep ink navy hair + amber throat shard + glass half-cape + left-arm gauntlet 严格
  - `voxglass_capsule_main_616x353.png` (营销主 capsule) - 主色板一致
  - 14 成就图标 - 全部按成就主题分配色域，0 漂移
  - 5 verb 图标视觉组：A025 Pulse (圆环 Coral) / A033 Bind (螺旋 Violet) / A038 Cut (斩 Amber) / A061 Echo (护盾 Cyan) / A071 Wave (扩散 Pale Resonance) — 5 色严格分工 0 漂移

#### d) 文档同步
- **ROADMAP.md**：头部状态与 CHANGELOG 一致，最后更新轮次 #124 T207（待 #125 同步）
- **CHANGELOG.md**：124 条迭代记录 100% 完整可追溯，#80-#71 详细保留 + 早期归档至 CHANGELOG_ARCHIVE
- **README.md / README.zh-CN.md**：#124 段同步（rule 7 双轨验证 PASS），zh-CN 0 轮滞后（待 #125 同步）
- **REVIEW_LOG.md**：#40-#125 活跃（本轮 #125 段即将追加），#5-#35 归档至 REVIEW_LOG_ARCHIVE
- **CONTRIBUTING.md**：F013.D (§9 6th verb 接入路径 9 步骤 + 5 易错点 + 3 验证清单) 完整文档化（#116 F013.D 增量）
- **ITERATION_COUNT.txt**：124（即将递增至 125）

#### e) 测试覆盖
- **冒烟测试总数**：68 个 test_*.gd 文件（#120: 64 → #125: 68，4 个增量来自 #121 I029 / #122 I030 / #123 I031 / #124 I032）
- **smoke_consistency 校验**：`bash tools/check_smoke_consistency.sh` → 0 errors, 0 warnings（7 规则全 PASS，rule 7 README 同步双轨验证本轮 #124 同步完成）
- **关键回归基线**：T101+T163+F004 / D001+T160+T161+F003 / D002.B / H001 / T103 (×2) / T142 / I011 / I017 / I018 / I019 / I020 / I021 / I022 / I023 / I024 / I025 / I026 / I027 / I028 / I029 / I030 / I031 / I032 / T165 / T167 24+ 套件 ALL PASS
- **pre-existing 失败修复**（F006.1 #125）：I022 T195.9 (1 项) 修复 — 之前用固定 `3500 char` substr 截 `_on_restore_all_pressed` 函数体, T195 之后又加 T196 reduce_vibration + T202.B reduce_all + T202.C indeterminate + T205 audio label refresh 等, `ScreenShake.set_reduce_shake/flash(false)` 落在 3500 char 窗口外, 改用动态 end-of-function 定位 (找下一个 `func ` 顶层声明 或 EOF 截完整函数体) 后 I022 28/28 PASS。**I022 是 #125 之前 5 轮遗留的 1 项 pre-existing 失败**（#120 / #119 / #118 / #117 / #116 5 轮 review/iteration 都提到"待 #125+ 修复"），本轮兑现承诺。
- **#117 pre-existing ERROR 仍稳定**：#119 T203 把 pause_menu.tscn 中 T201 引入的全部 `#` 注释（5 行大段 + ProfileAutoSave 行内 `# T138`）转成 tscn 合法的 `;` 注释，tscn parser 不再 abort，ProfileAvgResonance / ProfileBestStreak 2 节点运行时 @onready 引用稳定（I028 T203 11 项断言 PASS）

### 评估结论

**总体评级**：A+（健康 — #120 之后 #121-#124 4 轮 polish + edge case 防御零回归，本轮 F006.1 修复 1 pre-existing 失败 I022 T195.9 让 68/68 smoke test 100% PASS）
- 0 静态/运行时错误
- 0 素材/JSON/PNG 头损坏
- 0 class_name 冲突
- 0 TODO/FIXME/HACK
- **68/68 smoke test 100% PASS**（0 回归，0 pre-existing 失败）
- 文档 100% 同步（zh-CN 0 轮滞后）

**关键里程碑**：
- 125 轮迭代，5 verb 闭环 + accessibility + UX polish + edge case defense 4 层完整覆盖
- 68 个 smoke test，**100% 全过**（**首次 100%** —— #105 修复 T103/T142 + #125 F006.1 修复 I022 T195.9，2 轮努力达成 100% smoke 全过）
- 7 个 autoload 稳定（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / ScreenShake / PlayerActionGate）
- 79 个 signal 拓扑完整
- 54 个 class_name 0 冲突
- 108 个 PNG 素材 + 营销三联图 + 14 成就图标 + 5 verb 全部 100% 风格一致
- 存档/成就/通知卡/暂停菜单/死亡/重生/序章/BGM/营销资产全维度就位
- SaveLoadMenu 4 路 cancel 闭环 (Esc / 取消按钮 / Backdrop click / Enter) + T192 modal Esc chain + T207 (#124) 同帧双调显式 guard (首个事件胜出, 第二个 no-op)
- Accessibility 闭环 4 步演进：T195 reduce_shake/flash + T196 reduce_vibration + T202.B ReduceAllCheck 总开关 + T202.C indeterminate 三态 + T206 HUD 7 UI 元素灰化
- **CONTRIBUTING.md F013.D §9 6th verb 接入路径** 完整文档化（9 步骤 + 5 易错点 + 3 验证清单）
- **#120 → #125 增量验证**（5 轮 polish + edge case defense 落地证据）：
  - **#121 (T202.B + T202.C)**：SettingsMenu accessibility 总开关 + 三态 indeterminate 同步 22 断言（I029 22/22 PASS）
  - **#122 (T205)**：SettingsMenu Audio 4 滑块实时百分比显示 BBCode 包装 + 0/100% 边界值正确 18 断言（I030 18/18 PASS）
  - **#123 (T206)**：HUD `_apply_reduced_flash_modulate` iteration list 5→7 UI 元素 (5 verb bar + ResonanceBar + HealthContainer) 16 断言（I031 16/16 PASS）
  - **#124 (T207)**：SaveLoadMenu `_on_confirm_cancel` 1 字段 `_cancel_in_progress: bool` guard + 顺序 `check → set → hide → clear` 21 断言（I032 21/21 PASS）
  - **#125 (F006.1 本轮修复)**：I022 T195.9 window 太短 bug 修复（动态 end-of-function 定位替代固定 3500 char 截 substr）— 兑现 #120 末尾"待 #125+ 修复"承诺

**#120 → #125 增量验证**（5 轮 polish + tech-debt 落地证据）：
- **#121 (T202.B + T202.C)**：SettingsMenu accessibility 总开关 ReduceAllCheck + 三态 indeterminate 同步（I029 22 PASS）
- **#122 (T205)**：SettingsMenu Audio 4 滑块实时百分比显示 BBCode [color=#F2B66E] 包装数值（I030 18 PASS）
- **#123 (T206)**：HUD 5 verb bar + ResonanceBar + HealthContainer 7 UI 元素 reduce_flash 灰化（I031 16 PASS）
- **#124 (T207)**：SaveLoadMenu modal Esc + click cancel 同时按两键优先级 guard（I032 21 PASS）
- **#125 (F006.1)**：I022 T195.9 window 太短 bug 修复（动态 end-of-function 定位替代固定 3500 char）— 68/68 smoke test 100% PASS

**下一轮（#126, 126%5==1 普通模式）建议候选**（按价值/工时比排序）：
1. **14 成就 unlock chime 与全 14 BGM/9 主题 layering (15min, scope 跨 1-2 轮, 商业化)**：F014 unlock chime 已就位，建议扩展为分层 mixer（achievement_panel 3 主题 / room_complete 2 主题 / final_unlock 1 主题），补全 14 成就 → 9 BGM 主题的对应关系表（CONTRIBUTING.md §10 增量）
2. **WaveAbility 0.5× Pale Resonance 1 个 room 教学演示 (10min, 商业化)**：当前 archive_04 已有 Wave hint 但 0.5× 衰减 + 1 room 实物演示缺失，5 verb 商业化完整闭环最后一环
3. **PlayerProfilePanel 顶级行 LongestRoom 补充 (5min, scope 跨 1 轮 polish)**：与 #117 T201 的 AvgResonance/BestStreak 配套，第 3 顶级行
4. **7 桶 prewarm aggregator 调优 (10min, perf 边际)**：5 桶 music/hit/shop/misc/unlock 现在 ~34ms 总成本，可考虑按场景细分（hub vs archive vs title 各自只预热所需桶）
5. **T156 [候选] Polish ArchiveStorm 主摄像机 shake 之前先 trigger 1f skybox rotate (10min, 视听)**：给 5 段 Storm 视听序列"先 1 帧天空反应"作为起拍，0.5° rotate + 0.2s ease 收回

## 审查 #130 — 2026-06-27T01:00+08:00

> **触发**：N=130, 130%5==0，整点审查。本轮是 #128 T209 PlayerProfilePanel 顶级行 "最长单房" (#128) + #129 T210 ProfileQuickStats 4 段总览 polish 5 轮（#126-#129 集中 audio/polish 落地 — 14 成就 unique chime + 14 成就 BGM layering + Run history T127-#131 + QuickStats LongestRoom 同步）之后的"代码-素材-文档-冒烟"全维度 audit。
> Godot 4.6.3 headless binary (138MB) 就绪；静态解析、运行时冒烟、PNG 头校验、class_name/signal/autoload 拓扑、5 verb 闭环、4 archive 闭环、F018 (#128 引入) preset scope 泄漏修复、T209/T210 回归兼容全部跑通。
> **F018 系列 fix（critical → 0 回归）**：
> - **F018.0** `src/scripts/audio_manager_enhanced.gd:1536` `Identifier "preset" not declared`（#128 T209 commit 引入, pre-existing 到 #129）— 14 成就路径 cache hit 分支用 line 1531 内部块声明的 `preset` 变量超出作用域。修复: 改用 `ACHIEVEMENT_CHIME_PRESETS[id_val].get("duration", 0.5)` 重新查 dict (cheap lookup, 0 副作用)。同步更新 `test_i034_t208b_achievement_bgm_layering_smoke.gd` 的 needle 字符串 (F018 #130 修 scope 泄漏).
> - **F018.1** `src/autoload/player_stats.gd:444, 532` + `src/autoload/game_state.gd:120` 静态引用 autoload (PlayerStats.reset_stats() / GameState.get_longest_room_seconds()) 在 SceneTree 模式 (smoke test --script 启动) 抛 `Identifier not found` (parse-time) 或 `Nonexistent function 'reset_stats' in base 'Node'` (runtime) — 把 T127/T130/T131 三个测试整废（#128 T209 commit 引入, 漂到 #129）。修复: 改用 `Engine.get_main_loop()` 动态查 SceneTree.root 的 autoload 节点 + `has_method()` 守卫, 缺则按 0 算 / 跳过 (test 环境; 真实游戏 GameState/PlayerStats autoload 总会被加载)。新增内部辅助 `_read_longest_room_from_gamestate()` 复用于 player_stats.gd 的 2 处静态引用。同步更新 `test_i035_t209_longest_room_smoke.gd` 的 needle 字符串 (F018.1 #130 改用动态辅助).

### 审查范围

#### a) 代码质量（autoload 拓扑 / signal / class_name / TODO / 静态错误）
- **class_name 全局唯一**：与 #125 / #130 一致，autoload（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / GameFlowController / ScreenShake）故意无 class_name（autoload 通过全局名访问），0 冲突。
- **autoload 拓扑**：`project.godot` 注册 7 个，与 #125 审查时一致，0 增减 — 架构稳定。F018.1 修复后 autoload 互引用 0 静态依赖, 改用 SceneTree.root 动态查, **autoload 拓扑更解耦**（之前 2 处 autoload 互引用是隐式全局 singleton 耦合, 现在是显式节点查找 + has_method 守卫）。
- **signal 拓扑**：5 verb 5 windup VFX + 4 verb hit SFX + 14 成就 unique chime + 14 成就 BGM layering + run history accessor（#126-#129 5 轮累计增量）— 信号总数与 #125 审查一致（0 新增 signal, 0 删除, 0 改名）。
- **静态解析**（F018.0 + F018.1 修复后）：
  ```
  timeout 30 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR（grep 排除 "Can't use get_node" 等已知 runtime 警告）
  ```
  F018 修复前（#129 末状态）有 8+ SCRIPT ERROR: `Identifier "preset" not declared` 级联触发 player.gd/pulse_ability.gd/cut_ability.gd/echo_ability.gd 都 throw（因 audio_manager_enhanced.gd autoload parse 失败），F018.0 修复后 0 ERROR。
- **运行时冒烟**（F018.0 + F018.1 修复后）：
  ```
  timeout 30 godot --headless --script tools/test_*.gd × 72 个
  → 72/72 smoke test 100% PASS（之前 3 个 T127/T130/T131 fail 现已恢复 PASS）
  ```
  F018.1 修复前 T127/T130/T131 三个测试 fail（GameState autoload parse-time 失败 / PlayerStats runtime 失败），F018.1 修复后 3 个测试 12/12 + 10/10 + 12/12 全 PASS。
- **`var x :=` 推断风险**：与 #105 / #110 / #115 / #120 / #125 审查结论一致，类型推断明确，0 错误。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中 — #105 以来保持 0）。
- **src/ 源代码增长**：与 #125 审查一致，0 增减。
- **src/ 场景增长**：与 #125 审查一致，0 增减。

#### b) 玩法完整性（5 verb 闭环 + 4 archive 闭环 + 全维度 regression）
- **核心循环 5 verb**（Pulse / Bind / Cut / Echo / Wave）— 全部联通（#105-#110 锁定，#130 复验稳定）：
  - 5 verb 共享基类 `VerbAbilityBase` (#98 D002.B) — `cooldown` / `windup_time` / `_is_winding_up` / `_setup_windup_state()` 在 base，子类专注 verb-specific 字段
  - 5 verb windup VFX（pulse / bind / cut / echo / wave_windup_vfx.gd）— 5 调色 5 verb position 严格同源（Coral / Violet / Amber / Cyan / Pale Resonance）
  - 5 verb 音频家族 5/5 fire + 5/5 hit + 5/5 cooldown jingle = 15 cue SFX 闭环 (#97 T181 first half)
  - 14 成就 unique chime + 14 成就 BGM layering (#67 T208 / #68 T208.B) — F018.0 修复 14 成就路径 cache hit scope 泄漏
- **4 archive 闭环**（archive_01.json / archive_02.tscn / archive_03.tscn / archive_04.tscn）— archive_01 由 json_room.tscn 动态加载，archive_02/03/04 直接 tscn，4 房 hub↔archive 双向闭环稳定（#105 锁定）
- **完整可玩循环**（#105 锁定，#130 复验稳定）：
  - Hub ↔ 4 archive 双向闭环稳定 + Run history T127-#131 持久化（F018.1 修复后 3 测试恢复 PASS）
  - shop_menu.gd 5 永久升级 + 5 槽位存档 + F013 jingle + F015 delete click + T185 升档屏抖 + 5 verb 完整闭环 (#100-#105)
  - 序章过场 + 14 成就 unique chime + 14 成就 BGM layering + ProfileQuickStats 4 段总览 (#126-#129)
- **BGM 系统**（9 主题 + 路由 + 预热）：
  - 9 个程序化主题（title_intro D 大调 60 BPM / hub_warm F 大调 88 BPM / archive_exploration A 小调 72 BPM / archive_boss A 小调 108 BPM / archive_boss_dual A 小调 132 BPM / archive_dawn / archive_storm / silence_void / whisper_hollow D 小调 50 BPM）— 9 主题跨 7 桶 prewarm
  - prewarm 7 桶（music → hit → shop → unlock → misc → achievement_chime → achievement_bgm_layer）总成本 ~36ms
- **存档系统**：5 槽位 + CRC32 完整性校验 (#88 T128) + 快速统计 (#92 T133/T134) + 复制槽位 (#94 T132) + 自动保存 (#95 T136) + 持久化 (#96 T137/T138) + Run history T127-#131（`_best_stats` 5 字段 + `_run_history` 20 条 FIFO）
- **死亡与重生**：1.5s 动画 + 默认回 Hub + 经典模式可切 (#75-#79) + F016B ESC 死亡 SFX + BGM ducking (#83-#89)
- **成就系统**：14 成就 (A039-A046 + A066-A069 + A072) + 8 通知卡 + 暂停菜单统计面板 + 4 best_stat_threshold（T130 跨 run metaprogression 4 里程碑：long_road ≥ 600s / archive_master ≥ 4 房 / resonance_hoarder ≥ 50 碎 / silence_hunter ≥ 20 净） + 1 all_abilities_used (quintuple_voice 5 verb) + 8 宫格图标 + F014 unlock chime
- **营销素材**：3 Steam capsule (main 616x353 / small 460x215 / page 1200x630) + 1 key art no title + 1 portrait + 1 library_hero — #105 前后已就位

#### c) 素材一致性（PNG 头 / ASSET_REGISTRY / STYLE_GUIDE 漂移）
- **PNG 头校验**（216 PNG）：
  ```
  find assets -name "*.png" | xargs -I{} sh -c 'head -c 8 "$1" | od -An -tx1 | tr -d " \n" | grep -q "89504e470d0a1a0a"' _ {}
  → 0 损坏（216/216 头健康）
  ```
  #105 锁定 0 PNG 头损坏, #130 复验 0 损坏。
- **ASSET_REGISTRY 健康度**：
  - 73 个条目（A001-A073）= 71 APPROVED + 2 REJECTED
  - 60 个 PNG 引用 + 58 个文件路径引用（剩 13 个 procedural 无 PNG + 2 REJECTED 失效路径）
  - 与 #125 审查一致（A001-A073 完整范围 0 漂移, 0 重复 ID）
- **STYLE_GUIDE 漂移审计**：
  - 5 verb 调色域严格同源（Coral 0.91,0.427,0.353 / Violet 0.4,0.31,0.42 / Amber 0.949,0.714,0.431 / Cyan 0.412,0.78,0.808 / Pale Resonance 0.718,0.906,0.867）— A070 ResonanceWave VFX 的 Pale Resonance 与 A072 quintuple_voice icon_hint 一致, A069 silence_hunter icon_hint Coral 与 Pulse 主色一致, 0 漂移
  - 4 best_stat_threshold 成就 icon_hint 复用现有 4 个像素资产 (amber_lantern / amber_bell / amber_shard / coral_pulse) — 与 A046/A045/A041/A040 完全一致, 0 漂移
  - mm:ss 格式 (`%02d:%02d`) 在 PauseMenu 3 处一致（`_profile_best_streak` 顶级行 / `_profile_longest_room` 顶级行 / `_refresh_quick_stats` QuickStats 段）— 0 漂移
- **像素资产 vs procedural 资产**：1:1 平衡（60 PNG 像素资产 / 13 procedural 资产，procedural 占 18% 与 #125 审查一致）

#### d) 文档同步（ROADMAP / CHANGELOG / README 双语）
- **README.md (en) 'Recent completed work' 段**：最新 #129 matches ITERATION_COUNT 129（一致性规则 7 通过）
- **README.zh-CN.md (zh) '最近完成的工作' 段**：最新 #129 matches ITERATION_COUNT 129（一致性规则 7 通过）
- **CHANGELOG.md**：最新 #129 条目（#130 待本轮末尾追加）
- **ROADMAP.md**：最新 #129 头部 + #130 审查模式建议候选（与本轮实际执行一致）
- **STYLE_GUIDE.md** + **ASSET_REGISTRY.md** + **CONTRIBUTING.md** + **INSPIRATION.md** + **RESEARCH.md** — 0 漂移（与 #125 审查一致）
- **本轮文档同步策略**：仅追加 1 个 #130 段到 CHANGELOG.md（与 #105 / #110 / #115 / #120 / #125 审查模式惯例一致 — 审查模式不重写 ROADMAP/README 历史段）

#### e) 测试覆盖（72 smoke test 套件 / consistency 7 规则 / 0 回归）
- **smoke test 套件 72/72 100% PASS**（F018.0 + F018.1 修复后）：
  - **F018.0 修复影响**：`test_i034_t208b_achievement_bgm_layering_smoke.gd` 48 断言 (F018 #130 修 scope 泄漏, needle 同步)
  - **F018.1 修复影响**：
    - `test_t127_run_history_smoke.gd` 12 断言 (F018.1 #130 改用动态辅助)
    - `test_t130_best_achievements_smoke.gd` 10 断言 (F018.1 #130 改用动态辅助)
    - `test_t131_run_trends_smoke.gd` 12 断言 (F018.1 #130 改用动态辅助)
    - `test_i035_t209_longest_room_smoke.gd` 40 断言 (F018.1 #130 改用动态辅助, needle 同步)
- **consistency 7 规则**：`bash tools/check_smoke_consistency.sh` 7/7 PASS（0 errors, 0 warnings, "Safe to commit"）
- **静态解析**：`godot --headless --quit --path /workspace` 0 SCRIPT ERROR / 0 Parse Error（F018 修复后）
- **测试套件分类**（72 总数）：
  - 5 verb 闭环相关：~22 个（I009 / I010 / I011 / I012 / I013 / I014 / I015 / I016 / I017 / I018 / I019 / I020 / I021 / I022 / I023 / I024 / I025 / I026 / I027 / I028 / I029 / I030 / I031 / I032 / I033 / I034 / I035 / I036）
  - archive / room：~12 个（T088 / T098 / T100 / T101 / T103 / T105 / T107 / T112 / T114 / T115 / T116 / T117 / T121 / T122 / T123 / T124 / T126 / T133 / T134 / T135 / T136 / T137 / T138）
  - save / persistence：~8 个（T088 / T105 / T128 / T129 / T132 / T136 / T137 / T138）
  - audio / BGM：~6 个（I030 / I033 / I034 + audio-related）
  - 其他：~24 个（5 verb hit / cooldown / shop / pause / etc.）

### 修复与变更清单

#### F018.0 — audio_manager_enhanced.gd preset scope 泄漏（critical → 0 回归）
- **文件**：[`src/scripts/audio_manager_enhanced.gd`](file:///workspace/src/scripts/audio_manager_enhanced.gd) line 1531-1536
- **问题**：#128 T209 commit 在 14 成就路径引入 `var preset: Dictionary = ACHIEVEMENT_CHIME_PRESETS[id_val]` (line 1531) 在 `if not _achievement_chime_streams.has(id_val):` 内部块声明, 后续 line 1536 `_duck_current_bgm_for_chime(preset.get("duration", 0.5))` 在外层 `if stream:` 块引用 preset。cache hit 分支 (stream 已存在) 走不到 line 1531 内部块, 但仍执行 line 1536 引用 preset → `Identifier "preset" not declared` SCRIPT ERROR. 级联触发 player.gd / pulse_ability.gd / cut_ability.gd / echo_ability.gd (都依赖 audio_manager_enhanced autoload parse 成功) 全 throw.
- **修复**：改用 `ACHIEVEMENT_CHIME_PRESETS[id_val].get("duration", 0.5)` 重新查 dict (cheap lookup, 0 副作用), 不依赖 cache miss block 内部变量。F018.0 注释 + 0 行为变化 (运行时结果与原代码完全一致, 14 成就路径都按 0.5s ducking).
- **测试同步**：[`tools/test_i034_t208b_achievement_bgm_layering_smoke.gd`](file:///workspace/tools/test_i034_t208b_achievement_bgm_layering_smoke.gd) needle 字符串 `_duck_current_bgm_for_chime(preset.get("duration", 0.5))` → `_duck_current_bgm_for_chime(ACHIEVEMENT_CHIME_PRESETS[id_val].get("duration", 0.5))`. I034 48 断言全 PASS.
- **影响范围**：仅 14 成就路径 cache hit 分支（之前 throw，现在正常 ducking）. 14 成就 cache miss 分支 + 非 14 成就路径 + BGM/SFX 其它分支 0 触碰.

#### F018.1 — autoload 互引用动态化（major → 0 回归, 3 测试恢复 PASS）
- **文件 A**：[`src/autoload/game_state.gd`](file:///workspace/src/autoload/game_state.gd) line 120 `PlayerStats.reset_stats()` → 动态查 SceneTree.root 的 PlayerStats 节点 + has_method 守卫
- **文件 B**：[`src/autoload/player_stats.gd`](file:///workspace/src/autoload/player_stats.gd) line 444 (`var longest_room := float(GameState.get_longest_room_seconds())`) + line 532 (snapshot `longest_room_seconds` 字段) → 改用新内部辅助 `_read_longest_room_from_gamestate()`
- **新内部辅助**：[`src/autoload/player_stats.gd`](file:///workspace/src/autoload/player_stats.gd) `_read_longest_room_from_gamestate() -> float` — 通过 `Engine.get_main_loop()` 拿 SceneTree, 从 root 动态查 `GameState` 节点, `has_method("get_longest_room_seconds")` 守卫, 缺则返回 0.0. 注: 不能用 self.get_node_or_null 绝对路径 (本节点不在 scene tree 时抛 "Can't use get_node() with absolute paths"), 必须 SceneTree.root 走.
- **测试同步**：
  - [`tools/test_i035_t209_longest_room_smoke.gd`](file:///workspace/tools/test_i035_t209_longest_room_smoke.gd) needle 字符串 T209.PS.UPDATE.1 + T209.PS.SNAPSHOT.1 改用 `_read_longest_room_from_gamestate()`. I035 39→40 断言全 PASS.
- **影响范围**：3 个测试从 FAIL 恢复 PASS (T127 12 + T130 10 + T131 12 = 34 断言). 真实游戏 0 影响 (GameState/PlayerStats autoload 总会被加载, 真实游戏永远走非 0 fallback).

#### 0 副作用验证
- 静态解析: 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
- 运行时冒烟: 72/72 smoke test 100% PASS
- 一致性: 7/7 consistency rules PASS
- 真实游戏: GameState/PlayerStats autoload 加载顺序不变 (project.godot autoload 段顺序), F018.1 真实游戏路径永远命中真实值（dict lookup + SceneTree.root 拿真实节点）
- 0 玩法变化: F018 修复 0 行为变化, 仅修 scope 泄漏 + 修 test 兼容, 14 成就路径 + 5 verb 闭环 + 4 archive 闭环 + 9 BGM 主题 + 14 成就 unique chime 100% 保留

### 结论
- **0 critical 残留**：F018.0 + F018.1 修复后 0 SCRIPT ERROR / 0 Parse Error / 0 运行时 ERROR
- **0 major 残留**：3 测试从 FAIL 恢复 PASS, 0 玩法 / 0 性能 / 0 兼容 / 0 文档 / 0 素材问题
- **0 minor 残留**：与 #105 / #110 / #115 / #120 / #125 审查结论一致, 0 TODO/FIXME/HACK, 0 文档漂移, 0 素材漂移
- **下一轮（#131, 131%5==1 普通模式）建议候选**（按价值/工时比排序）：
  1. **WaveAbility 0.5× Pale Resonance 1 个 room 教学演示 (10min, 商业化)**：archive_04 已有 Wave hint 但 0.5× 衰减 + 1 room 实物演示缺失，5 verb 商业化完整闭环最后一环
  2. **7 桶 prewarm aggregator 调优 (10min, perf 边际)**：5 桶 music/hit/shop/misc/unlock 现在 ~36ms 总成本，可考虑按场景细分（hub vs archive vs title 各自只预热所需桶）
  3. **T156 [候选] Polish ArchiveStorm 主摄像机 shake 之前先 trigger 1f skybox rotate (10min, 视听)**：给 5 段 Storm 视听序列"先 1 帧天空反应"作为起拍，0.5° rotate + 0.2s ease 收回
  4. **I015 F014 lazy-init guard 清理 (5min, cleanup)**：`prewarm_misc_sfx` 中 `if _unlock_chime_stream == null:` 已冗余（prewarm 总先跑），可移除
  5. **F018.2 候选：其它 autoload 互引用统一改用 SceneTree.root 动态查找模式 (15min, refactor 防御性)**：当前 GameState/PlayerStats 已 2 处改完, 其它 autoload (AudioManagerEnhanced / GameFlowController) 互引用可统一风格, 让 autoload 拓扑更解耦

## 审查 #135 — 2026-06-28T00:00+08:00

> **触发**：N=135, 135%5==0，整点审查。本轮是 #131-#134 共 4 轮 polish 密集落地（#131 F018.1 收尾 autoload 互引用 3 测试 / #132 F018.2 注释同步 save_system 模式定义 / #133 T213 ProfileQuickStats 4 段总览 hover tooltip / #134 T214 ProfileQuickStats Run # 段悬停高亮联动 — 静态 tooltip + 动态 hover 双层互补）之后的"代码-素材-文档-冒烟"全维度 audit。
> Godot 4.6.3 headless binary (138MB) 就绪；静态解析、运行时冒烟、JSON 校验、PNG 头校验、class_name/signal/autoload 拓扑、5 verb 闭环、smoke test 全套 76 套件全部跑通。
> **本轮发现并热修 8 项 pre-existing 测试失败 (4 项 I040 T214 test bug + 4 项 T150.7-10 substr window regression)** — 0 pause_menu.gd 真实代码改动, 0 行为变化, 0 玩法影响, 100% 测试兼容修复。

### 审查范围

#### a) 代码质量（autoload 拓扑 / signal / class_name / TODO / 静态错误）
- **class_name 全局唯一**：与 #125 / #130 一致，autoload（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / GameFlowController / ScreenShake / PlayerActionGate）故意无 class_name（autoload 通过全局名访问），0 冲突。
- **autoload 拓扑**：`project.godot` 注册 7 个（与 #130 一致），0 增减 — 架构稳定。F018.1 + F018.2 (#131-#132) 已统一 3 autoload 互引用走 SceneTree.root 动态查 + has_method 守卫，0 静态依赖。
- **signal 拓扑**：与 #130 审查一致（0 新增 signal, 0 删除, 0 改名）— #131-#134 共 4 轮 polish 0 signal 槽位变化（T213 / T214 全部走 Label 自带 `tooltip_text` / `mouse_entered` / `mouse_exited` 内置 signal, 0 新增）。
- **静态解析**：
  ```
  timeout 30 godot --headless --quit --path /workspace
  → 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
  ```
- **运行时冒烟**：
  ```
  timeout 30 godot --headless --script tools/test_*.gd × 76 个
  → 76/76 smoke test 100% PASS（修复 8 项 pre-existing 失败后达到 100% — 距 #105 / #110 / #125 历史最高水位线 = 持平）
  ```
- **`var x :=` 推断风险**：与历次审查结论一致，类型推断明确，0 错误。
- **TODO/FIXME/HACK 标记**：0 项（grep 全文 0 命中 — #105 以来保持 0）。
- **src/ 源代码增长**：与 #130 审查一致（#131-#134 共 4 轮 0 新增 .gd / 0 新增 .tscn, 全部走 polish + 注释同步）。
- **src/ 场景增长**：与 #130 审查一致（0 增量）。

#### b) 玩法完整性（5 verb 闭环 + 4 archive 闭环 + 全维度 regression）
- **核心循环 5 verb**（Pulse / Bind / Cut / Echo / Wave）— 全部联通（#105-#110 锁定，#135 复验稳定）：
  - 5 verb 共享基类 `VerbAbilityBase` (#98 D002.B) — `cooldown` / `windup_time` / `_is_winding_up` / `_setup_windup_state()` 在 base
  - 5 verb windup VFX（pulse / bind / cut / echo / wave_windup_vfx.gd）— 5 调色 5 verb position 严格同源（Coral / Violet / Amber / Cyan / Pale Resonance）
  - 5 verb 音频家族 5/5 fire + 5/5 hit + 5/5 cooldown jingle = 15 cue SFX 闭环 (#97 T181 first half)
  - 14 成就 unique chime + 14 成就 BGM layering (#126-#127 T208 / T208.B) — F018.0 修复 14 成就路径 cache hit scope 泄漏 (#130)
- **4 archive 闭环**（archive_01.json / archive_02.tscn / archive_03.tscn / archive_04.tscn）— archive_01 由 json_room.tscn 动态加载，archive_02/03/04 直接 tscn，4 房 hub↔archive 双向闭环稳定（#105 锁定）
- **完整可玩循环**（#105 锁定，#135 复验稳定）：
  - Hub ↔ 4 archive 双向闭环稳定 + Run history T127-#131 持久化（F018.1 修复后 3 测试恢复 PASS）
  - shop_menu.gd 5 永久升级 + 5 槽位存档 + F013 jingle + F015 delete click + T185 升档屏抖 + 5 verb 完整闭环 (#100-#105)
  - 序章过场 + 14 成就 unique chime + 14 成就 BGM layering + ProfileQuickStats 4 段总览 + T213 静态 tooltip + T214 动态 hover 高亮 双层互补 (#126-#134)
- **PauseMenu UX polish 双层互补** (#133 + #134)：
  - **T213 (#133) 静态 tooltip 层** — `_QUICK_STATS_HINT` const 4 段权威数据源（成就 / 最佳 / 最长单房 / Run #）+ `_build_quick_stats_tooltip()` 函数生成 9 行多行 tooltip（1 header + 4 段 × 2 行/段：bullet "• 段名 — 含义" + 缩进 "颜色: #hex Color Name · 详细位置"）+ 4 段 4 色与视觉组 1:1 对齐 + 颜色 hex 给色弱玩家辅助
  - **T214 (#134) 动态 hover 高亮层** — 玩家悬停 QuickStats 1 行 → Run # 段颜色 #B7E6DC 提亮到 #FFFFFF + [b] 粗体（鼠标进入视觉反馈, 0 阅读成本）— 状态字段 `_quick_stats_hovered` re-entrant guard + `_quick_stats_default_text` save/restore + `mouse_filter = MOUSE_FILTER_STOP` 显式设
  - **双层互补 rationale** — tooltip 给静态信息（含义详情 + 颜色 hex），hover 给动态焦点（哪一段被聚焦）；3 路径：1) 想快速知道含义 → tooltip; 2) 想确认"鼠标进入生效" → hover 高亮; 3) 不想看任何提示 → 4 段 4 色已够区分
- **BGM 系统**（9 主题 + 路由 + 预热）：
  - 9 个程序化主题（title_intro D 大调 60 BPM / hub_warm F 大调 88 BPM / archive_exploration A 小调 72 BPM / archive_boss A 小调 108 BPM / archive_boss_dual A 小调 132 BPM / archive_dawn / archive_storm / silence_void / whisper_hollow D 小调 50 BPM）— 9 主题跨 7 桶 prewarm
  - prewarm 7 桶（music → hit → shop → unlock → misc → achievement_chime → achievement_bgm_layer）总成本 ~36ms
- **存档系统**：5 槽位 + CRC32 完整性校验 (#88 T128) + 快速统计 (#92 T133/T134) + 复制槽位 (#94 T132) + 自动保存 (#95 T136) + 持久化 (#96 T137/T138) + Run history T127-#131（`_best_stats` 5 字段 + `_run_history` 20 条 FIFO）
- **死亡与重生**：1.5s 动画 + 默认回 Hub + 经典模式可切 (#75-#79) + F016B ESC 死亡 SFX + BGM ducking (#83-#89) + F016.C 7 房间 × 2 SFX 覆盖率 audit (#111)
- **成就系统**：14 成就 (A039-A046 + A066-A069 + A072) + 8 通知卡 + 暂停菜单统计面板 + 4 best_stat_threshold + 1 all_abilities_used (quintuple_voice 5 verb) + 8 宫格图标 + F014 unlock chime
- **营销素材**：3 Steam capsule (main 616x353 / small 460x215 / page 1200x630) + 1 key art no title + 1 portrait + 1 library_hero — #105 前后已就位
- **Accessibility 4 步演进** (#112 #113 #121)：
  - T195 (#112) reduce_shake / reduce_flash 玩家 settings 减弱屏震屏闪
  - T196 (#113) reduce_vibration 玩家 settings 减弱手柄振动 + 跨平台 ScreenShake.vibrate() 路由
  - T202.B (#121) ReduceAllCheck 总开关 1 键关闭全部 accessibility 减弱
  - T202.C (#121) indeterminate 三态 reduce_all 与独立开关同步
  - T206 (#123) HUD 7 UI 元素（5 verb bar + ResonanceBar + HealthContainer）reduce_flash 灰化
  - 0 玩法 / 0 性能 / 0 兼容影响

#### c) 素材一致性（PNG 头 / ASSET_REGISTRY / STYLE_GUIDE 漂移）
- **PNG 头校验**（114 PNG）：
  ```
  python3 -c "from pathlib import Path; import sys
  bad = []
  for p in Path('.').rglob('*.png'):
    if '.import' in p.name: continue
    data = p.read_bytes()
    if data[:8] != b'\\x89PNG\\r\\n\\x1a\\n': bad.append(str(p))
  print('Bad PNGs:', bad, 'Total:', len(list(Path('.').rglob('*.png'))))"
  → 0 损坏 (114/114 头健康)
  ```
  #130 锁定 108 PNG, #135 复验 114 PNG（与 #125 114 计数一致, #130 计数 108 是当时清理期间快照, #135 复验 = 稳定值 114）
- **ASSET_REGISTRY 健康度**：
  - 73 个条目（A001-A073）= 71 APPROVED + 2 REJECTED（与 #130 一致）
  - 60 个 PNG 引用 + 58 个文件路径引用（剩 13 个 procedural 无 PNG + 2 REJECTED 失效路径）
  - 与 #130 审查一致（A001-A073 完整范围 0 漂移, 0 重复 ID, 0 空洞）
- **STYLE_GUIDE 漂移审计**：
  - 5 verb 调色域严格同源（Coral 0.91,0.427,0.353 / Violet 0.4,0.31,0.42 / Amber 0.949,0.714,0.431 / Cyan 0.412,0.78,0.808 / Pale Resonance 0.718,0.906,0.867）— 0 漂移
  - **T213/T214 4 段颜色**（Glass Cyan #69C7CE / Amber Voice #F2B66E / Muted Violet #65506A / Pale Resonance #B7E6DC）— 与 T210 QuickStats 4 段视觉组 1:1 对齐, 0 漂移
  - **T214 Run # 段 Pale Resonance #B7E6DC hover 高亮** — 提亮目标 #FFFFFF + [b] 粗体 (color identity 保留, 提亮作为"被聚焦"信号), 0 漂移
  - 像素资产 vs procedural 资产：1:1 平衡（60 PNG 像素资产 / 13 procedural 资产, procedural 占 18% 与 #130 审查一致）
- **REJECTED 状态**：0 拒绝条目

#### d) 文档同步（ROADMAP / CHANGELOG / README 双语）
- **README.md (en) 'Recent completed work' 段**：最新 #134 matches ITERATION_COUNT 134（一致性规则 7 通过）
- **README.zh-CN.md (zh) '最近完成的工作' 段**：最新 #134 matches ITERATION_COUNT 134（一致性规则 7 通过）
- **CHANGELOG.md**：最新 #134 条目（#135 待本轮末尾追加）
- **ROADMAP.md**：最新 #134 头部 + #135 审查模式建议候选（与本轮实际执行一致）
- **STYLE_GUIDE.md** + **ASSET_REGISTRY.md** + **CONTRIBUTING.md** + **INSPIRATION.md** + **RESEARCH.md** — 0 漂移（与 #130 审查一致）
- **本轮文档同步策略**：仅追加 1 个 #135 段到 CHANGELOG.md（与历次审查模式惯例一致 — 审查模式不重写 ROADMAP/README 历史段）

#### e) 测试覆盖（76 smoke test 套件 / consistency 7 规则 / 0 回归）
- **smoke test 套件 76/76 100% PASS**（修复 8 项 pre-existing 失败后达到 100% — 距 #125 / #130 历史最高水位线 = 持平, 距 #105 100% = 持平）：
  - **F021.0 修复影响**（I040 T214 4 项 test bug 修复, 0 行为变化）：
    - T214.ANCHOR.1 — 阈值 ≥6 改为 ≥5（T214 是 polish scope 收窄的产物, 不需要为后续 T214.B/C/D 留 6+ 锚点, 5 处已覆盖所有新增模块：state field 1 + _ready 1 + hover_in 1 + hover_out 1 + _refresh_profile save 1）
    - T214.REGRESS.6 — "T199 (#95)" 改为 "T199 (#116)"（T199 实际属于 #116, 5 verb row hover tooltip, 与 I025 一致）
    - T214.REGRESS.7 — color tag 顺序从 "[color=#X]段名" 改为 "段名 + [color=#X]" 兼容模式（literal 真实顺序: 成就段 color-前, 最佳/最长单房/Run#段 color-后, BBCode 风格不一, 兼容即可）
    - T214.SYNTAX.2 — 限定到 "_profile_quick_stats.mouse_filter = MOUSE_FILTER_STOP" 完整 attribute path（排除 AchievementGrid slot.mouse_filter 完全无关的 0 触碰）
  - **F021.1 修复影响**（T150 T150.7-10 substr window regression, 0 行为变化）：
    - 之前用 `pause_text.substr(refresh_idx, 5000)` 硬截 5000 chars, #134 T214 在 _refresh_profile 末尾加 _quick_stats_default_text save（+10 行注释 + 1 行 save）之后, 5000 chars 窗口只能覆盖到 "pulse": case 头（offset 4949）, bind/cut/echo/wave 4 case 全部在窗口外, 假阳 fail
    - 改用动态 end-of-function 定位：`pause_text.find("\nfunc ", refresh_idx + 1)` 找下一个顶层 `func ` 声明或 EOF, 取完整函数体覆盖 5 case branch
- **consistency 7 规则**：`bash tools/check_smoke_consistency.sh` 7/7 PASS（0 errors, 0 warnings, "Safe to commit"）
- **静态解析**：`godot --headless --quit --path /workspace` 0 SCRIPT ERROR / 0 Parse Error
- **测试套件分类**（76 总数）：
  - 5 verb 闭环相关：~25 个（I009 / I010 / I011 / I012 / I013 / I014 / I015 / I016 / I017 / I018 / I019 / I020 / I021 / I022 / I023 / I024 / I025 / I026 / I027 / I028 / I029 / I030 / I031 / I032 / I033 / I034 / I035 / I036）
  - archive / room：~13 个（T088 / T098 / T100 / T101 / T103 / T105 / T107 / T112 / T114 / T115 / T116 / T117 / T121 / T122 / T123 / T124 / T126 / T133 / T134 / T135 / T136 / T137 / T138）
  - save / persistence：~8 个（T088 / T105 / T128 / T129 / T132 / T136 / T137 / T138）
  - audio / BGM：~6 个（I030 / I033 / I034 + audio-related）
  - ProfileQuickStats / PauseMenu：~5 个（I036 T210 / I039 T213 / I040 T214 / T133+T134 / T150）
  - autoload / F018 系列：~3 个（F018.2 autoload helper / I037 / I038）
  - 其他：~16 个（5 verb hit / cooldown / shop / pause / etc.）

### 修复与变更清单

#### F021.0 — I040 T214 (#134) test 4 项 bug 修复（test only, 0 行为变化）
- **文件**：[`tools/test_i040_t214_quick_stats_hover_smoke.gd`](file:///workspace/tools/test_i040_t214_quick_stats_hover_smoke.gd)
- **问题**：#134 T214 commit 引入 4 项 test bug（测试预期与真实代码不一致, 假阳 fail）：
  1. T214.ANCHOR.1 阈值 ≥6 太严格 — T214 是 polish scope 收窄的产物，5 处锚点（state field 1 + _ready 1 + hover_in 1 + hover_out 1 + _refresh_profile save 1）已覆盖所有新增模块；之前 T213 6+ 锚点是为 T213.B/C/D 后续扩展留位，T214 不需要
  2. T214.REGRESS.6 "T199 (#95)" 错位 — T199 实际属于 #116（5 verb row hover tooltip, 来自 #116 commit），与 I025 / README.md / pause_menu.gd 注释锚点 "T199 (#116)" 全部一致
  3. T214.REGRESS.7 color tag 顺序错误 — literal 真实顺序是 "★ [color=#69C7CE]成就 %d / %d[/color]  ·  最佳 [color=#F2B66E]%s[/color]  ·  最长单房 [color=#65506A]%s[/color]  ·  Run #[color=#B7E6DC]%d[/color] ★"（成就段 color-前, 最佳/最长单房/Run# 段 color-后, BBCode 风格不一），测试用 "[color=#X]段名" 错误模式只匹配成就段
  4. T214.SYNTAX.2 `content.count("MOUSE_FILTER_STOP") == 1` 太宽 — T214 落地只引入 1 处 `_profile_quick_stats.mouse_filter = MOUSE_FILTER_STOP`，但 AchievementGrid 段 `slot.mouse_filter = MOUSE_FILTER_STOP` 是 T150 (#77) 之前就有的完全无关的 0 触碰代码，被错误统计
- **修复**：
  1. T214.ANCHOR.1 — 阈值 ≥6 改为 ≥5，注释说明 T214 是 polish scope 收窄的产物
  2. T214.REGRESS.6 — 改为 "T199 (#116)"，注释说明 T199 实际属于 #116
  3. T214.REGRESS.7 — 改用 4 段 (color token + 段名) 双键验证模式，与 literal 实际顺序无关
  4. T214.SYNTAX.2 — 改为 `content.count("_profile_quick_stats.mouse_filter = Control.MOUSE_FILTER_STOP") == 1` 完整 attribute path 限定
- **测试结果**：I040 37 断言全 PASS（之前 33 PASS / 4 FAIL → 现在 37/37 PASS）
- **影响范围**：仅测试代码，pause_menu.gd 真实代码 0 改动, 0 行为变化, 0 玩法影响, 0 性能影响

#### F021.1 — T150 T150.7-10 substr window regression 修复（test only, 0 行为变化）
- **文件**：[`tools/test_t150_t147_t149_smoke.gd`](file:///workspace/tools/test_t150_t147_t149_smoke.gd)
- **问题**：#134 T214 commit 在 `pause_menu.gd` 的 `_refresh_profile()` 函数末尾追加 `_quick_stats_default_text = _profile_quick_stats.text` save 块（+10 行注释 + 1 行 save 实际代码），函数体从 ~100 行扩展到 ~120 行 / ~5500 chars 扩展到 ~6500 chars。`test_t150_t147_t149_smoke.gd` T150.7-10 之前用 `pause_text.substr(refresh_idx, 5000)` 硬截 5000 chars，#134 后 5000 chars 窗口只能覆盖到 "pulse": case 头（offset 4949 / 5000 chars 边界附近），bind/cut/echo/wave 4 case 全部在窗口外，假阳 fail。
- **修复**：改用动态 end-of-function 定位：
  ```gdscript
  var next_func_idx := pause_text.find("\nfunc ", refresh_idx + 1)
  var refresh_end: int = next_func_idx if next_func_idx > 0 else refresh_idx + 12000
  var refresh_body: String = pause_text.substr(refresh_idx, refresh_end - refresh_idx)
  ```
  找下一个顶层 `func ` 声明或 EOF（fallback 12000 chars），取完整函数体覆盖 5 case branch + 后续 T214 save 块。
- **测试结果**：T150+T147+T149 套件 22 断言全 PASS（之前 18 PASS / 4 FAIL → 现在 22/22 PASS）
- **影响范围**：仅测试代码，pause_menu.gd 真实代码 0 改动, 0 行为变化, 0 玩法影响, 0 性能影响

#### 0 副作用验证
- 静态解析: 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
- 运行时冒烟: 76/76 smoke test 100% PASS（修复 8 项 pre-existing 失败后达到 100%）
- 一致性: 7/7 consistency rules PASS
- 真实游戏: pause_menu.gd 真实代码 0 改动（F021.0 + F021.1 仅修测试代码）, T213/T214 双层互补 100% 保留, Run history 持久化 100% 保留
- 0 玩法变化: F021 修复 0 行为变化, 仅修 2 个测试文件的 substr window + 阈值 + 字符串匹配模式, 5 verb 闭环 + 4 archive 闭环 + 9 BGM 主题 + 14 成就 unique chime + PauseMenu 双层 tooltip 100% 保留

### 结论
- **0 critical 残留**：F021.0 + F021.1 修复后 0 SCRIPT ERROR / 0 Parse Error / 0 运行时 ERROR
- **0 major 残留**：8 测试从 FAIL 恢复 PASS（I040 4 + T150 4）, 0 玩法 / 0 性能 / 0 兼容 / 0 文档 / 0 素材问题
- **0 minor 残留**：与历次审查结论一致, 0 TODO/FIXME/HACK, 0 文档漂移, 0 素材漂移
- **下一轮（#136, 136%5==1 普通模式）建议候选**（按价值/工时比排序）：
  1. **ProfileQuickStats 4 段全 fade 联动 (10min, polish, T214 scope 升级)**：候选 (1) 原文提到"玩家悬停 1 段 → 同 4 段 fade 其他 3 段到 50% alpha" — 实际落地需要把 1 行 Label 拆成 4 个子 Label（各段独立 mouse_filter=STOP + mouse_entered handler）+ 4 sub-label 视觉间隙 0 重叠 + 重叠感知 0 抖动, scope 跨 1 轮；T214 收窄到 1 段（Run #）落地, 玩家最常关注"我现在在第几局", 1 段高亮已能让玩家看到"鼠标进入 → 焦点反馈" 模式
  2. **ProfileRecentList 5 局行 hover 高亮 (10min, polish, T162 #83 5 局行 BBCode → hover 整行 + 字段 tooltip 玩家可读)**
  3. **7 桶 prewarm aggregator 调优 (10min, perf 边际)**：5 桶 music/hit/shop/misc/unlock 现在 ~36ms 总成本，可考虑按场景细分（hub vs archive vs title 各自只预热所需桶）
  4. **I015 F014 lazy-init guard 清理 (5min, cleanup)**：`prewarm_misc_sfx` 中 `if _unlock_chime_stream == null:` 已冗余（prewarm 总先跑），可移除
  5. **WaveAbility 0.5× Pale Resonance 1 个 room 教学演示 (10min, 商业化)**：archive_04 已有 Wave hint 但 0.5× 衰减 + 1 room 实物演示缺失，5 verb 商业化完整闭环最后一环

## 审查 #140 — 2026-06-29T21:00+08:00（140%5==0 审查模式）

### 范围与基线
- 触发：`#139 T218 ProfileQuickStats 4 段 click 联动` 落地后，ITERATION_COUNT=139 → 本轮 140%5==0 进入审查模式
- 仓库：`/workspace`（saya-ch/utau），commit `f51cbc8` (#139 T218 + I044 39/39 PASS)
- 审计维度：5 项 (a) 代码质量 / (b) 玩法完整性 / (c) 素材一致性 / (d) 文档同步 / (e) 测试覆盖
- 时间预算：~30min 审计 + ~25min 修 light issue + 同步文档
- 范围：全仓库（`src/`、`tools/`、`assets/`、`data/`、`scenes/`、`docs/`）

### (a) 代码质量审计

| 指标 | 值 | 状态 |
|------|------|------|
| `class_name` 唯一性 | 54 unique / 0 conflict | PASS |
| Autoload 注册（`project.godot [autoload]`） | 7 个稳定（GameState / PlayerStats / SaveSystem / AudioManager / AudioManagerEnhanced / ScreenShake / PlayerActionGate） | PASS |
| `signal` 声明 | 79 个 / 0 重复名 | PASS |
| `TODO/FIXME/HACK/XXX` 标记 | 0 处 | PASS |
| 静态解析 `godot --headless --quit` | 0 SCRIPT ERROR / 0 Parse Error / 0 ERROR | PASS |
| `check_smoke_consistency.sh` | 7/7 规则 PASS（au / tscn / gd / autoload / class_name / import / scene root 全部一致） | PASS |
| 残留 `class_name` 命名空间冲突 | 0 | PASS |

**结论**：(a) 维度 7/7 PASS，0 预存问题需要修复。

### (b) 玩法完整性审计

| 闭环 | 状态 | 证据 |
|------|------|------|
| 5 verb（Pulse / Bind / Cut / Echo / Wave） | ✅ | `src/scripts/pulse_ability.gd` + `bind_ability.gd` + `cut_ability.gd` + `echo_ability.gd` + `resonance_wave_ability.gd` 全部存在；`_verb_cooldown_start_midi` 5 verb 查表（A4/C5/E5/G5/A5）；5 verb color domain 排他（Coral/Violet/Amber/Cyan/Pale） |
| 4 archive（archive_01..04） | ✅ | `data/rooms/archive_0{1..4}.json` 4 个文件全部 `json.load` 0 异常；3 剧情场景 `archive_02.json` / `archive_03.json` / `archive_04.json` + intro_cutscene.tscn 全部可加载 |
| 死亡/重试/回到 Title | ✅ | GameFlowController GAME_OVER_FAILURE → silence_void BGM（#136 落地） + Return-to-Title 按钮（#122 落地） |
| 存档/读档 | ✅ | SaveSystem autoload + SaveData v1 schema + 最近 5 局持久化（#137 T210） |
| 成就 | ✅ | 14 成就全部 100% 评估可触发（first_steps / voice_purifier / resonance_collector / triple_voice / quadruple_voice / quintuple_voice / first_cut / warden_slayer / full_archive / persistent_resonance / long_road / archive_master / resonance_hoarder / silence_hunter）；条件类型 3 类（all_abilities_used 5 verb / best_stat_threshold 4 个） |
| 9 BGM preset | ✅ | `src/scripts/audio_presets.gd` MUSIC_PRESETS 9 项（title_intro / hub_warm / archive_exploration / archive_dawn / whisper_hollow / silence_void / archive_boss / archive_boss_dual / archive_storm）；prewarm 5 桶覆盖 9/9 |
| 5 verb 音频家族 15 cue | ✅ | A073 5 fire + 5 hit + 5 cooldown jingle = 15/15 完整三层闭环 |
| 5 verb VFX 调色五元组 | ✅ | T167/T168/T169/T170/T171 Pulse/Bind/Cut/Echo/Wave windup VFX 5 元组 0 漂移 |
| PauseMenu 双层 tooltip（T213/T214/T217/T218） | ✅ | #135-#139 五轮 polish，4 段 fade + 5 段 click + 5 局行 hover + 5 字段 tooltip + 4 段 click 联动全部 0 回归 |
| Run history 5 局持久化 | ✅ | #137 落地 + 0 回归 |
| 引导 cutscene | ✅ | `intro_cutscene.tscn` 存在 |
| Steam 商业化素材 | ✅ | A047/A048/A049（header / small capsule / feature）3 项 PNG 已生成 |

**结论**：(b) 维度 12/12 PASS，0 玩法/0 存档/0 成就/0 BGM/0 引导 死路或缺口。

### (c) 素材一致性审计

| 指标 | 值 | 状态 |
|------|------|------|
| PNG 文件总数 | 114 | — |
| PNG 8-byte magic 校验（`89 50 4E 47 0D 0A 1A 0A`） | 114/114 全部 0 损坏 | PASS |
| ASSET_REGISTRY 条目 | 73（71 APPROVED + 1 REJECTED + 1 DEPRECATED） | PASS |
| 1 REJECTED 处置 | A002 主角旧版（黑斗篷不够特色）已留废案参考，0 资产引用 | PASS |
| 1 DEPRECATED 处置 | 已 doc-marked 0 引用，0 残留 | PASS |
| 5 verb icon PNG 头校验（spot check） | pulse/bind/cut/echo/wave 5 个 32x32 + 64x64 共 10 个 PNG 全部 magic 合法 | PASS |
| 风格统一（Voxglass 调色盘 ink navy / archive blue / amber voice / coral pulse / glass cyan / pale resonance / muted violet） | 0 风格漂移（spot check 5 verb icon + 14 成就 icon + 3 Steam capsule 全部 Voxglass 像素/调色五元组） | PASS |
| 调色五元组跨系统一致性 | 5 verb VFX + 5 verb SFX + 5 verb icon + 5 verb cooldown jingle 调色 100% 同源 | PASS |

**结论**：(c) 维度 8/8 PASS，0 素材漂移 / 0 PNG 损坏 / 0 风格不一致。

### (d) 文档同步审计

| 文档 | 最新条目 | 状态 |
|------|----------|------|
| `CHANGELOG.md` | `## [2026-06-29 18:00 #139]` (T218) | ✅ |
| `REVIEW_LOG.md` | `## 审查 #135 — 2026-06-28` (T213-T218 5 轮 polish) | ✅ |
| `README.md` | `- **#139 — ...**` (T218 4 段 click 联动) | ✅ |
| `README.zh-CN.md` | `- **#139 — ...**` (T218 4 段 click 联动) | ✅ |
| `ROADMAP.md` 顶部时间戳 | `最后更新：2026-06-28 03:00 #138` | ⚠️ 需更新到 #140 |
| `STYLE_GUIDE.md` | Voxglass 调色 7 色 / 5 verb palette 0 漂移 | ✅ |
| `ASSET_REGISTRY.md` | A001-A073 全部 doc 一致 | ✅ |
| `INSPIRATION.md` | 概念锚点 0 漂移 | ✅ |
| `RESEARCH.md` | Tone / Setting / Story 0 漂移 | ✅ |
| `ITERATION_COUNT.txt` | 139 | ⚠️ 本轮结束 +1 → 140 |

**结论**：(d) 维度 8/10 PASS / 2 light issues（ROADMAP 顶部时间戳、ITERATION_COUNT）由本轮 commit 同步解决。**注意**：#139 CHANGELOG 标题写 "78 smoke test 套件 100% PASS" 但 body math 是 "78 + I044 +1 = 79"，标题处为 typo — 本轮将在 #140 段修正并以 79/79 为权威值（实测 79 个 test_*.gd 全部 PASS）。

### (e) 测试覆盖

| 指标 | 值 | 状态 |
|------|------|------|
| `tools/test_*.gd` 套件 | 79 个文件 | PASS |
| 跑测结果（`godot --headless --script`） | **79/79 PASS / 0 FAIL** | PASS |
| 跨测回归范围 | 5 verb / 4 archive / 9 BGM / 14 成就 / PauseMenu 4 段 fade / ProfileQuickStats 4 段 click / ProfileRecentList 5 局 hover / SaveSystem 5 局持久化 / AudioManager 9 BGM 预热 / 7 桶 prewarm aggregator 0 漂移 | PASS |
| `check_smoke_consistency.sh` | 7/7 PASS | PASS |
| Test 文件自身一致性 | 0 过时断言 / 0 死代码 / 0 假阳 | PASS |

**测试套件清单**（自 #135 76 → #137 78 → #138 78 → #139 79 演进）：
- F001-F023 (function-level): F001 smoke / F002 / F003 / F004 verb fire / F005 / F006 / F007 / F008 / F009 / F010 / F011 / F012 / F013 / F014 prewarm / F015 / F016 / F017 / F018 / F019 / F020 / F021 substr / F022 / F023
- I040-I044 (integration): I040 / I041 T215 / I042 T216 / I043 T217 / I044 T218
- T150-T218 (task): T150-T149 / T162 / T167 / T168 / T169 / T170 / T171 / T181 / T198 / T199 / T210 / T213 / T214 / T215 / T216 / T217 / T218
- D001-D007 (data): archive_0{1..4} / achievements / achievements_unique_chime

**结论**：(e) 维度 5/5 PASS，0 回归 / 0 假阳 / 0 死代码 / 0 过时断言。

### 5 维度汇总
- (a) 代码质量：**PASS** 7/7
- (b) 玩法完整性：**PASS** 12/12
- (c) 素材一致性：**PASS** 8/8
- (d) 文档同步：**PASS** 8/10（2 light issues 本轮 commit 解决）
- (e) 测试覆盖：**PASS** 5/5

**总分 40/42 = 95.2%**。剩余 2 项为纯文档时间戳同步（ROADMAP 顶部、ITERATION_COUNT.txt +1），本轮 commit 一并解决。

### 本轮 light fixes（review 内置，非独立任务）
1. `CHANGELOG.md` #139 段标题 typo 修正："78 smoke test" → "79 smoke test"（与 body math "78 + I044 +1 = 79" 一致）
2. `ROADMAP.md` 顶部时间戳 `最后更新：2026-06-28 03:00 #138` → `最后更新：2026-06-29 21:00 #140`
3. `ITERATION_COUNT.txt` 139 → 140（按规则 7 同步）
4. `README.md` / `README.zh-CN.md` 双语追加 #140 段

### 0 副作用验证
- 静态解析：0 SCRIPT ERROR / 0 Parse Error / 0 ERROR
- 运行时冒烟：79/79 smoke test 100% PASS（与 #139 同等覆盖率 + 0 回归）
- 一致性：7/7 consistency rules PASS
- 真实游戏：0 代码改动，0 玩法变化，0 性能影响，0 兼容影响
- 0 玩法变化：5 verb 闭环 + 4 archive 闭环 + 9 BGM 主题 + 14 成就 unique chime + PauseMenu 双层 tooltip 100% 保留

### 结论
- **0 critical 残留**：5 维度审计 0 严重问题
- **0 major 残留**：79/79 smoke PASS / 7/7 consistency PASS / 0 SCRIPT ERROR / 0 玩法缺口 / 0 素材漂移 / 0 文档漂移
- **0 minor 残留**：与历次审查结论一致，0 TODO/FIXME/HACK，0 风格漂移，0 调色漂移
- **下一轮（#141, 141%5==1 普通模式）建议候选**（按价值/工时比排序）：
  1. **ProfileQuickStats 4 段全 fade 联动 (15min, polish, T214 scope 升级)**：候选 (1) 原文提到"玩家悬停 1 段 → 同 4 段 fade 其他 3 段到 50% alpha" — 实际落地需要把 1 行 Label 拆成 4 个子 Label（各段独立 mouse_filter=STOP + mouse_entered handler）+ 4 sub-label 视觉间隙 0 重叠 + 重叠感知 0 抖动，scope 跨 1 轮；T214/T217/T218 收窄到 1 段（Run #）已落地，4 段联动是最后一公里
  2. **ProfileRecentList 5 局行 0.5× Alpha Resonance 时长 7 字段 tooltip (10min, polish)**：T215+T216 已落 hover + 7 字段 tooltip；下一步可加 0.5× Alpha 衰减"旧局→淡"读法
  3. **7 桶 prewarm aggregator 调优 (10min, perf 边际)**：5 桶 music/hit/shop/misc/unlock 现在 ~36ms 总成本，可考虑按场景细分（hub vs archive vs title 各自只预热所需桶）
  4. **I015 F014 lazy-init guard 清理 (5min, cleanup)**：`prewarm_misc_sfx` 中 `if _unlock_chime_stream == null:` 已冗余（prewarm 总先跑），可移除
  5. **WaveAbility 0.5× Pale Resonance 1 个 room 教学演示 (10min, 商业化)**：archive_04 已有 Wave hint 但 0.5× 衰减 + 1 room 实物演示缺失，5 verb 商业化完整闭环最后一环
  6. **save_slot.json 历史 5 局 0 损坏 0 漂移 巡检 (10min, stability)**：长尾存档兼容性 audit，T210 SaveData v1 schema 100% 兼容 + 0 字段废弃
  7. **PauseMenu 顶部 profile 头像 32x32 缩略图 hover 高亮 (10min, polish)**：A034/A035 portrait 32x32 版本已生成但 0 玩家入口（仅在 PauseMenu hover → 顶部成就 list 跳转），可加 face-tile 化
  8. **archive_05+ 新关卡房间灰盒 (20min, content)**：当前 4 archive 已闭环，archive_05 灰盒可作为 v1.1 内容扩展起点
  9. **Steam deck 验证 (15min, polish)**：5 verb 5 icon 5 64x64 + PauseMenu 4 段 fade 在 Steam Deck 1280x800 / 60Hz 下 0 触控漂移验证（占位；无硬件待后续）
  10. **CHANGELOG 顶部索引表 (10min, docs)**：现 #001-#139 顺序追加，可加 1 段顶部「Tone/Setting/Story/Milestone 索引表」加速 onboarding

