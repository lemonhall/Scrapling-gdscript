# v1: Godot foundation

Goal: 建立 `Godot 4.6` 工程骨架、Windows PowerShell 测试脚本、最小 headless 测试回路，为后续所有能力域提供稳定宿主。

## PRD Trace

- `REQ-0001-012`

## Scope

- 创建 `project.godot`，锁定 `config/features=PackedStringArray("4.6")`。
- 建立 `addons/scrapling/` 根目录与基础入口脚本。
- 建立 `tests/foundation/` 和最小 test runner。
- 建立 `scripts/run_godot_tests.ps1`，对齐 `openagentic-sdk-gdscript` 的 PowerShell 习惯。

## Out Of Scope

- 不在本计划内实现 parser、fetcher、spider、CLI、AI 能力。
- 不在本计划内引入浏览器 sidecar。

## Acceptance

1. `project.godot` 存在，且 `config/features=PackedStringArray("4.6")`。
2. `scripts/run_godot_tests.ps1 -Suite foundation` 能找到并运行 `tests/foundation/test_*.gd`。
3. 至少有 1 个 `test_*.gd` 在 headless 模式下通过，并验证真实节点或脚本状态。
4. 反作弊条款：仅创建空文件不算完成；基础测试必须实例化实际脚本或节点并完成断言。

## Files

- `project.godot`
- `addons/scrapling/plugin.cfg`
- `addons/scrapling/Scrapling.gd`
- `tests/foundation/test_project_boot.gd`
- `tests/test_runner.gd`
- `scripts/run_godot_tests.ps1`

## Steps

1. 写失败测试（红）
   - 添加 `tests/foundation/test_project_boot.gd`，断言项目入口和插件入口存在。
2. 运行到红
   - `powershell -File scripts/run_godot_tests.ps1 -Suite foundation`
   - 预期失败原因：缺少 `project.godot`、test runner 或入口脚本。
3. 实现（绿）
   - 新建 Godot 工程文件、入口脚本、PowerShell 测试脚本、最小测试 runner。
4. 运行到绿
   - `powershell -File scripts/run_godot_tests.ps1 -Suite foundation`
   - 预期结果：exit code `0`。
5. 必要重构（仍绿）
   - 把路径发现、suite 选择和超时控制从测试脚本中抽成纯函数或独立段落。
6. E2E 测试
   - 仍使用 headless Godot 作为 E2E；验证从命令调用到测试输出的整条链路。

## Risks

- `Godot 4.6` 控制台可执行文件路径在不同机器上可能不同，必须支持 `GODOT_WIN_EXE`。
- 测试 runner 如果与具体 suite 绑定过深，后续添加 parser/fetchers suites 时会返工。
