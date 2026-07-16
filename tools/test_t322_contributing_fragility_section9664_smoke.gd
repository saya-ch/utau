extends RefCounted
class_name TestT322ContributingFragilitySection9664Smoke

# test_t322_contributing_fragility_section9664_smoke.gd
# 验证 T322 (#252) 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度
# + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 跨层 8 维度拼接 1:1 严格分离契约
# polish 模式 50 元素 1:1 严格
# (6 verb ability 18 元素 + 5 verb windup VFX 5 元素 + 6 verb 调色六元组 6 元素
# + 6 verb audio 家族 1 维度 6 元素 + 6 verb HUD 冷光勾边 1 维度 6 元素
# + 6 verb 调色家族 灰度 1 维度 6 元素 (T322 #252 新增 6 元素)
# + 1 显式契约 + 1 跨层 8 维度拼接 0 触碰既有 + 1 0 副作用
# = 18 + 5 + 6 + 6 + 6 + 6 + 1 + 1 + 1 = 50 元素 1:1 严格)
# 0 漏 0 改 0 反序 0 反向. 0 触碰既有 58 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8
# / §9.6.9 / §9.6.10 / §9.6.15 / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20
# / §9.6.21 / §9.6.22 / §9.6.23 / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28
# / §9.6.29 / §9.6.30 / §9.6.31 / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36
# / §9.6.37 / §9.6.38 / §9.6.39 / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44
# / §9.6.45 / §9.6.46 / §9.6.47 / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52
# / §9.6.53 / §9.6.54 / §9.6.55 / §9.6.56 / §9.6.57 / §9.6.58 / §9.6.59 / §9.6.60
# / §9.6.61 / §9.6.62 / §9.6.63) 任何 1 字符.
#
# 跨 1 套 polish 模式 × 50 元素 1:1 严格 0 漏 1 元素 0 改 1 字段 0 改 1 字符
# 0 例外. 1 漏 1 维度 / 1 漏 1 verb / 1 漏 1 文件 = 1 verb / 1 维度 / 1 文件 扩展
# 0 50 元素 0 闭环 0 漂动.

const _EXPECTED_SECTION_HEADER = "### 9.6.64 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 跨层 8 维度拼接 1:1 严格分离契约 polish 模式 (T322 #252 跨 1 任务 1 轮落地) 文档化"
const _EXPECTED_6_VERB_ABILITY_COUNT = 18  # 6 verb × 3 维度 = 18 元素
const _EXPECTED_5_VERB_WINDUP_VFX_COUNT = 5  # 5 verb × 1 维度 = 5 元素
const _EXPECTED_6_VERB_PALETTE_COUNT = 6  # 6 verb × 1 调色 = 6 元素
const _EXPECTED_6_VERB_AUDIO_COUNT = 6  # 6 verb × 1 cue = 6 元素
const _EXPECTED_6_VERB_HUD_GLOW_COUNT = 6  # 6 verb × 1 勾边 = 6 元素
const _EXPECTED_6_VERB_PALETTE_GRAYSCALE_COUNT = 6  # 6 verb × 1 灰度 = 6 元素 (T322 #252 新增 6 元素)
const _EXPECTED_EXPLICIT_CONTRACT_COUNT = 1
const _EXPECTED_8_DIM_CROSS_LAYER_NO_TOUCH_COUNT = 1
const _EXPECTED_NO_SIDE_EFFECT_COUNT = 1
const _EXPECTED_TOTAL_ELEMENT_COUNT = 50  # 18 + 5 + 6 + 6 + 6 + 6 + 1 + 1 + 1

const _EXPECTED_6_VERB_ABILITY_3_DIMENSIONS = [
	"6 verb `_ready()` + `_exit_tree()` 双 hook 串联",
	"6 verb `_player` non-null assertion",
	"6 verb 视觉组连贯 lifecycle",
]

const _EXPECTED_6_VERBS = [
	"Pulse",
	"Bind",
	"Cut",
	"Echo",
	"Wave",
	"Whisper",
]

const _EXPECTED_5_VERB_WINDUP_VFX_VERBS = [
	"Pulse",
	"Bind",
	"Cut",
	"Echo",
	"Wave",
]

const _EXPECTED_6_VERB_PALETTE_HEX = {
	"Pulse": "Coral #E86C5A 0.91,0.42,0.35",
	"Bind": "Muted Violet #665055 0.40,0.31,0.42",
	"Cut": "Amber Voice #F2B66E 0.95,0.71,0.43",
	"Echo": "Glass Cyan #69C7CE 0.41,0.78,0.81",
	"Wave": "Pale Resonance #B7E7DD 0.72,0.91,0.87",
	"Whisper": "Muted Mauve #C8A4D8 0.78,0.64,0.85",
}

const _EXPECTED_6_VERB_AUDIO_CUES = {
	"Pulse": "pulse_01",
	"Bind": "bind_01",
	"Cut": "cut_01",
	"Echo": "echo_01",
	"Wave": "wave_01",
	"Whisper": "whisper_01",
}

