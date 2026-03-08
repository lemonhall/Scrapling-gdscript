# Scrapling-gdscript

目标：在 `Godot 4.6` / `GDScript` 中复刻 `Scrapling` 的核心能力，让 Godot 社区可以在纯 GDScript 工程中完成与源项目等价的 HTML 解析、静态/动态抓取、爬虫调度、交互式工具和 AI / MCP 工作流。

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
- Foundation 计划：`docs/plan/v1-godot-foundation.md`
- Parser 计划：`docs/plan/v1-parser-and-selector-parity.md`
- 当前推进：`docs/plan/v1-static-fetcher-and-session-parity.md`

## 当前状态

- 已完成：文档基线、源项目能力盘点、PRD、v1 计划矩阵。
- 已完成：`Godot 4.6` 工程骨架、插件元数据、PowerShell headless 测试脚本、foundation smoke test。
- 已验证：`powershell -File .\scripts\run_godot_tests.ps1 -Suite foundation` 返回 `PASS`。
- 已验证：`powershell -File .\scripts\run_godot_tests.ps1 -Suite parser` 返回 `PASS`，Parser / Selector 核心等价层已打通。
- 已验证：`powershell -File .\scripts\run_godot_tests.ps1 -Suite fetchers-static` 返回 `PASS`，当前已覆盖本地 fixture server 下的 `fetch_get()` / `fetch_post()` / `fetch_put()` / `fetch_delete()`、`headers` / `params`、显式 `cookies`、`FetcherSession` 的 cookie 持久化、`ProxyRotator` 的轮换逻辑，以及真实代理链路下的 per-request override / cyclic rotation。
- 进行中：Static Fetcher 的 timeout / 状态码策略 / 更完整错误处理仍待补齐。

## 当前目录

- `addons/scrapling/`：插件与实现入口。
- `tests/`：按 suite 拆分的 Godot headless 测试。
- `scripts/`：PowerShell 测试脚本与后续开发脚本。
- `docs/`：愿景、PRD、计划、变更通知单。

## 开发命令

- 运行 foundation 测试：
  - `powershell -File .\scripts\run_godot_tests.ps1 -Suite foundation`
- 运行 parser 测试：
  - `powershell -File .\scripts\run_godot_tests.ps1 -Suite parser`
- 运行静态 fetcher 测试：
  - `powershell -File .\scripts\run_godot_tests.ps1 -Suite fetchers-static`
- 指定 Godot 可执行文件：
  - `powershell -File .\scripts\run_godot_tests.ps1 -GodotExe "E:\Godot_v4.6-stable_win64.exe\Godot_v4.6-stable_win64_console.exe" -Suite foundation`
- 运行单个测试：
  - `powershell -File .\scripts\run_godot_tests.ps1 -One tests\foundation\test_project_boot.gd`

## 目标能力面

- `Selector` / `Selectors` 风格的 HTML 解析与导航。
- `Fetcher` / `AsyncFetcher` / `DynamicFetcher` / `StealthyFetcher` 风格的抓取接口。
- `Spider` / `Request` / `CrawlerEngine` / `CrawlResult` 风格的爬虫运行时。
- 交互式 Shell、命令行工具、curl 转换、结果导出。
- AI / MCP 侧的结构化提取与服务接口。
- Windows PowerShell 友好的 `Godot 4.6` headless 自动化测试。

## 开发纪律

- 需求编号遵循 `REQ-0001-NNN`。
- 计划文件遵循 `docs/plan/v1-*.md`。
- 每个完成的 slice 都要先验证，再 `commit + push`。
- 施工中若发现设计偏差，新增 `docs/ecn/ECN-NNNN-*.md` 并同步更新 PRD 与计划。


