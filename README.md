# DummyBird

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
