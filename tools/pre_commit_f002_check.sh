#!/usr/bin/env bash
# tools/pre_commit_f002_check.sh
#
# T265 (#186) — F002 self-test commit hook 集成 (防止 "commit 漏更新 README" 类问题回归).
#
# Background:
#   F002 self-test (#80 + #185 FIX-#185-1) 在审查时检测出 #183 commit 时漏更新
#   README.md + README.zh-CN.md 「Recent completed work」/「最近完成的工作」段。
#   F002.7 + F002.8 设计本意: "prove the hook would block if README missing #N-1
#   entry" — 但当时 hook 尚未集成到 commit 阶段, #183 commit 通过 (仅 CHANGELOG
#   更新).
#
#   T265 (#186) 把 F002.7 + F002.8 校验提前到 commit 阶段: commit 前自动跑测
#   README 同步状态, 缺失 → 阻断 commit (exit 1). 落地后任何 "commit 漏更新
#   README" 类问题在 commit 阶段即被捕获, 0 漂到审查阶段.
#
# What it checks (all must pass for exit 0):
#   1. README.md "Recent completed work" 段含 #N-1 条目 (F002.7 self-test)
#   2. README.zh-CN.md "最近完成的工作" 段含 #N-1 条目 (F002.8 self-test)
#
# Logic copy from tools/check_smoke_consistency.sh Rule 7 +
# tools/test_t158_t156_f002_smoke.gd F002.7/F002.8 — keep the parsing identical
# (via tools/_parse_recent_section.py) to avoid drift between the two checks.
#
# Usage:
#   tools/pre_commit_f002_check.sh         # run directly (also called by .git/hooks/pre-commit)
#   bash tools/install_hooks.sh             # install to .git/hooks/pre-commit
#
# Exit code:
#   0 = README in sync (safe to commit)
#   1 = at least one README out of sync (block commit, fix missing entry)
#
# Reviews: see REVIEW_LOG.md #185 FIX-#185-1 + ITERATION_GUIDE.md T265.

set -uo pipefail

# Resolve repo root (script lives in tools/ inside the repo).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

README_FILE="README.md"
README_ZH="README.zh-CN.md"
ITER_COUNT_FILE="ITERATION_COUNT.txt"
PARSER="$SCRIPT_DIR/_parse_recent_section.py"

errors=0
warnings=0

echo "=== F002 self-test commit hook (T265) ==="
echo "Repo root: $REPO_ROOT"

# Sanity: ITERATION_COUNT.txt must exist.
if [ ! -f "$ITER_COUNT_FILE" ]; then
	echo "[FAIL] $ITER_COUNT_FILE not found (cannot determine current iteration)"
	exit 1
fi

ITER_COUNT=$(cat "$ITER_COUNT_FILE" 2>/dev/null | tr -d '[:space:]')
if [ -z "$ITER_COUNT" ]; then
	echo "[FAIL] $ITER_COUNT_FILE is empty"
	exit 1
fi

# Sanity: parser script must exist (T265 landing dep).
if [ ! -f "$PARSER" ]; then
	echo "[FAIL] $PARSER not found — T265 落地不完整?"
	exit 1
fi

# Sanity: python3 must be available.
if ! command -v python3 >/dev/null 2>&1; then
	echo "[FAIL] python3 not found (required for F002 self-test parser)"
	exit 1
fi

# In a normal iteration, ITERATION_COUNT is the just-finished #N. The README
# "Recent completed work" section should at least list the previous #N-1 entry
# (since #N entry will be added by the same commit). We check #N-1 sync.
PREV_ITER=$((ITER_COUNT - 1))
if [ "$PREV_ITER" -lt 1 ]; then
	PREV_ITER=1
fi

echo "Current iteration: #$ITER_COUNT"
echo "Expected README 'Recent completed work' to include at least: #$PREV_ITER"
echo

# 对每个 README 文件跑一次 (英文 + 中文)
for rf in "$README_FILE" "$README_ZH"; do
	if [ ! -f "$rf" ]; then
		echo "[FAIL] F002: $rf not found (cannot run F002 sync check)"
		errors=$((errors + 1))
		continue
	fi

	# Parse the latest #N entry from the "Recent completed work" section.
	LATEST=$(python3 "$PARSER" "$rf" 2>/dev/null | tr -d '[:space:]')
	if [ -z "$LATEST" ]; then
		echo "[FAIL] F002: $rf has no parseable 'Recent completed work' / '最近完成的工作' section"
		errors=$((errors + 1))
		continue
	fi

	# 同步检查: 滞后 ≥ 1 轮 → 阻断 commit
	# 与 check_smoke_consistency.sh Rule 7 不同: commit hook 0 容忍任何滞后
	# (审查时 ≥ 2 轮才 FAIL, 但 commit hook 必须 0 漏 1 边 — 因为这个 commit
	# 应该更新 #N 段, 而 #N-1 必须已经存在)
	DIFF=$((ITER_COUNT - LATEST))
	if [ "$DIFF" -ge 1 ]; then
		echo "[FAIL] F002: $rf 'Recent completed work' 段最新 #$LATEST 与 ITERATION_COUNT $ITER_COUNT 滞后 $DIFF 轮 — 阻断 commit"
		echo "       请先在 $rf 'Recent completed work' 段添加 #$ITER_COUNT 条目 (或修复 #$LATEST 之前的滞后段)"
		errors=$((errors + 1))
	else
		echo "[OK] F002: $rf 'Recent completed work' 段最新 #$LATEST matches ITERATION_COUNT $ITER_COUNT"
	fi
done

echo
if [ "$errors" -gt 0 ]; then
	echo "=== F002 self-test commit hook FAIL: $errors error(s), $warnings warning(s) — commit BLOCKED ==="
	echo "Fix: ensure README.md 'Recent completed work' and README.zh-CN.md '最近完成的工作'"
	echo "     both contain the current #$ITER_COUNT entry (or fix any older missing entry)."
	exit 1
fi

if [ "$warnings" -gt 0 ]; then
	echo "=== F002 self-test commit hook PASS with $warnings warning(s) ==="
	exit 0
fi

echo "=== F002 self-test commit hook PASS: README + README.zh-CN.md 同步 #N ==="
exit 0
