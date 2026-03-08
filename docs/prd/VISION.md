# Vision: Scrapling parity for Godot

## 项目定义

`Scrapling-gdscript` 的目标不是做一个“灵感来自 Scrapling 的新工具”，而是在 `Godot 4.6` / `GDScript` 中交付一个对 Godot 社区可用、可测试、可维护、可发布的 Scrapling 等价物。

## 目标用户

- 需要在 Godot 项目内直接抓取网页、解析 DOM、提取结构化数据的插件作者。
- 需要在 Godot 中把网页抓取与游戏/工具/代理工作流联动的开发者。
- 需要在 Windows 11 + PowerShell 环境下稳定开发、运行、测试 GDScript 抓取能力的开发者。

## 核心价值

1. 在 GDScript 中提供与 `Scrapling 0.4.1` 等价的能力面。
2. 让核心能力可由自动化测试验证，而不是靠口头描述或手工点击。
3. 让 Godot 社区可以直接复用结果，而不是只能把它当作一次性实验代码。

## 成功标准

以下条目全部满足时，项目才算达成愿景：

1. 公开入口覆盖 `Selector`、`Selectors`、`Fetcher`、`AsyncFetcher`、`DynamicFetcher`、`StealthyFetcher`、`Spider`、`Request`、`CrawlerEngine`、`CrawlResult` 等核心对象。
2. `tests/` 中存在按能力域拆分的自动化测试套件，且可通过 `scripts/run_godot_tests.ps1` 在 Windows PowerShell 下 headless 执行。
3. 每条需求都能在 `docs/prd/PRD-0001-scrapling-parity.md`、`docs/plan/v1-index.md`、测试文件和实现文件之间建立追溯链。
4. 源项目关键用户流程在 Godot 中可复现：解析 HTML、发起请求、维护会话、运行爬虫、导出结果、使用命令入口、调用 AI/MCP 接口。
5. 项目输出可作为 Godot 项目或插件被导入，而不是依赖手工拼装脚本才能使用。

## 硬约束

- 基线锁定为 `Scrapling 0.4.1`，对应提交 `b9b5bb0c8011f3dcb844c074c2bd91ce44d77edd`。
- 目标引擎版本锁定为 `Godot 4.6`。
- 对外交付以“行为与结果等价”为验收口径，不以 Python 语法或包管理形式一致为验收口径。
- Windows 11 + PowerShell 必须是一级开发与测试环境；`GODOT_WIN_EXE` 和 headless 测试流程必须从第一轮实现开始就被纳入验证。
- 所有阶段都必须保留文档、计划、测试、实现之间的证据链。

## 非目标

- 不复刻 Python 的打包元数据、`pip` 安装体验和 `pyproject.toml` 生态。
- 不兼容 `Godot 4.6` 以下版本。
- 不把浏览器二进制、驱动二进制直接提交进仓库。

## 完成定义

只有当“能力等价、测试可跑、文档可追溯、项目可复用”四件事同时成立，`Scrapling-gdscript` 才算完成。
