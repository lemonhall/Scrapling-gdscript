# PRD-0001: Scrapling parity in GDScript

## Vision

见：`docs/prd/VISION.md`

## Summary

本 PRD 定义 `Scrapling-gdscript` 的首个总目标：以 `Scrapling 0.4.1` 为事实基线，在 `Godot 4.6` / `GDScript` 中复刻其核心能力、对外入口、测试维度和开发者工作流。

## Source Of Truth

- 源仓库：`E:\development\Scrapling`
- 源版本：`0.4.1`
- 源提交：`b9b5bb0c8011f3dcb844c074c2bd91ce44d77edd`
- 源公开入口：
  - `scrapling/__init__.py`
  - `scrapling/fetchers/__init__.py`
  - `scrapling/spiders/__init__.py`
- 源测试面：
  - `tests/parser/*`
  - `tests/fetchers/*`
  - `tests/spiders/*`
  - `tests/cli/*`
  - `tests/ai/*`
  - `tests/core/*`

## 非目标

- 不要求 GDScript 对外 API 与 Python 语法逐字符一致。
- 不要求第一轮就交付所有浏览器二进制或第三方驱动。
- 不把源项目的 README 文案直接翻译视为功能完成。

## Requirements

### REQ-0001-001 Parser core parity

- 动机：`Scrapling` 的基础价值从 HTML 解析开始；没有稳定解析层，后续抓取、爬虫和 AI 提取都无从谈起。
- 范围：解析 HTML 文本；生成 `Selector` / `Selectors` 风格对象；支持 CSS、XPath、文本、正则和过滤式查询。
- 非目标：不在本需求内实现动态浏览器或网络请求。
- 验收：
  - 对同一组固定 HTML fixtures，查询结果的元素数量、顺序、文本与属性值与锁定快照一致。
  - `Selector` 与 `Selectors` 的公开入口存在且可在 GDScript 中实例化和调用。

### REQ-0001-002 Navigation and element data parity

- 动机：源项目不仅能“找到元素”，还要能围绕元素移动、读取和转换数据。
- 范围：父子兄弟导航、属性访问、文本处理、HTML 输出、序列化输出。
- 非目标：不在本需求内实现自适应定位。
- 验收：
  - 导航 API 在固定 DOM fixtures 上返回与锁定快照一致的节点集合与文本结果。
  - 属性、文本和 HTML 提取接口覆盖正常、空值、缺失属性和边界输入。

### REQ-0001-003 Adaptive locating and similarity parity

- 动机：`Scrapling` 的差异化能力之一是页面变化后仍能找回目标元素。
- 范围：相似元素搜索、元素回溯、自适应定位、结构相似性比较。
- 非目标：不在本需求内实现浏览器抓取。
- 验收：
  - 当 fixture DOM 发生结构位移但保留语义相似性时，系统仍能找回锁定目标元素。
  - 相似元素排序稳定，且测试中至少覆盖正常、异常和边界三类场景。

### REQ-0001-004 Static HTTP fetcher parity

- 动机：静态请求是最低成本、最高频的抓取入口。
- 范围：`Fetcher` / `AsyncFetcher` 风格接口；GET/POST/PUT/DELETE；请求头、cookies、params、json、超时、错误处理。
- 非目标：不在本需求内处理浏览器自动化页面。
- 验收：
  - 对本地夹具服务器执行多种请求方法后，响应状态、正文、headers、cookies 和错误分支符合测试断言。
  - 同名或等价命名的 GDScript 入口存在，并可被测试和示例直接调用。

### REQ-0001-005 Session and proxy parity

- 动机：源项目的抓取能力不是单次请求，而是跨请求维护状态并支持代理策略。
- 范围：会话持久化、cookie 继承、每请求覆盖、代理轮换、域级配置。
- 非目标：不在本需求内实现浏览器 stealth。
- 验收：
  - 同一 session 连续请求时，状态按测试设计保持一致。
  - 代理轮换与每请求覆盖在测试中均可观测，不允许空壳实现。

