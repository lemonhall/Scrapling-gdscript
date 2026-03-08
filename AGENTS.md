# AGENTS.md

适用范围：仓库根目录及其全部子目录。

## 项目基线

- 目标：在 `Godot 4.6` / `GDScript` 中复刻 `Scrapling 0.4.1` 的能力面。
- 源项目基线：`E:\development\Scrapling`
- 源提交基线：`b9b5bb0c8011f3dcb844c074c2bd91ce44d77edd`
- 本地 Godot 参考工程：`E:\development\openagentic-sdk-gdscript`

## 工作流

- 严格遵循 `docs/prd/`、`docs/plan/`、`docs/ecn/` 的追溯链。
- 默认按塔山循环推进：先文档、后测试、再实现、最后验证与回写证据。
- 不允许擅自缩小“等价复刻”的目标范围；若必须调整范围，先更新 PRD/plan，必要时补 ECN。
- 每完成一刀（一个可独立验收的 slice），都执行一次完整验证，然后 `commit + push`。
- 本项目默认只有一个人/一个 agent 工作，**不要主动使用 git worktree**；除非用户明确要求。

## 实现纪律

- 新功能或行为修改必须先写失败测试，再写实现。
- 不要先写生产代码再补测试。
- 优先修根因，不做表面绕过。
- 不要引入与当前 slice 无关的重构。

## 技术约定

- 默认 shell 以 PowerShell 为主；连续命令使用 `;`，不要写 bash 风格 `&&`。
- 文本写回优先用 `pwsh.exe` 或 Python `Path.write_text(..., encoding="utf-8")`，避免编码漂移。
- 仓库文本文件统一使用 UTF-8。
- Godot 版本锁定 `4.6`。
- Windows 下 headless 测试入口统一使用 `scripts/run_godot_tests.ps1`。

## 目录约定

- `addons/scrapling/`：GDScript 实现。
- `tests/`：按能力域拆分的 `test_*.gd`。
- `scripts/`：开发与测试脚本。
- `docs/prd/`：需求与愿景。
- `docs/plan/`：版本化计划与索引。
- `docs/ecn/`：设计变更留痕。

## 提交约定

- 提交信息遵循：`vN: <type>: <summary>`。
- 常用类型：`doc`、`test`、`feat`、`fix`、`refactor`、`chore`。
- 在声称“完成/通过”前，必须重新运行对应验证命令，并以实际输出为准。
