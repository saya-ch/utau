#!/usr/bin/env python3
"""
T090 — 程序化生成 4 个环境装饰物件 sprite：
  1. archive_reed（水面/地面芦苇 — 暖色细长植物，3-4 株丛生）
  2. glass_shards（破损玻璃碎片堆 — 3-5 个青色三角形碎片）
  3. voice_feather（声音羽毛 — 浅色半透明细长羽毛飘落）
  4. archive_vine（档案馆藤蔓 — 墙上波浪线 + 节点攀附）

色板严格遵循 STYLE_GUIDE.md Voxglass 视觉宪法。
输出：32x32 透明背景 PNG，1px 黑色描边可选，1px 内描边。
"""

import math
import os
import random
from PIL import Image, ImageDraw

# STYLE_GUIDE 色板
ABYSS_BLACK = (5, 7, 13)
INK_NAVY = (8, 20, 38)
ARCHIVE_BLUE = (18, 51, 74)
DEEP_TEAL = (29, 101, 112)
GLASS_CYAN = (105, 199, 206)
PALE_RESONANCE = (183, 231, 221)
MUTED_VIOLET = (101, 80, 106)
CORAL_PULSE = (232, 109, 90)
AMBER_VOICE = (242, 182, 110)
WARM_PARCHMENT = (230, 213, 184)
BLACK_1PX = (0, 0, 0, 255)


