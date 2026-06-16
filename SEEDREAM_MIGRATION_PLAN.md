# Seedream 素材换血工程 — 多轮迭代计划（Voxglass Project）

> **启动迭代**: #99 | **负责人**: automated agent | **状态**: Planning → Active

---

## 1. 工程目标

**现状**（基于 `ASSET_REGISTRY.md` 分析 A001–A074）：

| 类别 | 素材数 | 生成方式 | 品质 | 换血优先级 |
|------|--------|---------|------|-----------|
| 主角（Saya）spritesheet | A026/A027 | procedural pixel art (Python PIL) | ★★★★☆ | 低 — 已有程序化精确控制，暂不换，保留作基线 |
| 敌人精灵（Silence Mote/InkWarden） | A022/A028/A030/A031/A032/A054 | Pollinations flux-anime (A022) + procedural (其他) | ★★★☆☆ | 中 — A022 用 Seedream 重做视觉更统一；其他保留 |
| 道具/存档灯笼（Voice Bell / Save Lantern） | A023/A024/A029 | Pollinations + procedural | ★★★☆☆ | 中 — A023/A024 换 Seedream；A029 不动 |
| 技能图标（5 verb icons） | A025/A033/A038/A061/A071 | procedural pixel art | ★★★★☆ | 低 — 色板/风格已高度统一，可留作对比基线 |
| 成就图标（9 个） | A039-A046 | procedural pixel art | ★★★★☆ | 低 — 同技能图标 |
| NPC 头像（3+1） | A034/A035/A051/A053 | procedural pixel art | ★★☆☆☆ | 高 — 二次元美少女主题应更精美 |
| 对话框底图 | A036 | procedural | ★★★☆☆ | 低 — UI 不影响核心视觉 |
| 装饰物件（hourglass/wave-totem/等） | A055-A060 | procedural pixel art | ★★★☆☆ | 中 — 可增加 Seedream 精细版本作为额外资源 |
| Steam capsule 三联图 | A047-A049 | procedural | ★★★☆☆ | 高 — 商店页面图是第一印象，升级回报最大 |
| 程序化音频（8 BGM + 15 SFX） | A050/A052/A063-A064/A065/A073-A074 | procedural synth | N/A | **不换血** — 图像工程不含音频 |
| 成就数据条目 | A062/A066-A069 | data | N/A | **不换血** |
| 概念设定（早期锚定素材） | A001-A018 | built-in imagegen (低质量) | ★★☆☆☆ | 高 — 用 Seedream 重绘成高分辨率概念参考 |

**结论**：换血工程不是"A001-A074 全部重做"，而是**分层替换**：
- **A 组（高优先级，8 张）**：概念设定重绘 + Steam capsule 三联图升级版 → 建立视觉宪法 v2
- **B 组（中优先级，~6 张）**：NPC 头像升级 + 早期敌人（A022 Silence Mote） + Voice Bell 修复前后状态
- **C 组（低优先级，可选扩展）**：装饰物件精致版 + 备选技能图标（做 A/B 对比用）

**总目标素材数**：约 20 张新图（A 组 8 + B 组 6 + C 组 6），全部登记为 A075–A094 新 ID。

---

## 2. 技术规范（所有新素材必须遵守）

### 2.1 生成后端

```
主后端: Seedream 5.0 (doubao-seedream-5-0-260128)
降级:   Seedream 4.5 → Pollinations flux-anime/pro
API Key: ARK_API_KEY 或 MODEL_IMAGE_API_KEY
```

### 2.2 尺寸 / 画布 / 抠图策略（按素材类型）

