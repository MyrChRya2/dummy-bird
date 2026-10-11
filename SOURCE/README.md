# SOURCE/ — 美术源文件母版

> **这些文件必须入库。** 实测确认：导出的 PNG 里**没有内嵌任何工程数据**
> （`tEXt/iTXt/zTXt` 块全空），所以 `.resprite` 是唯一的可编辑母版——
> 丢了就再也改不了原图，只能重画。

## 目录与导出对应关系

| 源文件（本目录） | 导出成品（Godot 工程内） | 尺寸 |
|---|---|---|
| `Resprite/Player.resprite` | `GAME/assets/sprite/entity/player.png` | 16×16 |
| `Resprite/Error.resprite` | `GAME/assets/sprite/error/Error.png` | 32×16 |
| `Resprite/Tiles.resprite` | `GAME/assets/sprite/tile/tiles.png` | 16×16 |

## 目录组织说明

本目录按**工具 / 项目名**分层（`Resprite/` 是你的像素画工具 Resprite 的工程），
而 `GAME/assets/sprite/` 按**用途**分层（`entity/`、`tile/`、`error/`）。

两种分层方式都成立，本目录选择前者（按工具分组，便于一个工具一个文件夹地备份/迁移）。
因此**这份对应表是必须的**——它代替了"两边目录同名"的隐含约定。

## 约定

1. 新增美术：先在 Resprite 里建工程存进本目录 → 导出 PNG 到 `GAME/assets/sprite/<用途>/` → **回来更新上面的对应表**。
2. 改名/移动源文件后，同步更新本表；`GAME/assets/` 侧的改动切记在 **Godot 编辑器里**做（引擎会自动改引用）。
3. `.resprite` 是 ZIP 容器格式，不要用文本编辑器改它。
