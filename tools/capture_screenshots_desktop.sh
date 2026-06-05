#!/usr/bin/env bash
# Voxglass 真实游戏截图 (桌面环境版本)
# =====================================
# 在带 Xvfb / X11 / Wayland / 真机的环境运行：
#   - 使用 Godot 4.6.3 + OpenGL3 渲染器真实截取
#   - 需要 Xvfb (apt install xvfb) 或真机显示器
#
# 用法:
#   ./tools/capture_screenshots_desktop.sh
#
# 输出:
#   docs/screenshots/01_title_screen.png (1920x1080)
#   docs/screenshots/02_hub_room.png
#   docs/screenshots/03_archive_01_pulse.png
#   docs/screenshots/04_archive_03_boss.png
#   docs/screenshots/05_archive_04_double_boss.png
#   docs/screenshots/06_shop_merchant.png

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "$SCRIPT_DIR/.." && pwd)"
GODOT="${GODOT:-$WORKSPACE/godot/Godot_v4.6.3-stable_linux.x86_64}"

cd "$WORKSPACE"

if [ ! -x "$GODOT" ]; then
    echo "[ERR] Godot binary not found: $GODOT"
    echo "      See godot/README.md 解压步骤"
    exit 1
fi

# 准备 Xvfb（如果可用）
if command -v xvfb-run >/dev/null 2>&1; then
    WRAPPER="xvfb-run -a -s '-screen 0 1920x1080x24'"
elif [ -n "$DISPLAY" ]; then
    WRAPPER=""
else
    echo "[WARN] Xvfb 未安装且无 \$DISPLAY，将尝试 headless 模式（可能失败）"
    echo "       推荐: sudo apt install xvfb"
    WRAPPER=""
fi

OUT_DIR="$WORKSPACE/docs/screenshots"
mkdir -p "$OUT_DIR"

# 截图配置: scene_path output_path wait_frames
SHOTS=(
    "res://src/scenes/title_screen.tscn  01_title_screen.png          45"
    "res://src/scenes/hub_room.tscn      02_hub_room.png              90"
    "res://src/scenes/json_room.tscn     03_archive_01_pulse.png      60"
    "res://src/scenes/json_room.tscn     04_archive_03_boss.png       60"
    "res://src/scenes/json_room.tscn     05_archive_04_double_boss.png 60"
    "res://src/scenes/hub_room.tscn      06_shop_merchant.png          60"
)

# 注: json_room 是 generic; 实际特定房间需要单独的 .tscn 或在
# RoomLoader 启动时通过 room_id 选择。这里我们直接调 json_room.tscn
# 并假设 RoomLoader 默认加载 archive_01; 其余需通过命令行参数覆盖。
# 详见 tools/capture_with_room.py 替代方案（待写）。

echo "==============================================="
echo " Voxglass 真实截图 (桌面环境)"
echo "==============================================="
echo " godot:  $GODOT"
echo " xvfb:   ${WRAPPER:-none}"
echo ""

for shot in "${SHOTS[@]}"; do
    read -r scene out frames <<< "$shot"
    out_path="$OUT_DIR/$out"
    if [ -f "$out_path" ]; then
        echo "  ↻ skip $out (exists)"
        continue
    fi
    echo "  → capturing $out (scene=$scene, frames=$frames)"
    $WRAPPER timeout 30 "$GODOT" \
        --rendering-driver opengl3 \
        --audio-driver Dummy \
        --path "$WORKSPACE" \
        -s tools/screenshot_capture.gd -- \
        "$scene" "$out_path" "$frames" 2>&1 | tail -5
done

echo ""
echo "✅ 完成。截图位于 $OUT_DIR"
ls -lh "$OUT_DIR"/*.png 2>/dev/null | awk '{printf "  %s  %s\n", $5, $9}'
