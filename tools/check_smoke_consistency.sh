#!/usr/bin/env bash
# tools/check_smoke_consistency.sh
#
# Detect stale references to BGM preset constants in test_*.gd files.
#
# Background:
#   #63 T121 moved `_MUSIC_PRESETS` / `_BOSS_MUSIC_TIER` from
#   `src/scripts/audio_manager_enhanced.gd` into the new
#   `src/scripts/audio_presets.gd` (preload as `AudioPresets`).
#   #65 caught that 4 tests still used the old `ame_script._MUSIC_PRESETS`
#   form (D001).  This script prevents that class of drift from
#   silently breaking the smoke test suite.
#
# What it checks (all must pass for exit 0):
#   1. Every test_*.gd that uses `AudioPresets.MUSIC_PRESETS` /
#      `AudioPresets.BOSS_MUSIC_TIER` MUST also `preload()` the
#      `audio_presets.gd` file (declared as a const at the top).
#   2. Tests that use the older `SRC_PRESETS := "res://src/scripts/
#      audio_presets.gd"` path constant are still valid (T114 form).
#   3. Tests must NOT use the stale `ame_script._MUSIC_PRESETS` /
#      `ame_script._BOSS_MUSIC_TIER` access pattern.
#   4. `src/scripts/audio_presets.gd` must declare `const MUSIC_PRESETS`
#      and `const BOSS_MUSIC_TIER` (the canonical source of truth).
#   5. `src/scripts/audio_manager_enhanced.gd` must NOT redeclare
#      inline `_MUSIC_PRESETS := {` or `_BOSS_MUSIC_TIER := {` dicts
#      (the old form that D001 caught).
#   6. (`#70` 审查新增 D002 预防) `src/autoload/save_system.gd` 的
#      `_verify_and_unwrap` 必须调用 `_normalize_int_floats()`，否则
#      Godot 4 的 `JSON.parse_string` 会把所有 int 解析为 float，导致
#      写入时算的 CRC32 与读回时算的不一致 → 玩家所有 save 都被误判
#      为 corrupted。这条规则固化 #70 D002 修复。
#
# Usage:
#   tools/check_smoke_consistency.sh
#
# Exit code:
#   0 = consistent (safe to commit)
#   1 = at least one consistency error (review and fix)
#
# Reviews: see REVIEW_LOG.md #65 D001 + F003 (suggested #66) +
#                        #70 D002 (rule 6).

set -uo pipefail

# Resolve repo root (script lives in tools/ inside the repo).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

PRESETS_FILE="src/scripts/audio_presets.gd"
AME_FILE="src/scripts/audio_manager_enhanced.gd"
SAVE_FILE="src/autoload/save_system.gd"

errors=0
warnings=0

echo "=== smoke consistency check ==="
echo "Repo root: $REPO_ROOT"
echo "Canonical preset file: $PRESETS_FILE"
echo

# Sanity: presets file must exist.
if [ ! -f "$PRESETS_FILE" ]; then
	echo "[FAIL] $PRESETS_FILE does not exist (canonical source missing)"
	exit 1
fi

# Canonical-source checks (rule 4).
if ! grep -q "const MUSIC_PRESETS" "$PRESETS_FILE"; then
	echo "[FAIL] $PRESETS_FILE missing 'const MUSIC_PRESETS' declaration"
	errors=$((errors + 1))
else
	echo "[OK] $PRESETS_FILE declares const MUSIC_PRESETS"
fi
if ! grep -q "const BOSS_MUSIC_TIER" "$PRESETS_FILE"; then
	echo "[FAIL] $PRESETS_FILE missing 'const BOSS_MUSIC_TIER' declaration"
	errors=$((errors + 1))
else
	echo "[OK] $PRESETS_FILE declares const BOSS_MUSIC_TIER"
fi

# Rule 5: ame_file must NOT have inline _MUSIC_PRESETS := { or _BOSS_MUSIC_TIER := {
# (i.e. no longer declares the data tables — those live in audio_presets.gd now).
# We tolerate `const` aliases and comments.
if grep -E -q '^[[:space:]]*const[[:space:]]+_MUSIC_PRESETS[[:space:]]*:=' "$AME_FILE"; then
	echo "[FAIL] $AME_FILE redeclares 'const _MUSIC_PRESETS := {...}' (moved to $PRESETS_FILE in T121 #63)"
	errors=$((errors + 1))
else
	echo "[OK] $AME_FILE does not redeclare _MUSIC_PRESETS inline"
