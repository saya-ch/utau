# Godot 4.6.3 本地二进制

> **⚠️ 首次解压或新克隆仓库后，必须先跑一次 `--import` 再启动任何场景！**
>
> ```bash
> GODOT=/workspace/godot/Godot_v4.6.3-stable_linux.x86_64
> timeout 60 $GODOT --headless --import --path /workspace 2>&1 | tail -5
> ```
>
> `.godot/imported/*.ctex` 缓存由本机生成，git 不跟踪。跳过此步会导致所有 PNG 资源加载失败，并级联触发 8+ 个 SCRIPT ERROR（看似 GDScript 解析错误，实为资源缺失）。审查 #25 已在沙箱首次跑 Godot 时踩到此坑，并已用 `--import` 修复。
> 参考本文件「步骤 2 重新生成 .import 文件」段。

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

### 方法 A：`unzip`（标准，多数情况可用）

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

### 方法 B：Python `zipfile` 兜底（`unzip` 报 "bad zipfile offset" 时）

> 沙箱环境（沙盒 / 容器 / 受限 `unzip` 实现）下 `unzip` 可能因多卷 ZIP 偏移解析失败而报 `bad zipfile offset`，但 ZIP 数据本身完好。优先用方法 C（`unzip -FF`）兜底；若 `unzip -FF` 也不在，再尝试 Python `zipfile`。

#### 方法 B-1（**首选**）：`unzip -FF` 强容错解压

```bash
cd /workspace/godot
cat Godot_v4.6.3-stable_linux.z01 \
    Godot_v4.6.3-stable_linux.z02 \
    Godot_v4.6.3-stable_linux.z03 \
    Godot_v4.6.3-stable_linux.z04 \
    Godot_v4.6.3-stable_linux.zip > /tmp/godot_full.zip
unzip -FF -o /tmp/godot_full.zip 2>&1 | tail -20
chmod +x Godot_v4.6.3-stable_linux.x86_64
```

预期输出含 `bad zipfile offset (local header sig): 67108868 (attempting to re-compensense)` 等 warning，最终 `inflating: Godot_v4.6.3-stable_linux.x86_64` 成功。这是 F003 (#82) 验证可用的兜底方案（沙箱反复确认 OK，详见方法 C 段）。

#### 方法 B-2：Python 标准库 `zipfile`（**仅 Python ≤ 3.13**）

```bash
cd /workspace/godot
cat Godot_v4.6.3-stable_linux.z01 \
    Godot_v4.6.3-stable_linux.z02 \
    Godot_v4.6.3-stable_linux.z03 \
    Godot_v4.6.3-stable_linux.z04 \
    Godot_v4.6.3-stable_linux.zip > /tmp/godot_full.zip
python3 -c "import zipfile; zipfile.ZipFile('/tmp/godot_full.zip').extractall('/workspace/godot/')"
chmod +x Godot_v4.6.3-stable_linux.x86_64
```

> ⚠️ **F003（#82 复现）**：**Python 3.14+** 的 `zipfile` 标准库已无法解压多卷 ZIP — `_extract_member` 在 `open()` 时会抛 `BadZipFile: Bad magic number for file header`（已实测 Python 3.14.4 复现）。
> 沙箱通常装 Python 3.13+，但 CI 镜像与新系统可能默认 3.14。**务必用方法 B-1 `unzip -FF` 而非 B-2。**
>
> 临时降级方案（不推荐，会破坏系统 Python）：
> ```bash
> # 检查 Python 版本（≥3.14 走 B-1）
> python3 -c "import sys; print(sys.version_info[:2])"
> ```

### 验证解压成功

```bash
/workspace/godot/Godot_v4.6.3-stable_linux.x86_64 --version
# 期望: 4.6.3.stable.official.7d41c59c4
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
