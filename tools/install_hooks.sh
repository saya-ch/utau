#!/usr/bin/env bash
# tools/install_hooks.sh
#
# T265 (#186) — F002 self-test commit hook installer.
#
# Background:
#   T265 落地 tools/pre_commit_f002_check.sh — F002.7 + F002.8 校验脚本
#   (检查 README.md + README.zh-CN.md 'Recent completed work' 段是否同步
#   #N-1 条目). 这个脚本把 pre_commit_f002_check.sh 复制到
#   .git/hooks/pre-commit, 让 git 在 commit 阶段自动跑测 F002 self-test.
#
#   落地后任何 "commit 漏更新 README" 类问题在 commit 阶段即被捕获, 0 漂到
#   审查阶段. 修复 #183 commit 时漏更新 README 的 regression vector.
#
# Usage:
#   bash tools/install_hooks.sh                # install pre-commit hook
#   bash tools/install_hooks.sh --uninstall    # remove pre-commit hook
#
# Notes:
#   - .git/hooks/pre-commit 是不入仓的 (每个开发者本地), 所以这个 installer
#     必须在每位开发者的机器上跑一次 (类似 git LFS, rustup, etc.)
#   - installer 不会覆盖已存在的 pre-commit hook — 它检查是否已安装, 已安装
#     则跳过 (避免覆盖开发者自定义的 hook)
#   - uninstall 模式只删除 F265 落地的 hook 标记, 不动其他 hook
#
# Reviews: see REVIEW_LOG.md #185 FIX-#185-1 + ITERATION_GUIDE.md T265.

set -uo pipefail

# Resolve repo root.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

HOOKS_DIR="$REPO_ROOT/.git/hooks"
PRE_COMMIT_HOOK="$HOOKS_DIR/pre-commit"
SOURCE_SCRIPT="$REPO_ROOT/tools/pre_commit_f002_check.sh"

# F002 hook marker — 用来区分 F265 落地的 hook 和开发者自定义的 hook.
F002_MARKER="# T265 F002 self-test commit hook (do not remove — see tools/pre_commit_f002_check.sh)"

UNINSTALL=0
if [ "${1:-}" = "--uninstall" ]; then
	UNINSTALL=1
fi

# Sanity: must be in a git repo.
if [ ! -d "$HOOKS_DIR" ]; then
	echo "[FAIL] $HOOKS_DIR not found — please run from inside a git repo"
	exit 1
fi

if [ ! -f "$SOURCE_SCRIPT" ]; then
	echo "[FAIL] $SOURCE_SCRIPT not found — T265 落地不完整?"
	exit 1
fi

if [ "$UNINSTALL" -eq 1 ]; then
	# ===== Uninstall mode =====
	if [ ! -f "$PRE_COMMIT_HOOK" ]; then
		echo "[OK] No pre-commit hook installed — nothing to uninstall"
		exit 0
	fi

	# Check if it's our F002 hook.
	if ! grep -q "F002 self-test commit hook" "$PRE_COMMIT_HOOK"; then
		echo "[OK] $PRE_COMMIT_HOOK is not the F002 hook (likely user-customized) — leaving untouched"
		exit 0
	fi

	# Check if it's a pure F002 hook (no user customization beyond our marker).
	# If our marker exists and the file is exactly our script, just remove it.
	# If the user appended custom logic, only remove the F002 lines.
	if grep -q "$F002_MARKER" "$PRE_COMMIT_HOOK" && [ "$(wc -l < "$PRE_COMMIT_HOOK")" -lt 100 ]; then
		# Likely pure F002 hook — just remove.
		rm "$PRE_COMMIT_HOOK"
		echo "[OK] Removed F002 pre-commit hook from $PRE_COMMIT_HOOK"
	else
		# Has custom logic — keep file, just remove F002 marker (if any).
		# For simplicity, we just keep the file untouched and warn.
		echo "[WARN] $PRE_COMMIT_HOOK contains user-customized logic beyond F002 hook"
		echo "       To uninstall cleanly, manually edit and remove F002-related lines"
	fi
	exit 0
fi

