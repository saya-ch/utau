# Seed 区间与管理策略

## 总表

| 区间        | 用途              | 起始 seed | 备注 |
|-------------|-------------------|-----------|------|
| 1001–1999  | 历史素材 (legacy) | 1001      | 已有素材，不修改 |
| **2001–2099** | **A 组：概念 / 胶囊** | **2001** | 本项目主要产出 |
| **2101–2199** | **B 组：NPC / 敌人 / 道具** | **2101** | 游戏内精灵升级 |
| **2201–2299** | **C 组：装饰 / 备选图标** | **2201** | 可选扩展 |
| 2301–2399  | D 组：预留         | 2301      | future 扩展位 |
| **2400–2499** | **RETRY 专用**     | **2400**  | L2 被 REJECTED 的跳跃重试，每次 +100 |

## 每素材分配

```
A组（概念/胶囊）—— 2001–2099
├── A075 moodboard            seed = 2001
├── A076 saya concept         seed = 2002
├── A077 archive scene        seed = 2003
├── A078 enemy sheet          seed = 2004
├── A079 prop sheet           seed = 2005
├── A080 HUD UI kit           seed = 2006
├── A081 Steam feature cap    seed = 2007
└── A082 Steam main cap       seed = 2008

B组（游戏内精灵）—— 2101–2199
├── A083 silence mote v2      seed = 2101
├── A084 bell - broken        seed = 2102
├── A085 bell - repaired      seed = 2103
├── A086 archivist portrait   seed = 2104
├── A087 tuner portrait       seed = 2105
└── A088 silent merchant      seed = 2106

C组（装饰/备选图标）—— 2201–2299
├── A089 hourglass            seed = 2201
├── A090 wave totem           seed = 2202
├── A091 hanging bell         seed = 2203
├── A092 pulse icon alt       seed = 2204
├── A093 echo icon alt        seed = 2205
└── A094 achievement alt      seed = 2206

RETRY 专用 —— 2400–2499
├── 2400, 2410, 2420, ...     (每次 +100，最多 10 次)
```

## 规则

1. **每个素材有唯一的主 seed**（上面分配）
2. **L1 失败（第 1 次）**：seed + 1，同区间重试
3. **L2 失败（被 REJECTED）**：跳到 RETRY 区间，seed = 2400 + (N×10)
   - 第 1 次被拒 → 2400
   - 第 2 次被拒 → 2410
   - 第 3 次被拒 → 2420
   - 最多 10 次：2490
4. **连续 3 轮 API 失败**：降级 Pollinations flux-anime，仍用相同 seed
5. **ASSET_REGISTRY 必须记录最终使用的 seed**（即使跳了 retry）

## 为什么这样设计？

- **可复现**：每个 Axxx 有唯一主 seed，未来重新 run 可以得到同一结果
- **风格隔离**：A/B/C 组在不同 seed 段，避免风格相互渗透
- **可追溯**：REJECTED 时用 retry seed 明显偏移段，从 ASSET_REGISTRY 一眼能看到是否经过重试
- **不与旧素材冲突**：最低 seed 2001 > 1999，与 legacy seed 完全隔离