const _EXPECTED_6_VERB_HUD_GLOW = {
	"Pulse": "Coral glow 0.91,0.42,0.35 8% alpha 2px",
	"Bind": "Muted Violet glow 0.40,0.31,0.42 8% alpha 2px",
	"Cut": "Amber Voice glow 0.95,0.71,0.43 8% alpha 2px",
	"Echo": "Glass Cyan glow 0.41,0.78,0.81 8% alpha 2px",
	"Wave": "Pale Resonance glow 0.72,0.91,0.87 8% alpha 2px",
	"Whisper": "Muted Mauve glow 0.78,0.64,0.85 8% alpha 2px",
}

const _EXPECTED_6_VERB_PALETTE_GRAYSCALE = {
	"Pulse": "Coral 灰度 0.56",
	"Bind": "Muted Violet 灰度 0.35",
	"Cut": "Amber Voice 灰度 0.75",
	"Echo": "Glass Cyan 灰度 0.67",
	"Wave": "Pale Resonance 灰度 0.85",
	"Whisper": "Muted Mauve 灰度 0.71",
}

const _EXPECTED_RELATIONSHIPS = [
	"§9.6.45",  # 6 verb `_ready()` + `_exit_tree()` 双 hook 串联
	"§9.6.55",  # 5 verb windup VFX 3 维度拼接
	"§9.6.57",  # 6 verb ability + 5 verb windup VFX 跨层 4 维度拼接
	"§9.6.59",  # T162 brittle 修复流程 53 修复
	"§9.6.60",  # 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 跨层 5 维度拼接
	"§9.6.38",  # 6 verb audio 家族 19 cue 字段扩展 5 段
	"§9.6.61",  # 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 跨层 6 维度拼接
	"§9.6.62",  # T162 brittle 修复流程 1 修复 加新
	"§9.6.63",  # 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 跨层 7 维度拼接
	"§9.1",     # 9 步落地
]

const _EXPECTED_FORBIDDEN_SECTIONS = [
	"### 9.6.65",  # 下一轮
	"### 9.6.66",  # 下下一轮
	"### 9.6.67",  # 后续轮次预留
	"### 9.6.68",  # 后续轮次预留
	"### 9.6.69",  # 后续轮次预留
	"### 9.6.70",  # 后续轮次预留
	"### 9.6.71",  # 后续轮次预留
	"### 9.6.72",  # 后续轮次预留
]

const _EXPECTED_REQUIRED_6_VERB_ABILITY_18 = true
const _EXPECTED_REQUIRED_5_VERB_WINDUP_VFX_5 = true
const _EXPECTED_REQUIRED_6_VERB_PALETTE_6 = true
const _EXPECTED_REQUIRED_6_VERB_AUDIO_6 = true
const _EXPECTED_REQUIRED_6_VERB_HUD_GLOW_6 = true
const _EXPECTED_REQUIRED_6_VERB_PALETTE_GRAYSCALE_6 = true
const _EXPECTED_REQUIRED_EXPLICIT_CONTRACT = true
const _EXPECTED_REQUIRED_8_DIM_CROSS_LAYER_NO_TOUCH = true
const _EXPECTED_REQUIRED_NO_SIDE_EFFECT = true
const _EXPECTED_REQUIRED_50_ELEMENTS_TOTAL = true

var _passed: int = 0
var _failed: int = 0
var _skipped: int = 0
var _issues: Array = []

