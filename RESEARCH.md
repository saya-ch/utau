# Research

## 2026-06-02 初始化市场调研

### 结论摘要

Steam/itch.io 的 2D 独立游戏机会仍然存在，但不能用「像素平台跳跃」本身当卖点。2025 Steam 供给极度拥挤，能被算法和玩家记住的项目通常有一个可被截图、短视频和 30 秒试玩直接理解的强钩子。UTAU 的第一方向应当避开纯 2D 平台动作的红海，采用「小范围高密度探索 + 可重复短局 + 独特世界观机制」。

本轮选择方向：**Voxglass**，一款以「声音修复 / 玻璃声匣 / 活体寂静」为核心意象的 2D 像素动作探索游戏。玩法基底是精炼 Metroidvania 房间探索，加入轻量 roguelite 的房间变体与短局奖励，但不做大地图、不做纯程序地牢。

### 市场趋势

- **供给过剩，识别度比题材更关键。** PC Gamer 统计 SteamDB 数据称 2025 年 Steam 超过 19,000 款新游戏上线，近半低于 10 条评测，说明「能被一眼记住」比单纯追热门标签更重要。
- **独立游戏仍有上行空间，但命中率很低。** How To Market A Game 对 2025 年 Steam 游戏的年度复盘显示，20,282 款新作中 608 款达到 1,000+ 评测，约 2.99%；这是改善，但仍要求强玩法和强展示。
- **成功标签偏向可重复游玩、叙事/氛围和系统深度。** 同一复盘中，Narrative、Simulation、Horror、RPG、Idle、Roguelike 都进入 2025 高评测数量前列；roguelike deckbuilder、management、horror 的表现优于普通平台跳跃。
- **2D 平台跳跃/解谜供给过密。** How To Market A Game 统计 2025 年 2D Platformer 约 1,658 款，但只有 3 款达到 1,000+ 评测；Puzzle 也供给极高。UTAU 不能只做「好看的平台跳跃」。
- **itch.io 的 2D/Pixel Art 生态很大但偏原型和浏览器体验。** itch.io 标签页显示 2D、Pixel Art、Roguelike、Metroidvania、Cozy 都有大量结果。Steam/itch 双平台方向应当保留 itch 的可传播原型优势，但产品目标必须是可下载、可手柄、可 Steam 页面展示的完整独立游戏。

### itch.io 标签观察

| 标签 | 观察 | 对 UTAU 的启发 |
| --- | --- | --- |
| 2D | itch.io `2D` 标签规模巨大，关联 Horror、Visual Novel、Singleplayer、Pixel Art、Puzzle 等 | 2D 是载体，不是差异点 |
| Pixel Art | 与 Horror、Cute、Atmospheric、Short、Exploration 等强关联 | 像素风必须靠色彩、轮廓和世界观立住 |
| Roguelike | 与 Pixel Art、Roguelite、Fantasy、Strategy、Dungeon Crawler、Card Game 关联 | 可以借短局、升级选择、重玩性，但避免泛地牢 |
| Metroidvania | 与 Pixel Art、Platformer、2D、Exploration、Retro 强关联 | 能服务探索和能力门，但市场对普通 MV 很挑剔 |
| Cozy | 与 Cute、Pixel Art、Relaxing、2D、Simulation 关联 | 可吸收「修复、安定、归还声音」的情感，不走纯可爱农场 |

### 玩家情感共鸣点

- **修复与找回。** 让玩家不是单纯杀怪，而是在战斗后恢复一段声音、一盏灯、一间房。奖励具有情绪反馈。
- **孤独但不绝望。** 视觉靠深色水下/地下空间承载氛围，奖励用暖色声波和玻璃亮起表达希望。
- **可掌握的短循环。** 30 秒内完成：进入房间 -> 读敌人节奏/弹道 -> 声波反制或位移 -> 获得共鸣碎片 -> 开门/升级/修复。
- **能力即世界观。** 攻击、开门、照明、解谜都来自「唱出/调谐声音」，避免功能堆叠。
- **失败可归因。** 敌人、电波、门锁、危险地形都用波形预兆表现，玩家失败应理解为读错节奏或站位，而不是视觉噪声。

### 候选方向

#### 方向 A：Voxglass / 声匣修复者

- 类型：2D 动作探索 + 轻量 roguelite 房间变体。
- 世界观：地下声档案馆被「活体寂静」腐蚀，人类失去的声音被封存在玻璃钟罩中。女主 Saya 用左臂玻璃声匣与喉口共鸣晶体修复声音，也把失声者的记忆带回世界。
- 核心机制：三种声波动词：Pulse 推/破盾、Bind 暂停/牵引、Cut 切断腐蚀链。每个动词既是战斗动作也是探索钥匙。
- 优势：截图识别度高；世界观与玩法天然绑定；可以从小竖切开始；适合像素艺术与 VFX。
- 风险：节奏/音频反馈如果做弱，卖点会变成空壳；需保证动作手感优先。

