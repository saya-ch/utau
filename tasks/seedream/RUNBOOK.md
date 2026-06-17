# Seedream 换血工程 · 执行手册（Runbook）

> ⚠️ **这不是规划文件 — 这是面向 #100 起每个未来 Agent 的逐轮执行手册。**
> **每读完一份任务规格后，必须按本手册真实调用 Seedream API、产出 PNG、抠图、登记台账。**
> **不要写代码就结束 — 必须有 `assets/.../<file>.png` 真的落在硬盘上。**

---

## 0. 强制启动序列（每个未来 Agent 必读）

```
1. 读取 ITERATION_GUIDE.md 并按其执行
2. 读取本 RUNBOOK.md（位于 tasks/seedream/）
3. 读取本轮 ROADMAP 中「新增任务池（#100 起）」分配的任务编号（T186–T205）
4. 读取 tasks/seedream/<group>/<Axxx_name>.md 任务规格（subject / overrides / output path）
5. ⚠️ 实际调用 byted-seedream-image-generate skill 生成 PNG ⚠️
6. ⚠️ 调用 pipeline_seedream.py 做后处理（抠图/描边/多尺寸）⚠️
7. ⚠️ 在 ASSET_REGISTRY.md 写入 1 条新登记 ⚠️
8. ⚠️ 提交 git commit（带新 PNG） ⚠️
9. 更新 ROADMAP（勾选 1 个 [x]）/ CHANGELOG（加 1 行）/ ITERATION_COUNT.txt（+1）
```

> **未生成 PNG 不得勾选 ROADMAP 任务。** 把任务写成 [x] 但磁盘上没有 PNG 等于自欺欺人。

---

## 1. 每轮严格 1 个素材（30 分钟节奏）

| 步骤 | 时间 | 说明 |
|------|------|------|
| 读规格 | 1 min | `tasks/seedream/<group>/<Axxx>.md` |
| 调 Seedream | 3–8 min | byted-seedream-image-generate skill |
| 后处理 | 2–3 min | `python scripts/pipeline_seedream.py --asset A075 ...` |
| 验证 L1 | 1 min | `validate_asset()` 自动通过 |
| 视觉 L2 | 2 min | 检查 PNG（cold 75% / 暖色 10% / shape language）|
| 登记台账 | 2 min | ASSET_REGISTRY.md 新增 1 行 |
| 写报告 | 2 min | `*_seedream_report.json` |
| git commit | 1 min | atomic 提交 |
| ROADMAP/CHANGELOG/iter | 2 min | 同步三份文档 |

> **不要** 一次塞 2 个素材。1 轮 1 资产 = atomic commit，可回滚可追溯。

---

## 2. 真实调用 Seedream API（必做）

### 2.1 skill 调用模板

```python
# scripts/pipeline_seedream.py 用法
python scripts/pipeline_seedream.py \
    --asset-id A075 \
    --asset-type moodboard \
    --style anime \
    --subject-file tasks/seedream/01_group_a_concept/A075_moodboard.md \
    --seed 2001 \
    --output-dir assets/marketing \
    --no-matting
```

> `--no-matting` 标志：**A 组概念/营销图不抠图**（场景完整保留）。
> **B/C 组不加 `--no-matting`**，自动白底抠图 + 描边 + 多尺寸导出。

### 2.2 skill 不可用时的回退

若 `byted-seedream-image-generate` 报错 / 超时 / 4xx/5xx：
1. 重试 1 次（同 seed）
2. 仍失败 → 换 `scripts/pollinations.py` 后备（标记为 "Pollinations fallback"，`model` 列改写为 `pollinations-flux`）
3. 再失败 → 在 CHANGELOG 标注 `[DEFERRED]`，跳过本轮（不勾 ROADMAP），下一轮从 seed+1 重试

> **不得** 把"API 调不通"当作"完成本轮"的理由。失败也是结果（必须登记 / 标注 / 提交失败 commit）。

### 2.3 seed 不确定性管理

若 Seedream 输出视觉/构图与 spec 期望差距大：
- 同 seed 重生成 1 次（2 次取最优）
- 不行 → 改 `retry_seed`（规格文件已写 A: 2400-2407 / B: 2500-2505 / C: 2600-2605）
- 再不行 → 标 `[NEEDS_PROMPT_REWORK]`，**不**勾 ROADMAP，留 #next 重新规划

---

## 3. 抠图 / 描边 / 多尺寸导出（按素材类型）

| 类型 | 后处理链 |
|------|----------|
| **A 组**（A075–A082） | `validate_asset()` → save full PNG（不抠图）|
| **B 组敌人 / 道具**（A083–A085） | `rembg_remove_bg(u2netp)` → `add_outline(width=1, color="ink_navy")` → `export_sizes([32, 64, 128, 256, 512])` |
| **B 组 NPC 头像**（A086–A088） | `rembg_remove_bg(u2netp)` → **不描边**（UI 圆形框）→ `export_sizes([128, 256, 512])` |
| **C 组装饰物件**（A089–A091） | `rembg_remove_bg` → `add_outline(width=1, color="black")` → `export_sizes([32, 64, 128, 256])` |
| **C 组图标/成就**（A092–A094） | `rembg_remove_bg` → `add_outline(width=1, color="black")` → `export_sizes([16, 32, 64, 128])` |

> **白底 pure white** 是 B/C 组必填底色（spec 已固化），否则 `rembg u2net` 失败。
> 描边颜色 / 宽度：每份 spec 写明，不允许拍脑袋改。

---

## 4. ASSET_REGISTRY.md 登记模板（每素材 1 行）

