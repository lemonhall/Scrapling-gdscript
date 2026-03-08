# v1 index

Goal: 完成源项目盘点、建立追溯链、锁定 `Godot 4.6` 工程与测试套路，并把后续实现拆成可执行计划文件。

## Source Baseline

- 源项目：`Scrapling 0.4.1`
- 源提交：`b9b5bb0c8011f3dcb844c074c2bd91ce44d77edd`
- 参考工程：`E:\development\openagentic-sdk-gdscript`

## Artifacts

- 愿景：`docs/prd/VISION.md`
- PRD：`docs/prd/PRD-0001-scrapling-parity.md`
- 源项目能力盘点：`docs/analysis/source-capability-inventory.md`
- Foundation 计划：`docs/plan/v1-godot-foundation.md`
- Parser 计划：`docs/plan/v1-parser-and-selector-parity.md`
- Static Fetcher 计划：`docs/plan/v1-static-fetcher-and-session-parity.md`
- Browser Fetcher 计划：`docs/plan/v1-browser-and-stealth-parity.md`
- Spider Runtime 计划：`docs/plan/v1-spider-runtime-parity.md`
- CLI / Shell / MCP 计划：`docs/plan/v1-cli-shell-and-mcp-parity.md`

## Milestones

| Milestone | Scope | Verify | Status |
|---|---|---|---|
| M0 | 建立愿景、PRD、能力盘点、v1 计划矩阵 | 文档存在且交叉链接有效 | done |
| M1 | 建立 `Godot 4.6` 工程脚手架与 headless 测试入口 | `powershell -File scripts/run_godot_tests.ps1 -Suite foundation` | done |
| M2 | 完成 Parser / Selector 核心等价层 | `powershell -File scripts/run_godot_tests.ps1 -Suite parser` | done |
| M3 | 完成静态 Fetcher / Session / Proxy 等价层 | `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static` | in_progress |
| M4 | 完成动态 Browser / Stealth 等价层 | `powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-browser` | todo |
| M5 | 完成 Spider Runtime / Checkpoint / Export 等价层 | `powershell -File scripts/run_godot_tests.ps1 -Suite spiders` | todo |
| M6 | 完成 CLI / Shell / AI / MCP 等价层 | `powershell -File scripts/run_godot_tests.ps1 -Suite tooling` | todo |

## Traceability Matrix

| Req ID | PRD | v1 Plan | 预期测试套件 | 证据 | Status |
|---|---|---|---|---|---|
| REQ-0001-001 | `PRD-0001` | `v1-parser-and-selector-parity.md` | `parser` | parser suite PASS 2026-03-08 | done |
| REQ-0001-002 | `PRD-0001` | `v1-parser-and-selector-parity.md` | `parser` | parser suite PASS 2026-03-08 | done |
| REQ-0001-003 | `PRD-0001` | `v1-parser-and-selector-parity.md` | `parser` | parser suite PASS 2026-03-08 | done |
| REQ-0001-004 | `PRD-0001` | `v1-static-fetcher-and-session-parity.md` | `fetchers-static` | methods/headers/params/status/timeout PASS 2026-03-08 | in_progress |
| REQ-0001-005 | `PRD-0001` | `v1-static-fetcher-and-session-parity.md` | `fetchers-static` | session/cookies/rotator/proxy PASS 2026-03-08 | in_progress |
| REQ-0001-006 | `PRD-0001` | `v1-browser-and-stealth-parity.md` | `fetchers-browser` | — | todo |
| REQ-0001-007 | `PRD-0001` | `v1-browser-and-stealth-parity.md` | `fetchers-browser` | — | todo |
| REQ-0001-008 | `PRD-0001` | `v1-spider-runtime-parity.md` | `spiders` | — | todo |
| REQ-0001-009 | `PRD-0001` | `v1-spider-runtime-parity.md` | `spiders` | — | todo |
| REQ-0001-010 | `PRD-0001` | `v1-cli-shell-and-mcp-parity.md` | `tooling` | — | todo |
| REQ-0001-011 | `PRD-0001` | `v1-cli-shell-and-mcp-parity.md` | `tooling` | — | todo |
| REQ-0001-012 | `PRD-0001` | `v1-godot-foundation.md` | `foundation` | foundation PASS 2026-03-08 | in_progress |

## ECN Index

- 当前为空，见：`docs/ecn/README.md`

## Evidence

- 2026-03-08：已建立愿景、PRD、能力盘点、v1 计划矩阵。
- 2026-03-08：`powershell -File scripts/run_godot_tests.ps1 -Suite foundation` → `PASS` / exit code `0`。
- 2026-03-08：`powershell -File scripts/run_godot_tests.ps1 -Suite parser -TimeoutSec 20` → `PASS` / exit code `0`。
- 2026-03-08：`powershell -File scripts/run_godot_tests.ps1 -Suite fetchers-static -TimeoutSec 25` → `PASS` / exit code `0`。

## Difference List

- `REQ-0001-012` 已完成文档基线、foundation 与 parser 套件验证；更多 fetcher / spider / tooling 回归仍待补齐。
- 当前仓库已具备 parser 核心等价层，以及静态 fetcher 的 GET / POST / PUT / DELETE / headers / params / cookies / 404 / timeout 最小实现，并已打通 `FetcherSession` 的 cookie 持久化、`ProxyRotator` 轮换逻辑与真实代理接线；browser、spider、tooling 仍待推进。
- 当前仓库已具备本地 HTTP fixture server；浏览器 sidecar、示例场景与完整运行时尚未实现。




