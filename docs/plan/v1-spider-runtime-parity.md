# v1: Spider runtime parity

Goal: 交付与 `Scrapling` 类似的 spider、request、scheduler、engine、checkpoint、streaming 和导出能力。

## PRD Trace

- `REQ-0001-008`
- `REQ-0001-009`

## Scope

- `Spider` 基类与 `Request` 对象。
- `Scheduler`、`CrawlerEngine`、并发、延迟、域级节流。
- `CrawlResult`、实时 stats、stream 模式。
- checkpoint、resume、JSON/JSONL 导出。

## Out Of Scope

- 不在本计划内实现 CLI / shell / MCP。
- 不在本计划内实现 stealth 浏览器内部细节。

## Acceptance

1. `powershell -File scripts/run_godot_tests.ps1 -Suite spiders` 返回 exit code `0`。
2. 示例 spider 在固定抓取图上能按预期顺序调度、产出 item、写出 stats。
3. checkpoint 中断恢复后，不重复抓取已完成请求。
4. 反作弊条款：不得把结果直接写入导出文件伪装成完成；导出必须来自真实 crawl 过程。

## Files

- `addons/scrapling/spiders/request.gd`
- `addons/scrapling/spiders/spider.gd`
- `addons/scrapling/spiders/scheduler.gd`
- `addons/scrapling/spiders/engine.gd`
- `addons/scrapling/spiders/checkpoint_store.gd`
- `addons/scrapling/spiders/crawl_result.gd`
- `tests/spiders/test_request.gd`
- `tests/spiders/test_scheduler.gd`
- `tests/spiders/test_engine.gd`
- `tests/spiders/test_checkpoint_resume.gd`
- `tests/spiders/test_result_export.gd`

## Steps

1. 写失败测试（红）
   - 先为 request、scheduler、engine、checkpoint、export 写细粒度断言。
2. 运行到红
   - `powershell -File scripts/run_godot_tests.ps1 -Suite spiders`
   - 预期失败原因：类不存在、调度行为错误、checkpoint 无法恢复。
3. 实现（绿）
   - 先实现 request/result 模型，再实现 scheduler/engine，最后接入 checkpoint/export。
4. 运行到绿
   - `powershell -File scripts/run_godot_tests.ps1 -Suite spiders`
5. 必要重构（仍绿）
   - 把调度策略、结果模型、存储接口拆层。
6. E2E 测试
   - 跑一个完整 spider：开始 → 抓取 → 中断 → 恢复 → 导出结果。

## Risks

- Godot 场景树生命周期与 spider runtime 无关，若把 engine 写成节点驱动，会让测试和复用都变差。
- checkpoint 存储格式必须先锁定，否则恢复语义容易漂移。
