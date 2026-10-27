# DummyBird

**中文** · [English](#english)

一款 **2D 像素 · 单键点击跳跃**小游戏（横屏、无剧情），目标平台为网页（itch.io）与 Android（TapTap）。

> **项目的主要目的是学习技术美术（技美）**：游戏是载体，shader / 特效 / 渲染 / 动画这些能力才是主要产出。
> 因此做取舍时优先选"能学到东西"的方案，而不是"最省事"的方案。

本仓库同时是一套**游戏项目文件结构的参考实现**——下面详细说明每一层放什么、为什么这样分组。
如果你想给自己的项目套用同样结构，见 [§6 如何复用到别的项目](#6-如何复用到别的项目)。

---

## 1. 目录总览

```
dummy-bird/                      # ← Git 仓库根 = 项目根（不是 Godot 工程根）
├── README.md                    # 本文件：结构说明与使用约定
├── PROJECT_INDEX.md             # 项目索引（空间地图 + 工作流约定）
├── LICENSE                      # MIT
├── .gitignore                   # 根级忽略规则
│
├── docs/                        # 文档中心（与游戏代码分离）
│   ├── GDD.md                   #   设计文档："这游戏是什么"
│   ├── ROADMAP.md               #   路线图："现在该做什么"
│   ├── PROJECT_TREE_TEMPLATE.md #   本结构规范的完整版（跨项目复用）
│   ├── tech-art-log.md          #   技美实验日志（按技法主题沉淀）
│   └── devlog/                  #   开发日志："那天发生了什么"
│       ├── TEMPLATE.md
│       └── YYYY-MM-DD.md
│
├── GAME/                        # ← Godot 工程（引擎目录，res:// 指向这里）
│   ├── project.godot            #   工程配置（渲染器/拉伸/版本号/主场景）
│   ├── export_presets.cfg       #   导出预设（Web / Android）
│   ├── icon.svg
│   ├── assets/                  #   运行时素材（进游戏包）
│   │   ├── sprite/{bg,entity,item,tile,error}/
│   │   └── audio/{bgm,sfx}/
│   ├── scenes/                  #   正式场景（.tscn）
│   │   ├── main.tscn            #     主场景：UILayer + 各界面
│   │   ├── playground.tscn      #     游戏世界
│   │   ├── Player.tscn
│   │   ├── failed_manu.tscn
│   │   ├── obstacle/            #     按功能分组的场景
│   │   └── ui/                  #     界面场景（菜单/暂停/HUD/设置）
│   ├── scripts/                 #   GDScript
│   │   ├── 00_game_state.gd     #     全局状态机（Autoload）
│   │   ├── main.gd              #     主场景装配
│   │   ├── Player.gd / jump.gd / 00_movement.gd
│   │   ├── obstacle/            #     按功能分组的脚本
│   │   ├── ui/                  #     各界面脚本
│   │   └── world/               #     世界规则（如 kill_zone）
│   ├── resources/               #   自定义 Resource 数据资产（.tres）
│   │   ├── ObstacleCurve.tres
│   │   └── ui/menu_theme.tres   #     UI 主题（共享样式）
│   ├── tools/                   #   工具脚本（见 §3.3）
│   │   ├── engine/              #     工程设置工具（跨项目可复用）
│   │   └── debug/               #     玩法调试件（发布前整个删掉）
│   └── DEV/                     #   开发草稿区（原型/试验，不承诺质量）
│       └── test_scenes/
│
├── SOURCE/                      # ← 美术/音频源文件母版（不进游戏包，但必须入库）
│   ├── README.md                #   源文件 ↔ 运行时素材的对应表
│   └── Resprite/                #   按工具名分组（Resprite 工程）
│
└── EXPORTS/                     # ← 导出产物（已被 .gitignore 忽略）
    ├── web/<版本>/
    └── android/<版本>.apk
```

> 说明：`.uid`（脚本/资源的稳定标识）、`.import`（导入配置）与 `.godot/`（引擎缓存）等文件未在树中展开。
> 其中 `.uid` 与 `.import` **必须入库**，`.godot/` **必须忽略**。

---

## 2. 分组依据：四条原则

### 2.1 仓库根 = 项目根，而不是 Godot 工程根

`GAME/` 只是仓库里的一个目录，`docs/`、`SOURCE/`、`EXPORTS/` 与它平级。

| 方案 | 优点 | 代价 |
|---|---|---|
| **仓库根 = 项目根（本方案）** | 文档、美术源文件、导出配置、发布物全在一个仓库；只有一个 `.git`；换引擎/加工具不用挪窝 | Godot 的 `res://` 只到 `GAME/`，引擎看不到 `docs/`——**这正是目的**：文档不该进游戏包 |
| 仓库根 = `GAME/` | 打开即用，路径短 | 文档/源文件/构建脚本只能塞进工程内，会被 `res://` 扫描、被导出、污染工程搜索 |

### 2.2 文档与代码分离（`docs/` vs `GAME/`）

文档不进 `GAME/`，因为 Godot 会扫描 `res://` 下所有文件；而 `docs/` 在仓库根，编辑器完全不感知。
四份文档职责不重叠：**GDD 回答"是什么"、ROADMAP 回答"做什么"、devlog 回答"那天发生了什么"、PROJECT_INDEX 回答"东西在哪"**。

### 2.3 运行时素材（`assets/`）与源文件母版（`SOURCE/`）分离

- `GAME/assets/` 放**导出成品**（`.png` / `.wav`），会被打进游戏包。
- `SOURCE/` 放**可编辑母版**（`.resprite` / `.aseprite` / `.psd` / `.blend`），**绝不进游戏包，但必须入库**。

> **为什么源文件必须入库**：实测确认导出的 PNG 里**没有内嵌工程数据**（`tEXt/iTXt/zTXt` 块全空）。
> 所以 `.resprite` 是唯一可编辑母版——丢了就再也改不了原图，只能重画。
> 反过来，母版放 `assets/` 会被 `res://` 扫描、进导出包、体积膨胀。

### 2.4 功能分组：一个功能 = 一组同名目录

当某个功能的文件散落在 `scripts/` 与 `scenes/` 且数量 ≥ 3，**或它已被正式场景引用**，就为它建一组同名目录：

```
scripts/obstacle/          scenes/obstacle/
├── spawner.gd             ├── obstacle.tscn
├── curve.gd               └── half.tscn
└── obstacle.gd
```

**判据**：如果一个功能的东西散落在多个顶层目录、来回跳 3 次才能找全，就该按功能打包。
本项目的 `obstacle/`、`ui/` 就是这么长出来的。

> 不要一开始就建 `core/`、`managers/`、`interfaces/` 十层目录——那是在给还不存在的复杂度付租金。
> 起盘阶段 `assets/ scenes/ scripts/ DEV/` 四个目录就够，长到需要时再拆。

---

## 3. 各目录放什么、不放什么

### 3.1 `GAME/assets/` — 运行时素材

| 放什么 | 不放什么 |
|---|---|
| 导出好的 `.png` / `.wav` / `.ogg` / `.ttf` | 可编辑母版（`.aseprite` / `.resprite` / `.psd`）→ 放 `SOURCE/` |
| 按用途分类：`sprite/{bg,entity,item,tile,error}`、`audio/{bgm,sfx}` | 不按"来源工具"分类 |
| 与 `SOURCE/` 保持**用途同名**，方便一眼对应 | 工程配置、文档、一次性脚本 |

### 3.2 `GAME/scenes/` 与 `GAME/scripts/` — 正式资产

| 放什么 | 不放什么 |
|---|---|
| 正式场景 `.tscn`、正式 GDScript | 原型/试验代码 → 放 `GAME/DEV/` |
| 按功能分组（`obstacle/`、`ui/`、`world/`） | 平铺几十个文件（找不到东西时就是该拆的信号） |
| 共享样式用 **Theme 资源**（`resources/ui/menu_theme.tres`） | 逐节点 `theme_override_*` 复制样式（不继承，且无法一处统一改） |

**命名约定**

| 类型 | 约定 | 示例 |
|---|---|---|
| 场景 | `PascalCase.tscn`，与根节点同名 | `Player.tscn` |
| 脚本 | `snake_case.gd` | `player_state_machine.gd` |
| 素材 | `snake_case` + 用途后缀 | `bird_idle_01.png` |
| 目录 | 全小写、单数、英文 | `assets/` `scenes/` `scripts/` |

> ⚠️ **Godot 只认 `res://`，不认"约定"**：目录规范是给人的，引擎只认场景里的路径引用。
> **移动/改名有引用的文件必须在编辑器里拖拽**（它会自动改所有引用）；只有"零外部引用"的文件才能从文件系统直接改名。
> 改名后若报 `Cannot open file '<旧路径>'`，删掉 `.godot/uid_cache.bin` 让编辑器重建即可。

### 3.3 `GAME/tools/` — 工具脚本，二分

| 目录 | 放什么 | 发布时 |
|---|---|---|
| `tools/engine/` | 改工程配置的脚本：主场景、渲染器、像素地基、输入动作 | **保留**（跨项目可复用） |
| `tools/debug/` | 玩法调试件：曲线预览、游戏内调参面板、状态可视化 | **整个删掉** |

**为什么分开**：让"发布前删调试工具"变成**删一个目录**这样的可执行动作，而不是在一堆脚本里挑。
混放的后果是发布包里混进调试代码，或删错文件。

### 3.4 `GAME/DEV/` — 开发草稿区

- **放**：原型场景、一次性试验脚本、临时手感调试。
- **不放**：正式玩法代码与正式场景。
- **晋升规则**：草稿验证成功 → 在编辑器里移进 `scenes/` / `scripts/` 并纳入正式引用；验证失败 → 直接删。
- 可选：放一个空的 `.gdignore`，Godot 就不再扫描它（代价：里面的场景无法在编辑器里运行）。

### 3.5 `GAME/resources/` — 数据资产（Resource）

- **放**：自定义 `Resource` 的 `.tres` 实例（曲线参数、主题、配置），可在检查器里可视化调参。
- **不放**：代码逻辑、场景。

### 3.6 `SOURCE/` — 美术/音频源文件

- 按**工具名**分组（`Resprite/`），因为一个工具一个工程目录，便于整体备份/迁移。
- 必须在 `SOURCE/README.md` 维护**源文件 ↔ 运行时路径 ↔ 尺寸**对应表——因为 `SOURCE/` 按工具分层、`assets/` 按用途分层，两者不同构，不靠表对不上。

### 3.7 `docs/` — 文档

| 文件 | 职责 | 更新时机 |
|---|---|---|
| `GDD.md` | 设计宪法：玩法、架构、待决策清单 | 设计变更 / 决策拍板 |
| `ROADMAP.md` | 里程碑、任务、完成标准、决策记录、Bug 表 | 任务完成 / 新增 / 优先级变动 |
| `devlog/YYYY-MM-DD.md` | 当天做了什么、踩了什么坑 | 每天收尾 |
| `PROJECT_TREE_TEMPLATE.md` | 本结构规范的完整版 | 结构变更 |
| `tech-art-log.md` | 技美实验：想验证什么 → 怎么做 → 学到什么 → 可否复用 | 每次实验 |

### 3.8 `EXPORTS/` — 导出产物（**不入库**）

Web 与 Android 的构建产物。体积大、可重新生成，已被 `.gitignore` 忽略。

---

## 4. 版本控制约定（重要）

| 文件 | 是否入库 | 原因 |
|---|---|---|
| `export_presets.cfg` | ✅ **提交** | 记录 Web/Android 导出配置，换机后能一键复现导出 |
| `*.uid` | ✅ **提交** | Godot 4.4+ 的稳定资源标识；不提交则引擎按路径重建，改路径易引用错乱 |
| `*.import` | ✅ **提交** | 导入配置（过滤/压缩参数） |
| `SOURCE/**` 母版 | ✅ **提交** | 唯一可编辑来源，丢了无法复原 |
| `.godot/` | ❌ 忽略 | 引擎缓存，可重建 |
| `EXPORTS/` `build/` `dist/` | ❌ 忽略 | 可重新生成的构建产物 |
| `*.keystore` `*.jks` | ❌ 忽略 | **签名密钥绝不入库** |

---

## 5. 常用命令

```bash
# 运行工程（无头自检）
godot --headless --path GAME --quit

# 导出 Web（itch.io 需单线程包：variant/thread_support=false）
mkdir -p EXPORTS/web/<版本>
godot --headless --path GAME --export-release "Web"

# 导出 Android（需先配好 JDK17 + Android SDK；调试包走 debug keystore）
mkdir -p EXPORTS/android
godot --headless --path GAME --export-debug "Android"

# 工程设置工具（都在 GAME/tools/engine/，走 ProjectSettings API 落盘）
godot --headless --path GAME --script res://tools/engine/set_pixel_perfect.gd
godot --headless --path GAME --script res://tools/engine/set_main_scene.gd -- res://scenes/main.tscn
godot --headless --path GAME --script res://tools/engine/setup_input_map.gd
```

---

## 6. 如何复用到别的项目

### 方式 A：用模板仓（推荐，一条命令）

结构已被抽出成独立模板仓 **[MyrChRya2/godot-game-template](https://github.com/MyrChRya2/godot-game-template)**：

```bash
git clone git@github.com:MyrChRya2/godot-game-template.git ~/templates/godot-game-template
cd ~/templates/godot-game-template
./new-game.sh my-new-game --dir ~/projects     # 生成骨架 + git init + 首次提交
```

生成后：Godot → Project Manager → Import → 选 `my-new-game/GAME/project.godot`。

### 方式 B：手工复刻清单

照着 §1 的树建目录即可，最小集：

```
# 必需
docs/{GDD.md, ROADMAP.md, devlog/TEMPLATE.md, PROJECT_TREE_TEMPLATE.md}
GAME/{assets,scenes,scripts,tools/{engine,debug},DEV}
SOURCE/
.gitignore  README.md  LICENSE  PROJECT_INDEX.md

# 按需（有了再加）
GAME/resources/            # 出现第一个 .tres 数据资产时
GAME/scenes/<feature>/     # 功能文件 ≥3 或已被正式场景引用时
```

---

## 7. 给 AI / 自动化工具的复刻说明

> 这一节是**可验收的结构合约**：按此实现，结果应与本仓库结构一致。

**必须（MUST）**

1. 仓库根 = 项目根；Godot 工程位于 `GAME/`，其 `project.godot` 在其中。
2. 顶层必须存在：`docs/`、`GAME/`、`SOURCE/`；`GAME/` 内必须存在 `assets/`、`scenes/`、`scripts/`、`tools/`、`DEV/`。
3. `tools/` 必须二分：`engine/`（工程设置脚本）与 `debug/`（玩法调试件）。
4. `.gitignore` 必须忽略：`.godot/`、`EXPORTS/`、`build/`、`dist/`、`*.keystore`、`*.jks`。
5. `.gitignore` **不得**忽略 `export_presets.cfg`、`*.uid`、`*.import`、`SOURCE/**`。
6. `SOURCE/` 下必须有 `README.md`，写明「源文件 ↔ 运行时路径 ↔ 尺寸」对应表。
7. 运行时素材放 `GAME/assets/`，可编辑母版放 `SOURCE/`，两者**不得混放**。

**应当（SHOULD）**

8. 文档按职责拆分（GDD / ROADMAP / devlog / 结构规范），不写重复内容。
9. 功能文件达到 3 个或已被正式场景引用时，建立 `scripts/<feature>/` + `scenes/<feature>/` 同名目录。
10. 共享 UI 样式用 Theme 资源，不逐节点 `theme_override_*`。
11. 主场景在 `project.godot` 的 `run/main_scene` 中设置（无主场景时按 F5 必然报错）。

**验收自检**

```bash
# 目录齐不齐
for d in docs GAME GAME/assets GAME/scenes GAME/scripts GAME/tools GAME/tools/engine GAME/tools/debug GAME/DEV SOURCE; do
  [ -d "$d" ] || echo "缺失: $d"
done
# 忽略规则对不对
git check-ignore -q GAME/.godot && echo "ok: .godot 被忽略"
git check-ignore -q GAME/export_presets.cfg || echo "ok: export_presets.cfg 可提交"
# 工程能否跑
godot --headless --path GAME --quit && echo "ok: 工程可运行"
```

---

## 8. 已知待整理

| 项 | 说明 |
|---|---|
| `GAME/scenes/failed_manu.tscn` | 文件名疑为 `failed_menu` 的拼写笔误（脚本已叫 `failed_menu.gd`），改名需在编辑器内做以保引用 |
| `GAME/assets/audio/{bgm,sfx}` | 目录已规划但尚无音频素材 |
| `SOURCE/Resprite/manu.resprite` | 已入库但尚无对应导出成品 |

---

## 9. 许可

代码与文档以 **MIT** 许可发布，见 [LICENSE](LICENSE)。

`GAME/icon.svg` 来自 Godot 引擎自带的默认工程图标模板（第三方内容，MIT），**正式发布前需替换为原创图标**。

<br>

---

# English

[中文](#dummybird) · **English**

A small **2D pixel-art one-button jump game** (landscape, no story), targeting the web (itch.io) and Android (TapTap).

> **The main purpose of this project is learning technical art.** The game is a vehicle; the real output is
> skill in shaders, VFX, rendering and animation. When there's a trade-off, prefer the option you can
> **learn something from** over the one that's merely convenient.

This repository also serves as a **reference implementation of a game-project folder structure**.
Below is what belongs in each layer and why it's grouped that way.
To apply it to your own project, see [§6 Reusing the structure](#6-reusing-the-structure).

---

## 1. Directory overview

```
dummy-bird/                      # ← Git repo root = project root (not the Godot project root)
├── README.md                    # this file: structure & conventions
├── PROJECT_INDEX.md             # project index (space map + workflow rules)
├── LICENSE                      # MIT
├── .gitignore                   # root-level ignore rules
│
├── docs/                        # documentation hub (kept out of the game code)
│   ├── GDD.md                   #   design doc: "what the game is"
│   ├── ROADMAP.md               #   roadmap: "what to do next"
│   ├── PROJECT_TREE_TEMPLATE.md #   full version of this spec (reusable; written in Chinese)
│   ├── tech-art-log.md          #   technical-art experiment log (by technique, not by date)
│   └── devlog/                  #   development log: "what happened that day"
│       ├── TEMPLATE.md
│       └── YYYY-MM-DD.md
│
├── GAME/                        # ← Godot project (engine dir; res:// points here)
│   ├── project.godot            #   project config (renderer / stretch / version / main scene)
│   ├── export_presets.cfg       #   export presets (Web / Android)
│   ├── icon.svg
│   ├── assets/                  #   runtime assets (shipped inside the build)
│   │   ├── sprite/{bg,entity,item,tile,error}/
│   │   └── audio/{bgm,sfx}/
│   ├── scenes/                  #   production scenes (.tscn)
│   │   ├── main.tscn            #     main scene: UILayer + all screens
│   │   ├── playground.tscn      #     the game world
│   │   ├── Player.tscn
│   │   ├── failed_manu.tscn
│   │   ├── obstacle/            #     feature-grouped scenes
│   │   └── ui/                  #     UI scenes (menu / pause / HUD / settings)
│   ├── scripts/                 #   GDScript
│   │   ├── 00_game_state.gd     #     global state machine (Autoload)
│   │   ├── main.gd              #     main-scene assembly
│   │   ├── Player.gd / jump.gd / 00_movement.gd
│   │   ├── obstacle/            #     feature-grouped scripts
│   │   ├── ui/                  #     per-screen scripts
│   │   └── world/               #     world rules (e.g. kill_zone)
│   ├── resources/               #   custom Resource data (.tres)
│   │   ├── ObstacleCurve.tres
│   │   └── ui/menu_theme.tres   #     UI theme (shared styles)
│   ├── tools/                   #   tool scripts (see §3.3)
│   │   ├── engine/              #     project-setting tools (reusable across projects)
│   │   └── debug/               #     gameplay debug tools (delete the whole dir before release)
│   └── DEV/                     #   draft area (prototypes/experiments, no quality promise)
│       └── test_scenes/
│
├── SOURCE/                      # ← source masters for art/audio (never shipped, always committed)
│   ├── README.md                #   source ↔ runtime asset mapping table
│   └── Resprite/                #   grouped by tool (Resprite projects)
│
└── EXPORTS/                     # ← build outputs (gitignored)
    ├── web/<version>/
    └── android/<version>.apk
```

> Notes: `.uid` (stable resource IDs), `.import` (import settings) and `.godot/` (engine cache) are omitted
> from the tree. `.uid` and `.import` **must be committed**; `.godot/` **must be ignored**.

---

## 2. Grouping rationale: four principles

### 2.1 Repo root = project root, not the Godot project root

`GAME/` is just one directory inside the repo; `docs/`, `SOURCE/` and `EXPORTS/` sit next to it.

| Approach | Pros | Costs |
|---|---|---|
| **Repo root = project root (this one)** | Docs, art sources, export config and builds all live in one repo; a single `.git`; swapping engines or adding tooling needs no relocation | Godot's `res://` stops at `GAME/`, so the engine can't see `docs/` — **which is the point**: docs must not end up in the game build |
| Repo root = `GAME/` | Works immediately, shorter paths | Docs/sources/build scripts must go inside the project, where `res://` scans them, they leak into exports, and they pollute project-wide search |

### 2.2 Docs separate from code (`docs/` vs `GAME/`)

Docs don't go into `GAME/` because Godot scans everything under `res://`; `docs/` lives at the repo root,
where the editor is completely unaware of it.
The four documents have non-overlapping jobs: **GDD answers "what is it", ROADMAP answers "what's next",
devlog answers "what happened that day", PROJECT_INDEX answers "where is everything"**.

### 2.3 Runtime assets (`assets/`) separate from source masters (`SOURCE/`)

- `GAME/assets/` holds **exported end products** (`.png` / `.wav`), which get packed into the build.
- `SOURCE/` holds **editable masters** (`.resprite` / `.aseprite` / `.psd` / `.blend`) — **never shipped, always committed**.

> **Why masters must be committed**: it was verified that exported PNGs contain **no embedded project data**
> (the `tEXt`/`iTXt`/`zTXt` chunks are all empty). So the `.resprite` file is the *only* editable source —
> lose it and you can't edit the art anymore, only redraw it.
> Conversely, keeping masters under `assets/` means `res://` scans them, they ship in the build, and the package bloats.

### 2.4 Feature grouping: one feature = one pair of same-named directories

When a feature's files are scattered across `scripts/` and `scenes/` and number ≥ 3,
**or the feature is already referenced by a production scene**, give it a pair of same-named directories:

```
scripts/obstacle/          scenes/obstacle/
├── spawner.gd             ├── obstacle.tscn
├── curve.gd               └── half.tscn
└── obstacle.gd
```

**Rule of thumb**: if gathering one feature's files means hopping across three top-level directories,
it's time to package it by feature. That's exactly how `obstacle/` and `ui/` grew in this project.

> Don't pre-create ten levels of `core/`, `managers/`, `interfaces/` on day one — that's paying rent on
> complexity that doesn't exist yet. At bootstrap time, `assets/ scenes/ scripts/ DEV/` is enough;
> split when it actually grows.

---

## 3. What goes where

### 3.1 `GAME/assets/` — runtime assets

| Put here | Do NOT put here |
|---|---|
| Exported `.png` / `.wav` / `.ogg` / `.ttf` | Editable masters (`.aseprite` / `.resprite` / `.psd`) → `SOURCE/` |
| Classified by purpose: `sprite/{bg,entity,item,tile,error}`, `audio/{bgm,sfx}` | Don't classify by "which tool made it" |
| Keep names matching `SOURCE/` **purposes** so they map at a glance | Project config, docs, one-off scripts |

### 3.2 `GAME/scenes/` and `GAME/scripts/` — production assets

| Put here | Do NOT put here |
|---|---|
| Production `.tscn` scenes, production GDScript | Prototypes/experiments → `GAME/DEV/` |
| Feature-grouped subdirectories (`obstacle/`, `ui/`, `world/`) | Dozens of flat files (if you can't find things, that's the signal to split) |
| Shared styling via a **Theme resource** (`resources/ui/menu_theme.tres`) | Per-node `theme_override_*` copies (they don't inherit and can't be changed in one place) |

**Naming conventions**

| Kind | Convention | Example |
|---|---|---|
| Scenes | `PascalCase.tscn`, same name as root node | `Player.tscn` |
| Scripts | `snake_case.gd` | `player_state_machine.gd` |
| Assets | `snake_case` + purpose suffix | `bird_idle_01.png` |
| Directories | all lowercase, singular, English | `assets/` `scenes/` `scripts/` |

> ⚠️ **Godot only understands `res://`, not conventions**: folder rules are for humans; the engine only
> follows path references inside scenes. **Files that are referenced must be moved/renamed by dragging in the
> editor** (it rewrites all references for you); only files with zero external references can be renamed from
> the filesystem. If you get `Cannot open file '<old path>'` afterwards, delete `.godot/uid_cache.bin` and let
> the editor rebuild it.

### 3.3 `GAME/tools/` — tool scripts, split in two

| Directory | What goes here | At release |
|---|---|---|
| `tools/engine/` | Scripts that change project settings: main scene, renderer, pixel-perfect setup, input actions | **Keep** (reusable across projects) |
| `tools/debug/` | Gameplay debug tools: curve preview, in-game tuning panel, state visualization | **Delete the entire directory** |

**Why split**: it turns "remove debug tooling before release" into an executable action — *delete one directory* —
instead of picking through a pile of scripts. Mixing them risks shipping debug code or deleting the wrong file.

### 3.4 `GAME/DEV/` — draft area

- **Put here**: prototype scenes, one-off experiment scripts, temporary feel tuning.
- **Don't put here**: production gameplay code or production scenes.
- **Promotion rule**: a successful draft gets moved into `scenes/` / `scripts/` *in the editor* and becomes
  properly referenced; a failed one is simply deleted.
- Optional: drop an empty `.gdignore` in it and Godot stops scanning it (cost: scenes inside can't run from the editor).

### 3.5 `GAME/resources/` — data assets (Resource)

- **Put here**: `.tres` instances of custom `Resource`s (curve parameters, themes, configs) — tunable in the Inspector.
- **Don't put here**: code logic, scenes.

### 3.6 `SOURCE/` — art/audio sources

- Grouped by **tool** (`Resprite/`), since one tool = one project directory, which makes whole-directory
  backup/migration easy.
- `SOURCE/README.md` must maintain a **source ↔ runtime path ↔ dimensions** table — because `SOURCE/` is layered
  by tool while `assets/` is layered by purpose; the two structures differ, so without the table you can't map them.

### 3.7 `docs/` — documentation

| File | Responsibility | When to update |
|---|---|---|
| `GDD.md` | Design constitution: gameplay, architecture, open decisions | Design changes / decisions made |
| `ROADMAP.md` | Milestones, tasks, acceptance criteria, decision log, bug list | Task done / added / reprioritized |
| `devlog/YYYY-MM-DD.md` | What was done today, what pitfalls were hit | End of each day |
| `PROJECT_TREE_TEMPLATE.md` | Full version of this structure spec | Structure changes |
| `tech-art-log.md` | Tech-art experiments: what to verify → how → what was learned → reusable? | Every experiment |

### 3.8 `EXPORTS/` — build outputs (**not committed**)

Web and Android build artifacts. Large and reproducible, therefore gitignored.

---

## 4. Version-control conventions (important)

| File | Committed? | Why |
|---|---|---|
| `export_presets.cfg` | ✅ **commit** | Records Web/Android export settings; lets you reproduce exports after switching machines |
| `*.uid` | ✅ **commit** | Stable resource IDs since Godot 4.4; without them the engine rebuilds IDs from paths and references break on renames |
| `*.import` | ✅ **commit** | Import settings (filtering/compression) |
| `SOURCE/**` masters | ✅ **commit** | The only editable source; unrecoverable if lost |
| `.godot/` | ❌ ignore | Engine cache, rebuildable |
| `EXPORTS/` `build/` `dist/` | ❌ ignore | Reproducible build outputs |
| `*.keystore` `*.jks` | ❌ ignore | **Signing keys must never be committed** |

---

## 5. Common commands

```bash
# Run the project (headless self-check)
godot --headless --path GAME --quit

# Export Web (itch.io needs a single-threaded build: variant/thread_support=false)
mkdir -p EXPORTS/web/<version>
godot --headless --path GAME --export-release "Web"

# Export Android (requires JDK 17 + Android SDK; debug builds use the debug keystore)
mkdir -p EXPORTS/android
godot --headless --path GAME --export-debug "Android"

# Project-setting tools (all in GAME/tools/engine/, persisted via the ProjectSettings API)
godot --headless --path GAME --script res://tools/engine/set_pixel_perfect.gd
godot --headless --path GAME --script res://tools/engine/set_main_scene.gd -- res://scenes/main.tscn
godot --headless --path GAME --script res://tools/engine/setup_input_map.gd
```

---

## 6. Reusing the structure

### Option A: use the template repo (recommended, one command)

The structure has been extracted into a standalone template repo,
**[MyrChRya2/godot-game-template](https://github.com/MyrChRya2/godot-game-template)**:

```bash
git clone git@github.com:MyrChRya2/godot-game-template.git ~/templates/godot-game-template
cd ~/templates/godot-game-template
./new-game.sh my-new-game --dir ~/projects     # scaffold + git init + initial commit
```

Then: Godot → Project Manager → Import → pick `my-new-game/GAME/project.godot`.

### Option B: replicate manually

Create directories following the tree in §1. Minimum set:

```
# Required
docs/{GDD.md, ROADMAP.md, devlog/TEMPLATE.md, PROJECT_TREE_TEMPLATE.md}
GAME/{assets,scenes,scripts,tools/{engine,debug},DEV}
SOURCE/
.gitignore  README.md  LICENSE  PROJECT_INDEX.md

# Add when needed
GAME/resources/            # when the first .tres data asset appears
GAME/scenes/<feature>/     # when a feature has ≥3 files or is referenced by a production scene
```

---

## 7. Replication contract for AI / automation

> This section is a **verifiable structural contract**: implement it as written and the result should match
> this repository's structure.

**MUST**

1. Repo root = project root; the Godot project lives in `GAME/` and contains `project.godot`.
2. Top level must contain `docs/`, `GAME/`, `SOURCE/`; `GAME/` must contain `assets/`, `scenes/`, `scripts/`,
   `tools/`, `DEV/`.
3. `tools/` must be split into `engine/` (project-setting scripts) and `debug/` (gameplay debug tools).
4. `.gitignore` must ignore: `.godot/`, `EXPORTS/`, `build/`, `dist/`, `*.keystore`, `*.jks`.
5. `.gitignore` must **not** ignore `export_presets.cfg`, `*.uid`, `*.import`, or `SOURCE/**`.
6. `SOURCE/` must contain a `README.md` with a "source ↔ runtime path ↔ dimensions" mapping table.
7. Runtime assets go in `GAME/assets/`; editable masters go in `SOURCE/`; the two must **never be mixed**.

**SHOULD**

8. Split documentation by responsibility (GDD / ROADMAP / devlog / structure spec) with no duplicated content.
9. When a feature reaches 3 files or is referenced by a production scene, create same-named
   `scripts/<feature>/` + `scenes/<feature>/` directories.
10. Share UI styling through a Theme resource rather than per-node `theme_override_*`.
11. Set the main scene in `project.godot`'s `run/main_scene` (without it, F5 always errors).

**Acceptance self-check**

```bash
# Are all directories present?
for d in docs GAME GAME/assets GAME/scenes GAME/scripts GAME/tools GAME/tools/engine GAME/tools/debug GAME/DEV SOURCE; do
  [ -d "$d" ] || echo "missing: $d"
done
# Are the ignore rules right?
git check-ignore -q GAME/.godot && echo "ok: .godot ignored"
git check-ignore -q GAME/export_presets.cfg || echo "ok: export_presets.cfg committable"
# Does the project run?
godot --headless --path GAME --quit && echo "ok: project runs"
```

---

## 8. Known cleanup items

| Item | Note |
|---|---|
| `GAME/scenes/failed_manu.tscn` | Filename is likely a typo for `failed_menu` (the script is already `failed_menu.gd`); rename must be done inside the editor to preserve references |
| `GAME/assets/audio/{bgm,sfx}` | Planned but still no audio assets |
| `SOURCE/Resprite/manu.resprite` | Committed, but has no exported counterpart yet |

---

## 9. License

Code and docs are released under the **MIT** license, see [LICENSE](LICENSE).

`GAME/icon.svg` comes from Godot's built-in default project icon template (third-party content, MIT) and
**must be replaced with original art before release**.
