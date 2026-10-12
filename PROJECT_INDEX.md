# 📁 DummyBird 项目管理文件索引

> 整理日期：2026-10-12 | 适用仓库版本：`main @ 1aa1efa`
> 本文件列出项目中与项目管理相关的全部文件及其作用，方便快速定位。
> **本文件也是 project-management skill 的项目配置入口**：路径约定、工作流规则都从这里读取。

## 〇、项目基本信息

| 项 | 值 |
|---|---|
| 项目名 | DummyBird（占位名，未定稿） |
| 仓库根 | `/mnt/d/Fox_n/!PROJECTS/#software/Projects/games/dummy-bird` |
| 远端仓库 | **公开** · `git@github.com:MyrChRya2/dummy-bird.git`（MIT） |
| 引擎 | Godot **4.7.1** stable（`D:\Fox_n\!PROJECTS\#software\Engines\Godot_v4.7.1-stable_win64.exe`） |
| 目标平台 | **网页 itch.io + 移动 TapTap**（双端；桌面用于开发验证） |
| 渲染器 | `Compatibility`（`gl_compatibility`）——2D 像素游戏的选择，见「待决策 #1」（已定，2026-10-11） |
| 当前里程碑 | **M1.5 整套框架（基本完成）→ M1 核心玩法原型收尾** |

## 一、核心管理文档（`docs/`，已纳入 Git 版本控制）

