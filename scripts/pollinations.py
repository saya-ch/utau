import requests
from PIL import Image
from io import BytesIO
from urllib.parse import quote

def generate_image_pollinations(
    prompt: str,
    width: int = 2048,
    height: int = 2048,
    model: str = "flux-pro",
    quality: str = "hd",
    enhance: bool = False,
    seed: int = -1,          # -1 = 随机种子
    negative_prompt: str = "",
    safe: bool = False,
    timeout: int = 120,
    proxy: str | None = None,  # 例如 "http://127.0.0.1:7890"，None 表示使用系统代理
    no_proxy: bool = False,    # True = 完全绕过代理直连
    save_path: str = "output.png",
) -> str:
    """
    使用 Pollinations API 生成图像。

    参数:
        prompt:          图像描述（英文效果更好）
        width / height:  图像尺寸 (64~2048)
        model:           模型选择（见下方说明）
        quality:         质量等级 — "low" | "medium" | "high" | "hd"
        enhance:         是否用 LLM 自动丰富 prompt（短 prompt 推荐开启）
        seed:            随机种子，相同 seed 生成相同图像 (-1 为随机)
        negative_prompt: 排除的元素，逗号分隔
        safe:            内容安全过滤
        timeout:         请求超时秒数 (默认 120)
        proxy:           代理地址，如 "http://127.0.0.1:7890"
        no_proxy:        设为 True 直连，忽略系统代理
        save_path:       保存路径

    常用 model 选项:
        flux          默认通用模型
        flux-pro      增强画质
        flux-realism  写实/照片风格
        flux-anime    二次元/动漫风格
        flux-3d       3D 渲染风格
        turbo         极速生成（质量较低）
    """
    params = {
        "width": width,
        "height": height,
        "model": model,
        "quality": quality,
        "seed": seed,
        "enhance": str(enhance).lower(),
        "safe": str(safe).lower(),
    }
    if negative_prompt:
        params["negative_prompt"] = negative_prompt

    # 代理配置
    if no_proxy:
        proxies = {"http": None, "https": None}  # 绕过代理直连
    elif proxy:
        proxies = {"http": proxy, "https": proxy}
    else:
        proxies = None  # 使用 requests 默认行为（系统代理）

    url = f"https://image.pollinations.ai/prompt/{quote(prompt)}"
    response = requests.get(url, params=params, proxies=proxies, timeout=timeout)

    if response.status_code == 200:
        image = Image.open(BytesIO(response.content))
        image.save(save_path)
        return save_path
    else:
        raise Exception(f"Image generation failed: {response.text}")

# ===== 使用示例 =====
if __name__ == "__main__":
    # 如果直连不通，设置你的代理地址：
    #   方式1: no_proxy=True 尝试直连
    #   方式2: proxy="http://127.0.0.1:7890" 使用 clash/v2ray 等代理
    image_path = generate_image_pollinations(
        prompt="best quality,anime style, 1girl, smile, cute, dynamic pose, detailed background",
        model="flux-pro",
        quality="hd",
        enhance=False,
        seed=9,
        negative_prompt="blurry, low quality, ugly, deformed, extra fingers",
        no_proxy=True,   # ← 尝试直连绕过系统代理
        # proxy="http://127.0.0.1:7890",  # ← 或者设置你的代理地址
    )
    print(f"图像已保存至：{image_path}")
