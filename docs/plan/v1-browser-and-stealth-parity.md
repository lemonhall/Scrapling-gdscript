# v1: Browser and stealth parity

Goal: 交付动态页面抓取、基础浏览器自动化、stealth 配置与 blocked request 检测能力。

## PRD Trace

- `REQ-0001-006`
- `REQ-0001-007`

## Scope

- `DynamicFetcher` 风格入口。
- 渲染后 DOM 读取、等待、导航、脚本执行。
- 域屏蔽、blocked request 检测、重试策略、stealth 配置接口。
- 明确定义浏览器 sidecar 协议边界。

## Out Of Scope

- 不在本计划内实现 spider runtime。
- 不在本计划内实现 CLI / shell。

## Acceptance

1. `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-browser` 返回 exit code `0`。
2. 对动态 fixture 页面，抓取到的渲染后 DOM 与 golden snapshot 一致。
3. blocked request 模拟场景中，检测与重试路径均被测试覆盖。
4. 反作弊条款：不得用静态 HTML 替代动态页面测试；至少 1 个测试必须依赖 JavaScript 渲染后的 DOM 差异。

## Files

- `addons/scrapling/fetchers/dynamic_fetcher.gd`
- `addons/scrapling/fetchers/stealthy_fetcher.gd`
- `addons/scrapling/fetchers/browser_adapter.gd`
- `addons/scrapling/fetchers/blocked_request_detector.gd`
- `tests/fetchers/browser/test_dynamic_fetcher.gd`
- `tests/fetchers/browser/test_stealthy_fetcher.gd`
- `tests/fetchers/browser/test_blocked_request_detection.gd`
- `tests/fixtures/browser/*`

## Steps

1. 写失败测试（红）
   - 先建立动态页面 fixtures 和 blocked 模拟场景，再写断言。
2. 运行到红
   - `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-browser`
   - 预期失败原因：动态抓取入口、浏览器 sidecar、检测逻辑未实现。
3. 实现（绿）
   - 先定义协议层，再实现 GDScript 适配器和浏览器后端接线。
4. 运行到绿
   - `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-browser`
5. 必要重构（仍绿）
   - 保持协议层与具体浏览器实现分离。
6. E2E 测试
   - 从命令启动动态 fixture → 运行 fetcher → 取得渲染后 DOM → 验证 blocked 检测与重试。

## Risks

- GDScript 本体不适合直接承载浏览器内核；sidecar 协议是高风险但必要的边界设计点。
- 浏览器启动与清理若不幂等，会让测试极易脏化。
