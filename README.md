# Scrapling-gdscript

目标：在 `Godot 4.6` / `GDScript` 中复刻 `Scrapling` 的可观察能力，让 Godot 社区可以在纯 GDScript 工程里完成与源项目等价的 HTML 解析、静态/动态抓取、爬虫调度、交互式工具和 AI/MCP 工作流。

## 基线

- 源项目：`E:\development\Scrapling`
- 源版本：`0.4.1`
- 源提交：`b9b5bb0c8011f3dcb844c074c2bd91ce44d77edd`
- 目标运行时：`Godot 4.6`
- 本地工程参考：`E:\development\openagentic-sdk-gdscript`

## 文档入口

- 愿景：`docs/prd/VISION.md`
- 总体 PRD：`docs/prd/PRD-0001-scrapling-parity.md`
- 源项目能力盘点：`docs/analysis/source-capability-inventory.md`
- 首轮计划索引：`docs/plan/v1-index.md`

## 当前状态

- 已完成：文档基线、源项目能力清单、PRD、v1 计划矩阵。
- 未开始：Godot 工程脚手架、测试基线、任何功能实现。
- 下一里程碑：`docs/plan/v1-godot-foundation.md`

## 目标能力面

- `Selector` / `Selectors` 风格的 HTML 解析与导航。
- `Fetcher` / `AsyncFetcher` / `DynamicFetcher` / `StealthyFetcher` 风格的抓取接口。
- `Spider` / `Request` / `CrawlerEngine` / `CrawlResult` 风格的爬虫运行时。
- 交互式 Shell、命令行工具、curl 转换、结果导出。
- AI / MCP 侧的结构化提取与服务接口。
- Windows PowerShell 友好的 `Godot 4.6` Headless 自动化测试。

## 文档纪律

- 需求编号遵循 `REQ-0001-NNN`。
- 计划文件遵循 `docs/plan/v1-*.md`。
- 施工中若发现设计偏差，新增 `docs/ecn/ECN-NNNN-*.md` 并同步更新 PRD 与计划。
