# Changelog

## [2026-06-02 00:37 #INIT] - 市场调研与方向锚定 | skills:imagegen, market-research, canvas-design-substitute, game-asset-design-substitute | 任务ID:INIT | 备注

- 初始化 8 个状态文件，`ITERATION_COUNT.txt` 保持 `0`。
- 完成 Steam/itch.io 2D 独立游戏市场调研，写入 `RESEARCH.md`。
- 选定工作方向 `Voxglass`：声音修复主题的 2D 动作探索 + 轻量 roguelite 房间结构。
- 生成并保存 5 张概念资产：情绪板、主角、场景、敌人与道具、UI 样本。
- 提炼视觉宪法写入 `STYLE_GUIDE.md`，登记素材到 `ASSET_REGISTRY.md`。
- 拆解 T001-T014 路线图，下一轮从 Godot 4.x 项目骨架开始。

## [2026-06-02 01:52 #INIT] - 女主重设与素材扩充 | skills:imagegen, game-asset-design-substitute, canvas-design-substitute | 任务ID:INIT | 备注

- 根据用户反馈废弃旧版无脸黑斗篷主角，改为原创二次元美少女声匣修复者 `Saya`。
- 保留核心设定：解剖学左前臂的紧凑玻璃声匣装置；为避免镜像错误，生成并登记左右朝向动作参考。
- 扩充 13 张后续可用美术素材：Saya 方向探索、最终设定、左右朝向动作参考、头像表情、敌人表、tile 概念、道具拾取物、VFX、HUD、NPC、背景组、无标题 key art。
- 更新 `STYLE_GUIDE.md`：加入 Saya 角色宪法、左臂声匣朝向规则、AI 风格负提示词。
- 更新 `ROADMAP.md`：T003/T005/T007/T008/T009/T013 改为引用新素材编号。

## [2026-06-02 10:37 #1] - Godot 项目骨架与 Saya 占位素材 | skills:game-development | 任务ID:T001,T002,T003 | 备注

- 完成 T001：手动创建 Godot 4.x 项目骨架，配置 480x270 内部分辨率、整数倍缩放到 1920x1080。
- 完成 T002：实现 Saya 角色控制器，包含移动、跳跃、土狼时间、跳跃缓冲、下落重力倍增、镜头跟随。
- 完成 T003：生成 Saya 占位 spritesheet (864x64, 18 帧)，遵循 STYLE_GUIDE 色板与左臂声匣设定。
- 创建 GameState 与 AudioManager 自动加载单例。
- 登记新素材 A019 到 ASSET_REGISTRY.md。
- `ITERATION_COUNT.txt` 更新为 `1`。
