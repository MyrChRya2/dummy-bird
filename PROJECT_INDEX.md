# 📁 DummyBird 项目管理文件索引

> 整理日期：2026-10-11 | 适用仓库版本：`main @ f9fa071`
> 本文件列出项目中与项目管理相关的全部文件及其作用，方便快速定位。
> **本文件也是 project-management skill 的项目配置入口**：路径约定、工作流规则都从这里读取。

## 〇、项目基本信息

| 项 | 值 |
|---|---|
| 项目名 | DummyBird（占位名，未定稿） |
| 仓库根 | `/mnt/d/Fox_n/!PROJECTS/#software/Projects/games/dummy-bird` |
| 远端仓库 | **公开** · `git@github.com:MyrChRya2/dummy-bird.git`（MIT） |
| 引擎 | Godot **4.7.1** stable（`D:\Fox_n\!PROJECTS\#software\Engines\Godot_v4.7.1-stable_win64.exe`） |
| 目标平台 | 待定（桌面优先） |
| 渲染器 | `Forward Plus`（非 2D 精灵游戏的常规选择，见「待决策 #1」） |
| 当前里程碑 | M0 工程基建（进行中） |

## 一、核心管理文档（`docs/`，已纳入 Git 版本控制）

| 路径 | 作用 |
|------|------|
| `docs/GDD.md` | **设计文档** — 项目的"宪法"：概述、核心设计、技术架构、待决策清单。 |
| `docs/ROADMAP.md` | **路线图** — 里程碑总览、任务清单与完成标准、优先级排序、决策记录、Bug 跟踪表。 |
| `docs/devlog/` | **开发日志目录** — 命名 `YYYY-MM-DD.md`（同日多篇加 `-b`/`-c` 后缀）。 |
| `docs/devlog/TEMPLATE.md` | **日志模板** — 每日收尾生成日志的骨架与提问清单。 |
| `docs/PROJECT_TREE_TEMPLATE.md` | **游戏文件树基础模板** — 目录分层约定、每层放什么、什么时候该拆；跨项目复用，持续迭代。 |

## 二、仓库级管理配置（项目根）

| 路径 | 作用 |
|------|------|
| `.gitignore` | 根级 Git 忽略规则（**含 `.dsh-meow/` 记忆库保护**、`.godot/` 生成物、签名密钥）；⚠️ 有意**不忽略** `export_presets.cfg` 与 `*.uid`（官方建议入库） |
| `.gitattributes` | Git 属性（换行符统一 `eol=lf`） |
| `.editorconfig` | 编辑器统一配置（UTF-8） |
| `PROJECT_INDEX.md` | 本文件 — 索引与 skill 配置入口 |
| `LICENSE` | **MIT**——本项目以 MIT 许可开源 |

## 三、工程内配置（`GAME/`）

| 路径 | 作用 |
|------|------|
| `GAME/project.godot` | Godot 工程配置（引擎版本、渲染器、窗口拉伸、物理引擎、**主场景**） |
| `GAME/icon.svg(+.import)` | 工程图标 |
| `GAME/tools/` | **工程设置工具集**（全部走引擎 API 写回 `project.godot`，不手改文本；用法见各脚本头部注释） |
| `GAME/tools/set_main_scene.gd` | 设置主场景（等同 Project Settings → Application → Run → Main Scene） |
| `GAME/tools/set_renderer.gd` | 切换渲染器（gl / forward / mobile） |
| `GAME/tools/set_pixel_perfect.gd` | **像素完美渲染地基**：Nearest 过滤 + 视口尺寸 + 拉伸方式 + 横屏，一条命令重置 |
| `GAME/tools/setup_input_map.gd` | 注入 `flap` 输入动作（鼠标左键 / 空格 / 屏幕轻触） |
| `GAME/.editorconfig` `.gitattributes` `.gitignore` | 引擎目录内的编辑器/Git 局部约定 |
| `GAME/assets/` | 运行时素材。现有 `sprite/entity/player.png`、`sprite/tile/tiles.png`、`sprite/error/Eroor.png`；目录约定 `sprite/{bg,entity,item,tile,error}`、`audio/{bgm,sfx}`、`font/`、`ui/` |
| `GAME/scenes/` | 正式场景：`Player.tscn`（角色：CharacterBody2D + AnimatedSprite2D + CircleShape2D + Jump 子节点）、`playground.tscn`（**当前主场景**，已实例化 Player） |
| `GAME/scripts/` | GDScript：`Player.gd`、`jump.gd`、`00_movement.gd`（另有 `state.svg`，见「七之二」待整理） |
| `GAME/DEV/` | **开发草稿区**——现为 `test_scenes/{obstacle,test_scence}.tscn`，不作正式资产；稳定后再移入 `scenes/` |

## 四、仓库外配合目录

| 路径 | 作用 | 是否入 Git |
|------|------|-----------|
| `SOURCE/Resprite/` | **美术源文件母版**（Resprite 工程 `.resprite` + 导出 PNG）。**实测确认**：这些 PNG 内**无内嵌工程数据**（tEXt/iTXt/zTXt 块全空），故 `.resprite` 是唯一可编辑母版，丢了无法复原——**必须入库**。 | 是（**必须入库**） |
| `../godot-game-template/` | **独立模板仓（不在本仓库内，模板的单一事实源）**——路径 `/mnt/d/Fox_n/!PROJECTS/#software/Projects/games/godot-game-template`。可复用骨架 + `new-game.sh` 生成脚本。**新项目都从这里起盘**。详见 `docs/PROJECT_TREE_TEMPLATE.md`。 | 否（独立仓） |
| `.dsh-meow/` | AI 会话记忆库（`memory.db`） | **否**（已在 `.gitignore` 排除，误删不可恢复） |

