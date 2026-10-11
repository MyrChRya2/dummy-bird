# 📁 DummyBird 项目管理文件索引

> 整理日期：2026-10-11 | 适用仓库版本：`main @ f9fa071`
> 本文件列出项目中与项目管理相关的全部文件及其作用，方便快速定位。
> **本文件也是 project-management skill 的项目配置入口**：路径约定、工作流规则都从这里读取。

## 〇、项目基本信息

| 项 | 值 |
|---|---|
| 项目名 | DummyBird（占位名，未定稿） |
| 仓库根 | `/mnt/d/Fox_n/!PROJECTS/#software/Projects/games/dummy-bird` |
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
| `.gitignore` | 根级 Git 忽略规则（**含 `.dsh-meow/` 记忆库保护**、`.godot/` 生成物） |
| `.gitattributes` | Git 属性（换行符统一 `eol=lf`） |
| `.editorconfig` | 编辑器统一配置（UTF-8） |
| `PROJECT_INDEX.md` | 本文件 — 索引与 skill 配置入口 |

## 三、工程内配置（`GAME/`）

| 路径 | 作用 |
|------|------|
| `GAME/project.godot` | Godot 工程配置（引擎版本、渲染器、窗口拉伸、物理引擎、**主场景**） |
| `GAME/icon.svg(+.import)` | 工程图标 |
| `GAME/tools/set_main_scene.gd` | **工具脚本**——设置主场景并写回 `project.godot`（等同编辑器菜单 Project → Project Settings → Application → Run → Main Scene）；不传参默认 `res://scenes/Main.tscn`，可传参指定。用法见脚本头部注释 |
| `GAME/.editorconfig` `.gitattributes` `.gitignore` | 引擎目录内的编辑器/Git 局部约定 |
| `GAME/assets/` | 运行时素材（`sprite/{bg,entity,item,tile}`、`audio/`） |
| `GAME/scenes/` | 正式场景（`.tscn`）。当前主场景 = `scenes/playground.tscn` |
| `GAME/scripts/` | GDScript 脚本（当前为空） |
| `GAME/DEV/` | **开发草稿区**——原型场景/试验脚本，不作正式资产；稳定后再移入 `scenes/`、`scripts/` |

## 四、仓库外配合目录

| 路径 | 作用 | 是否入 Git |
|------|------|-----------|
| `SOURCE/` | **美术/音频源文件**（`.aseprite` / `.psd` / `.kra` / `.blend`）。可编辑母版放这里，导出成品进 `GAME/assets/`。 | 是（**必须入库**，源文件无版本控制=无备份） |
| `templates/` | **可复用工程骨架（本仓内的工作副本）**——`godot-2d/` 是骨架，`new-game.sh` 是生成脚本。**单一事实源已抽出为独立仓 `../godot-game-template/`**（见下），本目录保留仅供就近使用与参考。 | 是 |
| `../godot-game-template/` | **独立模板仓（在仓库之外）**——路径 `/mnt/d/Fox_n/!PROJECTS/#software/Projects/games/godot-game-template`，创建时 HEAD = `7ddbfb7`。跨项目复用的单一事实源，详见 `docs/PROJECT_TREE_TEMPLATE.md`。 | 否（独立仓） |
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
├── templates/                     # 可复用工程骨架（工作副本；独立仓见 ../godot-game-template/）
└── .dsh-meow/                     # AI 记忆库（不入库）
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

- 2026-10-11（3）：渲染器切 `Compatibility`；`SORCE/`→`SOURCE/`；模板抽出独立仓 `../godot-game-template/`；新增 `GAME/tools/set_renderer.gd`；文件树模板升 v0.2（T1–T5 全部已决）。
- 2026-10-11（2）：补设主场景 `scenes/playground.tscn`；新增 `GAME/tools/set_main_scene.gd`；模板加入默认主场景 `Main.tscn`。
- 2026-10-11：创建本文件（索引首版）；建立仓库与 Godot 工程目录规范。
