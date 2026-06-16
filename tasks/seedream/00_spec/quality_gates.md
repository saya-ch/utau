# 质量门槛 — L1 自动校验 + L2 视觉评估

## L1（自动，postprocess.validate_asset）

| 检查项 | 要求 |
|--------|------|
| ok | True |
| content_ratio | 1% – 98% 之间（非全空，也非完全未抠） |
| center_offset | < 30%（主体不能严重偏离中心） |
| file_size | PNG < 10 MB（对于 1024+ 高清，允许 4–10 MB） |
| RGBA | 必须 4 通道 alpha（抠图类素材） |

## L2（可选，由 vision_eval.evaluate_asset 提供）

| 检查项 | 阈值 |
|--------|------|
| total_score | ≥ 14（满分 20，具体取决于 vision_eval 实现） |
| verdict | "KEEP" |
| has_subject | True（画面内有主体） |

## 失败策略

```
第一次失败（L1 或 L2）:
  → seed + 1 重跑（A/B/C 组内）
  → 仍失败 → seed + 100 跳到 RETRY 段 (2400+)
  → 仍失败 → 降级 Pollinations flux-anime
  → 连续 3 轮失败 → BLOCKED，下一轮再处理
```

## L1 检查实现（pipeline_seedream 内置）

```python
# 由 run_seedream_pipeline 在 L1 阶段自动调用:
v = validate_asset(img)
# v = {"ok": bool, "content_ratio": float, "center_offset": float, ...}
```

## 各素材 L2 阈值微调

| 素材 | 风格 | 难度 | L2 阈值 |
|------|------|------|---------|
| A075 moodboard | concept | 高（拼贴风） | 14 |
| A076 saya concept | anime | 中 | 14 |
| A077 archive scene | background | 高 | 14 |
| A078 enemy sheet | concept | 中 | 14 |
| A079 prop sheet | concept | 低 | 14 |
| A080 UI kit | ui | 低 | 14 |
| A081/A082 capsule | concept | 高 | 14 |
| B 组精灵 | pixel-art / anime | 中 | 14 |
| C 组装饰/图标 | pixel-art | 低 | 14 |

> 所有素材统一 14 门槛，保持简单。若长期失败，可按素材类型单独调整。