| 类型 | 生成尺寸 | 画布 | 底色策略 | 抠图 | 描边 | 导出尺寸 | 典型例子 |
|------|---------|------|---------|------|------|---------|---------|
| **character/sprite** | 1024×1024 | 512 | **白底** → 方便抠图 | ✅ rembg u2net | 2px Ink Navy | 64/128/256/512 | Saya 参考 |
| **monster/enemy** | 1024×1024 | 512 | **白底** | ✅ rembg u2net | 2px Ink Navy | 64/128/256/512 | Silence Mote, InkWarden |
| **NPC portrait** | 1024×1536 | 512×768 | **白底** | ✅ rembg u2net | 0px（圆形边框在游戏内叠加） | 128/256/512 | Archivist, Tuner, Silent Merchant |
| **item/prop** | 512×512 | 256 | **白底** | ✅ rembg u2net | 1px black | 32/64/128/256 | Voice Bell, Hourglass |
| **skill-icon** | 512×512 | 128 | **白底** | ✅ rembg u2net | 1px black | 32/64/128 | 5 verb icons |
| **achievement icon** | 256×256 | 64 | **白底** | ✅ rembg u2net | 1px black | 16/32/64 | Amber dot, Coral pulse, etc. |
| **background/environment** | 1920×1080 | N/A（不裁剪） | **场景自然底色** — 不抠图 | ❌ 不抠 | 0 | 480/960/1920 | Archive room, flooded hall |
| **tileset proxy** | 1024×1024 | N/A | **无缝纹理底** | ❌ 不抠 | 0 | 128/256/512 | Floor/wall tileset |
| **Steam capsule** | 616×353 / 1200×630 | exact（不变形） | **画面内自然渐变色** | ❌ 不抠 | 0 | 原始尺寸 | Main/Feature/Small |
| **effect/vfx** | 512×512 | 256 | **黑底**（便于 alpha 提取） | ✅ rembg u2net 或 manual | 0 | 64/128/256 | Wave pulse, repair bloom |

### 2.3 色板（严格继承 STYLE_GUIDE.md §色板）

```
Abyss Black      #05070D  — 最深背景
Ink Navy         #081426  — 主背景 / 阴影
Archive Blue     #12334A  — 石墙 / 远景
Deep Teal        #1D6570  — 水光 / 环境光
Glass Cyan       #69C7CE  — 玻璃边缘高光 / 交互高亮
Pale Resonance   #B7E7DD  — 高亮裂纹 / 眼睛
Muted Violet     #65506A  — 腐蚀边缘
Coral Pulse      #E86D5A  — 攻击波峰 / 危险预兆
Amber Voice      #F2B66E  — 修复成功 / 奖励 / 核心 UI
Warm Parchment   #E6D5B8  — 少量文字高亮
```

**色比强制**：冷色 75% + 中性色 15% + 暖色 10%。暖色仅作 accent，不做大面积填充。

### 2.4 Prompt 结构（英文，Seedream 5.0 标准输入）

```
[风格基座], [主体描述], [Voxglass 世界观], [色板约束], [技术后缀], [负提示词]
```

**示例（NPC 头像 - 档案管理员）**：
```
prompt = (
    "anime style illustration, cel-shaded, clean lineart, flat shading, "
    "elderly archivist scholar with white hair bun and round glasses, "
    "holding an amber glowing lantern, kind and wise expression, "
    "Voxglass style — melancholic resonance, flooded underground voice archive, "
    "cracked glass bells, living silence, warm waveform light. "
    "Color palette: ink-navy #081426 robe, archive-blue #12334A shadow, "
    "amber-voice #F2B66E lantern glow, warm-parchment #E6D5B8 skin. "
    "Cold colors dominate 75%, warm accents 10%. "
    "isolated on white background, upper body portrait, centered composition, "
    "expressive face, high contrast for easy background removal. "
    "game-ready 2D asset, crisp readable silhouette."
)

negative = (
    "no text, no watermark, no logo, no signature, no lettering, "
    "no blurry, no low quality, no jpeg artifacts, no grainy, no noisy, "
    "no photorealistic, no 3D render, no oversaturated, no overexposed, "
    "no realistic, no photorealistic, no rough sketch, no messy lines"
)
```

### 2.5 Seed 管理策略

```
Seed 区间分配（避免与既有 1001-1999 冲突）:
  2000-2199: A组 - 概念设定重绘 (20张)
  2200-2399: B组 - NPC/敌人/道具升级 (20张预留)
  2400-2599: C组 - 装饰/备选图标 (20张预留)
  2600-2999: 未来扩展预留

规则:
  - 每个新素材 = 1 个唯一 seed（起始 = 组起始值 + 偏移）
  - L2 评估不通过时: seed += 100（跳跃重试，避免邻近 seed 过于相似）
  - 新素材 ID 从 A075 开始递增（与既有 A001-A074 连续）
```

