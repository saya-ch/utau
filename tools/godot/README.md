# Godot 引擎工具链

> 本目录提供 Godot 4.6.3 stable 引擎的本地获取与使用流程，供 `ITERATION_GUIDE.md` 流程中的「Godot 运行时回归」使用。

## 文件清单

| 文件 | 用途 |
|------|------|
| `Godot_v4.6.3-stable_win64_console.exe` | Windows 本地开发用的 console binary（已 commit 跟踪） |
| `bootstrap.sh` | Linux/macOS 拉取 Godot 4.6.3-stable_linux.x86_64 的脚本 |
| `godot_release_url.txt` | Release 下载 URL（待填入） |
| `godot_sha256.txt` | Release zip 包 SHA256 校验和（待填入） |

## 为什么不全 commit 进仓库

GitHub 仓库单文件硬限制 25MB，Godot 4.6.3 Linux x86_64 解压后约 80MB，塞不进仓库。Windows 版较小（~193KB）所以直接 commit；Linux 版走 **GitHub Release**（单文件 2GB 上限） + 沙箱本地 bootstrap 拉取。

## 一次性配置（仓库 owner 执行一次）

### 1. 创建 GitHub Release

- 仓库主页 → **Releases** → **Draft a new release**
- **Choose a tag**: `v4.6.3`
- **Release title**: `Godot 4.6.3-stable (Linux x86_64)`
- **Attach binaries**: 上传 `Godot_v4.6.3-stable_linux.x86_64.zip`
  - 来源：https://github.com/godotengine/godot/releases/tag/4.6.3-stable
- 点 **Publish release**

### 2. 拿下载链接 + SHA256

发布后从 release 页面复制下载链接，例：

```
https://github.com/saya-ch/utau/releases/download/v4.6.3/Godot_v4.6.3-stable_linux.x86_64.zip
```

本地执行：

```bash
sha256sum Godot_v4.6.3-stable_linux.x86_64.zip
```

### 3. 填入本目录配置

- `godot_release_url.txt`：把上面那行 URL 替换占位行（去掉注释 `#`，仅 URL）
- `godot_sha256.txt`：把 hash 替换 `# <待填入>` 那行（去掉注释 `#`）

### 4. commit 配置

```bash
git add tools/godot/godot_release_url.txt tools/godot/godot_sha256.txt
git commit -m "chore:配置 Godot 4.6.3 Linux release URL 与 SHA256"
```

## 沙箱中使用（迭代 Agent 每次启动时跑）

```bash
chmod +x tools/godot/bootstrap.sh
./tools/godot/bootstrap.sh
```

脚本逻辑：
1. 检测 `Godot_v4.6.3-stable_linux.x86_64` 是否已存在且可执行 → 是则跑 `--version` 退出
2. 读 `godot_release_url.txt` 拉 zip 到 `/tmp`
3. 用 `godot_sha256.txt` 校验（空则跳过）
4. 解压到本目录 + `chmod +x`
5. 跑 `--version` 验证可启动

> **沙箱外发带宽受限**（审查 #21 期间下载 4.4.1 失败，仅 11MB 残片）→ Release URL 应在 GitHub 域内（github.com 直连通常不受限，release-attach-files 走的是 jsDelivr / GitHub S3 镜像）。

## 用法

### 静态语法 / 解析检查（最常用）

```bash
./tools/godot/Godot_v4.6.3-stable_linux.x86_64 --headless --check-only --path .
```

### 60 秒冒烟测试

```bash
./tools/godot/Godot_v4.6.3-stable_linux.x86_64 --headless --path . --quit-after 60
```

### Windows 开发者

直接双击 `Godot_v4.6.3-stable_win64_console.exe`，或：

```powershell
.\tools\godot\Godot_v4.6.3-stable_win64_console.exe --headless --check-only --path .
```

### 常见选项

| 选项 | 作用 |
|------|------|
| `--headless` | 无渲染模式（CI / 服务器必备） |
| `--check-only` | 仅检查脚本能否解析，不真正运行 |
| `--path <dir>` | 指定项目根（含 `project.godot`） |
| `--quit-after <n>` | 跑 n 帧后退出 |
| `--verbose` | 详细日志 |

## 在迭代中的使用（参考 ITERATION_GUIDE.md）

- **常规迭代轮**：可选（`--check-only` 5 秒内完成）
- **审查轮（#5k）**：**必跑**（解决审查 #21 提到的"Godot 运行时回归流程漏洞"）
- **Bug 修复轮**：若修复涉及脚本改动，必跑 `--check-only`

## 跨平台对照

| 平台 | 二进制名 | 来源 | 沙箱支持 |
|------|----------|------|----------|
| Windows x86_64 | `Godot_v4.6.3-stable_win64_console.exe` | 直接 commit | ✅ |
| Linux x86_64 | `Godot_v4.6.3-stable_linux.x86_64` | GitHub Release + bootstrap | ✅ |
| macOS Universal | `Godot_v4.6.3-stable_macos.universal` | 待补 | ❌ |

## 版本对齐

本项目 `project.godot` 的 `config/features=PackedStringArray("4.4")` 与 4.6.3 兼容（审查 #20 + 审查 #21 已验证 parse 干净）。
