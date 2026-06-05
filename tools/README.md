# Voxglass 营销截图工具 (T083)

本目录提供 Voxglass Steam 商店页面所需的 6 张 1920x1080 营销截图。

## 文件

| 文件 | 用途 |
|------|------|
| `screenshot_capture.gd` | Godot 4.6.3 SceneTree 脚本，真实抓取 viewport → PNG |
| `capture_screenshots_desktop.sh` | 桌面环境（带 Xvfb / X11）真实 capture 包装 |
| `generate_screenshot_mockups.py` | 沙箱环境（无 GL）Python + Pillow 资产合成 |
| `generate_screenshot_mockups.sh` | 上述 Python 脚本的 bash 包装 |
| `README.md` | 本文件 |

## 截图列表

| 文件 | 内容 | 设计意图 |
|------|------|----------|
| `01_title_screen.png` | 标题屏（VOXGLASS + 4 按钮） | 第一印象、世界观锚定 |
| `02_hub_room.png` | Hub 安全区 + 4 扇门 + 墨守者剪影 | 进度可视化、伏笔 |
| `03_archive_01_pulse.png` | 第一档案房 + Saya + SilenceMote + Pulse 圆环 | 核心循环教学 |
| `04_archive_03_boss.png` | 第三档案房 + InkWarden Boss + Saya | 战斗张力、敌人多样性 |
| `05_archive_04_double_boss.png` | 第四档案房「共鸣祭坛」+ 双 InkWarden | 终极挑战、机制纯度 |
| `06_shop_merchant.png` | 无声商贩 + 商店 UI + 5 个永久升级 | 系统深度、收集循环 |

## 沙箱限制

本仓库迭代 Agent 跑在 CI 沙箱（无 Xvfb、无 Wayland 显示、无 OpenGL 上下文），
Godot 4.6.3 headless 模式强制使用 dummy 渲染服务器，导致
`Viewport.get_texture().get_image()` 返回 null。

**本轮交付路径**：使用 `generate_screenshot_mockups.py` 基于既有资产
程序化合成 6 张截图，作为营销上线（M10）的最后阻塞解除。

**桌面环境路径**：在有 Xvfb / X11 / Wayland 的环境，run：
```bash
./tools/capture_screenshots_desktop.sh
```
会通过 `screenshot_capture.gd` 真实截取 6 张。

## 风格约束

- 严格遵循 `STYLE_GUIDE.md` 色板（冷色 75% / 中性 15% / 暖色 10%）
- 480x270 内部分辨率 + 4x 整数倍缩放到 1920x1080
- 标题 + 副标题 + 标签使用 mono 字体 + 描边（深底 + 浅字可读）
- 顶部 HUD + 底部提示条（与项目 HUD 设计一致）
- 6 张整体形成完整故事：标题 → Hub → 第一关 → Boss → 终极 → 系统

## 像素规格复核

| 元素 | 尺寸 | 来源 |
|------|------|------|
| 标题 VOXGLASS | 48px bold sans | 系统默认字体 |
| 副标题 | 12px mono | DejaVuSansMono |
| HUD 文本 | 6-8px mono | DejaVuSansMono |
| 平台 | 16px 高 | 程序绘制 |
| Saya 精灵 | 48x64 | A026/A027 |
| InkWarden | 96x96 (scale up from 64x96) | A030-A032 |
| Pulse 圆环 | 36-60px 半径 | 程序绘制 |
