"""
视觉质量评价 — 通过阿里云百炼 vision 模型评估生成素材。
Agent 描述预期效果，模型看图对比，评分并给出 KEEP/RETRY/DISCARD 意见。
"""

import base64, json, time, threading
import requests
from io import BytesIO
from PIL import Image

API_KEY = "sk-586ece00d06c4bf68dbb85fee1df4fc4"
API_URL = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions"

# ─── 模型梯队（仅多模态 vision 模型） ───
MODEL_TIERS = {
    "T0": ["kimi-k2.6"],
    "T1": ["qwen3.6-plus", "qwen3.6-plus-2026-04-02"],
    "T2": ["qwen3.5-plus-2026-04-20"],
    "T3": ["qwen3.6-max-preview"],
}

ASSET_PRIORITY_TIER = {
    "character": "T0", "monster": "T0", "card": "T0",
    "portrait": "T0", "background": "T0",
    "item": "T1", "weapon": "T1", "armor": "T1",
    "npc": "T1", "effect": "T1", "logo": "T1",
    "icon": "T2", "skill-icon": "T2", "ui-element": "T2",
    "dialog-box": "T2", "tileset": "T2", "tile-single": "T2",
    "particle": "T2",
}

# ─── 模型可用性追踪 ───
_unavailable_until = {}
_lock = threading.Lock()
UNAVAILABLE_DURATION = 30 * 60
MAX_TIMEOUTS_BEFORE_UNAVAILABLE = 2
_timeout_counts = {}

_ALL_KNOWN_MODELS = {m for models in MODEL_TIERS.values() for m in models}


def _mark_unavailable(model: str):
    with _lock:
        _unavailable_until[model] = time.time() + UNAVAILABLE_DURATION
        _timeout_counts.pop(model, None)


def _record_timeout(model: str) -> bool:
    with _lock:
        c = _timeout_counts.get(model, 0) + 1
        _timeout_counts[model] = c
        if c >= MAX_TIMEOUTS_BEFORE_UNAVAILABLE:
            _mark_unavailable(model)
            return True
    return False


def _is_available(model: str) -> bool:
    with _lock:
        until = _unavailable_until.get(model, 0)
        if until > time.time():
            return False
        if until > 0 and until <= time.time():
            del _unavailable_until[model]
    return True


def _pick_model(asset_type: str, preferred_model: str = None) -> str:
    if preferred_model and preferred_model in _ALL_KNOWN_MODELS and _is_available(preferred_model):
        return preferred_model
    start_tier = ASSET_PRIORITY_TIER.get(asset_type, "T1")
    tier_order = ["T0", "T1", "T2", "T3"]
    try:
        tier_idx = tier_order.index(start_tier)
    except ValueError:
        tier_idx = 1
    for idx in range(tier_idx, len(tier_order)):
        tier = tier_order[idx]
        models = MODEL_TIERS[tier]
        available = [m for m in models if _is_available(m)]
        if available:
            return available[int(time.time()) % len(available)]
    return MODEL_TIERS["T2"][0]


# ─── 通过阈值 ───
_PASS_THRESHOLDS = {
    "character": 14, "monster": 14, "npc": 14,
    "item": 14, "weapon": 14, "armor": 14,
    "icon": 15, "skill-icon": 15,
    "ui-element": 15, "dialog-box": 15,
    "background": 13,
    "tileset": 14, "tile-single": 14,
    "effect": 13, "particle": 13,
    "card": 14, "portrait": 14, "logo": 14,
}

_TYPE_LABELS = {
    "character": "character sprite", "monster": "monster sprite",
    "npc": "NPC sprite", "item": "item icon", "weapon": "weapon sprite",
    "armor": "armor sprite", "icon": "UI icon", "skill-icon": "skill icon",
    "ui-element": "UI element", "dialog-box": "dialog box",
    "background": "game background", "tileset": "tileset texture",
    "tile-single": "single tile", "effect": "visual effect sprite",
    "particle": "particle sprite", "card": "game card",
    "portrait": "character portrait", "logo": "game logo",
}


# ─── 核心 ───

def _encode_image(image: Image.Image) -> str:
    buf = BytesIO()
    image.save(buf, "PNG")
    return f"data:image/png;base64,{base64.b64encode(buf.getvalue()).decode()}"