| 路径 | 作用 |
|------|------|
| `docs/GDD.md` | **设计文档** — 项目的"宪法"：概述、核心设计、技术架构、待决策清单。 |
| `docs/ROADMAP.md` | **路线图** — 里程碑总览、任务清单与完成标准、优先级排序、决策记录、Bug 跟踪表。 |
| `docs/devlog/` | **开发日志目录** — 命名 `YYYY-MM-DD.md`（同日多篇加 `-b`/`-c` 后缀）。 |
| `docs/devlog/TEMPLATE.md` | **日志模板** — 每日收尾生成日志的骨架与提问清单。 |
| `docs/PROJECT_TREE_TEMPLATE.md` | **游戏文件树基础模板** — 目录分层约定、每层放什么、什么时候该拆；跨项目复用，持续迭代。 |
| `docs/tech-art-log.md` | **技术美术实验日志** — 项目目的的落点（`GDD.md` §0）：按技法主题沉淀"想验证什么→怎么做→学到什么→可否复用"，**非按日期**。含待研究清单 T1–T10。 |

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
| `GAME/tools/engine/` | **工程设置工具**（跨项目可复用，已同步进模板仓 `godot-game-template`）。全部走引擎 API 写回 `project.godot`，不手改文本 |
| `GAME/tools/engine/set_main_scene.gd` | 设置主场景（等同 Project Settings → Application → Run → Main Scene） |
| `GAME/tools/engine/set_renderer.gd` | 切换渲染器（gl / forward / mobile） |
| `GAME/tools/engine/set_pixel_perfect.gd` | **像素完美渲染地基**：Nearest 过滤 + 视口尺寸 + 拉伸方式 + 横屏，一条命令重置 |
| `GAME/tools/engine/setup_input_map.gd` | 注入 `flap` 输入动作（鼠标左键 / 屏幕轻触；**2026-10-12 起不绑空格**——用户「这个游戏不需要点空格」） |
| `GAME/tools/debug/` | **玩法调试件**（本作专属，**发布前应整体删除**） |
| `GAME/tools/debug/curve_preview.gd` | 曲线可视化——画出 `ObstacleCurve` 的通道高度点带，并标注 `center_y` 中线与 `center_y ± half_range` 包络线 |
| `GAME/tools/debug/curve_tuner.gd` | 游戏内实时调参面板——滑杆读写 `ObstacleCurve` 导出属性 + spawner 的 `spacing`/`speed`；**F1 显隐、F2 打印当前参数**；带"相邻落差"统计。只读写参数、不改游戏逻辑 |
| `GAME/resources/` | 数据资产：`ObstacleCurve.tres`（障碍通道曲线参数实例）+ `ui/menu_theme.tres`（**Theme 资源**——`Button/font_sizes/font_size = 5`，多个控件共享样式靠它，不用逐节点 `theme_override_*`） |
| `GAME/.editorconfig` `.gitattributes` `.gitignore` | 引擎目录内的编辑器/Git 局部约定 |
| `GAME/assets/` | 运行时素材。现有 `sprite/entity/player.png`、`sprite/tile/tiles.png`、`sprite/error/Error.png`；目录约定 `sprite/{bg,entity,item,tile,error}`、`audio/{bgm,sfx}`、`font/`、`ui/` |
| `GAME/scenes/main.tscn` | **当前主场景**（框架入口）：`Main`(Node2D) → `UILayer`(CanvasLayer) 下并列挂 `StartMenu`/`PauseMenu`/`HUD`/`FailedManu`/`SettingsPanel`；脚本 `scripts/main.gd` |
| `GAME/scenes/` 其余 | 正式场景：`Player.tscn`（角色）、`playground.tscn`（游戏世界：Player + ObstacleSpawner + KillZone + 调试节点）、`obstacle/obstacle.tscn`（障碍复合体）、`obstacle/half.tscn`（纯几何 half）、`failed_manu.tscn`（失败界面——**文件名疑为 `menu` 的笔误**） |
| `GAME/scenes/ui/` | UI 界面场景：`start_menu.tscn` / `pause_menu.tscn` / `hud.tscn` / `settings_panel.tscn` |
| `GAME/scripts/00_game_state.gd` | **状态机 Autoload `GameState`**（已在 project.godot 注册）：`enum State { BOOT, MENU, PLAYING, PAUSED, GAME_OVER, SETTINGS }`、`state_changed` 信号、`FailReason`+`failed` 信号、`toggle_pause()`（记住暂停前状态）、`open/close_settings()`、`restart_requested` 信号、`obstacle_speed` 只读缓存 |
| `GAME/scripts/` 其余 | `main.gd`（主场景装配与状态驱动）、`Player.gd`、`jump.gd`、`00_movement.gd`；`state.svg` 是作者自定义**节点图标**（`@icon(...)` 引用，**勿移动**）。`ui/` = 各界面脚本 + `failed_menu.gd`；`world/` = `kill_zone.gd`（掉出世界检测，只报告失败不碰 UI/paused）；`obstacle/` = spawner/curve/obstacle |
| `GAME/scripts/obstacle/` | **障碍物系统**（按功能分组，便于日后扩展多种障碍）：`spawner.gd`（生成）、`curve.gd`（`class_name ObstacleCurve`，双正弦+噪声通道曲线）、`obstacle.gd`（左移+出界回收） |
| `GAME/DEV/test_scenes/` | **开发草稿区**——仅剩 `test_scene.tscn`（试玩沙盒：Spawner + 曲线预览）。正式资产已按功能归位（见 `scripts/obstacle/`、`scenes/obstacle/`），DEV 回到"干净的草稿区" |

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
│   ├── tech-art-log.md            # 技美实验日志（项目目的的落点）
│   └── devlog/                    # 开发日志
│       ├── TEMPLATE.md
│       └── YYYY-MM-DD.md
├── GAME/                          # Godot 工程（引擎目录）
│   ├── project.godot              # 渲染器 = gl_compatibility
│   ├── assets/{sprite,audio}/     # 运行时素材
│   ├── scenes/                    # 正式场景（主场景 = main.tscn；scenes/ui/ = 五个界面）
│   ├── scripts/                   # GDScript（main.gd / 00_game_state.gd + ui/ world/ obstacle/）
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