# ===== Install mode — F002 =====
if [ -f "$PRE_COMMIT_HOOK" ]; then
	# pre-commit hook already exists.
	if grep -q "F002 self-test commit hook" "$PRE_COMMIT_HOOK"; then
		echo "[OK] F002 pre-commit hook already installed at $PRE_COMMIT_HOOK"
	else
		# User has a custom pre-commit hook — append our hook to it.
		echo "[INFO] $PRE_COMMIT_HOOK exists (user-customized) — appending F002 hook to it"
		{
			echo ""
			echo "$F002_MARKER"
			echo "# Auto-appended by tools/install_hooks.sh (T265). Remove with:"
			echo "#   bash tools/install_hooks.sh --uninstall"
			echo "# F002 + README slim mutual-exclusion fix (Task 6 Round1 C1): docs-only -> WARN"
			echo "if git diff --cached --name-only | grep -qv \"^docs/\"; then"
			echo "    bash \"$SOURCE_SCRIPT\" || exit 1"
			echo "else"
			echo "    bash \"$SOURCE_SCRIPT\" || echo \"WARN F002 failed but docs-only, continue\""
			echo "fi"
		} >> "$PRE_COMMIT_HOOK"
		chmod +x "$PRE_COMMIT_HOOK"
		echo "[OK] Appended F002 hook to existing $PRE_COMMIT_HOOK"
	fi
else
	# No existing pre-commit hook — create one with F002 self-test.
	echo "[INFO] Creating new pre-commit hook at $PRE_COMMIT_HOOK"
	{
		echo "#!/usr/bin/env bash"
		echo "$F002_MARKER"
		echo "# Auto-installed by tools/install_hooks.sh (T265). Remove with:"
		echo "#   bash tools/install_hooks.sh --uninstall"
		echo "# F002 + README slim mutual-exclusion fix (Task 6 Round1 C1): docs-only -> WARN"
		echo "if git diff --cached --name-only | grep -qv \"^docs/\"; then"
		echo "    bash \"$SOURCE_SCRIPT\" || exit 1"
		echo "else"
		echo "    bash \"$SOURCE_SCRIPT\" || echo \"WARN F002 failed but docs-only, continue\""
		echo "fi"
	} > "$PRE_COMMIT_HOOK"
	chmod +x "$PRE_COMMIT_HOOK"
	echo "[OK] Installed F002 pre-commit hook at $PRE_COMMIT_HOOK"
	echo ""
	echo "Test it with: git commit --allow-empty -m 'test F002 hook'"
	echo "If it blocks: check README.md + README.zh-CN.md 'Recent completed work' sync status"
fi

# ===== Install mode — docs-lint hook (幂等) — Task 6 =====
GITHOOKS_DIR="$REPO_ROOT/.githooks"
GITHOOKS_PRE_COMMIT="$GITHOOKS_DIR/pre-commit"
DOCS_LINT_MARKER="# docs-lint hook (幂等 — see tools/docs-lint.ps1)"
F002_GITHOOKS_MARKER="# T265 F002 self-test commit hook (do not remove — see tools/pre_commit_f002_check.sh)"

mkdir -p "$GITHOOKS_DIR"
if [ ! -f "$GITHOOKS_PRE_COMMIT" ]; then
	echo "#!/bin/sh" > "$GITHOOKS_PRE_COMMIT"
	echo "$F002_GITHOOKS_MARKER" >> "$GITHOOKS_PRE_COMMIT"
	echo "# F002 + README slim mutual-exclusion fix (Task 6 Round1 C1): docs-only -> WARN" >> "$GITHOOKS_PRE_COMMIT"
	echo "if git diff --cached --name-only | grep -qv \"^docs/\"; then" >> "$GITHOOKS_PRE_COMMIT"
	echo "  bash tools/pre_commit_f002_check.sh || exit 1" >> "$GITHOOKS_PRE_COMMIT"
	echo "else" >> "$GITHOOKS_PRE_COMMIT"
	echo "  bash tools/pre_commit_f002_check.sh || echo \"WARN F002 failed but docs-only, continue\"" >> "$GITHOOKS_PRE_COMMIT"
	echo "fi" >> "$GITHOOKS_PRE_COMMIT"
	echo "$DOCS_LINT_MARKER" >> "$GITHOOKS_PRE_COMMIT"
	echo "pwsh -File tools/docs-lint.ps1 -Path docs" >> "$GITHOOKS_PRE_COMMIT"
	chmod +x "$GITHOOKS_PRE_COMMIT"
	echo "[OK] Created docs-lint pre-commit hook at $GITHOOKS_PRE_COMMIT"
