# T370 smoke test — CONTRIBUTING.md §9.6.112 polish 模式 1:1 落地验证 (15 断言)
# 设计本意 — 在 CI 早期捕获 §9.6.112 段被误改/误删/旧值未升级 类问题, 0 漂到审查阶段.
# T370 #313 §9.6.112 = 6 verb 视觉组 塑性 1 维度 6 元素 跨层 56 维度拼接 1:1 严格分离契约 polish 模式.
# 0 派生自 §9.6.108 toughness T_u + §9.6.109 brittleness B + §9.6.110 ductility D + §9.6.111 elasticity E, 1:1 独立第五轴 (Mises 1913 yield criterion).
extends RefCounted

const _CONTRIBUTING_PATH := "res://CONTRIBUTING.md"
const _EXPECTED_SECTION_HEADER := "### 9.6.112 6 verb ability + 5 verb windup VFX + 6 verb 调色六元组 + 6 verb audio 家族 1 维度 + 6 verb HUD 冷光勾边 1 维度 + 6 verb 调色家族 灰度 1 维度 + 6 verb 调色家族 亮边 1 维度 + 6 verb 调色家族 暗边 1 维度 + 6 verb 调色家族 饱和度 1 维度 + 6 verb 调色家族 中点 1 维度 + 6 verb 视觉组 base shader 1 维度 + 6 verb cooldown ready jingle 1 维度 + 6 verb 调色家族 色调 1 维度 + 6 verb 调色家族 暖度 1 维度 + 6 verb 视觉组 形状 1 维度 + 6 verb 视觉组 时长 1 维度 + 6 verb 视觉组 起点偏移 1 维度 + 6 verb 视觉组 终点偏移 1 维度 + 6 verb 视觉组 旋转 1 维度 + 6 verb 视觉组 缩放 1 维度 + 6 verb 视觉组 透明度 1 维度 + 6 verb 视觉组 速度 1 维度 + 6 verb 视觉组 加速度 1 维度 + 6 verb 视觉组 减速度 1 维度 + 6 verb 视觉组 旋转阻尼 1 维度 + 6 verb 视觉组 角速度 1 维度 + 6 verb 视觉组 径向速度 1 维度 + 6 verb 视觉组 切向速度 1 维度 + 6 verb 视觉组 法向速度 1 维度 + 6 verb 视觉组 副法向速度 1 维度 + 6 verb 视觉组 旋度 1 维度 + 6 verb 视觉组 发散度 1 维度 + 6 verb 视觉组 切变 1 维度 + 6 verb 视觉组 螺旋度 1 维度 + 6 verb 视觉组 扭转度 1 维度 + 6 verb 视觉组 流形曲率 1 维度 + 6 verb 视觉组 雅可比行列式 1 维度 + 6 verb 视觉组 高斯曲率 1 维度 + 6 verb 视觉组 平均曲率 1 维度 + 6 verb 视觉组 总曲率 1 维度 + 6 verb 视觉组 主曲率 max 1 维度 + 6 verb 视觉组 主曲率 min 1 维度 + 6 verb 视觉组 弯曲度 1 维度 + 6 verb 视觉组 形状指数 1 维度 + 6 verb 视觉组 曲率各向异性 1 维度 + 6 verb 视觉组 能密度 1 维度 + 6 verb 视觉组 强度 1 维度 + 6 verb 视觉组 刚度 1 维度 + 6 verb 视觉组 黏度 1 维度 + 6 verb 视觉组 韧度 1 维度 + 6 verb 视觉组 脆度 1 维度 + 6 verb 视觉组 延展性 1 维度 + 6 verb 视觉组 弹性 1 维度 + 6 verb 视觉组 塑性 1 维度 跨层 56 维度拼接 1:1 严格分离契约 polish 模式 (T370 #313 跨 1 任务 1 轮落地) 文档化"
const _EXPECTED_ELEMENT_KEY := "plasticity"
const _EXPECTED_ELEMENT_VALUES := [
        "Pulse 塑性 0.00",
        "Bind 塑性 0.58",
        "Cut 塑性 0.12",
        "Echo 塑性 0.05",
        "Wave 塑性 0.70",
        "Whisper 塑性 0.00",
]
const _EXPECTED_FORMULA_KEY := "P = 1 - E"
const _EXPECTED_TOTAL_ELEMENTS := "366 元素"
const _EXPECTED_CROSS_LAYER := "跨层 56 维度拼接"
const _EXPECTED_RELATION_PARENT := "与 §9.6.111 关系"
const _EXPECTED_RELATION_STEP_9 := "与 §9.6.1 9 步关系"
const _EXPECTED_NEW_6_ELEMENTS_NOTE := "T370 #313 新增 6 元素"
const _EXPECTED_EPSILON_NOTE := "视觉平滑 由 P 单路 ε=0.05 视觉平滑 注入"