fi
if grep -E -q '^[[:space:]]*const[[:space:]]+_BOSS_MUSIC_TIER[[:space:]]*:=' "$AME_FILE"; then
	echo "[FAIL] $AME_FILE redeclares 'const _BOSS_MUSIC_TIER := {...}' (moved to $PRESETS_FILE in T121 #63)"
	errors=$((errors + 1))
else
	echo "[OK] $AME_FILE does not redeclare _BOSS_MUSIC_TIER inline"
fi

# Rule 6 (#70 D002 预防): save_system.gd._verify_and_unwrap 必须调用
# _normalize_int_floats()，否则 JSON.parse_string 的 int→float 副作用会让
# 所有含整数字段的 save 被判为 corrupted。
if [ ! -f "$SAVE_FILE" ]; then
	echo "[WARN] $SAVE_FILE does not exist (skipping rule 6)"
	warnings=$((warnings + 1))
elif ! grep -E -q 'func _normalize_int_floats' "$SAVE_FILE"; then
	echo "[FAIL] $SAVE_FILE missing 'func _normalize_int_floats' (#70 D002 修复关键函数)"
	errors=$((errors + 1))
elif ! grep -E -q '_normalize_int_floats\(data_raw\)' "$SAVE_FILE"; then
	echo "[FAIL] $SAVE_FILE has _normalize_int_floats but not called in _verify_and_unwrap (data_raw 路径)"
	errors=$((errors + 1))
else
	echo "[OK] $SAVE_FILE has _normalize_int_floats + calls it in _verify_and_unwrap"
fi

# Rule 7 (#80 F002 预防): README.md / README.zh-CN.md "Recent completed work"
# 段必须包含当前或上一轮的 #N 条目。G001 (#65 / #75 / #80) 同类问题
# 第 3 次出现，本规则固化 README 同步检查：解析两 README 的"Recent
# completed work" / "最近完成的工作" 段，取最新 #N，与 ITERATION_COUNT.txt
# 比对。滞后 ≥ 2 轮 → FAIL（阻断 commit），滞后 1 轮 → WARN。
README_FILE="README.md"
README_ZH="README.zh-CN.md"
ITER_COUNT=$(cat ITERATION_COUNT.txt 2>/dev/null | tr -d '[:space:]')
if [ -z "$ITER_COUNT" ]; then
	ITER_COUNT=0
fi

