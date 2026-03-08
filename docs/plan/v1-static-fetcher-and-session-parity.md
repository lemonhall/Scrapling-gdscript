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
3. 代理轮换至少覆盖循环策略、自定义 strategy 与每请求覆盖三类行为。
4. 反作弊条款：不得把响应写死在测试中；测试必须经过真实 HTTP 请求链路。

## Files

- `addons/scrapling/fetchers/fetcher.gd`
- `addons/scrapling/fetchers/async_fetcher.gd`
- `addons/scrapling/fetchers/AsyncFetcher.gd`
- `addons/scrapling/fetchers/AsyncFetcherSession.gd`
- `addons/scrapling/fetchers/FetcherSession.gd`
- `addons/scrapling/fetchers/fetcher_session.gd`
- `addons/scrapling/fetchers/ProxyRotator.gd`
- `tests/fetchers/static/test_fetcher_get.gd`
- `tests/fetchers/static/test_fetcher_post.gd`
- `tests/fetchers/static/test_fetcher_put.gd`
- `tests/fetchers/static/test_fetcher_delete.gd`
- `tests/fetchers/static/test_fetcher_request_options.gd`
- `tests/fetchers/static/test_fetcher_cookies.gd`
- `tests/fetchers/static/test_fetcher_session.gd`
- `tests/fetchers/static/test_proxy_rotator.gd`
- `tests/fetchers/static/test_proxy_rotator_strategy.gd`
- `tests/fetchers/static/test_proxy_rotator_utils.gd`
- `tests/fetchers/static/test_fetcher_proxy_flow.gd`
- `tests/fetchers/static/test_fetcher_status_timeout.gd`
- `tests/fetchers/static/test_fetcher_session_defaults.gd`
- `tests/fetchers/static/test_async_fetcher_get.gd`
- `tests/fetchers/static/test_async_fetcher_session.gd`
- `tests/fetchers/static/test_async_fetcher_methods.gd`
- `tests/fetchers/static/test_async_fetcher_session_methods.gd`
- `tests/fetchers/static/test_async_fetcher_session_defaults.gd`
- `tests/fetchers/static/test_async_fetcher_response_metadata.gd`
- `tests/fetchers/static/test_fetcher_retry_with_rotator.gd`
- `tests/fetchers/static/test_async_fetcher_retry_with_rotator.gd`
- `tests/fetchers/static/test_fetcher_session_retry_defaults.gd`
- `tests/fetchers/static/test_async_fetcher_session_retry_defaults.gd`
- `tests/fetchers/static/test_fetcher_response_headers.gd`
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

## Evidence

