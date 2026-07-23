extends RefCounted
# T359 smoke test — CONTRIBUTING.md §9.6.101 polish 模式 1:1 落地验证 (17 断言)
# 设计本意 — 在 CI 早期捕获 §9.6.101 段被误改/误删/旧值未升级 类问题, 0 漂到审查阶段.
# T359 #298 §9.6.101 = 6 verb 视觉组 曲率差 1 维度 6 元素 跨层 45 维度拼接 1:1 严格分离契约 polish 模式.

const _CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const _EXPECTED_SECTION_HEADER := "### 9.6.101 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 + 6 verb 调色家族 亮边 1 维度 + 6 verb 调色家族 暗边 1 维度 + 6 verb 调色家族 饱和度 1 维度 + 6 verb 调色家族 中点 1 维度 + 6 verb 视觉组 base shader 1 维度 + 6 verb cooldown ready jingle 1 维度 + 6 verb 调色家族 色调 1 维度 + 6 verb 调色家族 暖度 1 维度 + 6 verb 视觉组 形状 1 维度 + 6 verb 视觉组 时长 1 维度 + 6 verb 视觉组 起点偏移 1 维度 + 6 verb 视觉组 终点偏移 1 维度 + 6 verb 视觉组 旋转 1 维度 + 6 verb 视觉组 缩放 1 维度 + 6 verb 视觉组 透明度 1 维度 + 6 verb 视觉组 速度 1 维度 + 6 verb 视觉组 加速度 1 维度 + 6 verb 视觉组 减速度 1 维度 + 6 verb 视觉组 旋转阻尼 1 维度 + 6 verb 视觉组 角速度 1 维度 + 6 verb 视觉组 径向速度 1 维度 + 6 verb 视觉组 切向速度 1 维度 + 6 verb 视觉组 法向速度 1 维度 + 6 verb 视觉组 副法向速度 1 维度 + 6 verb 视觉组 旋度 1 维度 + 6 verb 视觉组 发散度 1 维度 + 6 verb 视觉组 切变 1 维度 + 6 verb 视觉组 螺旋度 1 维度 + 6 verb 视觉组 扭转度 1 维度 + 6 verb 视觉组 流形曲率 1 维度 + 6 verb 视觉组 雅可比行列式 1 维度 + 6 verb 视觉组 高斯曲率 1 维度 + 6 verb 视觉组 平均曲率 1 维度 + 6 verb 视觉组 总曲率 1 维度 + 6 verb 视觉组 主曲率 max 1 维度 + 6 verb 视觉组 主曲率 min 1 维度 + 6 verb 视觉组 曲率差 1 维度 跨层 45 维度拼接 1:1 严格分离契约 polish 模式 (T359 #298 跨 1 任务 1 轮落地) 文档化"
const _EXPECTED_ELEMENT_KEY := "shape_curvature_difference"
const _EXPECTED_ELEMENT_VALUES := [
	"Pulse 曲率差 0.00",
	"Bind 曲率差 0.50",
	"Cut 曲率差 0.42",
	"Echo 曲率差 0.14",
	"Wave 曲率差 0.64",
	"Whisper 曲率差 0.00",
]
const _EXPECTED_FORMULA_KEY := "Δκ = κ₁ - κ₂"
const _EXPECTED_TOTAL_ELEMENTS := "289 元素"
const _EXPECTED_CROSS_LAYER := "跨层 45 维度拼接"
const _EXPECTED_RULE_BROKEN_SECTIONS := [
	"§9.6.1-§9.6.100 100 段 0 旧段触碰",
	"0 触碰 CONTRIBUTING.md 既有 95 套 polish 模式任何 1 字符",
]
const _EXPECTED_RELATION_MIN_PARENT := "与 §9.6.100 关系"
const _EXPECTED_RELATION_STEP_9 := "与 §9.6.1 9 步关系"
const _EXPECTED_NEW_6_ELEMENTS_NOTE := "T359 #298 新增 6 元素"
const _EXPECTED_ANISOTROPY_NOTE := "各向异性"