- 2026-10-12（14）：**补齐 ROADMAP 状态 + 清掉复发的僵尸场景**——ROADMAP：M1.5 标"基本完成"（2.5.1–2.5.7 落地、2.5.8 待真机）、2.5.6 说明 Esc 走内置 `ui_cancel`、2.5.4 的"退出"平台显隐标为已实测、M1 的 1.4/1.5 标部分完成（掉出→失败已通、**撞障碍与分数未做**）、补 6 条 2026-10-12 决策、启用 Bug 跟踪表（2 条已修复）、§6 补导出环境依赖；本索引：更正渲染器/目标平台/当前里程碑、`Eroor.png`→`Error.png`、目录速览主场景、`setup_input_map` 注明不再绑空格；`DEV/test_scenes/` 下复发的 3 个僵尸场景已清（零引用），新增 `docs/devlog/2026-10-12.md`。
- 2026-10-12（13）：**整套 UI/场景框架落地**——主场景切到 `scenes/main.tscn`（Main → UILayer + 五个界面）；`GameState` 状态机 Autoload 注册；新增 `scenes/ui/`（start_menu/pause_menu/hud/settings_panel）、`failed_manu.tscn`、`resources/ui/menu_theme.tres`（共享 Theme）、`scripts/world/kill_zone.gd`；playground 改接 KillZone。
- 2026-10-11（12）：**项目目的明确为「学习技术美术」** → GDD 新增 §0（含取舍原则与推进顺序）、§5.4 框架架构、§5.5 UI 清单；ROADMAP 新增 **M1.5 整套框架**与 **M4 技术美术研究**里程碑；新建 `docs/tech-art-log.md`。
- 2026-10-11（11）：曲线参数定稿（游戏内调优）——`ObstacleCurve.tres`（half_range 65 / freq2 0.24 / noise_amp 0.46 / noise_step 0.72 / seed 46190）、spawner（speed 129、spacing 138）；新增 `tools/curve_tuner.gd` 游戏内调参面板；`curve_preview.gd` 增画中线与包络线；`playground.tscn` 直接指定 `.tres`。
- 2026-10-11（10）：同步障碍物生成系统——新增 `GAME/resources/`（自定义 Resource 数据资产 `ObstacleCurve.tres`）、`tools/debug/curve_preview.gd`（曲线可视化）、`DEV/test_scenes/` 障碍原型；`playground.tscn` 接入 Spawner；`project.godot` 新增空动作 `click`（待绑定）。
- 2026-10-11（9）：处理 4 项整理项——state.svg 保持原地（确认是自定义节点图标）、Eroor→Error 改名、SOURCE 保留组织并补 README、test_scence→test_scene；索引同步。
- 2026-10-11（8）：同步开发进展——`scenes/`（Player/playground）、`scripts/`（Player/jump/00_movement）、`assets/sprite/{entity,tile,error}`、`DEV/test_scenes/`、`SOURCE/Resprite/`（美术源文件母版）；并登记 4 项待整理。
- 2026-10-11（7）：新增 `GAME/tools/{set_pixel_perfect,setup_input_map}.gd`；定义 `flap` 输入动作（鼠标左键/空格/屏幕轻触）；修正 `.gitignore` 误忽略 `export_presets.cfg`，纳入 `*.uid`，补签名密钥忽略；模板仓同步修正。
- 2026-10-11（6）：推送为 GitHub 公开仓 `MyrChRya2/dummy-bird`（MIT）；M0 基建里程碑完成。
- 2026-10-11（5）：确定开源许可 **MIT**；新增根目录 `LICENSE`；登记 `GAME/icon.svg` 为 Godot 官方默认图标（第三方内容）。
- 2026-10-11（4）：删除本仓 `templates/` 副本（用户拍板）——模板只保留独立仓 `../godot-game-template/`，消除双副本漂移；本仓起盘入口改为指向独立仓。
- 2026-10-11（3）：渲染器切 `Compatibility`；`SORCE/`→`SOURCE/`；模板抽出独立仓 `../godot-game-template/`；新增 `GAME/tools/engine/set_renderer.gd`；文件树模板升 v0.2（T1–T5 全部已决）。
- 2026-10-11（2）：补设主场景 `scenes/playground.tscn`；新增 `GAME/tools/engine/set_main_scene.gd`；模板加入默认主场景 `Main.tscn`。
- 2026-10-11：创建本文件（索引首版）；建立仓库与 Godot 工程目录规范。

## 七之二、已处理的整理项（2026-10-11 用户逐项拍板）