- 2026-03-08 Red: `$env:SCRAPLING_FIXTURE_BASE_URL='http://127.0.0.1:8765'; powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 20` → `FAIL: Missing res://addons/scrapling/fetchers/Fetcher.gd`
- 2026-03-08 Green 1: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（fixture server + `fetch_get()`）
- 2026-03-08 Red 2: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `FAIL: Fetcher must expose fetch_post()`
- 2026-03-08 Red 3: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_fetcher_post.gd -TimeoutSec 25` → `FAIL: Response body must echo posted json`
- 2026-03-08 Green 2: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（fixture server + `fetch_get()` + `fetch_post()`）
- 2026-03-08 Red 4: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `FAIL: Fetcher must expose fetch_delete()` / `FAIL: Fetcher must expose fetch_put()`
- 2026-03-08 Green 3: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（fixture server + `fetch_get()` + `fetch_post()` + `fetch_put()` + `fetch_delete()`）
- 2026-03-08 Red 5: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `SCRIPT ERROR: Invalid call to function 'fetch_get (via call)'. Expected 1 argument(s).`
- 2026-03-08 Green 4: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（`headers` + `params` + 全部现有静态 fetcher 覆盖）
- 2026-03-08 Red 6: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `FAIL: Failed to load res://addons/scrapling/fetchers/FetcherSession.gd`
- 2026-03-08 Green 5: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（`FetcherSession` + cookie jar 持久化）
- 2026-03-08 Red 7: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `SCRIPT ERROR: Invalid call to function 'fetch_get (via call)'. Expected 3 argument(s).`
- 2026-03-08 Green 6: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（显式 `cookies` + 全部现有静态 fetcher 覆盖）
- 2026-03-08 Red 8: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `FAIL: Failed to load res://addons/scrapling/fetchers/ProxyRotator.gd`
- 2026-03-08 Green 7: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（`ProxyRotator` cyclic rotation + per-request override 逻辑）
- 2026-03-08 Red 9: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_fetcher_proxy_flow.gd -TimeoutSec 25` → `FAIL: SCRAPLING_PROXY_FIXTURE_A_URL must be set for proxy tests`
- 2026-03-08 Green 8: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（origin fixture + proxy-a/proxy-b fixture + 真实代理链路）
- 2026-03-08 Red 10: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_fetcher_status_timeout.gd -TimeoutSec 25` → `SCRIPT ERROR: Invalid call to function 'fetch_get (via call)'. Expected 6 argument(s).`
- 2026-03-08 Green 9: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（404 + timeout + 全部现有静态 fetcher 覆盖）
- 2026-03-08 Red 11: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_fetcher_session_defaults.gd -TimeoutSec 25` → `Invalid call to function 'new' in base 'GDScript'. Expected 1 argument(s).`
- 2026-03-08 Green 10: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（`FetcherSession` 默认 headers / timeout / proxy_rotator）
- 2026-03-08 Red 12: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_async_fetcher_get.gd -TimeoutSec 25` → `FAIL: Failed to load res://addons/scrapling/fetchers/AsyncFetcher.gd`
- 2026-03-08 Green 11: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（最小 `AsyncFetcher.fetch_get()` + 全量静态 fetcher 回归）
- 2026-03-08 Red 13: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_async_fetcher_session.gd -TimeoutSec 25` → `FAIL: Failed to load res://addons/scrapling/fetchers/AsyncFetcherSession.gd`
- 2026-03-08 Green 12: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（最小 `AsyncFetcherSession.fetch_get()` + cookie persistence）
- 2026-03-08 Red 14: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_fetcher_response_headers.gd -TimeoutSec 25` → `FAIL: FetcherResponse must expose get_headers()`
- 2026-03-08 Green 13: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（`FetcherResponse.get_headers()` + `get_header()`）
- 2026-03-08 Green 14: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_async_fetcher_methods.gd -TimeoutSec 25` → `PASS` / exit code `0`（补齐 `AsyncFetcher` 的 POST / PUT / DELETE 覆盖）
- 2026-03-08 Red 15: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_proxy_rotator_strategy.gd -TimeoutSec 25` → `FAIL: ProxyRotator._init() 缺少 strategy 参数 / 缺少自省接口`
- 2026-03-08 Green 15: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（`ProxyRotator` custom strategy + `get_proxies()` + `size()` + `_to_string()`）
- 2026-03-08 Red 16: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_proxy_rotator_utils.gd -TimeoutSec 25` → `FAIL: ProxyRotator 缺少公共 `cyclic_rotation()` 工具函数`
- 2026-03-08 Green 16: `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`（`ProxyRotator.cyclic_rotation()` + `is_proxy_error()`）
- 2026-03-08 Green 17: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_async_fetcher_session_methods.gd -TimeoutSec 25` → `PASS` / exit code `0`（补齐 `AsyncFetcherSession` 的 POST / PUT / DELETE 覆盖）
- 2026-03-08 Green 18: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_async_fetcher_session_defaults.gd -TimeoutSec 25` → `PASS` / exit code `0`（补齐 `AsyncFetcherSession` 默认 headers / timeout / proxy_rotator 覆盖）
- 2026-03-08 Green 19: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_async_fetcher_response_metadata.gd -TimeoutSec 25` → `PASS` / exit code `0`（补齐 `AsyncFetcher` 的 response-headers / 404 / timeout 覆盖）
- 2026-03-08 Red 20: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_fetcher_retry_with_rotator.gd -TimeoutSec 25` → `SCRIPT ERROR: Fetcher.fetch_get() 缺少 retries / retry_delay_sec 参数`
- 2026-03-08 Green 20: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_fetcher_retry_with_rotator.gd -TimeoutSec 25` → `PASS` / exit code `0`（`Fetcher` 每请求 retries + rotator failover）
- 2026-03-08 Green 21: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_async_fetcher_retry_with_rotator.gd -TimeoutSec 25` → `PASS` / exit code `0`（`AsyncFetcher` 每请求 retries + rotator failover）
- 2026-03-08 Green 22: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_fetcher_session_retry_defaults.gd -TimeoutSec 25` → `PASS` / exit code `0`（`FetcherSession` 默认 retries / retry_delay_sec）
- 2026-03-08 Green 23: `powershell -File scripts/run_godot_tests.ps1 -One tests\fetchers\static\test_async_fetcher_session_retry_defaults.gd -TimeoutSec 25` → `PASS` / exit code `0`（`AsyncFetcherSession` 默认 retries / retry_delay_sec）

## Notes

- 由于 Godot `Object.get` 冲突，当前静态 fetcher 使用 Godot-safe alias：`fetch_get()`。
- 为保持命名一致性，当前静态 fetcher 同步使用 Godot-safe alias：`fetch_post()`、`fetch_put()`、`fetch_delete()`。
- 当前 `headers` 通过重复 `-H` 传给 `curl.exe`，`params` 通过 URL query string 显式拼接并做 `uri_encode()`。
- `FetcherSession` 当前通过 `curl.exe -b/-c <cookie-jar>` 实现跨请求 cookie 持久化。
- 显式 `cookies` 当前通过额外 `curl.exe -b "k=v; ..."` 透传到请求。
- `ProxyRotator` 当前已接入 fetcher 请求层；`fetch_get()` / `fetch_post()` / `fetch_put()` / `fetch_delete()` 支持 per-request `proxy` 和 `proxy_rotator`，并补齐 cyclic / custom strategy、自省接口、字符串表示以及 `cyclic_rotation()` / `is_proxy_error()` 公共工具函数。
- `scripts/run_godot_tests.ps1` 当前会自动拉起一个 origin fixture 和两个 proxy fixture，分别验证 per-request override 与 cyclic rotation 的真实链路。
- `timeout_sec` 当前通过 `curl.exe --max-time <seconds>` 下沉到请求层；超时后当前返回 `status=0`、空 body。
- `FetcherSession` 当前支持默认 `headers`、默认 `proxy`、默认 `proxy_rotator`、默认 `timeout_sec`，请求级参数优先级高于会话默认值。
- `Fetcher` / `AsyncFetcher` 当前支持每请求 `retries` 与 `retry_delay_sec`；网络失败时会重新解析 rotator，从而实现真实代理 failover。
- `FetcherSession` / `AsyncFetcherSession` 当前支持默认 `retries` 与默认 `retry_delay_sec`，请求级参数优先级高于会话默认值。
- `AsyncFetcher` 当前以后台 `Thread` 包装同步 `Fetcher`，主线程通过 `process_frame` 轮询完成状态；已覆盖 `fetch_get()` / `fetch_post()` / `fetch_put()` / `fetch_delete()`。
- `AsyncFetcher` 当前已补齐 `fetch_get()` / `fetch_post()` / `fetch_put()` / `fetch_delete()` 的真实 HTTP 测试覆盖。
- `AsyncFetcher` 当前已补齐 response-headers、`404` 与 `timeout` 的真实 HTTP 测试覆盖。
- `AsyncFetcherSession` 当前镜像同步会话能力：默认 `headers` / `proxy` / `proxy_rotator` / `timeout_sec` + cookie jar 持久化；已覆盖 `fetch_get()` / `fetch_post()` / `fetch_put()` / `fetch_delete()` 与默认值行为。
- `FetcherResponse` 当前支持 `get_headers()` / `get_header()`，响应头通过 `curl.exe -D <temp-file>` 捕获并解析最后一个响应头块。
- POST JSON 当前通过临时文件 + `curl.exe --data-binary` 发送，避免 `OS.execute(...)` 直传 JSON 字面量时丢失引号。

## Risks

- Godot 原生 HTTP 能力与 Python `curl_cffi` 差异较大，需要先定义“可观测行为等价层”。
- Windows 上本地 fixture server 的启动、端口清理和超时需要脚本化处理。