func _read_text(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()

func _assert_true(cond: bool, msg: String) -> bool:
	if not cond:
		push_error("T359 §9.6.101 smoke FAILED: " + msg)
	return cond

func run() -> int:
	var failures := 0
	var text := _read_text(_CONTRIBUTING_PATH)
	if text.length() == 0:
		push_error("T359 §9.6.101 smoke FAILED: CONTRIBUTING.md 不可读")
		return 1

	# 断言 1: §9.6.101 段标题存在 (与 §9.6.100 / §9.6.99 / §9.6.98 共同保持 polish 链 1:1)
	if not _assert_true(text.find(_EXPECTED_SECTION_HEADER) >= 0,
			"§9.6.101 段标题 0 找到"):
		failures += 1

	# 断言 2: shape_curvature_difference 键名存在
	if not _assert_true(text.find(_EXPECTED_ELEMENT_KEY) >= 0,
			"shape_curvature_difference 键名 0 找到 (派生自 shape_max_principal_curvature - shape_min_principal_curvature 差分)"):
		failures += 1

	# 断言 3-8: 6 元素 1:1 严格 (与 §9.6.99 max - §9.6.100 min 1:1 派生)
	for ev in _EXPECTED_ELEMENT_VALUES:
		if not _assert_true(text.find(ev) >= 0,
				"6 元素值缺失: " + ev):
			failures += 1

	# 断言 9: 派生公式 Δκ = κ₁ - κ₂ 视觉曲率各向异性 差分投影 存在
	if not _assert_true(text.find(_EXPECTED_FORMULA_KEY) >= 0,
			"派生公式 " + _EXPECTED_FORMULA_KEY + " 0 找到 (主曲率差分: max - min, Δκ ≥ 0 各向异性度量)"):
		failures += 1

	# 断言 10: 总元素 289 (从 §9.6.100 282 + 7 元素)
	if not _assert_true(text.find(_EXPECTED_TOTAL_ELEMENTS) >= 0,
			"总元素 289 0 找到 (1 维度加 6 元素 + 1 跨层 0 触碰既有 = 7 元素, 282 + 7 = 289)"):
		failures += 1

	# 断言 11: 跨层 45 维度拼接 存在
	if not _assert_true(text.find(_EXPECTED_CROSS_LAYER) >= 0,
			"跨层 45 维度拼接 0 找到 (从 §9.6.100 跨层 44 升级 1 维 → 跨层 45)"):
		failures += 1

	# 断言 12: 与 §9.6.100 关系段 存在 (1:1 派生姊妹段契约)
	if not _assert_true(text.find(_EXPECTED_RELATION_MIN_PARENT) >= 0,
			"与 §9.6.100 关系段 0 找到 (姊妹段派生契约)"):
		failures += 1

	# 断言 13: 0 触碰既有 100 段契约 存在
	if not _assert_true(text.find(_EXPECTED_RULE_BROKEN_SECTIONS[0]) >= 0,
			"0 触碰既有 100 段契约 0 找到"):
		failures += 1

	# 断言 14: 0 触碰既有 95 套 polish 模式契约 存在
	if not _assert_true(text.find(_EXPECTED_RULE_BROKEN_SECTIONS[1]) >= 0,
			"0 触碰既有 95 套 polish 模式契约 0 找到"):
		failures += 1

	# 断言 15: 与 §9.6.1 9 步关系段 存在
	if not _assert_true(text.find(_EXPECTED_RELATION_STEP_9) >= 0,
			"与 §9.6.1 9 步关系段 0 找到 (走 4 步落地)"):
		failures += 1

	# 断言 16: T359 #298 新增 6 元素 标记 存在
	if not _assert_true(text.find(_EXPECTED_NEW_6_ELEMENTS_NOTE) >= 0,
			"T359 #298 新增 6 元素 标记 0 找到 (T359 #298 跨 1 任务 1 轮落地)"):
		failures += 1

	# 断言 17: 各向异性 标记 存在 (curvature difference = curvature anisotropy)
	if not _assert_true(text.find(_EXPECTED_ANISOTROPY_NOTE) >= 0,
			"各向异性 标记 0 找到 (Δκ 视觉曲率各向异性 anisotropy 标量派生)"):
		failures += 1

	if failures == 0:
		print("T359 §9.6.101 smoke PASSED (17 断言 0 失败): 289 元素 / 跨层 45 维度 / 6 元素 1:1 严格")
		return 0
	push_error("T359 §9.6.101 smoke FAILED: %d 断言失败" % failures)
	return 1
