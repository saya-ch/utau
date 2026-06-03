# Roadmap

## 当前方向

工作标题：**Voxglass**

目标：做一款可下载的 2D 独立游戏竖切，不做 Web 小游戏。首个里程碑是一个能在 60 秒内展示「进入房间 -> Pulse 声波反制 -> 修复玻璃声匣 -> 开门」的可玩原型。

## 任务队列

- [x] T001 Code 搭建 Godot 4.x 项目骨架、主场景、输入映射与 480x270 内部分辨率 (45min)
- [x] T002 Code 实现 Saya 移动、跳跃、下落缓冲、土狼时间与镜头跟随；碰撞盒不包含声匣/披肩外轮廓 (50min) <!-- 依赖:T001 -->
- [x] T003 Art 根据 A007-A009 制作 Saya 左/右朝向 idle/run/jump 占位 spritesheet，左臂声匣不得镜像错位 (45min) <!-- 依赖:T001 -->
- [x] T004 Code 实现 Pulse 声波动作：短前摇、圆环判定、击退、玻璃锁触发 (50min) <!-- 依赖:T002 -->
- [x] T005 Art 根据 A003/A012/A017 制作首个回声档案馆 tile proxy 图集与背景分层 (45min) <!-- 依赖:T001 -->
- [x] T006 Code 实现单房间灰盒：平台、浅水危险区、声匣门、修复目标 (50min) <!-- 依赖:T002 -->
- [x] T007 VFX 根据 A014 制作 Pulse 圆环、玻璃裂纹亮起、修复成功暖色波形特效 (45min) <!-- 依赖:T004 -->
- [x] T008 Code 根据 A011 实现 silence mote 敌人：巡逻、波形预兆、可被 Pulse 击退/净化 (50min) <!-- 依赖:T004 -->
- [x] T009 UI 根据 A015 实现 HUD：生命、共鸣能量、Pulse 冷却、声匣修复提示 (40min) <!-- 依赖:T004 -->
- [x] T010 Code 实现房间完成奖励：共鸣碎片计数、修复动画、门开启状态 (45min) <!-- 依赖:T006,T008 --> <!-- 2026-06-02 12:00 -->
- [x] T011 Docs 写首版 Steam 页面定位：一句话卖点、短描述、标签、首屏截图清单 (35min) <!-- 依赖:T006 --> <!-- 2026-06-02 12:00 -->
- [x] T012 Code 打包首个 60 秒竖切：开始房间、1 个敌人、1 个声匣、1 扇门、失败/重试 (55min) <!-- 依赖:T007,T009,T010 --> <!-- 2026-06-02 12:40 -->
- [x] T013 Art 从 A011/A013/A014/A015 切分或重绘第二轮核心素材：silence mote spritesheet、voice bell 修复前后、Pulse icon (50min) <!-- 依赖:T003,T005 --> <!-- 2026-06-02 13:00 -->
- [x] T014 Review 第 5 轮审查：核心循环、手感、可读性、风格漂移与文档同步 (45min) <!-- 依赖:T012 --> <!-- 2026-06-02 12:20 -->
- [x] T015 Code 补充 icon.svg 与项目图标 (15min) <!-- 2026-06-02 12:40 -->
- [x] T016 Code 实现开始菜单与暂停菜单 (40min) <!-- 依赖:T012 --> <!-- 2026-06-02 12:40 -->
- [x] T017 Art 生成 Saya 正式版 idle/run/jump 左右朝向 spritesheet（替代 A019 占位） (55min) <!-- 依赖:T003 --> <!-- 2026-06-02 14:00 -->
- [x] T018 Code 实现第二个房间变体：不同平台布局、新增 note wisp 敌人 (50min) <!-- 依赖:T012,T013 --> <!-- 2026-06-02 14:00 -->
- [x] T019 VFX 增强：环境粒子（水面浮光、灰尘）、声匣修复后房间色调渐变 (40min) <!-- 依赖:T007 --> <!-- 2026-06-02 15:00 -->
- [x] T020 Audio 设计音效占位系统：Pulse 回声、脚步声、玻璃碎裂、敌人低鸣 (35min) <!-- 依赖:T004,T008 --> <!-- 2026-06-02 15:00 -->
- [x] T021 Art 生成 NoteWisp 正式版精灵素材 (30min) <!-- 依赖:T018 --> <!-- 2026-06-02 15:00 -->
- [x] T022 Code 实现房间切换与进度持久化 (40min) <!-- 依赖:T018 --> <!-- 2026-06-02 16:00 -->
- [x] T023 Code 玩家受击无敌帧、屏幕震动与受伤音效；敌人受击闪烁增强 (35min) <!-- 2026-06-02 17:00 -->
- [x] T024 Art 生成 Saya 左朝向正式版 spritesheet（独立绘制，非镜像，替代 A027 临时版） (45min) <!-- 依赖:T017 --> <!-- 2026-06-02 17:00 -->
- [x] T025 Code 实现第三个房间变体 archive_03：垂直阶梯平台 + 混合敌人（2 SilenceMote + 1 NoteWisp）+ 双水域 (40min) <!-- 依赖:T018,T022 --> <!-- 2026-06-02 17:00 -->
- [x] T026 Code 实现存档检查点（Save Lantern）+ 死亡重生点 (35min) <!-- 2026-06-02 18:00 -->
- [x] T027 Code 增强 SilenceMote AI：追击状态 + 净化后掉落 (30min) <!-- 2026-06-02 18:00 -->
- [x] T028 Art 生成存档灯笼素材 + 检查点 VFX (25min) <!-- 依赖:T026 --> <!-- 2026-06-02 18:00 -->