### REQ-0001-006 Dynamic browser parity

- 动机：现代网页需要执行 JavaScript 才能获得最终 DOM。
- 范围：`DynamicFetcher` 风格接口；页面打开、等待、跳转、读取渲染后 DOM、执行脚本、基础导航工具。
- 非目标：不在本需求内交付 stealth 与反检测策略。
- 验收：
  - 对 JavaScript 驱动的本地 fixture 页面，获取的最终 DOM 与测试快照一致。
  - 页面导航、等待和脚本执行行为在 headless 自动化测试中可重复通过。

### REQ-0001-007 Stealth and blocked-request handling parity

- 动机：源项目把抗检测与阻断重试作为核心卖点之一。
- 范围：`StealthyFetcher` 风格接口、blocked request 检测、重试策略、指纹配置接口、域屏蔽。
- 非目标：不承诺复制所有第三方浏览器库的内部实现细节。
- 验收：
  - 在本地模拟阻断场景中，系统能识别阻断并按策略重试或失败退出。
  - 域屏蔽和指纹配置可从测试中被观测，不能仅保存配置而不生效。

### REQ-0001-008 Spider runtime parity

- 动机：`Scrapling` 不只是抓取库，也提供类似 Scrapy 的爬虫运行时。
- 范围：`Spider`、`Request`、`Response`、`Scheduler`、`CrawlerEngine`、并发限制、下载延迟、域级节流。
- 非目标：不在本需求内实现 CLI。
- 验收：
  - 以固定抓取图运行示例 spider 时，请求调度顺序、并发限制和结果收集符合测试断言。
  - `Spider` 派生类可在 GDScript 中按约定启动并运行到完成状态。

### REQ-0001-009 Checkpoint, streaming, export and stats parity

- 动机：长时任务需要暂停、恢复、流式消费与结果导出。
- 范围：checkpoint、graceful shutdown、resume、stream 模式、结果统计、JSON/JSONL 导出。
- 非目标：不在本需求内实现浏览器自动化。
- 验收：
  - 中断后重启可从最近 checkpoint 恢复，不允许从头重复抓取已完成任务。
  - 流式模式可逐条产出 item，并同时暴露实时统计。
  - JSON/JSONL 导出文件内容与锁定结构一致。

### REQ-0001-010 CLI and interactive shell parity

- 动机：源项目提供直接命令入口和交互式工作流，影响开发效率与社区可用性。
- 范围：URL 直接抓取、提取命令、curl 转换、交互式 shell、页面预览辅助、命令帮助。
- 非目标：不要求复用 Python 的 `click` 或 IPython 本体。
- 验收：
  - 命令入口可在 Windows PowerShell 中运行，并完成固定示例命令。
  - 交互式 shell 至少支持加载响应对象、运行查询和展示常用帮助命令。

### REQ-0001-011 AI / MCP parity

- 动机：源项目已把 AI/MCP 作为正式能力面，不是附属实验功能。
- 范围：结构化提取接口、MCP 服务入口、面向 AI 的内容裁剪与传输。
- 非目标：不要求绑定某一个特定模型供应商。
- 验收：
  - MCP 入口可启动，且至少有一个端到端测试覆盖“抓取页面 → 提取内容 → 返回结构化结果”。
  - 内容裁剪逻辑在固定 fixture 上输出稳定结果。

### REQ-0001-012 Test, docs and packaging parity

- 动机：没有测试和文档，功能面再大也无法在 Godot 社区稳定落地。
- 范围：`Godot 4.6` 工程脚手架、headless 测试脚本、样例、安装/使用文档、发布口径。
- 非目标：不要求第一轮就完成 Godot Asset Library 发布。
- 验收：
  - `scripts/run_godot_tests.ps1` 能按 suite 执行 `test_*.gd`。
  - 文档中存在从愿景到计划再到测试的追溯链。
  - 项目目录结构允许社区用户直接导入并运行示例与测试。
