# Source capability inventory

本文件只记录事实基线、源项目能力切面和翻译到 GDScript 时的结构建议，不把任何“还没实现的行为”伪装成现状。

## 1. 基线事实

| 项目 | 值 |
|---|---|
| 源仓库 | `E:\development\Scrapling` |
| 源版本 | `0.4.1` |
| 源提交 | `b9b5bb0c8011f3dcb844c074c2bd91ce44d77edd` |
| 源 Python 要求 | `>=3.10` |
| 核心依赖 | `lxml`、`cssselect`、`orjson`、`tld`、`w3lib` |
| 可选依赖 | `playwright`、`patchright`、`browserforge`、`curl_cffi`、`anyio`、`mcp`、`IPython` |
| 目标引擎 | `Godot 4.6` |
| 本地 Godot 参考工程 | `E:\development\openagentic-sdk-gdscript` |

## 2. 源项目公开入口

### 2.1 顶层入口 `scrapling/__init__.py`

- `Selector`
- `Selectors`
- `Fetcher`
- `AsyncFetcher`
- `StealthyFetcher`
- `DynamicFetcher`

### 2.2 抓取入口 `scrapling/fetchers/__init__.py`

- `Fetcher`
- `AsyncFetcher`
- `ProxyRotator`
- `FetcherSession`
- `DynamicFetcher`
- `DynamicSession`
- `AsyncDynamicSession`
- `StealthyFetcher`
- `StealthySession`
- `AsyncStealthySession`

### 2.3 爬虫入口 `scrapling/spiders/__init__.py`

- `Spider`
- `SessionConfigurationError`
- `Request`
- `CrawlerEngine`
- `CrawlResult`
- `SessionManager`
- `Scheduler`
- `Response`

## 3. 源项目模块切面

| 模块域 | 代表文件 | 观察 |
|---|---|---|
| Parser | `scrapling/parser.py` | 体量最大，既有查询也有导航、自适应、属性处理与选择器生成。 |
| Fetchers | `scrapling/fetchers/*.py`、`scrapling/engines/static.py` | 同时覆盖静态请求、会话、动态浏览器、stealth、配置与验证。 |
| Spiders | `scrapling/spiders/*.py` | 包含请求模型、调度、会话管理、结果对象、engine、checkpoint。 |
| Core | `scrapling/core/*.py` | 包含 shell、storage、AI、类型与工具函数。 |
| CLI | `scrapling/cli.py` | 提供安装、MCP、shell、extract、HTTP 方法命令、fetch、stealthy_fetch。 |
| Docs | `docs/*` | 文档已按 parsing / fetching / spiders / cli / ai 等主题拆分。 |

## 4. 测试面盘点

### 4.1 按能力域统计

| 测试域 | 文件数 |
|---|---:|
| `parser` | 5 |
| `fetchers` | 21 |
| `spiders` | 8 |
| `cli` | 3 |
| `ai` | 2 |
| `core` | 3 |

### 4.2 测试文件清单摘要

- Parser
  - `tests/parser/test_general.py`
  - `tests/parser/test_attributes_handler.py`
  - `tests/parser/test_parser_advanced.py`
  - `tests/parser/test_adaptive.py`
- Fetchers
  - `tests/fetchers/sync/test_requests.py`
  - `tests/fetchers/sync/test_requests_session.py`
  - `tests/fetchers/sync/test_dynamic.py`
  - `tests/fetchers/sync/test_stealth_session.py`
  - `tests/fetchers/async/test_requests.py`
  - `tests/fetchers/async/test_requests_session.py`
  - `tests/fetchers/async/test_dynamic.py`
  - `tests/fetchers/async/test_dynamic_session.py`
  - `tests/fetchers/async/test_stealth.py`
  - `tests/fetchers/async/test_stealth_session.py`
  - `tests/fetchers/test_base.py`
  - `tests/fetchers/test_constants.py`
  - `tests/fetchers/test_impersonate_list.py`
  - `tests/fetchers/test_pages.py`
  - `tests/fetchers/test_proxy_rotation.py`
  - `tests/fetchers/test_response_handling.py`
  - `tests/fetchers/test_utils.py`
  - `tests/fetchers/test_validator.py`
- Spiders
  - `tests/spiders/test_checkpoint.py`
  - `tests/spiders/test_engine.py`
  - `tests/spiders/test_request.py`
  - `tests/spiders/test_result.py`
  - `tests/spiders/test_scheduler.py`
  - `tests/spiders/test_session.py`
  - `tests/spiders/test_spider.py`
- CLI / Core / AI
  - `tests/cli/test_cli.py`
  - `tests/cli/test_shell_functionality.py`
  - `tests/core/test_shell_core.py`
  - `tests/core/test_storage_core.py`
  - `tests/ai/test_ai_mcp.py`

## 5. 源 README 明示的能力卖点

根据 `README.md` 的“Key Features”分区，源项目公开强调的能力可归纳为：

1. 完整爬虫框架：Scrapy 风格 Spider API、并发抓取、多 session、暂停恢复、流式输出、阻断检测、内建导出。
2. 高级抓取：HTTP 抓取、动态页面、anti-bot、session、代理轮换、域屏蔽、完整 async 支持。
3. 自适应抓取与 AI：智能元素追踪、灵活选择器、相似元素查找、MCP 服务。
4. 开发体验：交互式 shell、终端命令、DOM 导航、文本处理、自动选择器生成、强类型提示。

## 6. 文档结构对目标仓库的启发

源项目文档目录已按主题拆分：

- `docs/parsing`
- `docs/fetching`
- `docs/spiders`
- `docs/cli`
- `docs/ai`
- `docs/api-reference`
- `docs/tutorials`

这说明目标仓库也应按能力域而不是按“临时实现文件”组织文档和测试。

## 7. Godot 参考工程提供的可复用套路

来自 `E:\development\openagentic-sdk-gdscript` 的事实：

- `project.godot` 已锁定 `config/features=PackedStringArray("4.6")`。
- `scripts/run_godot_tests.ps1` 已验证一套适合 Windows PowerShell 的 Godot headless 测试入口模式。
- 参考工程使用 `tests/**/test_*.gd` 作为 suite 划分规范，适合本项目沿用。

## 8. 建议的目标仓库模块边界

为避免一开始就写成“大泥球”，目标仓库建议从以下边界起步：

- `addons/scrapling/parser/`
- `addons/scrapling/fetchers/`
- `addons/scrapling/spiders/`
- `addons/scrapling/core/`
- `addons/scrapling/cli/`
- `tests/parser/`
- `tests/fetchers/static/`
- `tests/fetchers/browser/`
- `tests/spiders/`
- `tests/cli/`
- `tests/ai/`
- `tests/foundation/`
- `scripts/`

## 9. 首批翻译风险

以下条目不是“缩范围”的理由，而是需要在计划中单独立项的风险：

1. `lxml` / `cssselect` / `orjson` 在 GDScript 中没有等价标准库，需要自建或引入替代层。
2. 动态浏览器与 stealth 能力在 GDScript 中不宜直接硬写进主逻辑，必须先定义协议层或 sidecar 边界。
3. 源项目的 async 与 session 语义需要和 Godot 的 `await`、信号和节点生命周期对齐。
4. CLI / shell / MCP 必须区分“能力协议”和“宿主实现”，否则会被具体 UI 或命令宿主绑死。
