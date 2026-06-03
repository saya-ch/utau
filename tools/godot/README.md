# Godot 引擎二进制（本地工具链）

> 本目录存放 Godot 4.6.3 stable 引擎二进制，供 `ITERATION_GUIDE.md` 流程中的「Godot 运行时回归」使用。

## 当前文件

| 文件 | 平台 | 大小 | 用途 |
|------|------|------|------|
| `Godot_v4.6.3-stable_win64_console.exe` | Windows x86_64 | ~193KB | Windows 本地开发与 CI |

> **Console 版本**（无 GUI 资源）适合脚本化调用；如需 GUI 编辑器请额外下载 `Godot_v4.6.3-stable_win64.exe`（带 GUI，约 80MB+）。

## 用法

### 静态语法 / 解析检查（最常用）

```powershell
# Windows PowerShell
.\tools\godot\Godot_v4.6.3-stable_win64_console.exe --headless --check-only --path .
```

### 60 秒冒烟测试

```powershell
.\tools\godot\Godot_v4.6.3-stable_win64_console.exe --headless --path . --quit-after 60
```

### 常见选项

| 选项 | 作用 |
|------|------|
| `--headless` | 无渲染模式（CI 必备） |
| `--check-only` | 仅检查脚本能否解析，不真正运行 |
| `--path <dir>` | 指定项目根（含 `project.godot`） |
| `--quit-after <n>` | 跑 n 帧后退出 |
| `--verbose` | 详细日志 |

## 跨平台说明

| 平台 | 二进制名 | 沙箱支持 |
|------|----------|----------|
| Windows x86_64 | `Godot_v4.6.3-stable_win64_console.exe` | ✅ 当前持有 |
| Linux x86_64 | `Godot_v4.6.3-stable_linux.x86_64` | ❌ 待补（沙箱为 Linux，需此版才能在 CI 自动跑） |
| macOS Universal | `Godot_v4.6.3-stable_macos.universal` | ❌ 待补 |

### Linux 二进制如何补齐

1. 访问 https://godotengine.org/download/ 或 https://github.com/godotengine/godot/releases/tag/4.6.3-stable
2. 下载 `Godot_v4.6.3-stable_linux.x86_64.zip`
3. 解压并将 binary 重命名为 `Godot_v4.6.3-stable_linux.x86_64` 后放至本目录
4. `chmod +x` 加上可执行权限
5. commit 到本目录

## 在迭代中的使用

按 `ITERATION_GUIDE.md` 流程：

- **常规迭代轮**：可选（`--check-only` 在 CI 中跑 5 秒内完成）
- **审查轮（#5k）**：**必跑**（解决审查 #21 提到的"Godot 运行时回归流程漏洞"）
- **Bug 修复轮**：若修复涉及脚本改动，必跑 `--check-only`

## 为什么不直接下载

- Godot GitHub Release 直链受沙箱外发带宽限制（审查 #21 期间下载 4.4.1 失败，仅 11MB 残片）
- 用户上传到本目录后跟踪进 git（每个平台 ~80-200MB），跨平台成员都能直接使用
- 如未来需要减小仓库体积，可改用 Git LFS 或独立 binary release

## 版本对齐

本项目 `project.godot` 的 `config/features=PackedStringArray("4.4")` 与 4.6.3 兼容（审查 #20 + 审查 #21 已验证 parse 干净）。
