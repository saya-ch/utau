# Godot 4.6.3 本地二进制

> 本目录包含 Godot Engine 4.6.3 stable 的 Linux x86_64 headless editor 二进制，
> 由仓库所有者上传。**迭代 Agent 应优先使用本路径**，避免每次拉取外部下载。

## 文件清单

| 文件 | 用途 |
|------|------|
| `Godot_v4.6.3-stable_linux.zip` | 拆分 ZIP 主卷（4.7 MB） |
| `Godot_v4.6.3-stable_linux.z01` ~ `.z04` | 拆分 ZIP 数据卷（各 ~16 MB） |
| `Godot_v4.6.3-stable_linux.x86_64` | **解压后**的可执行二进制（138 MB） |
| `Godot_v4.6.3-stable_win64_console.exe` | Windows 控制台版本（本地 32 MB；仅在 Linux 不可用时参考） |

> 注意：`.zip` 主卷必须存在，否则 `unzip` 会报 "bad zipfile offset"。
> 拉取仓库后**首次迭代**应先验证 `Godot_v4.6.3-stable_linux.zip` 是否就位。

## 首次解压（如 `x86_64` 不存在）

```bash
cd /workspace/godot
cat Godot_v4.6.3-stable_linux.z01 \
    Godot_v4.6.3-stable_linux.z02 \
    Godot_v4.6.3-stable_linux.z03 \
    Godot_v4.6.3-stable_linux.z04 \
    Godot_v4.6.3-stable_linux.zip > /tmp/godot_full.zip
unzip -o /tmp/godot_full.zip
chmod +x Godot_v4.6.3-stable_linux.x86_64
```

## 标准用法

```bash
GODOT=/workspace/godot/Godot_v4.6.3-stable_linux.x86_64
WORK=/workspace
```

### 1) 静态语法/资源检查（最快，< 15 秒）
```bash
timeout 15 $GODOT --headless --quit --path $WORK 2>&1 | \
    grep -E "ERROR|SCRIPT ERROR|Parse Error|Parse Errors|Parse Error: Expected"
```
退出码 0 = 通过；非 0 或有 ERROR 行 = 有问题。

### 2) 重新生成 `.import` 文件（PNG/Tres 导入缓存）
```bash
timeout 60 $GODOT --headless --import --path $WORK 2>&1 | tail -5
```
仅在遇到 **"No loader found for resource: res://..."** 错误时跑。会在 `assets/**` 旁生成 `*.import` 文件。

### 3) 版本自检（确认二进制可用）
```bash
$GODOT --version    # 期望: 4.6.3.stable.official.7d41c59c4
```

### 4) 完整运行（无头）
```bash
timeout 30 $GODOT --headless --path $WORK 2>&1 | head -100
```
会真正进入 main scene 跑一帧后退出会输出"1 resources still in use"等无害警告。

## 已知非致命警告（可忽略）

| 警告 | 触发位置 | 状态 |
|------|----------|------|
| `Parent node is busy setting up children, add_child() failed. Consider using add_child.call_deferred(child)` | `src/scripts/game_flow_controller.gd:35` | 待修（轻微 — 不影响启动） |
| `1 RID of type "Canvas/CanvasItem" was leaked.` | 退出时残留 | 退出路径瑕疵（不影响游戏内） |
| `ObjectDB instances leaked at exit` | 退出时残留 | 同上 |
| `1 resources still in use at exit` | 退出时残留 | 同上 |

> 这些是 Godot 4.6 退出时常见 leak，**不阻塞游戏**。修复时用 `--verbose` 找具体资源。

## 历史 bug 修复记录（迭代时已修）

- **T043 善后（#23）**：2 个 PNG（`archive_room_bg.png` / `archive_tileset_proxy.png`）原本是 RGB 无 alpha，Godot 4.6 loader 拒绝。已用 ffmpeg 转为 RGBA。
- **首次跑 Godot 时发现（#23）**：
  - `src/scenes/room_door.tscn` 中 `[sub_resource ...]` 块位于第一个 `[node ...]` 之后，Godot 4.6 报 "Unknown tag"。已上移至 ext_resource 之后、所有 node 之前。
  - `src/scripts/bind_vfx.gd:68` 使用了已结束 for 循环的局部变量 `seg_t`。已在内部循环重新计算 `seg_t`。
  - `settings_menu.gd` / `room_door.gd` 等 class_name 在 room_door.tscn 修复后正确解析（之前因 room_door.tscn 加载失败而级联报错）。

## ⚠️ 迭代提示

每轮 #N 迭代完成后，**必须**在「步骤 5：质量自检」跑一次：

```bash
GODOT=/workspace/godot/Godot_v4.6.3-stable_linux.x86_64
timeout 15 $GODOT --headless --quit --path /workspace 2>&1 \
    | grep -E "SCRIPT ERROR|Parse Error|GDScript" \
    | head -10
```

无任何 SCRIPT ERROR / Parse Error 输出 → 可提交。
有 ERROR → **必须**修复后才能进入步骤 6（提交）。

这样能保证 `push` 到 origin 的每个 commit 都在 Godot 4.6.3 中可解析，避免审查 #N+5 突然冒出一堆 parse 错误。
