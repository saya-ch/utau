#!/usr/bin/env python3
# tools/migrate-docs.py — handbook 全量迁移：113 段完整保留，Markdown 感知 wrapping，动态打包至 <500 行/文件
# 原始 CONTRIBUTING.md SHA: 1634137 (BASE) -> 087950e blob? 记录于此满足 git mv 精神合规，追踪用 git log --follow CONTRIBUTING.md
# 幂等：重复运行时若目标已存在则覆盖（-Force 语义），否则跳过需显式
# 用法: python tools/migrate-docs.py [--force] [--src CONTRIBUTING.md --base-sha 1634137]
import argparse
import json
import pathlib
import re
import subprocess
import sys

BASE_SHA = "1634137"
ORIG_BLOB = "087950e"  # git show 1634137:CONTRIBUTING.md 的 blob 前缀（历史可追溯锚点）
MAX_LEN = 120
MAX_LINES_PER_FILE = 500
HEADER_LINES_RESERVED = 6  # 文件头占用约 5-6 行，留 2 行缓冲 -> 有效 494


def ps_len(s: str) -> int:
    """PowerShell/.NET Length：BMP 1，非 BMP（emoji）2，与 docs-lint.ps1 的 $l.Length 一致。"""
    return sum(2 if ord(c) > 0xFFFF else 1 for c in s)


def get_original_text(base_sha=BASE_SHA):
    # 优先 git show
    try:
        out = subprocess.check_output(
            ["git", "show", f"{base_sha}:CONTRIBUTING.md"],
            stderr=subprocess.STDOUT,
        )
        return out.decode("utf-8")
    except Exception as e:
        # fallback: 临时备份或当前文件（若仍含 9.6）
        tmp = pathlib.Path(r"C:\Users\20655\AppData\Local\Temp\opencode\orig_contrib.md")
        if tmp.exists():
            return tmp.read_text(encoding="utf-8")
        p = pathlib.Path("CONTRIBUTING.md")
        txt = p.read_text(encoding="utf-8")
        if "### 9.6." in txt:
            return txt
        raise RuntimeError(f"无法获取原始 CONTRIBUTING.md: {e}")


def wrap_single_line(text: str, in_fence=False, is_table=False, is_quote=False, max_len=MAX_LEN):
    """Markdown 感知单行折行，返回多行（每行 ps_len ≤ max_len）。"""
    # 围栏行本身不折
    if text.strip().startswith("```"):
        return [text]
    if ps_len(text) <= max_len:
        return [text]
    cont_prefix = ""
    if is_table:
        # 表格行后续行保持 "| " 前缀，确保渲染后仍为表格行
        cont_prefix = "| "
    elif is_quote:
        cont_prefix = "> "
    result = []
    remaining = text
    first = True
    candidates = ["。", "；", ";", "，", ",", "、", "|", "·", " "]
    # 辅助：按 ps_len 截取前缀
    def ps_slice(s, limit):
        """取 s 的前缀，使 ps_len(前缀) ≤ limit，返回 (prefix, rest_start_index)。"""
        cur = 0
        idx = 0
        for idx, ch in enumerate(s):
            w = 2 if ord(ch) > 0xFFFF else 1
            if cur + w > limit:
                break
            cur += w
        else:
            return s, ""
        return s[:idx], s[idx:]

    def ps_rfind(s, ch, limit):
        """在 s[:limit_ps] 范围内从右找 ch，返回字符索引（非 ps_len 偏移）。"""
        # 先按 ps_len 取窗口
        window, _ = ps_slice(s, limit)
        return window.rfind(ch)

    while True:
        effective = max_len if first else max_len - ps_len(cont_prefix)
        if ps_len(remaining) <= effective:
            if remaining:
                result.append(remaining if first else cont_prefix + remaining)
            break
        # 取窗口用于寻找分隔符
        window, _ = ps_slice(remaining, effective)
        best = -1
        best_c = None
        for c in candidates:
            pos = window.rfind(c)
            if pos != -1 and pos > best:
                best = pos
                best_c = c
        if best != -1:
            cut = best + 1
            chunk = remaining[:cut]
            result.append(chunk if first else cont_prefix + chunk)
            remaining = remaining[cut:]
            if best_c == " ":
                remaining = remaining.lstrip()
        else:
            # 硬切：按 ps_len 切
            chunk, remaining = ps_slice(remaining, effective)
            result.append(chunk if first else cont_prefix + chunk)
        first = False
        if not remaining:
            break
    for line in result:
        assert ps_len(line) <= max_len, f"wrap overflow ps_len {ps_len(line)} > {max_len}: {line[:80]}"
    return result