## 严重修复任务（来自审查 #19，下轮必修）

- [ ] **[严重] T041 Code 修复 Cut ↔ SilencedWeb 物理层 + 补齐三动词音效 + 实现 apply_bind 语义** (45min) <!-- 2026-06-03 13:00 -->
  - **S-01 必修**：`CutAbility` 物理查询 `mask=0b11100` 不含 SilencedWeb 所在 Layer 1，Cut 永远切不开网。修复：在 `_perform_cut_hit_check()` 末尾追加按 `corruption_chain` 组迭代 + 弧度过滤。
  - **G-03 合并**：移除 silenced_web 误标的 `hazards` 组，注释修正为 `# Cut-only obstacle; pulses pass through`。
  - **G-01 合并**：在 `AudioManagerEnhanced` 中实现 `play_cut()` / `play_bind()` / `play_repair_success()` 三个生成式 SFX，缓存 `_damage_stream`。
  - **G-02 合并**：在 `silence_mote.gd` / `note_wisp.gd` / `ink_warden.gd` 中实现 `apply_bind(duration)` 状态机（冻结动画 + 速度归零 + 持续时间）。Bind 从"软绑定零伤牵引"升级为"真正暂停敌人"。
  - **M-08 合并**：`play_repair_success` 实现后，`save_lantern.gd` / `ability_gate.gd` 的软引用将自动生效。
  - 验收：在 archive_01 实际按 L 切 SilencedWeb，丝网应被斩开并淡出；按 K 应能冻结 SilenceMote 数秒。

- [ ] **[严重] T042 Code GDScript 作用域与 tween 安全（来自审查 #19-深度 D-01~D-03）** (20min) <!-- 2026-06-03 14:00 -->
  - **D-01 必修**：`bind_vfx.gd:68` `seg_t` 出作用域导致 Bind VFX 螺旋线段完全不可见。改为 `float(i) / spiral_points.size()`。
  - **D-02 合并**：`silence_mote.gd:152-153` 同样 modulate no-op 模式未修复，简化与 ink_warden 一致。
  - **D-03 合并**：`player.gd:291` `_sprite_flash_tween` 不 kill，改为调用前 `if _sprite_flash_tween: _sprite_flash_tween.kill()`。
  - 验收：按 K 触发 Bind，应能看见完整内旋螺旋；SilenceMote 追击时显示珊瑚色调；玩家连续受伤无 tween 冲突。

- [ ] **[严重] T043 Code Autoload 生命周期与逻辑（来自审查 #19-深度 D-04~D-06, D-16）** (30min) <!-- 2026-06-03 15:00 -->
  - **D-04 必修**：从 `project.godot` 移除 `AudioManager` autoload 行（已死代码），或合并到 `AudioManagerEnhanced`。
  - **D-05 必修**：`room_controller.gd:35` autoload 信号累积连接，在 `_exit_tree` 中 disconnect，或用 `CONNECT_ONE_SHOT`。
  - **D-06 必修**：`room_controller.gd:54` 玻璃锁缺失时房间被当作"自动完成"——改为 `false`（缺玻璃锁的房间视为未完成）。
  - **D-16 合并**：`silenced_web.gd:22` 移除 `add_to_group("hazards")` 误导成员，注释改写。
  - 验收：连续切换 5 个房间无 "Freed object" 警告；缺玻璃锁房间保持门锁；AudioManager 日志不再出现。