### 2.6 质量门槛（L1 + L2 双校验）

**L1（自动化，必须通过）**：
- `validate_asset()` → `ok == True`
- 内容占比 1%-98% 之间（非全空 / 非未抠）
- 中心偏移 < 30%

**L2（vision_eval，必须 PASS 且 verdict == KEEP）**：
- total score ≥ 14（默认阈值）
- 若 REJECTED → seed +100 重试一次
- 仍 REJECTED → 标注为 BLOCKED，写入 ASSET_REGISTRY 状态 REJECTED，原因存档

---

## 3. 分批次详细计划

### A 组：概念设定 & Steam 胶囊（视觉宪法 v2）

> **目标**: 用 Seedream 5.0 重绘 8 张核心概念图 + 升级 Steam capsule 三联图
> **迭代范围**: #99–#103（约 5 轮）
> **素材 ID**: A075–A082

| # | 素材名 | 类型 | 尺寸 | Seed | 参考旧素材 | 预计迭代 |
|---|--------|------|------|------|-----------|---------|
| A075 | Voxglass 情绪板 v2（概念艺术） | Moodboard/Concept | 2048×2048 | 2001 | A001 | #99 |
| A076 | Saya 主角设定 v2（全身 + 声匣特写） | Character/Concept | 1024×1536 | 2002 | A007 | #99 |
| A077 | 回声档案馆场景概念 v2（大厅视角） | Environment/Concept | 2048×1152 | 2003 | A003 | #100 |
| A078 | 寂静生物群概念 v2（Mote/Wisp/Warden 三态） | Enemy/Concept | 2048×2048 | 2004 | A004/A011 | #100 |
| A079 | 声匣道具概念 v2（破损/修复/共鸣三态） | Prop/Concept | 1024×1024 | 2005 | A013 | #101 |
| A080 | 共鸣 HUD/UI 套件 v2（横版布局） | UI/Concept | 1920×1080 | 2006 | A015 | #101 |
| A081 | Steam Feature Capsule 升级版（1200×630） | Marketing | 1200×630 | 2007 | A049 | #102 |
| A082 | Steam Main Capsule 升级版（616×353） | Marketing | 616×353 | 2008 | A047 | #103 |

**A 组产出物**:
- 8 张 PNG 原图（保留 raw 目录）
- 8 份 *_seedream_report.json（完整 prompt/seed/L1/L2 记录）
- ASSET_REGISTRY.md 新增 8 行（A075-A082）
- ROADMAP.md 新增 T183-T190 任务条目

### B 组：游戏内精灵升级（NPC/敌人/道具）

> **目标**: 替换掉 3 张 Pollinations 素材 + 升级 3 张程序化 NPC 头像
> **迭代范围**: #104–#109（约 6 轮）
> **素材 ID**: A083–A088

| # | 素材名 | 类型 | 尺寸 | Seed | 参考旧素材 | 预计迭代 |
|---|--------|------|------|------|-----------|---------|
| A083 | Silence Mote 敌人精灵 v2（漂浮态） | Enemy/Sprite | 1024→32游戏内 | 2201 | A022 | #104 |
| A084 | Voice Bell - 破损态 v2 | Prop/Item | 512→32游戏内 | 2202 | A023 | #105 |
| A085 | Voice Bell - 修复态 v2 | Prop/Item | 512→32游戏内 | 2203 | A024 | #105 |
| A086 | Archivist 头像 v2（NPC 对话） | NPC/Portrait | 1024×1536 → 512×768 | 2204 | A034 | #106 |
| A087 | Tuner 头像 v2（NPC 对话） | NPC/Portrait | 1024×1536 → 512×768 | 2205 | A035 | #107 |
| A088 | Silent Merchant 头像 v2（商店 NPC） | NPC/Portrait | 1024×1536 → 512×768 | 2206 | A051 | #108 |

**B 组关键约束**:
- 与 A 组不同，B 组需要**保持设计语义一致性**（角色轮廓、服饰主色必须与旧版对齐）
- A086-A088 头像是**圆形框友好构图**（主体在中心圆形内）
- A083 需做 shimmer 动画测试（与 A022 对比）
- 生成过程保留 flip 版本（角色左右朝向）