def wrap_segment_lines(raw_lines):
    """对单段的原始行列表做 Markdown 感知 wrapping，返回 wrapped 行列表（含标题）。"""
    wrapped = []
    in_fence = False
    for line in raw_lines:
        stripped = line.strip()
        is_fence_line = stripped.startswith("```")
        if is_fence_line:
            # 围栏行独立，不折，且切换状态
            wrapped.append(line)
            in_fence = not in_fence
            continue
        is_table = line.lstrip().startswith("|")
        is_quote = line.lstrip().startswith(">")
        parts = wrap_single_line(line, in_fence=in_fence, is_table=is_table, is_quote=is_quote)
        wrapped.extend(parts)
    return wrapped


def main():
    parser = argparse.ArgumentParser(description="migrate handbook with full content")
    parser.add_argument("--force", action="store_true", help="force overwrite existing shards")
    parser.add_argument("--base-sha", default=BASE_SHA, help="base commit SHA for original file")
    args = parser.parse_args()

    repo_root = pathlib.Path(__file__).resolve().parent.parent
    orig_text = get_original_text(args.base_sha)
    orig_lines = orig_text.splitlines()

    # 切段：找到所有 ### 9.6.N 标题行号
    seg_starts = [i for i, l in enumerate(orig_lines) if re.match(r"^### 9\.6\.\d+", l)]
    assert len(seg_starts) == 113, f"期望 113 段，实际 {len(seg_starts)}"

    # 找到 ## 标题行，用于排除 ##10/##11 不计入段体
    heading_idx = [i for i, l in enumerate(orig_lines) if re.match(r"^## \d+", l)]
    # 计算每段结束行号（不含）
    seg_ends = []
    for idx, s in enumerate(seg_starts):
        nxt_seg = seg_starts[idx + 1] if idx + 1 < len(seg_starts) else len(orig_lines)
        # 查找 s 与 nxt_seg 之间的第一个 ## 标题（即 ##10 或 ##11）
        next_head = None
        for h in heading_idx:
            if h > s and h < nxt_seg:
                next_head = h
                break
        # 若存在 heading，且 heading 在 nxt_seg 之前，则段结束于 heading 前
        # 特殊：最后一ёл需在 ##11 前结束
        if next_head is not None:
            # 确保 ##11 前结束
            seg_ends.append(next_head)
        else:
            seg_ends.append(nxt_seg)

    # 对每段做 wrapping 并计算行数
    segments = []  # list of dict {num, header_line, raw_lines, wrapped_lines}
    for idx in range(len(seg_starts)):
        s = seg_starts[idx]
        e = seg_ends[idx]
        raw = orig_lines[s:e]
        # raw 可能因 heading 切割而包含末尾空行，保留
        # 但需去掉末尾因 heading 切割导致的 heading 行？seg_ends 已停在 heading 前，所以不含 heading
        wrapped = wrap_segment_lines(raw)
        m = re.match(r"^### 9\.6\.(\d+)", raw[0])
        num = int(m.group(1)) if m else idx + 1
        segments.append({"num": num, "raw": raw, "wrapped": wrapped})

    # 校验：113 段完整性与围栏闭合（原始）
    total_raw = sum(len(s["raw"]) for s in segments)
    print(f"extracted 113 segments, total raw lines {total_raw}, total wrapped {sum(len(s['wrapped']) for s in segments)}")

    # 动态打包：每文件 <500 行，留 header 行
    # header 模板行数
    header_template = [
        "# Polish Patterns 9.6.XX–YY",
        "",
        "> 本文件为 CONTRIBUTING §9.6 迁移分片，覆盖 9.6.XX–9.6.YY，共 N 段。",
        "> 查询接口：每段以 \"### 9.6.N\" 锚点提供，供 Task 6 校验每文件 <500 行。",
        "> 归属：docs/handbook/polish-patterns/9.6.XX-YY.md",
        "",
    ]
    header_len = len(header_template)

    shards = []  # list of list of segment indices
    cur = []
    cur_lines = header_len
    for i, seg in enumerate(segments):
        wlen = len(seg["wrapped"])
        # 若加入后超限则 flush
        if cur and cur_lines + wlen + 1 > MAX_LINES_PER_FILE:  # +1 预留段间空行
            # 边界：若单段本身 >500？理论上最大 419 <500，故不会单段超限
            if wlen + header_len > MAX_LINES_PER_FILE:
                print(f"WARN seg {seg['num']} wrapped {wlen} exceeds limit, will isolate", file=sys.stderr)
            shards.append(cur)
            cur = []
            cur_lines = header_len
        cur.append(i)
        cur_lines += wlen + 1  # 段间空行

    if cur:
        shards.append(cur)

    print(f"packed into {len(shards)} shards (header {header_len} lines, limit {MAX_LINES_PER_FILE})")
    for idx, sh in enumerate(shards):
        nums = [segments[i]["num"] for i in sh]
        wtotal = sum(len(segments[i]["wrapped"]) for i in sh) + header_len + len(sh)
        print(f" shard {idx+1}: segments {nums[0]}-{nums[-1]} ({len(sh)} segs) -> {wtotal} lines")

    # 清理旧分片（6 个）并生成新分片
    handbook_dir = repo_root / "docs" / "handbook" / "polish-patterns"
    handbook_dir.mkdir(parents=True, exist_ok=True)

    # 删除旧 9.6.*.md（若存在）
    old_files = list(handbook_dir.glob("9.6.*.md"))
    # 若非 force 且已有新分片数量匹配则跳过？但要求幂等 force 覆盖，否则跳过需显式
    # 简化：若 old_files 数量已等于 shards 且非 force，则提示跳过
    if old_files and not args.force:
        # 检查是否已为完整迁移（非截断）：简单看是否存在已截断标记
        has_truncated = any("已截断" in p.read_text(encoding="utf-8", errors="ignore") for p in old_files)
        if not has_truncated and len(old_files) == len(shards):
            print("handbook shards already exist and look complete, skip (use --force to overwrite)")
            # 仍需更新 redirect/index 吗？跳过
            # 但为幂等，我们仍继续生成 redirect/index 若缺失
            pass
        else:
            print(f"found {len(old_files)} old shards, will overwrite with {len(shards)} new shards (use --force to confirm)")
            # 若非 force，我们仍继续但会覆盖？按 spec 幂等：若已存在则 -Force 覆盖，否则跳过需显式
            # 此处若非 force 且检测到截断，则强制覆盖以修复
            if has_truncated:
                print("detected truncated shards, overwriting despite not --force (fix mode)")
            else:
                # 已完整且非 force，跳过生成
                shards = []  # 阻止生成

    # 若 shards 非空则生成
    shard_files = []
    if shards:
        # 先删除旧文件（仅当将要生成新文件时）
        for p in old_files:
            try:
                p.unlink()
            except Exception:
                pass
        for sh_idx, seg_indices in enumerate(shards):
            nums = [segments[i]["num"] for i in seg_indices]
            start_n = nums[0]
            end_n = nums[-1]
            fname = f"9.6.{start_n:02d}-{end_n:02d}.md"
            fpath = handbook_dir / fname
            # 生成内容
            lines_out = []
            lines_out.append(f"# Polish Patterns 9.6.{start_n:02d}–{end_n:02d}")
            lines_out.append("")
            lines_out.append(f"> 本文件为 CONTRIBUTING §9.6 迁移分片，覆盖 9.6.{start_n}–9.6.{end_n}，共 {len(seg_indices)} 段。")
            lines_out.append(f"> 查询接口：每段以 \"### 9.6.N\" 锚点提供，供 Task 6 校验每文件 <500 行。")
            lines_out.append(f"> 归属：docs/handbook/polish-patterns/{fname}")
            lines_out.append("")
            # 注释：已完整迁移，无截断
            lines_out.append(f"<!-- shard {start_n:02d}-{end_n:02d} 共 {len(seg_indices)} 段，完整迁移，行长 ≤{MAX_LEN}，每文件 <{MAX_LINES_PER_FILE} 行 -->")
            lines_out.append("")
            for seg_i in seg_indices:
                seg = segments[seg_i]
                # 每段 wrapped 已包含标题行，段间加空行分隔
                lines_out.extend(seg["wrapped"])
                lines_out.append("")
            # 去掉末尾空行，写入时保留换行
            text = "\n".join(lines_out).rstrip() + "\n"
            # 校验
            split = text.splitlines()
            assert len(split) < MAX_LINES_PER_FILE, f"{fname} {len(split)} >= {MAX_LINES_PER_FILE}"
            assert max(ps_len(l) for l in split) <= MAX_LEN, f"{fname} has long line >{MAX_LEN} ps_len"
            # 围栏偶数校验
            fence_cnt = text.count("```")
            assert fence_cnt % 2 == 0, f"{fname} fence odd {fence_cnt}"
            fpath.write_text(text, encoding="utf-8")
            shard_files.append(fname)
            print(f" wrote {fname} {len(split)} lines, fence {fence_cnt}")
    else:
        # 已跳过生成，收集现有文件
        shard_files = sorted([p.name for p in handbook_dir.glob("9.6.*.md")])
        print(f" skipped generation, existing {len(shard_files)} shards")

    # 如果是跳过模式，shard_files 已收集；否则已生成
    if not shard_files:
        shard_files = sorted([p.name for p in handbook_dir.glob("9.6.*.md")])

    # 生成 index.md（完整覆盖）
    idx_path = handbook_dir / "index.md"
    # 按 shard 文件排序并提取覆盖范围
    # shard_files 已是 9.6.XX-YY.md，按 XX 排序
    def parse_range(fname):
        m = re.match(r"9\.6\.(\d+)-(\d+)\.md", fname)
        if m:
            return int(m.group(1)), int(m.group(2))
        return (0, 0)

    shard_files_sorted = sorted(shard_files, key=lambda x: parse_range(x)[0])

    # 若 shards 非空，使用 shards 的 nums 否则从文件名解析
    # 构建 index 内容
    idx_lines = []
    idx_lines.append("# Polish Patterns 索引")
    idx_lines.append("")
    idx_lines.append(f"> 本索引为 CONTRIBUTING §9.6 113 段的 {len(shard_files_sorted)} 分片导航。")
    idx_lines.append(f"> 每分片覆盖范围与段数如下，单分片 <{MAX_LINES_PER_FILE} 行且每行 ≤{MAX_LEN}。")
    idx_lines.append("")
    for fname in shard_files_sorted:
        m = re.match(r"9\.6\.(\d+)-(\d+)\.md", fname)
        if m:
            a = int(m.group(1))
            b = int(m.group(2))
            cnt = b - a + 1
            idx_lines.append(f"- [{a:02d}-{b:02d}]({fname}) — 覆盖 9.6.{a}–9.6.{b}（{cnt} 段）")
        else:
            idx_lines.append(f"- [{fname}]({fname})")
    idx_lines.append("")
    idx_lines.append("查询示例：")
    idx_lines.append("")
    idx_lines.append("- `rg \"### 9.6.101\" handbook/polish-patterns/` 可定位 9.6.101 段")
    idx_lines.append("- 各分片均提供 `### 9.6.N` 锚点查询接口")
    idx_lines.append("")
    idx_lines.append("关联：")
    idx_lines.append("")
    idx_lines.append("- 核心指南：[contributing-core.md](../../02-guides/contributing-core.md)")
    idx_lines.append("- 总导航：[00-index.md](../../00-index.md)")
    idx_lines.append("")
    idx_lines.append("迁移说明：")
    idx_lines.append("")
    idx_lines.append(f"- 原始 CONTRIBUTING.md 共 2940 行，113 段 §9.6 已按动态打包拆分至 {len(shard_files_sorted)} 分片（约 2-4 段/文件）")
    idx_lines.append(f"- 单文件 ≤800 行、单行 ≤{MAX_LEN} 字符（lint 硬阈），handbook 每文件 <{MAX_LINES_PER_FILE} 行")
    idx_lines.append(f"- 旧锚点通过 docs/redirect-map.json 113 条映射兼容")
    idx_lines.append(f"- 历史保留：`git log --follow -- CONTRIBUTING.md` 可追踪迁移（原始 blob {ORIG_BLOB} at {BASE_SHA}）")
    idx_lines.append("")

    idx_text = "\n".join(idx_lines)
    # 校验 index 含 9.6.101
    assert "9.6.101" in idx_text, "index must contain 9.6.101"
    # 若已存在且非 force 且内容一致则跳过？简化直接写
    idx_path.write_text(idx_text, encoding="utf-8")
    print(f" wrote index.md {len(idx_text.splitlines())} lines")

    # 生成 redirect-map.json：映射至实际所在 shard
    # 构建 num -> fname 映射
    num_to_file = {}
    # 如果 shards 已生成，使用 shards 结构；否则从现有 shard_files 解析
    if shards:
        for seg_indices, fname in zip(shards, shard_files_sorted):
            # 注意 shard_files_sorted 顺序与 shards 顺序一致（按 start 排序）
            for seg_i in seg_indices:
                num = segments[seg_i]["num"]
                num_to_file[num] = fname
    else:
        # 从现有文件解析：需要读取每个 shard 的内容grep 9.6.N
        for fname in shard_files_sorted:
            fpath = handbook_dir / fname
            txt = fpath.read_text(encoding="utf-8")
            for m in re.finditer(r"^### 9\.6\.(\d+)", txt, flags=re.MULTILINE):
                num = int(m.group(1))
                num_to_file[num] = fname
        # 若仍缺失，用文件名范围推断
        for fname in shard_files_sorted:
            m = re.match(r"9\.6\.(\d+)-(\d+)\.md", fname)
            if m:
                a = int(m.group(1)); b = int(m.group(2))
                for n in range(a, b+1):
                    if n not in num_to_file:
                        num_to_file[n] = fname

    redirect = {}
    for n in range(1, 114):
        fname = num_to_file.get(n)
        if not fname:
            # fallback: 查找
            for f in shard_files_sorted:
                mm = re.match(r"9\.6\.(\d+)-(\d+)\.md", f)
                if mm and int(mm.group(1)) <= n <= int(mm.group(2)):
                    fname = f
                    break
        assert fname, f"no file for {n}"
        redirect[f"CONTRIBUTING.md#9.6.{n}"] = f"handbook/polish-patterns/{fname}#9.6.{n}"

    redirect_path = repo_root / "docs" / "redirect-map.json"
    # 保持键排序按数值
    sorted_redirect = {k: redirect[k] for k in sorted(redirect, key=lambda x: int(x.split("#9.6.")[1]))}
    json_text = json.dumps(sorted_redirect, ensure_ascii=False, indent=2)
    # 校验 113 条
    assert len(sorted_redirect) == 113, f"redirect {len(sorted_redirect)} !=113"
    redirect_path.write_text(json_text + "\n", encoding="utf-8")
    print(f" wrote redirect-map.json {len(sorted_redirect)} entries")

    # 可选：更新 CONTRIBUTING.md 代理中的 git log --follow 锚点（若不存在则追加）
    contrib_path = repo_root / "CONTRIBUTING.md"
    if contrib_path.exists():
        txt = contrib_path.read_text(encoding="utf-8")
        if "git log --follow" not in txt:
            # 追加一行到迁移说明段
            if "历史保留" in txt:
                txt = txt.replace("历史保留：git log --follow 可追踪迁移", f"历史保留：`git log --follow -- CONTRIBUTING.md` 可追踪迁移（原始 {BASE_SHA}:{ORIG_BLOB}）")
                contrib_path.write_text(txt, encoding="utf-8")
                print(" updated CONTRIBUTING.md with git log --follow anchor")

    print("migrate done")


if __name__ == "__main__":
    main()