def evaluate_asset(
    image: Image.Image,
    asset_type: str = "character",
    expectation: str = "",
    model: str = None,
    pass_threshold: int = None,
) -> dict:
    """
    用 vision 模型对比 Agent 预期与实际生成结果，评分并给出处理意见。

    Args:
        image:       PIL 图像
        asset_type:  素材类型
        expectation: Agent 的预期描述（英文）。模型会对比此描述与图像实际内容。
        model:       内部用，不传（由梯队自动路由）
        pass_threshold: 内部用

    Returns:
        {"pass": bool, "scores": {...}, "total": int, "threshold": int,
         "description": "Qwen对图像的详细描述",
         "verdict": "KEEP"|"RETRY"|"DISCARD",
         "issues": [...], "suggestions": "改进建议", "model_used": str}
    """
    label = _TYPE_LABELS.get(asset_type, "game asset")
    threshold = pass_threshold or _PASS_THRESHOLDS.get(asset_type, 14)
    chosen_model = _pick_model(asset_type, model)
    img_b64 = _encode_image(image)

    expectation_block = (
        f'The artist intended to create a **{label}** with this description:\n'
        f'"{expectation}"\n\n'
        f'Now look at the generated image. Compare it against the artist\'s intent.'
    ) if expectation else (
        f'Evaluate this game **{label}**.'
    )

    prompt = (
        f"You are a game art director reviewing an artist's work.\n\n"
        f"{expectation_block}\n\n"
        f"STEP 1 — Describe what you actually see in the image in detail.\n"
        f"Be thorough: character features, colors, pose, proportions, equipment, background, "
        f"anything notable. Include things the artist might NOT have wanted (extra limbs, "
        f"wrong colors, missing details, unexpected elements). "
        f"This is the most important step — the artist will read your description to catch "
        f"problems you might not flag as issues.\n\n"
        f"STEP 2 — Compare against the artist's intent and score each dimension 1-5:\n"
        f"1) **intent_match** — How well does the image match the artist's description? "
        f"(1=completely wrong, 5=perfect match)\n"
        f"2) **quality** — Art quality: clean edges, good rendering, proper resolution, no artifacts\n"
        f"3) **composition** — Framing, centering, no cut-off, appropriate proportions\n"
        f"4) **game_ready** — Transparent background, proper size, directly usable in a game engine\n\n"
        f"Respond ONLY with valid JSON, no markdown:\n"
        f'{{"description": "detailed description of what you see in the image", '
        f'"scores": {{"intent_match": 1-5, "quality": 1-5, "composition": 1-5, "game_ready": 1-5}}, '
        f'"verdict": "KEEP"|"RETRY"|"DISCARD", '
        f'"issues": ["specific mismatches vs expectation"], '
        f'"suggestions": "what to change in the prompt if RETRY"}}'
    )

    messages = [{
        "role": "user",
        "content": [
            {"type": "text", "text": prompt},
            {"type": "image_url", "image_url": {"url": img_b64}},
        ],
    }]

    try:
        resp = requests.post(
            API_URL,
            headers={"Authorization": f"Bearer {API_KEY}", "Content-Type": "application/json"},
            json={"model": chosen_model, "messages": messages,
                  "max_tokens": 500, "temperature": 0.1},
            timeout=60,
        )

        if resp.status_code == 429:
            _mark_unavailable(chosen_model)
            fallback = _pick_model(asset_type)
            if fallback != chosen_model:
                return evaluate_asset(image, asset_type, expectation, fallback, threshold)
            return _error_result(threshold, chosen_model, "Rate limited, no fallback")

        if resp.status_code == 200:
            data = resp.json()
            content = data["choices"][0]["message"]["content"].strip()
            if content.startswith("```"):
                content = content.split("\n", 1)[1].rsplit("\n```", 1)[0]
            result = json.loads(content)
            raw_scores = result.get("scores", {})
            total = sum(raw_scores.values())
            result["total"] = total
            result["threshold"] = threshold
            result["pass"] = total >= threshold
            result["model_used"] = chosen_model
            # 确保 verdict 存在
            if "verdict" not in result:
                result["verdict"] = "KEEP" if total >= threshold else "RETRY"
            return result
        else:
            return _error_result(threshold, chosen_model, f"API HTTP {resp.status_code}")

    except requests.exceptions.Timeout:
        _record_timeout(chosen_model)
        fallback = _pick_model(asset_type)
        if fallback != chosen_model:
            return evaluate_asset(image, asset_type, expectation, fallback, threshold)
        return _error_result(threshold, chosen_model, "Timeout")

    except Exception as e:
        return _error_result(threshold, chosen_model, str(e), pass_on_error=True)


def _error_result(threshold, model, msg, pass_on_error=False):
    return {
        "pass": True if pass_on_error else False,
        "scores": {"intent_match": 0, "quality": 0, "composition": 0, "game_ready": 0},
        "total": 0, "threshold": threshold,
        "description": f"Evaluation unavailable: {msg}",
        "verdict": "KEEP" if pass_on_error else "RETRY",
        "issues": [msg], "suggestions": "",
        "model_used": model, "error": True,
    }


def evaluate_batch(images, asset_type="character", expectation="", model=None):
    return [evaluate_asset(img, asset_type, expectation, model) for img in images]


def get_model_status():
    return {tier: {m: {"available": _is_available(m),
                       "unavailable_until": _unavailable_until.get(m, None)}
                  for m in models}
            for tier, models in MODEL_TIERS.items()}