else
	# 确保 F002 也在 .githooks 中（幂等）— 若旧 hook 含严格 || exit 1, 升级为 docs-exempt wrapper
	if ! grep -q "F002" "$GITHOOKS_PRE_COMMIT" 2>/dev/null; then
		echo "" >> "$GITHOOKS_PRE_COMMIT"
		echo "$F002_GITHOOKS_MARKER" >> "$GITHOOKS_PRE_COMMIT"
		echo "# F002 + README slim mutual-exclusion fix (Task 6 Round1 C1): docs-only -> WARN" >> "$GITHOOKS_PRE_COMMIT"
		echo "if git diff --cached --name-only | grep -qv \"^docs/\"; then" >> "$GITHOOKS_PRE_COMMIT"
		echo "  bash tools/pre_commit_f002_check.sh || exit 1" >> "$GITHOOKS_PRE_COMMIT"
		echo "else" >> "$GITHOOKS_PRE_COMMIT"
		echo "  bash tools/pre_commit_f002_check.sh || echo \"WARN F002 failed but docs-only, continue\"" >> "$GITHOOKS_PRE_COMMIT"
		echo "fi" >> "$GITHOOKS_PRE_COMMIT"
		chmod +x "$GITHOOKS_PRE_COMMIT"
		echo "[OK] Appended F002 hook to $GITHOOKS_PRE_COMMIT"
	elif grep -q "bash tools/pre_commit_f002_check.sh || exit 1" "$GITHOOKS_PRE_COMMIT" 2>/dev/null; then
		# 已有旧严格 F002 行 — 升级为 docs-exempt wrapper (幂等迁移)
		echo "[INFO] Upgrading existing strict F002 hook to docs-exempt wrapper in $GITHOOKS_PRE_COMMIT"
		tmpfile=$(mktemp)
		# 使用 ~ 分隔符避免与 || 冲突; 保留 marker 之前内容, 替换旧单行 F002 为 wrapper
		sed "s~bash tools/pre_commit_f002_check.sh || exit 1~# F002 + README slim mutual-exclusion fix (Task 6 Round1 C1): docs-only -> WARN\nif git diff --cached --name-only | grep -qv \"^docs/\"; then\n  bash tools/pre_commit_f002_check.sh || exit 1\nelse\n  bash tools/pre_commit_f002_check.sh || echo \"WARN F002 failed but docs-only, continue\"\nfi~" "$GITHOOKS_PRE_COMMIT" > "$tmpfile" && mv "$tmpfile" "$GITHOOKS_PRE_COMMIT"
		chmod +x "$GITHOOKS_PRE_COMMIT"
		echo "[OK] Upgraded F002 hook to docs-exempt wrapper"
	fi
	if ! grep -q "docs-lint" "$GITHOOKS_PRE_COMMIT" 2>/dev/null; then
		echo "" >> "$GITHOOKS_PRE_COMMIT"
		echo "$DOCS_LINT_MARKER" >> "$GITHOOKS_PRE_COMMIT"
		echo "pwsh -File tools/docs-lint.ps1 -Path docs" >> "$GITHOOKS_PRE_COMMIT"
		chmod +x "$GITHOOKS_PRE_COMMIT"
		echo "[OK] Appended docs-lint hook to $GITHOOKS_PRE_COMMIT"
	else
		echo "[OK] docs-lint hook already present in $GITHOOKS_PRE_COMMIT"
		chmod +x "$GITHOOKS_PRE_COMMIT"
	fi
fi

git config core.hooksPath .githooks
echo "[OK] Set git core.hooksPath to .githooks"
echo ""
echo "Test docs-lint hook with: pwsh -File tools/docs-lint.ps1 -Path docs"
exit 0