### C 组：装饰物件精致版 + 备选图标（可选扩展）

> **目标**: 提供"更好但非必需"的美术资产，供未来关卡扩展使用
> **迭代范围**: #110–#115（约 6 轮，若前面迭代有剩余时间）
> **素材 ID**: A089–A094

| # | 素材名 | 类型 | Seed | 备注 |
|---|--------|------|------|------|
| A089 | Hourglass 沙漏精致版 | Prop/Decorative | 2401 | A055 升级版 |
| A090 | Wave Totem 声波图腾精致版 | Prop/Decorative | 2402 | A056 升级版 |
| A091 | Hanging Bell 悬挂铃铛精致版 | Prop/Decorative | 2403 | A057 升级版 |
| A092 | 备选技能图标 - Pulse（不同圆环风格） | UI/Icon | 2404 | A/B 测试素材 |
| A093 | 备选技能图标 - Echo（不同护盾风格） | UI/Icon | 2405 | A/B 测试素材 |
| A094 | 备选成就图标 - 5 verb 合集 | UI/Achievement | 2406 | 设计探索 |

**C 组策略**: 仅在 A/B 组完成且有余力时执行。不作为 Steam 页面必需项。

---

## 4. 执行模板（每轮迭代内的操作序列）

### 每次执行 Seedream 换血任务时的标准操作流程：

```
1. 读取状态文件（ROADMAP/ASSET_REGISTRY/STYLE_GUIDE/ITERATION_COUNT）
2. 确认本组当前轮到的素材编号（例如 A组第3张 = A077）
3. 调用:
   result = run_seedream_pipeline(
       asset_type=<类型>,
       style=<风格>,
       subject=<英文主体描述>,
       seed=<本组 seed>,
       output_dir="/workspace/assets/<子目录>/<素材名>",
       version="5.0",
       fallback_to_pollinations=True,
       [可选 overrides: gen_size, canvas, exports, outline, ...],
   )
4. 检查 result["status"]:
   - "PASSED" → 保留，写 ASSET_REGISTRY
   - "BLOCKED"/"REJECTED" → 记录原因，尝试 seed+100 再跑一次；仍失败则进下一轮
5. 若 result 有 exports（多尺寸），确保最小尺寸（32/64）可读
6. 更新:
   - ASSET_REGISTRY.md 追加一行（按现有表格格式）
   - ROADMAP.md 标记本任务 done，追加下一任务
   - CHANGELOG.md 追加本条迭代记录（含 prompt 摘要 + seed + 产出文件路径）
   - ITERATION_COUNT.txt +1
7. 提交（Git），格式:
   iteration:seedream-<A/B/C>-<素材名> | tasks:T<xxx> | skills:byted-seedream-image-generate
```

### ASSET_REGISTRY 新行模板（遵循已有表格格式）:

```
| A075 | Voxglass 情绪板 v2 | Moodboard/Concept | Voxglass Seedream concept | doubao-seedream-5-0-260128 | 2001 | flooded voice archive atmosphere, melancholic resonance color palette | PASSED | assets/concepts/voxglass_moodboard_v2.png | 继承 A001 语义，Seedream 5.0 重绘；色板严格 #081426/#F2B66E 约束 |
```

---

## 5. 风险与缓解

| 风险 | 概率 | 影响 | 缓解策略 |
|------|------|------|---------|
| Seedream API 配额用完 / 响应慢 | 中 | 阻塞整轮 | 开启 fallback_to_pollinations=True；若持续失败，标记当前素材 BLOCKED，跳到下一张；等 quota 恢复后用 ITERATION_GUIDE retry 机制补做 |
| API key 缺失 | 高（agent 环境） | 无法启动 Seedream | 检测到无 key 时自动降级到 Pollinations；若连 Pollinations 也不可用 → 跳过本轮，保持旧素材，在 CHANGELOG 中注明「seedream 不可用，保持 v1 素材」 |
| 抠图失败（白底色与主体融合） | 中 | 边缘锯齿 | 双重抠图: rembg u2net + alpha matting；若失败，method="auto" 走边缘采样色度差抠图 |
| 色板漂移（AI 生成偏暖色太多） | 高 | 风格不统一 | negative prompt 强制 "no warm-tinted background"；L2 评估时检查冷/暖色占比；必要时 post-process 做色阶压缩 |
| seed 碰撞/重复 | 低 | 无法追溯 | 本组 seed 起始 2001 与旧 1001-1999 隔离；每次 +1/+100 严格递增；ASSET_REGISTRY 记录实际使用的 seed |
| 素材体积膨胀 | 低 | 仓库大小 | PNG 优化（optimize=True）；多尺寸导出保留最小 2-3 档（32/64/256 够了） |

