# v1: Parser and selector parity

Goal: 交付 `Selector` / `Selectors` 核心能力，使固定 HTML fixtures 上的查询、导航、属性与文本行为达到与源项目等价的可观测结果。

## PRD Trace

- `REQ-0001-001`
- `REQ-0001-002`
- `REQ-0001-003`

## Scope

- HTML 文本解析为内部 DOM 表示。
- CSS / XPath / 文本 / 正则 / 过滤式查询。
- 父子兄弟导航、属性访问、文本提取、HTML 导出。
- 相似元素搜索、自适应定位的第一版算法。

## Out Of Scope

- 不在本计划内实现网络请求。
- 不在本计划内实现浏览器自动化。

## Acceptance

1. `powershell -File scripts/run_godot_tests.ps1 -Suite parser` 返回 exit code `0`。
2. 固定 fixtures 上的节点数量、排序、文本值、属性值与 golden snapshots 一致。
3. 自适应定位覆盖正常、异常、边界三类场景，且每类至少 1 个测试。
4. 反作弊条款：不能靠按 fixture 文件名硬编码答案；同一算法必须通过多组 fixtures。

## Files

- `addons/scrapling/parser/selector.gd`
- `addons/scrapling/parser/selectors.gd`
- `addons/scrapling/parser/query_engine.gd`
- `addons/scrapling/parser/navigation.gd`
- `addons/scrapling/parser/adaptive_locator.gd`
- `tests/parser/test_selector_queries.gd`
- `tests/parser/test_navigation.gd`
- `tests/parser/test_attributes_and_text.gd`
- `tests/parser/test_adaptive.gd`
- `tests/fixtures/parser/*`

## Steps

1. 写失败测试（红）
   - 从源项目 parser 测试和文档示例提取 fixtures 与断言。
2. 运行到红
   - `powershell -File scripts/run_godot_tests.ps1 -Suite parser`
   - 预期失败原因：类不存在、查询结果不匹配、导航 API 未实现。
3. 实现（绿）
   - 先做最小 parser 表示层，再做 query/navigation，最后做 adaptive。
4. 运行到绿
   - `powershell -File scripts/run_godot_tests.ps1 -Suite parser`
5. 必要重构（仍绿）
   - 将 DOM 解析、查询匹配、导航和 adaptive 算法拆层，避免单文件膨胀。
6. E2E 测试
   - 运行一个完整 fixture 流程：解析 HTML → 定位元素 → 导出结构化结果。

## Evidence

- 2026-03-08 Red: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `FAIL: Missing res://addons/scrapling/parser/Selector.gd`
- 2026-03-08 Green: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `PASS` / exit code `0`
- 2026-03-08 Red 2: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `FAIL: Selector must expose parent()`
- 2026-03-08 Green 2: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `PASS` / exit code `0` (smoke + navigation)
- 2026-03-08 Red 3: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `FAIL: Selector must expose find_by_text()`
- 2026-03-08 Green 3: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `PASS` / exit code `0` (smoke + navigation + text search)
- 2026-03-08 Red 4: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `FAIL: Selector must expose re()`
- 2026-03-08 Green 4: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `PASS` / exit code `0` (smoke + navigation + text search + regex extract)
- 2026-03-08 Red 5: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `FAIL: Selector must expose getall()`
- 2026-03-08 Green 5: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `PASS` / exit code `0` (smoke + navigation + text search + regex extract + content access)
- 2026-03-08 Red 6: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `FAIL: Selector must expose find_similar()`
- 2026-03-08 Green 6: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `PASS` / exit code `0` (smoke + navigation + text search + regex extract + content access + find_similar)
- 2026-03-08 Red 7: `powershell -File scripts/run_godot_tests.ps1 -Suite parser` → `FAIL: Selector must expose find()`
## Notes`n`n- 由于 Godot `Object.get` 与源项目 `get()` 命名冲突，内容读取在当前实现中使用 Godot-safe aliases：`get_text()` / `get_all_text()`。`n`n## Risks

- `lxml` / `cssselect` 语义在 GDScript 中没有现成对照物，必须先锁定支持子集再扩展。
- XPath 支持范围如果不先定义，会导致计划漂移；需要以源测试覆盖范围为首版边界。














