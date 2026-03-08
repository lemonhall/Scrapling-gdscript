# v1: CLI, shell and MCP parity

Goal: 交付命令行入口、交互式 shell、curl 转换、AI 提取和 MCP 服务入口，让项目具备与源项目相同的开发者工作流出口。

## PRD Trace

- `REQ-0001-010`
- `REQ-0001-011`
- `REQ-0001-012`

## Scope

- 命令入口：抓取、提取、帮助、配置。
- 交互式 shell：加载响应对象、运行查询、展示辅助命令。
- curl 转换与页面结果预览辅助。
- MCP 服务入口与结构化提取链路。

## Out Of Scope

- 不在本计划内实现 parser 或 spider 的底层细节。
- 不在本计划内定义任何供应商绑定的 AI 模型协议。

## Acceptance

1. `powershell -File scripts/run_godot_tests.ps1 -Suite tooling` 返回 exit code `0`。
2. 至少 1 条命令行抓取路径和 1 条 MCP 路径有端到端自动化测试。
3. shell 至少支持载入响应、执行选择器查询和显示帮助命令。
4. 反作弊条款：帮助文本或空壳命令不算完成；命令必须驱动真实实现路径。

## Files

- `addons/scrapling/cli/command_router.gd`
- `addons/scrapling/cli/shell_session.gd`
- `addons/scrapling/cli/curl_converter.gd`
- `addons/scrapling/ai/mcp_server.gd`
- `addons/scrapling/ai/content_extractor.gd`
- `tests/cli/test_command_router.gd`
- `tests/cli/test_shell_session.gd`
- `tests/ai/test_mcp_server.gd`
- `tests/ai/test_content_extractor.gd`

## Steps

1. 写失败测试（红）
   - 先写命令路由、shell 会话、curl 转换和 MCP 入口测试。
2. 运行到红
   - `powershell -File scripts/run_godot_tests.ps1 -Suite tooling`
   - 预期失败原因：命令入口不存在、shell 无状态、MCP 服务未启动。
3. 实现（绿）
   - 先做命令路由，再做 shell，再做 AI/MCP。
4. 运行到绿
   - `powershell -File scripts/run_godot_tests.ps1 -Suite tooling`
5. 必要重构（仍绿）
   - 命令解析、运行上下文、MCP 适配器必须解耦。
6. E2E 测试
   - 从命令行调用抓取，再经提取链路输出结构化结果；另跑 1 条 MCP 端到端流程。

## Risks

- 如果把 shell、CLI、MCP 直接绑在某一种 UI 或宿主上，会破坏“协议优于实现”的目标。
- 命令入口必须兼容 Windows PowerShell 的参数传递习惯。