# 对每个 README 文件跑一次 (英文 + 中文)
for rf in "$README_FILE" "$README_ZH"; do
	if [ ! -f "$rf" ]; then
		echo "[WARN] rule 7: $rf not found (skipping)"
		warnings=$((warnings + 1))
		continue
	fi
	# 提取 "## Recent completed work" 或 "## 最近完成的工作" 段：从该 heading
	# 起，到下一个非迭代的 ## heading 止。awk 简单状态机。
	# 注: README 的 Recent work 段实际是 ### (3 个 #) — # 段层级不是固定的，
	# 匹配 2-3 个 # 都行。
	# T267 (#187) — FIX rule 7 parser bug:
	# 原来 `/^##[[:space:]]/` 会误匹配 `## #N` 迭代条目（`## #186` 等），
	# 导致 flag 在 section header 后立刻被清零，section 被截断为空。
	# 修复: 把停边界改为 `^##[[:space:]]+[^#]`（要求 `## ` 后非 `#`），
	# 即非迭代的 `## ` 标题（如 `## Room Editor (JSON)`），
	# 正确跳过 `## #N` 迭代条目。
	RECENT_SECTION=$(awk '
		/^#{2,3}[[:space:]]+(Recent completed work|最近完成的工作)/ { flag=1; next }
		/^##[[:space:]]+[^#]/ { if (flag) { flag=0 } }
		flag { print }
	' "$rf")
	if [ -z "$RECENT_SECTION" ]; then
		echo "[WARN] rule 7: $rf has no 'Recent completed work' / '最近完成的工作' section"
		warnings=$((warnings + 1))
		continue
	fi
	# 提取 #N 数字（仅 heading 行 `^## #N` 形式，跳过正文中 #N 文本引用），取第一个 (段内最顶 / 最新 polish 轮, README 约定 review 在顶 + 最新 polish 紧跟其后)
	LATEST=$(echo "$RECENT_SECTION" | grep -oE '^#{2,3}[[:space:]]+#[0-9]+' | head -1 | grep -oE '[0-9]+$')
	if [ -z "$LATEST" ]; then
		echo "[WARN] rule 7: $rf 'Recent completed work' 段无 #N 条目 (可能段头格式变了)"
		warnings=$((warnings + 1))
	elif [ "$LATEST" -lt "$ITER_COUNT" ]; then
		DIFF=$((ITER_COUNT - LATEST))
		if [ "$DIFF" -ge 2 ]; then
			echo "[FAIL] rule 7: $rf 'Recent completed work' 段最新 #$LATEST 与 ITERATION_COUNT $ITER_COUNT 滞后 $DIFF 轮 (>= 2) — 阻断 commit，需先同步 README"
			errors=$((errors + 1))
		else
			echo "[WARN] rule 7: $rf 'Recent completed work' 段最新 #$LATEST 与 ITERATION_COUNT $ITER_COUNT 滞后 1 轮 (下一轮必须同步)"
			warnings=$((warnings + 1))
		fi
	else
		echo "[OK] rule 7: $rf 'Recent completed work' 段最新 #$LATEST matches ITERATION_COUNT $ITER_COUNT"
	fi
done

echo
echo "--- Per-test checks (rules 1, 2, 3) ---"

# Collect test files
mapfile -t test_files < <(find tools -maxdepth 1 -type f -name "test_*.gd" -printf "%f\n" | sort)

if [ "${#test_files[@]}" -eq 0 ]; then
	echo "[WARN] no test_*.gd files found in tools/"
	warnings=$((warnings + 1))
fi

for tf in "${test_files[@]}"; do
	path="tools/$tf"
	uses_presets_alias=0     # uses AudioPresets.MUSIC_PRESETS or .BOSS_MUSIC_TIER
	preloads_presets=0       # has 'const AudioPresets = preload(...audio_presets.gd)'
	uses_src_presets=0       # has 'SRC_PRESETS := "...audio_presets.gd"' (T114 form)
	uses_stale_ame_private=0 # has 'ame_script._MUSIC_PRESETS' or 'ame_script._BOSS_MUSIC_TIER'

	# Runtime-dict access on the alias (e.g. AudioPresets.MUSIC_PRESETS[key],
	# AudioPresets.MUSIC_PRESETS.keys(), AudioPresets.BOSS_MUSIC_TIER.has(...)).
	# Plain string mentions of "AudioPresets.MUSIC_PRESETS" (used by
	# test_t121 to grep source text) do NOT require the preload.
	if grep -E -q 'AudioPresets\.(MUSIC_PRESETS|BOSS_MUSIC_TIER)(\[|\.|\)|$)' "$path"; then
		uses_presets_alias=1
	fi
	# Also catch 'var x := AudioPresets.MUSIC_PRESETS' (with type-inferred assign).
	if grep -E -q ':= AudioPresets\.(MUSIC_PRESETS|BOSS_MUSIC_TIER)' "$path"; then
		uses_presets_alias=1
	fi
	if grep -E -q '^[[:space:]]*const[[:space:]]+AudioPresets[[:space:]]*=[[:space:]]*preload\(' "$path" \
		&& grep -E -q 'audio_presets\.gd' "$path"; then
		preloads_presets=1
	fi
	if grep -E -q 'SRC_PRESETS.*audio_presets\.gd' "$path"; then
		uses_src_presets=1
	fi
	if grep -E -q '(ame_script|_music_script)\._(MUSIC_PRESETS|BOSS_MUSIC_TIER)' "$path"; then
		uses_stale_ame_private=1
	fi

	# Rule 1: alias usage requires preload.
	if [ "$uses_presets_alias" -eq 1 ] && [ "$preloads_presets" -eq 0 ]; then
		echo "[FAIL] $path uses 'AudioPresets.MUSIC_PRESETS' but is missing 'const AudioPresets = preload(\"...audio_presets.gd\")' at the top"
		errors=$((errors + 1))
	fi

	# Rule 3: stale ame_script._MUSIC_PRESETS pattern (D001 trigger).
	if [ "$uses_stale_ame_private" -eq 1 ]; then
		echo "[FAIL] $path uses stale 'ame_script._MUSIC_PRESETS' / '_BOSS_MUSIC_TIER' (should be 'AudioPresets.MUSIC_PRESETS' with preload)"
		errors=$((errors + 1))
	fi

	# Soft report (only print non-trivial cases to reduce noise).
	if [ "$uses_presets_alias" -eq 1 ] || [ "$uses_src_presets" -eq 1 ]; then
		echo "[OK] $path uses canonical access (preload=$preloads_presets, src_presets=$uses_src_presets, alias=$uses_presets_alias)"
	fi
done

echo
echo "=== summary ==="
if [ "$errors" -eq 0 ]; then
	echo "[OK] No consistency errors. ($warnings warnings)"
	echo "Safe to commit."
	exit 0
else
	echo "[FAIL] $errors consistency error(s) found, $warnings warnings."
	echo "Review the failures above before committing."
	exit 1
fi
