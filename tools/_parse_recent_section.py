#!/usr/bin/env python3
# tools/_parse_recent_section.py
#
# T265 (#186) — Helper: parse "Recent completed work" / "最近完成的工作"
# section from a README file, and print the latest #N entry found.
#
# This is a Python re-implementation of the awk parser in
# tools/check_smoke_consistency.sh Rule 7, because the awk version
# silently produces empty output when a `## #N` heading immediately
# follows `### Recent completed work` (the flag gets reset on the
# very next line before any line is printed).
#
# Section detection rules:
#   - Section starts at `^#{2,3}\s+(Recent completed work|最近完成的工作)\s*$`
#   - Section includes `## #N` heading lines (each is a #N entry)
#   - Section ENDS at:
#     (a) the next `## ` (2 #) heading line that is NOT a #N entry
#         (e.g. `## Recent completed work` of a parent section), OR
#     (b) the next `### ` (3 #) heading line (a sub-section)
#   - "## #N" 标题之间的内容里 #N 引用全部忽略（避免文本叙述污染）
#
# Output: latest #N number (e.g. "185") or empty string if no entry found.
# Exit 0 always (caller decides pass/fail based on output).
#
# Usage:
#   python3 tools/_parse_recent_section.py README.md
#   python3 tools/_parse_recent_section.py README.zh-CN.md
#
# Reviews: see REVIEW_LOG.md #185 FIX-#185-1 + ITERATION_GUIDE.md T265.

import re
import sys
import os


def parse_recent_section(path: str) -> str:
    """Return the latest #N number from the 'Recent completed work' section,
    or empty string if not found.

    "Latest" is defined as the **largest numeric** #N, not the last line we
    happen to see — sections may be ordered reverse-chronologically (newest
    first), so a naive "last match wins" approach would return the oldest #N
    instead of the newest.
    """
    if not path or not os.path.exists(path):
        return ""

    with open(path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    in_section = False
    max_n = 0

    for line in lines:
        stripped = line.rstrip("\n")

        # Check if we are entering the section.
        if not in_section:
            m = re.match(r"^#{2,3}\s+(Recent completed work|最近完成的工作)\s*$", stripped)
            if m:
                in_section = True
            continue

        # We are inside the section. Process headings line-by-line.
        # A `## #N` heading is itself a #N entry.
        m_n = re.match(r"^##\s+#\s*(\d+)", stripped)
        if m_n:
            n = int(m_n.group(1))
            if n > max_n:
                max_n = n
            continue

        # `### ` (3 #) heading ends the section (next sub-section).
        if re.match(r"^###\s+", stripped):
            break

        # `## ` (2 #) heading that is NOT a #N entry ends the section.
        # (e.g. `## Open Items`, `## Inspiration`, etc.)
        if re.match(r"^##\s+", stripped):
            break

        # Otherwise (regular text, `>` blockquote, empty line, etc.) — ignore
        # any #N references in the text to avoid false positives from prose
        # like "下一轮（#186, 186%5==1 普通模式）suggested candidates" which
        # mention upcoming #N values.

    return str(max_n) if max_n > 0 else ""


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 _parse_recent_section.py <README.md>", file=sys.stderr)
        sys.exit(2)
    result = parse_recent_section(sys.argv[1])
    print(result)
    sys.exit(0)