| # | 事项 | 用户决定 | 落实 |
|---|---|---|---|
| 1 | `GAME/scripts/state.svg` 的归属 | 「是我自定义的**节点图标**，先不用动」 | **保持原地**。它是 `00_movement.gd` 第 1 行 `@icon("res://scripts/state.svg")` 用的**自定义节点图标**，位置与用途一致，非误放。⚠️ 它是被 `res://` 引用的，**别随意移动**，否则要同步改 `@icon` 路径 |
| 2 | `sprite/error/Eroor.png` 拼写 | 「**改名**」 | 已改为 `Error`（PNG + `.import` + `SOURCE/` 侧 `Error.resprite`/`Error.png` 一并改，保持源↔成品同名对应）；Godot 重新导入成功，全工程 0 处残留 |
| 3 | `SOURCE/` 与 `assets/` 不同构 | 「**保留原样**」 | 保持"按工具/项目名分层"。已补 `SOURCE/README.md`，写明**每个源文件导出到哪个运行时路径** + 尺寸，代替"两边同名"的隐含约定 |
| 4 | `DEV/test_scenes/test_scence.tscn` 拼写 | 「**修成拼写**」 | 已改为 `test_scene.tscn`，根节点名 `TestScence` → `TestScene`；该场景**零外部引用**，改动安全 |

> 执行方式说明：本次改动经**引用检查**确认无风险后才动手（`Eroor` 只被自身 `.import` 引用；`test_scence` 零外部引用）。按 Godot 的规矩，**移动有引用的文件应在编辑器里拖拽**；本次是"零引用的改名"，且已用 `--headless --editor` 重新扫描验证通过。

## 七之三、已处理：文件树重构（2026-10-11 用户确认方案）

用户确认三点：①障碍物按**功能分组**（"以后可能会增加不同种类与属性的 obstacle"）；②`tools/` 按 `engine` / `debug` 二分（"**发布游戏时肯定会删掉调试工具**"）；③旧版 `test_scene.tscn` 可删。

| 原位置 | 新位置 | 说明 |
|---|---|---|
| `DEV/test_scenes/obstacle_spawner.gd` | `scripts/obstacle/spawner.gd` | 障碍生成 |
| `DEV/test_scenes/obstacle_curve.gd` | `scripts/obstacle/curve.gd` | `class_name ObstacleCurve` |
| `DEV/test_scenes/obstacle.gd` | `scripts/obstacle/obstacle.gd` | 单个障碍行为 |
| `DEV/test_scenes/obstacle.tscn` | `scenes/obstacle/obstacle.tscn` | 障碍复合体 |
| `DEV/test_scenes/obstacle_half.tscn` | `scenes/obstacle/half.tscn` | 纯几何 half |
| `tools/set_*.gd`、`setup_input_map.gd` | `tools/engine/` | 工程设置工具（跨项目复用，已同步模板仓） |
| `tools/curve_*.gd` | `tools/debug/` | 玩法调试件（**发布前整体删除**） |
| `DEV/test_scenes/test_scence.tscn` | `DEV/test_scenes/test_scene.tscn` | 修拼写，作为试玩沙盒保留 |
| `DEV/test_scenes/test_scene.tscn`（旧版） | — | **已删除**（内容被新版取代） |

> 本表记录的是**历史变更**：`DEV/test_scenes/` 下的障碍脚本与场景**已全部移出**，不要再按旧路径找文件。

## 八、许可与第三方内容

| 项 | 说明 |
|---|---|
| 本项目代码与文档 | **MIT License**（见根目录 `LICENSE`），Copyright (c) 2026 MyrChRya2 |
| `GAME/icon.svg` | **不是本项目原创**——来自 Godot 引擎自带的默认工程图标模板，版权归 Godot Engine 贡献者所有，按 MIT 许可使用（Godot Engine 亦为 MIT）。日后替换为原创图标时，请删除本行说明 |
| 未来新增的美术/音频 | 若要与代码采用不同许可（例如素材用 CC0 而代码保持 MIT），在本表登记并在 `SOURCE/`、`GAME/assets/` 下放置对应说明 |
| Godot 引擎本身 | MIT；**用 Godot 制作和分发游戏不产生任何开源义务**，可闭源商用 |