---

## 6. 完成标准（Exit Criteria）

### 完成 = 任一条件满足:

1. **A 组 + B 组全部完成**（共 14 张素材 PASSED） → 核心换血完成
2. **迭代计数 #109 达到** → 时间预算用尽，未完成项标记 POSTPONED
3. **连续 3 轮 API 不可用** → 暂停并降级策略

### 验收清单:

- [ ] ASSET_REGISTRY.md 中 A075–A088 至少 14 条新增记录且状态 = PASSED/APPROVED
- [ ] 每张新素材的 *_seedream_report.json 存在且包含完整 prompt/seed/steps/L2 score
- [ ] 每张新素材的多尺寸导出 PNG 可打开（游戏内测试待开发侧接入）
- [ ] STYLE_GUIDE.md 末尾追加「Seedream v2 补充: 实际生成色板验证」一节
- [ ] ROADMAP.md 中 T183-T195 全部标记为 - [x]
- [ ] CHANGELOG.md 覆盖 #99-#109 的每条迭代记录

---

## 7. 与既有素材的共存策略

**不会删除或替换任何旧素材**。策略:

- **旧素材 (A001-A074)**：保留在 ASSET_REGISTRY 中，状态保持不变（APPROVED / DEPRECATED 不改变）
- **新素材 (A075-A094)**：标记为 "v2 upgrade"，路径独立（如 `assets/character/saya_concept_v2.png`）
- **游戏内接入**：开发者可选择在 Godot 场景中切换使用 v1 或 v2 精灵；默认先用 v1，待质量对比通过后切 v2
- **未来里程碑**：#120+ 做一轮"接入 v2 素材到实际场景"的 Code + Scene 编辑任务

---

## 8. 素材清单速查（A/B 组合计 14 张）

```
A组 - 概念设定 / Steam 胶囊 (8)
├── A075: Voxglass 情绪板 v2 (2048²)      ← 视觉宪法核心
├── A076: Saya 主角设定 v2 (1024×1536)     ← 二次元美少女 + 声匣
├── A077: 档案馆场景 v2 (2048×1152)        ← 环境参考
├── A078: 寂静生物群 v2 (2048²)            ← 敌人设计参考
├── A079: 声匣道具三态 v2 (1024²)          ← 道具设计参考
├── A080: HUD/UI 套件 v2 (1920×1080)       ← UI 设计参考
├── A081: Steam Feature 胶囊 (1200×630)    ← 商店大图升级版
└── A082: Steam Main 胶囊 (616×353)        ← 商店主胶囊升级版

B组 - 游戏内精灵升级 (6)
├── A083: Silence Mote v2 (1024→32)        ← 替换 A022 Pollinations 版
├── A084: Voice Bell - 破损态 v2 (512→32)  ← 替换 A023
├── A085: Voice Bell - 修复态 v2 (512→32)  ← 替换 A024
├── A086: Archivist 头像 v2 (1024→512)     ← 替换 A034
├── A087: Tuner 头像 v2 (1024→512)         ← 替换 A035
└── A088: Silent Merchant 头像 v2 (1024→512) ← 替换 A051

C组 - 可选扩展 (6)  [仅在 A/B 完成后做]
├── A089-A091: 三件装饰物件精致版
└── A092-A094: 三张备选图标（设计探索用）
```

---

*本计划随 #99 开始执行，每轮迭代结束后自动更新本文件的「进度速查」一节（如补充实际产出路径）。*