func _read_text(path: String) -> String:
        var f := FileAccess.open(path, FileAccess.READ)
        if f == null:
                return ""
        return f.get_as_text()

func _assert_true(cond: bool, msg: String) -> bool:
        if not cond:
                push_error("T370 §9.6.112 smoke FAILED: " + msg)
        return cond

func run() -> Dictionary:
        var failures := 0
        var text := _read_text(_CONTRIBUTING_PATH)
        if text.length() == 0:
                push_error("T370 §9.6.112 smoke FAILED: CONTRIBUTING.md 不可读")
                return {"passed": 0, "failed": 1, "skipped": 0, "issues": ["CONTRIBUTING.md 不可读"]}

        # 断言 1: §9.6.112 段标题存在
        if not _assert_true(text.find(_EXPECTED_SECTION_HEADER) >= 0,
                        "§9.6.112 段标题 0 找到"):
                failures += 1

        # 断言 2: plasticity 键名存在
        if not _assert_true(text.find(_EXPECTED_ELEMENT_KEY) >= 0,
                        "plasticity 键名 0 找到 (0 派生自 toughness T_u + brittleness B + ductility D + elasticity E, 1:1 独立第五轴 Mises 1913 yield criterion)"):
                failures += 1

        # 断言 3-8: 6 元素 1:1 严格
        for ev in _EXPECTED_ELEMENT_VALUES:
                if not _assert_true(text.find(ev) >= 0,
                                "6 元素值缺失: " + ev):
                        failures += 1

        # 断言 9: 派生公式 P = 1 - E 存在
        if not _assert_true(text.find(_EXPECTED_FORMULA_KEY) >= 0,
                        "派生公式 " + _EXPECTED_FORMULA_KEY + " 0 找到 (视觉塑性 1 减弹性 派生塑性, Mises 1913 yield criterion 体系下 plasticity 维度)"):
                failures += 1

        # 断言 10: 总元素 366
        if not _assert_true(text.find(_EXPECTED_TOTAL_ELEMENTS) >= 0,
                        "总元素 366 0 找到 (359 §9.6.111 元素 + 6 塑性 + 1 跨层 56 维度拼接 0 触碰既有)"):
                failures += 1

        # 断言 11: 跨层 56 维度拼接 存在
        if not _assert_true(text.find(_EXPECTED_CROSS_LAYER) >= 0,
                        "跨层 56 维度拼接 0 找到 (从 §9.6.111 跨层 55 升级 1 维 → 跨层 56)"):
                failures += 1

        # 断言 12: 与 §9.6.111 关系段 存在
        if not _assert_true(text.find(_EXPECTED_RELATION_PARENT) >= 0,
                        "与 §9.6.111 关系段 0 找到 (姊妹段 + 第五轴段 契约)"):
                failures += 1

        # 断言 13: 与 §9.6.1 9 步关系段 存在
        if not _assert_true(text.find(_EXPECTED_RELATION_STEP_9) >= 0,
                        "与 §9.6.1 9 步关系段 0 找到 (走 4 步落地)"):
                failures += 1

        # 断言 14: T370 #313 新增 6 元素 标记 存在
        if not _assert_true(text.find(_EXPECTED_NEW_6_ELEMENTS_NOTE) >= 0,
                        "T370 #313 新增 6 元素 标记 0 找到 (T370 #313 跨 1 任务 1 轮落地)"):
                failures += 1

        # 断言 15: P 单路 ε=0.05 视觉平滑 注入 标记 存在 (P = 1 - E 减法 0 引入新 ε, P 单路独立)
        if not _assert_true(text.find(_EXPECTED_EPSILON_NOTE) >= 0,
                        "P 单路 ε=0.05 视觉平滑 注入 标记 0 找到 (0 涉及 toughness T_u ε=0.05 0 涉及 brittleness B ε=0.05 0 涉及 ductility D ε=0.05 0 涉及 elasticity E ε=0.05, 0 双计数 0 三重计数 0 四重计数 0 五重计数)"):
                failures += 1

        var issues: Array = []
        if failures > 0:
                issues.append("%d 断言失败" % failures)
                print("T370 §9.6.112 smoke FAILED: %d 断言失败" % failures)
        else:
                print("T370 §9.6.112 smoke PASSED (15 断言 0 失败): 366 元素 / 跨层 56 维度 / 6 元素 1:1 严格")
        return {"passed": 15 - failures, "failed": failures, "skipped": 0, "issues": issues}