#### 方向 B：Mosslight Courier / 苔灯邮差

- 类型：俯视角 cozy exploration + 轻生存路线规划。
- 世界观：玩家在夜间森林给失眠村落送会发光的苔灯，路上避开会吞光的雾。
- 优势：cozy 与探索结合，情绪友好，范围可控。
- 风险：玩法张力偏弱，容易变成任务清单；Steam 首屏钩子不如 A。

#### 方向 C：Debt Lantern / 债灯旅馆

- 类型：2D 管理 + 夜间防守 + 叙事事件。
- 世界观：玩家经营给亡者暂住的灯旅馆，用房间、债务和禁忌交易维持生意。
- 优势：管理/叙事标签市场表现较好；系统深度空间大。
- 风险：第一轮需要较多 UI 与数据系统，视觉动作展示弱。

#### 方向 D：Clock-Braid / 断钟编织

- 类型：短关卡时间回溯 puzzle-platformer。
- 世界观：玩家用断裂钟线缝合一座失序城市。
- 优势：机制纯度高，适合短视频展示。
- 风险：Puzzle/Platformer 供给过密；关卡设计难度高，早期产出慢。

#### 方向 E：Null Orchard / 空果园

- 类型：cozy horror farming + 资源转化。
- 世界观：种出来的不是作物，而是人们不愿面对的记忆。
- 优势：cozy+horror 情绪反差有传播性。
- 风险：容易靠文本支撑，核心动作循环不够清晰。

### 选定依据

选择 **方向 A：Voxglass / 声匣修复者**。

1. 它把市场中的有效元素压缩成可做的范围：roguelite 的短局选择、Metroidvania 的能力门、horror/narrative 的氛围，但不承诺大地图或大叙事。
2. 「声音修复」能直接生成玩法动词、VFX、UI、收集物和结算反馈，避免世界观与机制脱节。
3. 视觉锚点清晰：玻璃钟罩、波形、深水档案馆、暖色共鸣、黑色寂静生物。截图中不需要文字就能识别。
4. 第一版竖切可以很小：一个房间、一个角色、一个敌人、一个声波技能、一个可修复钟罩、一个门。
5. 它继承 UTAU 名称的「歌 / 声」联想，但不依赖既有 IP。

### 概念锚定

**工作标题：Voxglass**

在一座沉入地下水脉的声档案馆里，人类失去的告别、名字和歌声被封存在玻璃钟罩中。某天，「寂静」长出形体，开始吞掉钟罩里的波形。玩家扮演最后的声匣修复者 Saya：短深色头发、一缕长青色发束、喉口琥珀共鸣晶体、左臂紧凑玻璃声匣、裂纹玻璃披肩与声波围巾构成她的第一眼识别。她在破碎房间之间穿行，每修复一枚声音，房间会亮起一段暖色声波，也解开一条新的路。Saya 不拯救世界，只把被夺走的声音一点点还给它的主人。

**核心循环**

1. 进入一个 20-40 秒可完成的小房间。
2. 观察敌人/陷阱的声波预兆。
3. 使用 Pulse / Bind / Cut 解决战斗或移动难题。
4. 获得共鸣碎片，修复钟罩或选择本轮升级。
5. 开启新门，回到 hub 或进入下一房间变体。

**首轮可验证卖点**

- 一键 Pulse 既攻击敌人、震碎玻璃锁，也点亮场景波形。
- 所有危险都提前发出可读波形，强化「听见危险」的感觉。
- 战斗胜利不是掉金币，而是房间恢复一段暖色声音。
- 关卡规模小但密度高：3 个房间即可展示核心体验。

### 源与链接

- How To Market A Game, `What the hell happened in 2025?`: https://howtomarketagame.com/2026/01/27/what-the-hell-happened-in-2025/
- PC Gamer, `More than 19,000 games launched on Steam this year`: https://www.pcgamer.com/gaming-industry/more-than-19-000-games-launched-on-steam-this-year-but-almost-half-have-fewer-than-10-reviews/
- SteamDB, `Top Rated Steam Releases of 2025`: https://steamdb.info/stats/gameratings/2025/
- itch.io, `Top games tagged 2D`: https://itch.io/games/tag-2d
- itch.io, `Top games tagged Pixel Art`: https://itch.io/games/tag-pixel-art
- itch.io, `Top games tagged Roguelike`: https://itch.io/games/tag-roguelike
- itch.io, `Top games tagged Metroidvania`: https://itch.io/games/tag-metroidvania
- itch.io, `Top games tagged Cozy`: https://itch.io/games/tag-cozy