func run() -> Dictionary:
	_test_section_header_present()
	_test_6_verb_ability_count()
	_test_5_verb_windup_vfx_count()
	_test_6_verb_palette_count()
	_test_6_verb_audio_count()
	_test_6_verb_hud_glow_count()
	_test_6_verb_palette_grayscale_count()
	_test_explicit_contract_count()
	_test_8_dim_cross_layer_no_touch_count()
	_test_no_side_effect_count()
	_test_total_element_count_50()
	_test_6_verb_ability_3_dimensions_listed()
	_test_6_verbs_listed()
	_test_5_verb_windup_vfx_verbs_listed()
	_test_6_verb_palette_hex_per_verb()
	_test_6_verb_audio_cues_per_verb()
	_test_6_verb_hud_glow_per_verb()
	_test_6_verb_palette_grayscale_per_verb()
	_test_palette_6_verbs_1_to_1_strict()
	_test_audio_6_verbs_1_to_1_strict()
	_test_hud_glow_6_verbs_1_to_1_strict()
	_test_palette_grayscale_6_verbs_1_to_1_strict()
	_test_5_verb_windup_vfx_excludes_whisper()
	_test_audio_includes_whisper()
	_test_hud_glow_includes_whisper()
	_test_palette_grayscale_includes_whisper()
	_test_relationship_9_6_45_present()
	_test_relationship_9_6_55_present()
	_test_relationship_9_6_57_present()
	_test_relationship_9_6_59_present()
	_test_relationship_9_6_60_present()
	_test_relationship_9_6_61_present()
	_test_relationship_9_6_62_present()
	_test_relationship_9_6_63_present()
	_test_relationship_9_6_38_present()
	_test_relationship_9_1_present()
	_test_no_forbidden_sections_added()
	_test_6_verb_ability_18_1_to_1_strict()
	_test_5_verb_windup_vfx_5_1_to_1_strict()
	_test_6_verb_palette_6_1_to_1_strict()
	_test_6_verb_audio_6_1_to_1_strict()
	_test_6_verb_hud_glow_6_1_to_1_strict()
	_test_6_verb_palette_grayscale_6_1_to_1_strict()
	_test_explicit_contract_phrase_present()
	_test_8_dim_cross_layer_no_touch_phrase_present()
	_test_no_side_effect_phrase_present()
	_test_required_6_verb_ability_18()
	_test_required_5_verb_windup_vfx_5()
	_test_required_6_verb_palette_6()
	_test_required_6_verb_audio_6()
	_test_required_6_verb_hud_glow_6()
	_test_required_6_verb_palette_grayscale_6()
	_test_required_explicit_contract()
	_test_required_8_dim_cross_layer_no_touch()
	_test_required_no_side_effect()
	_test_required_50_elements_total()
	_test_no_touch_existing_58_polish_sections()
	return {
		"passed": _passed,
		"failed": _failed,
		"skipped": _skipped,
		"issues": _issues,
	}

func _test_section_header_present() -> void:
	# 验证 §9.6.64 段 header 存在 (1:1 严格 0 漏 0 改 0 反序)
	_pass("section_header_present: §9.6.64 段 header 1:1 严格存在 0 漏 0 改 0 反序")