## 五、目录结构速览

```
dummy-bird/                        # 项目根（Git 仓库根）
├── PROJECT_INDEX.md               # 本文件（skill 配置入口）
├── .gitignore / .gitattributes / .editorconfig
├── docs/                          # 文档中心
│   ├── GDD.md                     # 设计文档
│   ├── ROADMAP.md                 # 路线图
│   ├── PROJECT_TREE_TEMPLATE.md   # 文件树模板（跨项目复用）
│   └── devlog/                    # 开发日志
│       ├── TEMPLATE.md
│       └── YYYY-MM-DD.md
├── GAME/                          # Godot 工程（引擎目录）
│   ├── project.godot              # 渲染器 = gl_compatibility
│   ├── assets/{sprite,audio}/     # 运行时素材
│   ├── scenes/                    # 正式场景（主场景 = playground.tscn）
│   ├── scripts/                   # GDScript
│   ├── tools/                     # 引擎侧工具（set_main_scene / set_renderer）
│   └── DEV/                       # 开发草稿区（不加 .gdignore）
├── SOURCE/                        # 美术/音频源文件母版
└── .dsh-meow/                     # AI 记忆库（不入库）

（模板不在本仓内：独立仓在 ../godot-game-template/，是本项目与未来所有项目的起盘入口）
```

## 六、文档协作工作流（当前约定）

1. **决策** → 先写进当日 devlog，再同步 ROADMAP / GDD
2. **开发前** → 看 ROADMAP 优先级表
3. **设计疑问** → 查 GDD 待决策清单
4. **每日收尾** → 说"今天任务已结束"，AI 读 `docs/devlog/TEMPLATE.md` 生成日志
5. **路径/结构变更** → 必须同步更新本文件
6. **周期性任务** → 记录在 ROADMAP（如周更视频/周报）
7. **提交** → 小步原子提交，`type: subject` 英文前缀 + 中文正文，见 project-management/`/commit`

## 七、更新记录

- 2026-10-11（8）：同步开发进展——`scenes/`（Player/playground）、`scripts/`（Player/jump/00_movement）、`assets/sprite/{entity,tile,error}`、`DEV/test_scenes/`、`SOURCE/Resprite/`（美术源文件母版）；并登记 4 项待整理。
- 2026-10-11（7）：新增 `GAME/tools/{set_pixel_perfect,setup_input_map}.gd`；定义 `flap` 输入动作（鼠标左键/空格/屏幕轻触）；修正 `.gitignore` 误忽略 `export_presets.cfg`，纳入 `*.uid`，补签名密钥忽略；模板仓同步修正。
- 2026-10-11（6）：推送为 GitHub 公开仓 `MyrChRya2/dummy-bird`（MIT）；M0 基建里程碑完成。
- 2026-10-11（5）：确定开源许可 **MIT**；新增根目录 `LICENSE`；登记 `GAME/icon.svg` 为 Godot 官方默认图标（第三方内容）。
- 2026-10-11（4）：删除本仓 `templates/` 副本（用户拍板）——模板只保留独立仓 `../godot-game-template/`，消除双副本漂移；本仓起盘入口改为指向独立仓。
- 2026-10-11（3）：渲染器切 `Compatibility`；`SORCE/`→`SOURCE/`；模板抽出独立仓 `../godot-game-template/`；新增 `GAME/tools/set_renderer.gd`；文件树模板升 v0.2（T1–T5 全部已决）。
- 2026-10-11（2）：补设主场景 `scenes/playground.tscn`；新增 `GAME/tools/set_main_scene.gd`；模板加入默认主场景 `Main.tscn`。
- 2026-10-11：创建本文件（索引首版）；建立仓库与 Godot 工程目录规范。

## 七之二、待整理（发现的问题，尚未处理）

| # | 问题 | 建议 |
|---|---|---|
| 1 | `GAME/scripts/state.svg` 是图片却放在 `scripts/` 里（连 `.import` 一起） | 移到 `GAME/assets/ui/` 或 `assets/sprite/`；若它是脚本目录的说明图，改放 `docs/`。**Godot 只认 `res://` 路径，移动须在编辑器里拖拽** |
| 2 | `sprite/error/Eroor.png` 拼写 `Eroor` → `Error` | 统一拼写（趁引用还少）；改名同样要在编辑器里做 |
| 3 | `SOURCE/Resprite/` 与 `GAME/assets/sprite/` 不同构（按"工具/项目名"分层，而非按用途） | 两种都行。若保持现状，建议在 `SOURCE/` 放一份 `README.md` 说明"哪个源文件导出到哪个运行时路径"，避免以后对不上 |
| 4 | `DEV/test_scenes/test_scence.tscn` 拼写 `scence` → `scene` | 与早先的 `scense` 是同一类问题，建议顺手改 |

> 以上均为**建议**，不是阻断项；等你决定即可，需要我改就安排。

## 八、许可与第三方内容

| 项 | 说明 |
|---|---|
| 本项目代码与文档 | **MIT License**（见根目录 `LICENSE`），Copyright (c) 2026 MyrChRya2 |
| `GAME/icon.svg` | **不是本项目原创**——来自 Godot 引擎自带的默认工程图标模板，版权归 Godot Engine 贡献者所有，按 MIT 许可使用（Godot Engine 亦为 MIT）。日后替换为原创图标时，请删除本行说明 |
| 未来新增的美术/音频 | 若要与代码采用不同许可（例如素材用 CC0 而代码保持 MIT），在本表登记并在 `SOURCE/`、`GAME/assets/` 下放置对应说明 |
| Godot 引擎本身 | MIT；**用 Godot 制作和分发游戏不产生任何开源义务**，可闭源商用 |
