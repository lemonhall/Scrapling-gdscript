# v1: Static fetcher and session parity

Goal: 交付静态 HTTP 抓取、会话持久化和代理轮换能力，为 spider 运行时提供稳定基础。

## PRD Trace

- `REQ-0001-004`
- `REQ-0001-005`

## Scope

- `Fetcher` / `AsyncFetcher` 风格入口。
- GET / POST / PUT / DELETE。
- headers、cookies、params、json、超时、错误处理。
- session 共享状态、代理轮换、每请求覆盖。

## Out Of Scope

- 不在本计划内实现动态浏览器抓取。
- 不在本计划内实现 stealth 与 blocked detection。

## Acceptance

1. `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static` 返回 exit code `0`。
2. 本地 fixture server 上的请求、响应、cookie 和记忆状态均符合断言。
3. 代理轮换至少覆盖循环策略与每请求覆盖两类行为。
4. 反作弊条款：不得把响应写死在测试中；测试必须经过真实 HTTP 请求链路。

## Files

- `addons/scrapling/fetchers/fetcher.gd`
- `addons/scrapling/fetchers/async_fetcher.gd`
- `addons/scrapling/fetchers/fetcher_session.gd`
- `addons/scrapling/fetchers/proxy_rotator.gd`
- `tests/fetchers/static/test_fetcher_methods.gd`
- `tests/fetchers/static/test_fetcher_session.gd`
- `tests/fetchers/static/test_proxy_rotator.gd`
- `scripts/http_fixture_server.py`

## Steps

1. 写失败测试（红）
   - 先建立本地 fixture server，再写请求方法、session 和代理轮换测试。
2. 运行到红
   - `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static`
   - 预期失败原因：HTTP 类不存在、fixture server 未接入、session 行为缺失。
3. 实现（绿）
   - 先实现同步路径，再补 async，再补 session 与代理逻辑。
4. 运行到绿
   - `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static`
5. 必要重构（仍绿）
   - 把请求配置、响应包装、session 状态和代理策略拆开。
6. E2E 测试
   - 启动 fixture server，运行完整抓取流程并验证导出的响应对象。

## Evidence`n`n- 2026-03-08 Red: `$env:SCRAPLING_FIXTURE_BASE_URL='http://127.0.0.1:8765'; powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 20` → `FAIL: Missing res://addons/scrapling/fetchers/Fetcher.gd`
- 2026-03-08 Green: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0` (fixture server + fetch_get)`n`n## Notes`n`n- 由于 Godot `Object.get` 冲突，当前静态 fetcher 使用 Godot-safe alias：`fetch_get()`。`n`n## Risks

- Godot 原生 HTTP 能力与 Python `curl_cffi` 差异较大，需要先定义“可观测行为等价层”。
- Windows 上本地 fixture server 的启动、端口清理和超时需要脚本化处理。



