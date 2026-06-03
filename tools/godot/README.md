# Godot 引擎工具链

> 本目录提供 Godot 4.6.3 stable 引擎的本地获取与使用流程，供 `ITERATION_GUIDE.md` 流程中的「Godot 运行时回归」使用。

## 文件清单

| 文件 | 用途 | 存储方式 |
|------|------|----------|
| `Godot_v4.6.3-stable_win64_console.exe` | Windows 本地开发用的 console binary | git 直存 (~193KB) |
| `Godot_v4.6.3-stable_linux.x86_64` | Linux 沙箱 / CI 用的 headless binary | **Git LFS** (~80MB) |
| `README.md` | 本文档 | git 直存 |

## 为什么用 Git LFS

GitHub 仓库单文件硬限制 25MB，Godot 4.6.3 Linux x86_64 ~80MB 塞不进普通 git 仓库。Git LFS 替换大文件为指针文件，单文件支持 2GB，且沙箱已装好 `git-lfs v3.4.1`，`git pull` 自动拉取 LFS 对象。

> 注：GitHub Release 也支持 2GB 单文件，但通过 web 拖拽上传常被错误路由到 issue/PR 附件通道（25MB 限制），Git LFS 走 git 协议最稳。

## 一次性配置

### 1. 仓库 owner 在 GitHub 启用 LFS

- 仓库主页 → **Settings** → **Packages**（或直接搜 "Git LFS"）→ **Enable Git LFS**
- 仅 repo owner 一次操作

### 2. 本地配置 LFS 跟踪

本仓库的 `.gitattributes` 已经跟踪：

```
tools/godot/Godot_v4.6.3-stable_linux.x86_64 filter=lfs diff=lfs merge=lfs -text
*.x86_64                                                  filter=lfs diff=lfs merge=lfs -text
```

如果你本地克隆后做修改：

```bash
git lfs install                # 安装 git-lfs smudge/clean 过滤器
git lfs pull                   # 拉取 LFS 对象到本地
```

### 3. 添加 Godot Linux 二进制到仓库

> **仅在仓库 owner 端执行一次**（或换 Godot 版本时）：

```bash
# 下载官方 Godot 4.6.3 Linux x86_64 zip
wget https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_linux.x86_64.zip
unzip Godot_v4.6.3-stable_linux.x86_64.zip
mv Godot_v4.6.3-stable_linux.x86_64 tools/godot/
chmod +x tools/godot/Godot_v4.6.3-stable_linux.x86_64

# git-lfs 会自动通过 .gitattributes 跟踪此文件
git add tools/godot/Godot_v4.6.3-stable_linux.x86_64
git commit -m "chore(lfs):添加 Godot 4.6.3-stable Linux x86_64 二进制"
git push origin main
```

## 沙箱中使用

迭代 Agent 每次启动时：

```bash
git pull                # LFS 对象会自动拉取（沙箱已装 git-lfs）
chmod +x tools/godot/Godot_v4.6.3-stable_linux.x86_64  # 仅首次需要
```

验证：

```bash
tools/godot/Godot_v4.6.3-stable_linux.x86_64 --version
# 应输出: 4.6.3.stable.official
```

### 静态语法 / 解析检查（最常用）

```bash
tools/godot/Godot_v4.6.3-stable_linux.x86_64 --headless --check-only --path .
```

### 60 秒冒烟测试

```bash
tools/godot/Godot_v4.6.3-stable_linux.x86_64 --headless --path . --quit-after 60
```

### 常见选项

| 选项 | 作用 |
|------|------|
| `--headless` | 无渲染模式（CI / 服务器必备） |
| `--check-only` | 仅检查脚本能否解析，不真正运行 |
| `--path <dir>` | 指定项目根（含 `project.godot`） |
| `--quit-after <n>` | 跑 n 帧后退出 |
| `--verbose` | 详细日志 |

### Windows 开发者

直接双击 `Godot_v4.6.3-stable_win64_console.exe`，或：

```powershell
.\tools\godot\Godot_v4.6.3-stable_win64_console.exe --headless --check-only --path .
```

## 在迭代中的使用（参考 ITERATION_GUIDE.md）

- **常规迭代轮**：可选（`--check-only` 5 秒内完成）
- **审查轮（#5k）**：**必跑**（解决审查 #21 提到的"Godot 运行时回归流程漏洞"）
- **Bug 修复轮**：若修复涉及脚本改动，必跑 `--check-only`

## 跨平台对照

| 平台 | 二进制名 | 来源 | 沙箱支持 |
|------|----------|------|----------|
| Windows x86_64 | `Godot_v4.6.3-stable_win64_console.exe` | git 直存 | ✅ |
| Linux x86_64 | `Godot_v4.6.3-stable_linux.x86_64` | Git LFS | ✅ |
| macOS Universal | `Godot_v4.6.3-stable_macos.universal` | 待补 LFS | ❌ |

## 版本对齐

本项目 `project.godot` 的 `config/features=PackedStringArray("4.4")` 与 4.6.3 兼容（审查 #20 + 审查 #21 已验证 parse 干净）。