- [ ] **[严重] T047 Code 替换 assert() 为 push_error 防 release 崩溃（来自审查 #19-深度 D-15）** (10min) <!-- 2026-06-03 16:00 -->
  - **D-15 必修**：`cut_ability.gd` 4 处 `assert()` 在 release 构建不执行，改为 `if not x: push_error(...); return` 守卫模式。
  - 验收：导出 release 构建后按 L 切网，缺 _player 节点时输出 push_error 不崩溃。

## 新增任务池

- [x] T029 Code 实现共鸣碎片拾取物（ResonanceShard）：掉落物物理、吸引、收集动画 (30min) <!-- 2026-06-02 19:00 -->
- [x] T030 Code 实现精英敌人 InkWarden：高血量、护盾、破盾后眩晕 (50min) <!-- 2026-06-02 20:00 -->
- [x] T031 Art 生成 InkWarden 精英敌人素材 (35min) <!-- 2026-06-02 20:00 -->
- [x] T032 Code 实现第二个声波能力 Bind（牵引/暂停）：新输入键、新 VFX、新交互 (55min) <!-- 2026-06-02 20:00 -->
- [x] T033 Code 实现能力门系统：需要特定能力解锁的通道 (40min) <!-- 2026-06-02 21:00 -->
- [x] T034 Art 生成 Bind 能力图标与 VFX 素材 (30min) <!-- 2026-06-02 21:00 -->
- [x] T035 Code 实现 Hub 区域：安全区、NPC 对话框架、能力选择 (50min) <!-- 2026-06-02 22:00 -->
- [x] T036 Art 生成 Hub NPC 头像与对话 UI (35min) <!-- 2026-06-02 22:00 -->
- [x] T037 Code 实现设置菜单：音量、分辨率、按键重映射 (35min) <!-- 2026-06-02 19:00 -->
- [x] T038 Code 实现关卡编辑器支持：房间配置 JSON 化 (45min) <!-- 2026-06-03 10:00 -->
- [x] T039 Code 实现 Cut 声波能力（第三动词）：短前摇、弧形判定、切断腐蚀链、贯穿伤害 (50min) <!-- 2026-06-03 11:00 -->
- [x] T040 Art 生成 Cut 能力图标素材 (20min) <!-- 2026-06-03 11:00 -->
- [ ] **T044 Code 静态类型注解补全 + 资源加载优化（来自审查 #19-深度 D-07, D-08, D-09）** (30min) <!-- 计划 #21 -->
  - D-07: 7 个脚本的 @onready 变量补 ClassName 类型注解
  - D-08: room_loader 的 runtime `load()` 改 `_scene_cache` 模式预加载
  - D-09: room_loader 的 `set_script` 反模式推迟到 T050 大重构
- [ ] **T045 Code 性能与缓存优化（来自审查 #19-深度 D-10~D-12）** (20min) <!-- 计划 #21 -->
  - D-10: silence_mote/ink_warden/ability_gate 缓存 player_ref
  - D-11: audio_manager_enhanced.play_damage() SFX 缓存
  - D-12: dialogue_box 无界循环 tween 在 hide 时 kill
- [ ] **T046 Code 死代码清理与方法重命名（来自审查 #19-深度 D-13, D-14）** (10min) <!-- 计划 #22 -->
  - D-13: hud.gd 死常量、silenced_web 死变量、silence_mote 死变量、archive_final 死字符串清理
  - D-14: hud.show_pulse_blocked → show_ability_blocked 重命名
- [ ] **T048 Code 风格与设计盲点收尾（来自审查 #19-深度 D-17~D-22）** (30min) <!-- 计划 #22 -->
  - D-17: archive_final 房间内容补全（创建 archive_final.json + archive_final.tscn）
  - D-18: has_method 软调用改为 class_name 类型化（局部）
  - D-19: @onready 子节点名硬编码改 get_node_or_null
  - D-20: @export_range 数值范围补全
  - D-22: await 守卫补 is_instance_valid 检查
