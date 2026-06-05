#!/usr/bin/env bash
# Voxglass 营销截图生成器 (T083)
# =====================================
# 在沙箱 / 无 Xvfb / 无 GL context 环境运行：
#   - 使用 Python + Pillow 基于既有资产合成 6 张 1920x1080 截图
#   - 输出到 docs/screenshots/01-06_*.png
#
# 在桌面环境（带 Xvfb / X11 / 真机）使用真实 capture：
#   ./tools/capture_screenshots_desktop.sh
#
# 用法:
#   ./tools/generate_screenshot_mockups.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$WORKSPACE"

PYTHON=${PYTHON:-python3}
if ! command -v "$PYTHON" >/dev/null 2>&1; then
    echo "[ERR] python3 not found"
    exit 1
fi

# 检查 Pillow
if ! "$PYTHON" -c "from PIL import Image" 2>/dev/null; then
    echo "[INFO] 安装 Pillow ..."
    "$PYTHON" -m pip install --quiet Pillow
fi

echo "==============================================="
echo " Voxglass 营销截图 mockup 生成器 (T083)"
echo "==============================================="
echo " workspace: $WORKSPACE"
echo " python:    $($PYTHON --version 2>&1)"
echo ""

"$PYTHON" tools/generate_screenshot_mockups.py

echo ""
echo "✅ 完成。截图位于 docs/screenshots/"
ls -lh docs/screenshots/*.png 2>/dev/null | awk '{printf "  %s  %s\n", $5, $9}'