```markdown
| A075 | Voxglass 情绪板 v2 | Marketing/Moodboard | Voxglass Seedream anime moodboard | doubao-seedream-5-0-260128 | 2001 | 4-panel moodboard: bell, wave, light, silhouette | PASSED | assets/marketing/moodboard_v2.png | 替换 A001；4-panel 概念版；cold 75% / warm 10%；不抠图 | 2026-06-12 |
```

字段顺序（与既有台账一致）：
1. `Axxx` Asset ID
2. 名称
3. 类型/分类
4. 风格描述
5. 模型 + 版本
6. seed
7. 主体一句话描述
8. 状态（PASSED / FALLBACK / DEFERRED）
9. 路径
10. 备注（替换关系 / 抠图策略 / 色彩比例）
11. 日期

---

## 5. seedream_report.json 模板

`assets/.../A075_moodboard_seedream_report.json`：

```json
{
  "asset_id": "A075",
  "model": "doubao-seedream-5-0-260128",
  "version": "5.0",
  "seed": 2001,
  "prompt": "<完整 subject 字符串>",
  "negative": "<完整 negative 字符串>",
  "gen_size": [2048, 2048],
  "canvas": 1024,
  "exports": [1024],
  "outline": 0,
  "matting": false,
  "timestamp": "2026-06-12T15:30:00Z",
  "status": "PASSED",
  "fallback_chain": []
}
```

> **必须** 把调用原貌留档，未来审计/重生成/对比风格时唯一可信源。

---

## 6. 失败 / 跳过 / 重做的纪律

| 情况 | 处理 |
|------|------|
| Seedream 报错 1 次 | 重试同 seed |
| 重试仍失败 | 换 retry_seed |
| retry_seed 也失败 | 标 `DEFERRED`，**不勾 ROADMAP** |
| 视觉与期望严重不符（颜色/构图/形状语言） | 标 `NEEDS_REWORK`，**不勾 ROADMAP** |
| Pollinations 后备成功 | `model` 列改为 `pollinations-flux`，`status` = `FALLBACK`，CHANGELOG 注明 |
| PNG 落盘但无 `*_seedream_report.json` | 视为**未完成**，需补报告 |

> **任何情况下**，"我没时间跑 API" / "skill 调不通就算了" / "明天再说" → **视为任务失败**，CHANGELOG 留 1 行失败记录。

---

## 7. git commit 规范

每完成 1 个素材 → 1 个 atomic commit：

```bash
git add tasks/seedream/<group>/<Axxx>_<name>.md
git add assets/.../<Axxx>_<name>.png
git add assets/.../<Axxx>_<name>_seedream_report.json
git add ASSET_REGISTRY.md
git commit -m "[Seedream] A075 Voxglass moodboard v2 — moodboard 4-panel, seed 2001, doubao-seedream-5-0-260128, status PASSED"
```

> 一次 commit 一个素材；不打 bundle。便于回溯任一时刻任一素材状态。

---

## 8. 20 轮节奏建议（给 #100–#119 未来 Agent 的优先序）

| 轮次 | 任务 | 优先级 |
|------|------|--------|
| #100 | T186 A075 moodboard | **最高**（奠定所有图风格基调）|
| #101 | T187 A076 Saya concept | 高（主角定稿）|
| #102 | T188 A077 archive scene | 高（场景氛围）|
| #103 | T189 A078 enemy sheet | 高（敌人族系）|
| #104 | T190 A079 bell three-state | 中 |
| #105 | T191 A080 HUD kit | 中 |
| #106 | T192 A081 Steam feature | 中 |
| #107 | T193 A082 Steam main | 中 |
| #108 | T194 A083 silence mote | **最高**（首张核心精灵换血）|
| #109 | T195 A084 bell-broken | 高 |
| #110 | T196 A085 bell-repaired | 高 |
| #111 | T197 A086 Archivist NPC | 高 |
| #112 | T198 A087 Tuner NPC | 高 |
| #113 | T199 A088 Silent Merchant NPC | 高 |
| #114 | T200 A089 hourglass | 中 |
| #115 | T201 A090 wave totem | 中 |
| #116 | T202 A091 hanging bell | 中 |
| #117 | T203 A092 Pulse icon alt | 低 |
| #118 | T204 A093 Echo icon alt | 低 |
| #119 | T205 A094 achievement set | 低（探索素材，可延后）|

> #100–#113 是核心换血，**必须** 落地；#114–#119 是装饰/探索，可视时间延后。

---

## 9. 自检清单（每轮结束前 30 秒）

- [ ] `assets/.../<Axxx>.png` 落盘（且 `ls -lh` 看到尺寸 > 0）
- [ ] `assets/.../<Axxx>_seedream_report.json` 落盘
- [ ] `ASSET_REGISTRY.md` 增 1 行
- [ ] `ROADMAP.md` 对应 T186..T205 勾 1 个 `[x]`
- [ ] `CHANGELOG.md` 顶部增 1 条 #n 条目
- [ ] `ITERATION_COUNT.txt` +1
- [ ] `git status` 干净（1 个 commit 包含 1 个素材 + 报告 + 台账 + 文档）
- [ ] **PNG 在 16x16 缩略图下仍可辨识主体**（最小尺寸 sanity check）

> **任何一项未完成 = 本轮未完成，不得勾 ROADMAP。**

---

## 10. 一句话总结

**每轮 1 素材 = 调 API + 抠图 + 描边 + 导出 + 登记台账 + git commit。**
**不调 API = 没干活 = 不算迭代。**

未来 Agent 看到此手册：**请真跑 API、真存 PNG、真登记。** 任何"我只写了 spec"的 iteration 视为 0 进度。