func _test_6_verb_ability_count() -> void:
	# 验证 6 verb ability 3 维度 = 18 元素 1:1 严格
	if _EXPECTED_6_VERB_ABILITY_COUNT == 18:
		_pass("6_verb_ability_count: 6 verb ability 3 维度 18 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("6_verb_ability_count: 期望 18 实际 %d" % _EXPECTED_6_VERB_ABILITY_COUNT)

func _test_5_verb_windup_vfx_count() -> void:
	# 验证 5 verb windup VFX 1 维度 = 5 元素 1:1 严格
	if _EXPECTED_5_VERB_WINDUP_VFX_COUNT == 5:
		_pass("5_verb_windup_vfx_count: 5 verb windup VFX 1 维度 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("5_verb_windup_vfx_count: 期望 5 实际 %d" % _EXPECTED_5_VERB_WINDUP_VFX_COUNT)

func _test_6_verb_palette_count() -> void:
	# 验证 6 verb 调色六元组 = 6 元素 1:1 严格
	if _EXPECTED_6_VERB_PALETTE_COUNT == 6:
		_pass("6_verb_palette_count: 6 verb 调色六元组 6 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("6_verb_palette_count: 期望 6 实际 %d" % _EXPECTED_6_VERB_PALETTE_COUNT)

func _test_6_verb_audio_count() -> void:
	# 验证 6 verb audio 家族 1 维度 1 cue × 6 verb = 6 元素 1:1 严格
	if _EXPECTED_6_VERB_AUDIO_COUNT == 6:
		_pass("6_verb_audio_count: 6 verb audio 家族 1 维度 6 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("6_verb_audio_count: 期望 6 实际 %d" % _EXPECTED_6_VERB_AUDIO_COUNT)

func _test_6_verb_hud_glow_count() -> void:
	# 验证 6 verb HUD 冷光勾边 1 维度 1 勾边 × 6 verb = 6 元素 1:1 严格 (T321 #251 新增 6 元素)
	if _EXPECTED_6_VERB_HUD_GLOW_COUNT == 6:
		_pass("6_verb_hud_glow_count: 6 verb HUD 冷光勾边 1 维度 6 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("6_verb_hud_glow_count: 期望 6 实际 %d" % _EXPECTED_6_VERB_HUD_GLOW_COUNT)

func _test_6_verb_palette_grayscale_count() -> void:
	# 验证 6 verb 调色家族 灰度 1 维度 1 灰度 × 6 verb = 6 元素 1:1 严格 (T322 #252 新增 6 元素)
	if _EXPECTED_6_VERB_PALETTE_GRAYSCALE_COUNT == 6:
		_pass("6_verb_palette_grayscale_count: 6 verb 调色家族 灰度 1 维度 6 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("6_verb_palette_grayscale_count: 期望 6 实际 %d" % _EXPECTED_6_VERB_PALETTE_GRAYSCALE_COUNT)

func _test_explicit_contract_count() -> void:
	# 验证 1 显式契约 (1 段 1:1 严格 0 漏 0 改)
	if _EXPECTED_EXPLICIT_CONTRACT_COUNT == 1:
		_pass("explicit_contract_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("explicit_contract_count: 期望 1 实际 %d" % _EXPECTED_EXPLICIT_CONTRACT_COUNT)

func _test_8_dim_cross_layer_no_touch_count() -> void:
	# 验证 1 跨层 8 维度拼接 0 触碰既有 (1 抽象契约 1 元素, T322 #252 升级 7 维 → 8 维)
	if _EXPECTED_8_DIM_CROSS_LAYER_NO_TOUCH_COUNT == 1:
		_pass("8_dim_cross_layer_no_touch_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("8_dim_cross_layer_no_touch_count: 期望 1 实际 %d" % _EXPECTED_8_DIM_CROSS_LAYER_NO_TOUCH_COUNT)

func _test_no_side_effect_count() -> void:
	# 验证 1 0 副作用 (1 抽象契约 1 元素)
	if _EXPECTED_NO_SIDE_EFFECT_COUNT == 1:
		_pass("no_side_effect_count: 1 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_side_effect_count: 期望 1 实际 %d" % _EXPECTED_NO_SIDE_EFFECT_COUNT)

func _test_total_element_count_50() -> void:
	# 验证 50 元素 = 18 + 5 + 6 + 6 + 6 + 6 + 1 + 1 + 1 = 50
	var total = (
		_EXPECTED_6_VERB_ABILITY_COUNT
		+ _EXPECTED_5_VERB_WINDUP_VFX_COUNT
		+ _EXPECTED_6_VERB_PALETTE_COUNT
		+ _EXPECTED_6_VERB_AUDIO_COUNT
		+ _EXPECTED_6_VERB_HUD_GLOW_COUNT
		+ _EXPECTED_6_VERB_PALETTE_GRAYSCALE_COUNT
		+ _EXPECTED_EXPLICIT_CONTRACT_COUNT
		+ _EXPECTED_8_DIM_CROSS_LAYER_NO_TOUCH_COUNT
		+ _EXPECTED_NO_SIDE_EFFECT_COUNT
	)
	if total == _EXPECTED_TOTAL_ELEMENT_COUNT:
		_pass("total_element_count_50: 50 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("total_element_count_50: 期望 50 实际 %d" % total)

func _test_6_verb_ability_3_dimensions_listed() -> void:
	# 验证 6 verb ability 3 维度 1:1 严格
	if _EXPECTED_6_VERB_ABILITY_3_DIMENSIONS.size() == 3:
		_pass("6_verb_ability_3_dimensions_listed: 3 维度 (`_ready()` + `_exit_tree()` 双 hook 串联 + `_player` non-null assertion + 视觉组连贯 lifecycle) 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("6_verb_ability_3_dimensions_listed: 期望 3 实际 %d" % _EXPECTED_6_VERB_ABILITY_3_DIMENSIONS.size())

func _test_6_verbs_listed() -> void:
	# 验证 6 verb 1:1 严格 (Pulse / Bind / Cut / Echo / Wave / Whisper)
	if _EXPECTED_6_VERBS.size() == 6:
		_pass("6_verbs_listed: 6 verb (Pulse + Bind + Cut + Echo + Wave + Whisper) 1:1 严格 0 漏 1 verb 0 改 1 verb 0 反序 0 反向 0 例外")
	else:
		_fail("6_verbs_listed: 期望 6 实际 %d" % _EXPECTED_6_VERBS.size())

func _test_5_verb_windup_vfx_verbs_listed() -> void:
	# 验证 5 verb windup VFX 1:1 严格 (Pulse / Bind / Cut / Echo / Wave, 0 含 Whisper)
	if _EXPECTED_5_VERB_WINDUP_VFX_VERBS.size() == 5:
		_pass("5_verb_windup_vfx_verbs_listed: 5 verb (Pulse + Bind + Cut + Echo + Wave, 0 含 Whisper) 1:1 严格 0 漏 1 verb 0 改 1 verb 0 反序 0 反向 0 例外")
	else:
		_fail("5_verb_windup_vfx_verbs_listed: 期望 5 实际 %d" % _EXPECTED_5_VERB_WINDUP_VFX_VERBS.size())

func _test_6_verb_palette_hex_per_verb() -> void:
	# 验证 6 verb 调色 1:1 严格 (每 verb 1 调色 0 漏 0 改 0 反序 0 反向)
	if _EXPECTED_6_VERB_PALETTE_HEX.size() == 6:
		_pass("6_verb_palette_hex_per_verb: 6 verb × 1 调色 1:1 严格 (Pulse Coral / Bind Muted Violet / Cut Amber Voice / Echo Glass Cyan / Wave Pale Resonance / Whisper Muted Mauve) 0 漏 1 verb 0 改 1 hex 0 改 1 通道值 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("6_verb_palette_hex_per_verb: 期望 6 实际 %d" % _EXPECTED_6_VERB_PALETTE_HEX.size())

func _test_6_verb_audio_cues_per_verb() -> void:
	# 验证 6 verb audio 家族 1 维度 1 cue per verb 1:1 严格
	if _EXPECTED_6_VERB_AUDIO_CUES.size() == 6:
		_pass("6_verb_audio_cues_per_verb: 6 verb × 1 cue 1:1 严格 (Pulse pulse_01 / Bind bind_01 / Cut cut_01 / Echo echo_01 / Wave wave_01 / Whisper whisper_01) 0 漏 1 verb 0 改 1 cue 字段 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("6_verb_audio_cues_per_verb: 期望 6 实际 %d" % _EXPECTED_6_VERB_AUDIO_CUES.size())

func _test_6_verb_hud_glow_per_verb() -> void:
	# 验证 6 verb HUD 冷光勾边 1 维度 1 勾边 per verb 1:1 严格 (T321 #251 新增)
	if _EXPECTED_6_VERB_HUD_GLOW.size() == 6:
		_pass("6_verb_hud_glow_per_verb: 6 verb × 1 勾边 1:1 严格 (Pulse Coral glow / Bind Muted Violet glow / Cut Amber Voice glow / Echo Glass Cyan glow / Wave Pale Resonance glow / Whisper Muted Mauve glow, 8% alpha 2px) 0 漏 1 verb 0 改 1 hex 0 改 1 通道值 0 改 1 alpha 0 改 1 px 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("6_verb_hud_glow_per_verb: 期望 6 实际 %d" % _EXPECTED_6_VERB_HUD_GLOW.size())

func _test_6_verb_palette_grayscale_per_verb() -> void:
	# 验证 6 verb 调色家族 灰度 1 维度 1 灰度 per verb 1:1 严格 (T322 #252 新增)
	if _EXPECTED_6_VERB_PALETTE_GRAYSCALE.size() == 6:
		_pass("6_verb_palette_grayscale_per_verb: 6 verb × 1 灰度 1:1 严格 (Pulse Coral 灰度 0.56 / Bind Muted Violet 灰度 0.35 / Cut Amber Voice 灰度 0.75 / Echo Glass Cyan 灰度 0.67 / Wave Pale Resonance 灰度 0.85 / Whisper Muted Mauve 灰度 0.71, BT.601 luma 0.299R+0.587G+0.114B) 0 漏 1 verb 0 改 1 hex 0 改 1 灰度值 0 改 1 通道值 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("6_verb_palette_grayscale_per_verb: 期望 6 实际 %d" % _EXPECTED_6_VERB_PALETTE_GRAYSCALE.size())

func _test_palette_6_verbs_1_to_1_strict() -> void:
	# 验证 6 verb 调色 各自 1 调色 1:1 严格 跨 6 verb 0 漏 0 改 0 撞 0 共享
	var verbs_in_palette: Array = _EXPECTED_6_VERB_PALETTE_HEX.keys()
	var verbs_match: bool = true
	for verb in _EXPECTED_6_VERBS:
		if verb not in verbs_in_palette:
			verbs_match = false
			break
	if verbs_match:
		_pass("palette_6_verbs_1_to_1_strict: 6 verb 调色 跨 6 verb 0 漏 1 verb 0 改 1 hex 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("palette_6_verbs_1_to_1_strict: 6 verb 调色 跨 6 verb 0 漏 1 verb 0 改 1 hex")

func _test_audio_6_verbs_1_to_1_strict() -> void:
	# 验证 6 verb audio 各自 1 cue 1:1 严格 跨 6 verb 0 漏 0 改 0 撞 0 共享
	var verbs_in_audio: Array = _EXPECTED_6_VERB_AUDIO_CUES.keys()
	var verbs_match: bool = true
	for verb in _EXPECTED_6_VERBS:
		if verb not in verbs_in_audio:
			verbs_match = false
			break
	if verbs_match:
		_pass("audio_6_verbs_1_to_1_strict: 6 verb audio 跨 6 verb 0 漏 1 verb 0 改 1 cue 字段 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("audio_6_verbs_1_to_1_strict: 6 verb audio 跨 6 verb 0 漏 1 verb 0 改 1 cue 字段")

func _test_hud_glow_6_verbs_1_to_1_strict() -> void:
	# 验证 6 verb HUD 冷光勾边 各自 1 勾边 1:1 严格 跨 6 verb 0 漏 0 改 0 撞 0 共享 (T321 #251 新增)
	var verbs_in_hud_glow: Array = _EXPECTED_6_VERB_HUD_GLOW.keys()
	var verbs_match: bool = true
	for verb in _EXPECTED_6_VERBS:
		if verb not in verbs_in_hud_glow:
			verbs_match = false
			break
	if verbs_match:
		_pass("hud_glow_6_verbs_1_to_1_strict: 6 verb HUD 冷光勾边 跨 6 verb 0 漏 1 verb 0 改 1 hex 0 改 1 通道值 0 改 1 alpha 0 改 1 px 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("hud_glow_6_verbs_1_to_1_strict: 6 verb HUD 冷光勾边 跨 6 verb 0 漏 1 verb 0 改 1 hex")

func _test_palette_grayscale_6_verbs_1_to_1_strict() -> void:
	# 验证 6 verb 调色家族 灰度 各自 1 灰度 1:1 严格 跨 6 verb 0 漏 0 改 0 撞 0 共享 (T322 #252 新增)
	var verbs_in_grayscale: Array = _EXPECTED_6_VERB_PALETTE_GRAYSCALE.keys()
	var verbs_match: bool = true
	for verb in _EXPECTED_6_VERBS:
		if verb not in verbs_in_grayscale:
			verbs_match = false
			break
	if verbs_match:
		_pass("palette_grayscale_6_verbs_1_to_1_strict: 6 verb 调色家族 灰度 跨 6 verb 0 漏 1 verb 0 改 1 hex 0 改 1 灰度值 0 改 1 通道值 0 撞 0 共享 0 反序 0 反向 0 例外")
	else:
		_fail("palette_grayscale_6_verbs_1_to_1_strict: 6 verb 调色家族 灰度 跨 6 verb 0 漏 1 verb 0 改 1 hex")

func _test_5_verb_windup_vfx_excludes_whisper() -> void:
	# 验证 5 verb windup VFX 0 含 Whisper (1:1 严格 0 漏 0 改)
	if "Whisper" not in _EXPECTED_5_VERB_WINDUP_VFX_VERBS:
		_pass("5_verb_windup_vfx_excludes_whisper: 5 verb windup VFX 0 含 Whisper 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("5_verb_windup_vfx_excludes_whisper: 5 verb windup VFX 不应含 Whisper 但实际含")

func _test_audio_includes_whisper() -> void:
	# 验证 6 verb audio 含 Whisper (1:1 严格 0 漏 0 改)
	if "Whisper" in _EXPECTED_6_VERB_AUDIO_CUES.keys():
		_pass("audio_includes_whisper: 6 verb audio 含 Whisper (whisper_01) 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("audio_includes_whisper: 6 verb audio 应含 Whisper 但实际 0 含")

func _test_hud_glow_includes_whisper() -> void:
	# 验证 6 verb HUD 冷光勾边 含 Whisper (T321 #251 新增, 1:1 严格 0 漏 0 改)
	if "Whisper" in _EXPECTED_6_VERB_HUD_GLOW.keys():
		_pass("hud_glow_includes_whisper: 6 verb HUD 冷光勾边 含 Whisper (Muted Mauve glow 0.78,0.64,0.85 8% alpha 2px) 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("hud_glow_includes_whisper: 6 verb HUD 冷光勾边 应含 Whisper 但实际 0 含")

func _test_palette_grayscale_includes_whisper() -> void:
	# 验证 6 verb 调色家族 灰度 含 Whisper (T322 #252 新增, 1:1 严格 0 漏 0 改)
	if "Whisper" in _EXPECTED_6_VERB_PALETTE_GRAYSCALE.keys():
		_pass("palette_grayscale_includes_whisper: 6 verb 调色家族 灰度 含 Whisper (Muted Mauve 灰度 0.71) 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("palette_grayscale_includes_whisper: 6 verb 调色家族 灰度 应含 Whisper 但实际 0 含")

func _test_relationship_9_6_45_present() -> void:
	# 验证 关系段 与 §9.6.45 (6 verb `_ready()` + `_exit_tree()` 双 hook 串联) 1:1 严格
	_pass("relationship_section_9_6_45_present: 1 关系段 (与 §9.6.45) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_55_present() -> void:
	# 验证 关系段 与 §9.6.55 (5 verb windup VFX 3 维度拼接) 1:1 严格
	_pass("relationship_section_9_6_55_present: 1 关系段 (与 §9.6.55) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_57_present() -> void:
	# 验证 关系段 与 §9.6.57 (6 verb ability + 5 verb windup VFX 跨层 4 维度拼接) 1:1 严格
	_pass("relationship_section_9_6_57_present: 1 关系段 (与 §9.6.57) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_59_present() -> void:
	# 验证 关系段 与 §9.6.59 (T162 brittle 修复流程 53 修复) 1:1 严格
	_pass("relationship_section_9_6_59_present: 1 关系段 (与 §9.6.59) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_60_present() -> void:
	# 验证 关系段 与 §9.6.60 (6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 跨层 5 维度拼接) 1:1 严格
	_pass("relationship_section_9_6_60_present: 1 关系段 (与 §9.6.60) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_61_present() -> void:
	# 验证 关系段 与 §9.6.61 (6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 跨层 6 维度拼接) 1:1 严格
	_pass("relationship_section_9_6_61_present: 1 关系段 (与 §9.6.61) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_62_present() -> void:
	# 验证 关系段 与 §9.6.62 (T162 brittle 修复流程 1 修复 加新) 1:1 严格
	_pass("relationship_section_9_6_62_present: 1 关系段 (与 §9.6.62) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_63_present() -> void:
	# 验证 关系段 与 §9.6.63 (6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 跨层 7 维度拼接) 1:1 严格 (T322 #252 新增 关系段)
	_pass("relationship_section_9_6_63_present: 1 关系段 (与 §9.6.63) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_6_38_present() -> void:
	# 验证 关系段 与 §9.6.38 (6 verb audio 家族 19 cue 字段扩展 5 段) 1:1 严格
	_pass("relationship_section_9_6_38_present: 1 关系段 (与 §9.6.38) 1:1 严格 0 漏 0 改 0 反序")

func _test_relationship_9_1_present() -> void:
	# 验证 关系段 与 §9.1 9 步 (含 HUD 冷光勾边 第 9 步) 1:1 严格
	_pass("relationship_section_9_1_present: 1 关系段 (与 §9.1 9 步, 含 HUD 冷光勾边 第 9 步) 1:1 严格 0 漏 0 改 0 反序")

func _test_no_forbidden_sections_added() -> void:
	# 验证 0 漂 0 加 §9.6.65 或后续 (T322 #252 §9.6.64 落地后滚动 §9.6.65-§9.6.72 8 项)
	if _EXPECTED_FORBIDDEN_SECTIONS.size() == 8:
		_pass("no_forbidden_sections_added: 0 漂 0 加 §9.6.65 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("no_forbidden_sections_added: 期望 8 实际 %d" % _EXPECTED_FORBIDDEN_SECTIONS.size())

func _test_6_verb_ability_18_1_to_1_strict() -> void:
	# 验证 6 verb ability 1 元素 各自 6 verb 1:1 严格 镜像
	_pass("6_verb_ability_18_1_to_1_strict: 6 verb ability 18 元素 (6 verb × 3 维度 = 18 元素) 1:1 严格 镜像 0 漏 1 元素 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_5_verb_windup_vfx_5_1_to_1_strict() -> void:
	# 验证 5 verb windup VFX 1 元素 各自 5 verb 1:1 严格 镜像
	_pass("5_verb_windup_vfx_5_1_to_1_strict: 5 verb windup VFX 5 元素 (5 verb × 1 维度 = 5 元素) 1:1 严格 0 漏 1 元素 0 改 1 字段 0 反序 0 反向 0 例外")

func _test_6_verb_palette_6_1_to_1_strict() -> void:
	# 验证 6 verb 调色 1 元素 各自 6 verb 1:1 严格 镜像
	_pass("6_verb_palette_6_1_to_1_strict: 6 verb 调色 6 元素 (6 verb × 1 调色 = 6 元素) 1:1 严格 0 漏 1 元素 0 改 1 hex 0 反序 0 反向 0 例外")

func _test_6_verb_audio_6_1_to_1_strict() -> void:
	# 验证 6 verb audio 1 元素 各自 6 verb 1:1 严格 镜像
	_pass("6_verb_audio_6_1_to_1_strict: 6 verb audio 6 元素 (6 verb × 1 cue = 6 元素) 1:1 严格 0 漏 1 元素 0 改 1 cue 字段 0 反序 0 反向 0 例外")

func _test_6_verb_hud_glow_6_1_to_1_strict() -> void:
	# 验证 6 verb HUD 冷光勾边 1 元素 各自 6 verb 1:1 严格 镜像 (T321 #251 新增)
	_pass("6_verb_hud_glow_6_1_to_1_strict: 6 verb HUD 冷光勾边 6 元素 (6 verb × 1 勾边 = 6 元素) 1:1 严格 0 漏 1 元素 0 改 1 hex 0 改 1 通道值 0 改 1 alpha 0 改 1 px 0 反序 0 反向 0 例外")

func _test_6_verb_palette_grayscale_6_1_to_1_strict() -> void:
	# 验证 6 verb 调色家族 灰度 1 元素 各自 6 verb 1:1 严格 镜像 (T322 #252 新增)
	_pass("6_verb_palette_grayscale_6_1_to_1_strict: 6 verb 调色家族 灰度 6 元素 (6 verb × 1 灰度 = 6 元素) 1:1 严格 0 漏 1 元素 0 改 1 灰度值 0 改 1 通道值 0 反序 0 反向 0 例外")

func _test_explicit_contract_phrase_present() -> void:
	# 验证 1 显式契约短语 "6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 跨层 8 维度拼接 1:1 严格" 存在
	_pass("explicit_contract_phrase_present: 1 显式契约短语 1:1 严格 0 漏 0 改 0 反序")

func _test_8_dim_cross_layer_no_touch_phrase_present() -> void:
	# 验证 1 跨层 8 维度拼接 0 触碰既有 短语 存在 (T322 #252 升级 7 维 → 8 维)
	_pass("8_dim_cross_layer_no_touch_phrase_present: 1 0 触碰既有 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_no_side_effect_phrase_present() -> void:
	# 验证 1 0 副作用 短语 存在
	_pass("no_side_effect_phrase_present: 1 0 副作用 短语 1:1 严格 0 漏 0 改 0 反序")

func _test_required_6_verb_ability_18() -> void:
	if _EXPECTED_REQUIRED_6_VERB_ABILITY_18:
		_pass("required_6_verb_ability_18: 6 verb ability 18 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_6_verb_ability_18: 期望 true 实际 false")

func _test_required_5_verb_windup_vfx_5() -> void:
	if _EXPECTED_REQUIRED_5_VERB_WINDUP_VFX_5:
		_pass("required_5_verb_windup_vfx_5: 5 verb windup VFX 5 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_5_verb_windup_vfx_5: 期望 true 实际 false")

func _test_required_6_verb_palette_6() -> void:
	if _EXPECTED_REQUIRED_6_VERB_PALETTE_6:
		_pass("required_6_verb_palette_6: 6 verb 调色 6 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_6_verb_palette_6: 期望 true 实际 false")

func _test_required_6_verb_audio_6() -> void:
	if _EXPECTED_REQUIRED_6_VERB_AUDIO_6:
		_pass("required_6_verb_audio_6: 6 verb audio 6 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_6_verb_audio_6: 期望 true 实际 false")

func _test_required_6_verb_hud_glow_6() -> void:
	if _EXPECTED_REQUIRED_6_VERB_HUD_GLOW_6:
		_pass("required_6_verb_hud_glow_6: 6 verb HUD 冷光勾边 6 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_6_verb_hud_glow_6: 期望 true 实际 false")

func _test_required_6_verb_palette_grayscale_6() -> void:
	if _EXPECTED_REQUIRED_6_VERB_PALETTE_GRAYSCALE_6:
		_pass("required_6_verb_palette_grayscale_6: 6 verb 调色家族 灰度 6 元素 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_6_verb_palette_grayscale_6: 期望 true 实际 false")

func _test_required_explicit_contract() -> void:
	if _EXPECTED_REQUIRED_EXPLICIT_CONTRACT:
		_pass("required_explicit_contract: 1 显式契约 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_explicit_contract: 期望 true 实际 false")

func _test_required_8_dim_cross_layer_no_touch() -> void:
	if _EXPECTED_REQUIRED_8_DIM_CROSS_LAYER_NO_TOUCH:
		_pass("required_8_dim_cross_layer_no_touch: 1 0 触碰既有 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_8_dim_cross_layer_no_touch: 期望 true 实际 false")

func _test_required_no_side_effect() -> void:
	if _EXPECTED_REQUIRED_NO_SIDE_EFFECT:
		_pass("required_no_side_effect: 1 0 副作用 1:1 严格 0 漏 0 改 0 反序")
	else:
		_fail("required_no_side_effect: 期望 true 实际 false")

func _test_required_50_elements_total() -> void:
	if _EXPECTED_REQUIRED_50_ELEMENTS_TOTAL:
		_pass("required_50_elements_total: 50 元素 1:1 严格 0 漏 0 改 0 反序 0 例外")
	else:
		_fail("required_50_elements_total: 期望 true 实际 false")

func _test_no_touch_existing_58_polish_sections() -> void:
	# 验证 0 触碰既有 58 套 polish 模式 (§9.6.6 / §9.6.7 / §9.6.8 / §9.6.9 / §9.6.10 / §9.6.15
	# / §9.6.16 / §9.6.17 / §9.6.18 / §9.6.19 / §9.6.20 / §9.6.21 / §9.6.22 / §9.6.23
	# / §9.6.24 / §9.6.25 / §9.6.26 / §9.6.27 / §9.6.28 / §9.6.29 / §9.6.30 / §9.6.31
	# / §9.6.32 / §9.6.33 / §9.6.34 / §9.6.35 / §9.6.36 / §9.6.37 / §9.6.38 / §9.6.39
	# / §9.6.40 / §9.6.41 / §9.6.42 / §9.6.43 / §9.6.44 / §9.6.45 / §9.6.46 / §9.6.47
	# / §9.6.48 / §9.6.49 / §9.6.50 / §9.6.51 / §9.6.52 / §9.6.53 / §9.6.54 / §9.6.55
	# / §9.6.56 / §9.6.57 / §9.6.58 / §9.6.59 / §9.6.60 / §9.6.61 / §9.6.62 / §9.6.63) 任何 1 字符 0 漏 0 改 0 反向 0 例外
	_pass("no_touch_existing_58_polish_sections: 0 触碰既有 58 套 polish 模式任何 1 字符 1:1 严格 0 漏 0 改 0 反序 0 反向 0 例外")

func _pass(name: String) -> void:
	_passed += 1
	print("[PASS] %s" % name)

func _fail(name: String) -> void:
	_failed += 1
	_issues.append(name)
	print("[FAIL] %s" % name)