# ─────────────────────────────────────────────────────────────
# 1. Archive Reed（芦苇丛）
# 设计：底部深色基座 + 3 株茎杆（细线）+ 顶部弯曲线条叶尖
# 尺寸 32x32
# ─────────────────────────────────────────────────────────────
def draw_archive_reed(size: int = 32, seed: int = 1054) -> Image.Image:
	rng = random.Random(seed)
	img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	draw = ImageDraw.Draw(img)

	# 底部水/泥基座（横向椭圆）
	draw.ellipse([4, 26, 28, 30], fill=(*DEEP_TEAL, 180))
	draw.ellipse([6, 27, 26, 29], fill=(*ARCHIVE_BLUE, 220))

	# 3 株茎杆
	stems = [
		(11, 24, 9, 5, AMBER_VOICE),    # 左：直立
		(16, 22, 13, 6, WARM_PARCHMENT), # 中：略弯
		(21, 24, 11, 5, AMBER_VOICE),    # 右：直立
	]

	for base_x, base_y, height, sway, color in stems:
		# 茎杆路径（用 4 段点画曲线）
		points = []
		for t in range(0, 11):
			tt = t / 10.0
			# 二次曲线：底部直立，顶部略微弯曲
			x = base_x + sway * (tt * tt) * rng.choice([-1, 1]) * 0.5
			y = base_y - tt * height
			points.append((x, y))
		# 茎杆本体（2px 暖色）
		for i in range(len(points) - 1):
			draw.line([points[i], points[i + 1]], fill=(*color, 220), width=1)
		# 茎杆上端叶尖（细长三角）
		top_x, top_y = points[-1]
		sway_dir = rng.choice([-1, 1])
		leaf_tip = (top_x + sway_dir * 3, top_y - 2)
		draw.polygon(
			[(top_x - 1, top_y), (top_x + 1, top_y), (leaf_tip[0], leaf_tip[1])],
			fill=(*color, 240),
		)
		# 茎杆中段芦苇穗（细椭圆）
		mid_x, mid_y = points[len(points) // 2]
		draw.ellipse(
			[mid_x - 1, mid_y - 2, mid_x + 1, mid_y + 2],
			fill=(*CORAL_PULSE, 200),
		)

	# 暗角噪点
	pixels = img.load()
	for y in range(size):
		for x in range(size):
			r, g, b, a = pixels[x, y]
			if a > 0 and rng.random() < 0.05:
				noise = rng.randint(-6, 6)
				pixels[x, y] = (
					max(0, min(255, r + noise)),
					max(0, min(255, g + noise)),
					max(0, min(255, b + noise)),
					a,
				)

	return img


# ─────────────────────────────────────────────────────────────
# 2. Glass Shards（破损玻璃碎片堆）
# 设计：地面散落的 4-5 个三角形玻璃碎片，1px 青色边缘高亮
# ─────────────────────────────────────────────────────────────
def draw_glass_shards(size: int = 32, seed: int = 1055) -> Image.Image:
	rng = random.Random(seed)
	img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	draw = ImageDraw.Draw(img)

	# 地面阴影（横向深色椭圆）
	draw.ellipse([3, 24, 29, 30], fill=(*ABYSS_BLACK, 150))

	# 4 个三角形碎片，按 y 顺序画（后画的在上）
	shards = [
		# (center_x, base_y, width, height, fill, edge)
		(8, 22, 7, 9, PALE_RESONANCE, GLASS_CYAN),
		(15, 24, 8, 7, ARCHIVE_BLUE, GLASS_CYAN),
		(21, 22, 6, 10, PALE_RESONANCE, GLASS_CYAN),
		(26, 25, 5, 6, MUTED_VIOLET, GLASS_CYAN),
	]

	for cx, base_y, w, h, fill, edge in shards:
		# 随机微抖动
		jx = rng.randint(-1, 1)
		jy = rng.randint(-1, 1)
		# 三角形顶点：顶尖朝上
		top = (cx + jx, base_y - h + jy)
		left = (cx - w // 2 + jx, base_y + jy)
		right = (cx + w // 2 + jx, base_y + jy)
		# 填充
		draw.polygon([top, left, right], fill=(*fill, 220))
		# 1px 青色边缘（左侧亮线）
		draw.line([top, left], fill=(*edge, 255), width=1)
		draw.line([top, right], fill=(*edge, 200), width=1)
		# 底部白反光
		draw.line(
			[(left[0] + 1, left[1] - 1), (right[0] - 1, right[1] - 1)],
			fill=(255, 255, 255, 200),
			width=1,
		)

	# 中央点缀一个发光小颗粒（"残留声波"）
	draw.ellipse([15, 18, 17, 20], fill=(*AMBER_VOICE, 220))
	draw.ellipse([15, 18, 16, 19], fill=(255, 255, 255, 255))

	# 噪点
	pixels = img.load()
	for y in range(size):
		for x in range(size):
			r, g, b, a = pixels[x, y]
			if a > 0 and rng.random() < 0.05:
				noise = rng.randint(-5, 5)
				pixels[x, y] = (
					max(0, min(255, r + noise)),
					max(0, min(255, g + noise)),
					max(0, min(255, b + noise)),
					a,
				)

	return img


# ─────────────────────────────────────────────────────────────
# 3. Voice Feather（声音羽毛）
# 设计：飘落的细长羽毛，主体浅色，羽轴细线，羽枝稀疏
# ─────────────────────────────────────────────────────────────
def draw_voice_feather(size: int = 32, seed: int = 1056) -> Image.Image:
	rng = random.Random(seed)
	img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	draw = ImageDraw.Draw(img)

	# 羽毛主轴（从底部到顶部，微微弧形）
	start = (10, 28)
	end = (22, 4)
	control = (20, 18)  # 弯曲控制点

	# 画三次贝塞尔近似
	points = []
	for t in range(0, 21):
		tt = t / 20.0
		x = (1 - tt) ** 2 * start[0] + 2 * (1 - tt) * tt * control[0] + tt ** 2 * end[0]
		y = (1 - tt) ** 2 * start[1] + 2 * (1 - tt) * tt * control[1] + tt ** 2 * end[1]
		points.append((x, y))

	# 羽轴细线
	for i in range(len(points) - 1):
		draw.line([points[i], points[i + 1]], fill=(*MUTED_VIOLET, 220), width=1)

	# 羽枝（从主轴垂直伸出，渐变缩短）
	for i in range(2, len(points) - 1):
		cx, cy = points[i]
		# 上下两侧羽枝
		progress = i / len(points)  # 0 → 1，从底部到顶部
		feather_len = 4 - 2 * progress  # 底部 4px → 顶部 2px
		if feather_len < 1:
			continue
		# 上侧羽枝
		draw.line(
			[(cx, cy), (cx - feather_len, cy - feather_len * 0.5)],
			fill=(*PALE_RESONANCE, 180),
			width=1,
		)
		# 下侧羽枝
		draw.line(
			[(cx, cy), (cx - feather_len, cy + feather_len * 0.5)],
			fill=(*PALE_RESONANCE, 180),
			width=1,
		)

	# 顶部羽尖（白色亮点）
	tx, ty = points[-1]
	draw.ellipse([tx - 1, ty - 1, tx + 1, ty + 1], fill=(255, 255, 255, 255))

	# 底部羽根（深色）
	bx, by = points[0]
	draw.ellipse([bx - 1, by - 1, bx + 1, by + 1], fill=(*MUTED_VIOLET, 240))

	# 周围点缀几个飘落小点（声音残响）
	for _ in range(3):
		dx = rng.randint(2, 30)
		dy = rng.randint(2, 30)
		# 不覆盖主羽毛
		if 8 < dx < 24 and 4 < dy < 28:
			continue
		draw.ellipse([dx, dy, dx + 1, dy + 1], fill=(*AMBER_VOICE, 180))

	return img


# ─────────────────────────────────────────────────────────────
# 4. Archive Vine（档案馆藤蔓）
# 设计：攀附在墙上的波浪线 + 节点，深色 + 暗紫阴影
# ─────────────────────────────────────────────────────────────
def draw_archive_vine(size: int = 32, seed: int = 1057) -> Image.Image:
	rng = random.Random(seed)
	img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	draw = ImageDraw.Draw(img)

	# 主藤蔓：2 条波浪线（不同方向）
	wave1 = []
	for t in range(0, 17):
		tt = t / 16.0
		x = 2 + tt * 28
		y = 6 + math.sin(tt * math.pi * 2.0) * 4 + tt * 14
		wave1.append((x, y))

	# 画主藤蔓
	for i in range(len(wave1) - 1):
		draw.line([wave1[i], wave1[i + 1]], fill=(*MUTED_VIOLET, 240), width=2)
		# 亮色高光
		hx1, hy1 = wave1[i]
		hx2, hy2 = wave1[i + 1]
		draw.line(
			[(hx1, hy1 - 1), (hx2, hy2 - 1)],
			fill=(*ARCHIVE_BLUE, 200),
			width=1,
		)

	# 副藤蔓（分支）
	branch_start_idx = 8
	branch_start = wave1[branch_start_idx]
	branch = []
	for t in range(0, 11):
		tt = t / 10.0
		x = branch_start[0] + tt * 6
		y = branch_start[1] - tt * 6
		branch.append((x, y))
	for i in range(len(branch) - 1):
		draw.line([branch[i], branch[i + 1]], fill=(*MUTED_VIOLET, 220), width=1)

	# 节点（叶状）：每 3 个 wave1 点放一个
	for i in range(0, len(wave1), 3):
		cx, cy = wave1[i]
		leaf_size = 2
		draw.polygon(
			[
				(cx, cy - leaf_size),
				(cx + leaf_size, cy),
				(cx, cy + leaf_size),
				(cx - leaf_size, cy),
			],
			fill=(*DEEP_TEAL, 240),
		)
		# 叶心
		draw.ellipse([cx - 1, cy - 1, cx + 1, cy + 1], fill=(*GLASS_CYAN, 220))

	# 末端 1-2 个蜷须
	end_x, end_y = wave1[-1]
	draw.line(
		[(end_x, end_y), (end_x + 2, end_y - 2)],
		fill=(*MUTED_VIOLET, 220),
		width=1,
	)
	draw.ellipse([end_x + 1, end_y - 3, end_x + 3, end_y - 1], fill=(*GLASS_CYAN, 220))

	return img


# ─────────────────────────────────────────────────────────────
# Spritesheet 拼接 + 输出
# ─────────────────────────────────────────────────────────────
def create_spritesheet(frames: list, cell_size: int = 32) -> Image.Image:
	total_w = cell_size * len(frames)
	sheet = Image.new("RGBA", (total_w, cell_size), (0, 0, 0, 0))
	for i, frame in enumerate(frames):
		sheet.paste(frame, (i * cell_size, 0))
	return sheet


if __name__ == "__main__":
	out_dir = "/workspace/assets/sprites/decorations"
	os.makedirs(out_dir, exist_ok=True)

	# 4 种装饰
	reed = draw_archive_reed(32, seed=1054)
	shards = draw_glass_shards(32, seed=1055)
	feather = draw_voice_feather(32, seed=1056)
	vine = draw_archive_vine(32, seed=1057)

	# 单帧输出
	reed.save(f"{out_dir}/archive_reed.png")
	shards.save(f"{out_dir}/glass_shards.png")
	feather.save(f"{out_dir}/voice_feather.png")
	vine.save(f"{out_dir}/archive_vine.png")

	# 4 帧 spritesheet (4 装饰合集，方便 debug)
	sheet = create_spritesheet([reed, shards, feather, vine], 32)
	sheet.save(f"{out_dir}/decorations_spritesheet.png")

	# 64x64 upscaling（用于 settings menu 缩略 / debug）
	for name, img in [
		("archive_reed", reed),
		("glass_shards", shards),
		("voice_feather", feather),
		("archive_vine", vine),
	]:
		img.resize((64, 64), Image.NEAREST).save(f"{out_dir}/{name}_64.png")

	print("Decoration sprites generated:")
	for f in [
		"archive_reed.png",
		"glass_shards.png",
		"voice_feather.png",
		"archive_vine.png",
		"decorations_spritesheet.png (4-frame, 128x32)",
		"+ 4× 64x64 upscaled variants",
	]:
		print(f"  - {out_dir}/{f}")
