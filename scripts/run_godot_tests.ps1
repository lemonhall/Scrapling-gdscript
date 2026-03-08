Param(
  [string]$GodotExe = $env:GODOT_WIN_EXE,
  [string]$Suite = "all",
  [string]$One = "",
  [int]$TimeoutSec = $(if ($env:GODOT_TEST_TIMEOUT_SEC) { [int]$env:GODOT_TEST_TIMEOUT_SEC } else { 120 }),
  [string[]]$ExtraArgs = @()
)

$ErrorActionPreference = "Stop"

function Quote-Arg([string]$a) {
  if ($null -eq $a) { return '""' }
  if ($a -match '[\s"]') {
    $escaped = $a -replace '"', '\\"'
    return '"' + $escaped + '"'
  }
  return $a
}

function Run-ProcessCapture {
  Param(
    [Parameter(Mandatory = $true)][string]$FilePath,
    [Parameter(Mandatory = $true)][string[]]$Args,
    [Parameter(Mandatory = $true)][string]$WorkingDirectory,
    [Parameter(Mandatory = $true)][int]$TimeoutSec
  )

  $psi = [System.Diagnostics.ProcessStartInfo]::new()
  $psi.FileName = $FilePath
  $psi.WorkingDirectory = $WorkingDirectory
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.CreateNoWindow = $true
  $psi.Arguments = (($Args | ForEach-Object { Quote-Arg $_ }) -join ' ')

  $p = [System.Diagnostics.Process]::new()
  $p.StartInfo = $psi

  [void]$p.Start()
  $outTask = $p.StandardOutput.ReadToEndAsync()
  $errTask = $p.StandardError.ReadToEndAsync()

  $timedOut = -not $p.WaitForExit($TimeoutSec * 1000)
  if ($timedOut) {
    try { $p.Kill($true) } catch { try { Stop-Process -Id $p.Id -Force } catch {} }
  }

  $p.WaitForExit()

  $stdoutText = ""
  $stderrText = ""
  try { $stdoutText = $outTask.GetAwaiter().GetResult() } catch { $stdoutText = "" }
  try { $stderrText = $errTask.GetAwaiter().GetResult() } catch { $stderrText = "" }

  return @{
    timed_out = $timedOut
    exit_code = [int]$p.ExitCode
    stdout = $stdoutText
    stderr = $stderrText
  }
}

function Usage {
  Write-Host @"
Run Godot headless test scripts from Windows (PowerShell).

Usage:
  scripts/run_godot_tests.ps1 [-GodotExe <path-to-godot-console-exe>] [-Suite <name>] [-One <test_script.gd>] [-TimeoutSec <seconds>] [-ExtraArgs <args...>]

Examples:
  scripts/run_godot_tests.ps1
  scripts/run_godot_tests.ps1 -Suite foundation
  scripts/run_godot_tests.ps1 -GodotExe "E:\Godot_v4.6-stable_win64.exe\Godot_v4.6-stable_win64_console.exe"

Suites:
  all (default), foundation, parser, fetchers-static, fetchers-browser, spiders, tooling

Notes:
  - Use the console exe for reliable headless output.
  - You can also set GODOT_WIN_EXE to avoid passing -GodotExe every time.
  - To avoid hung tests, set GODOT_TEST_TIMEOUT_SEC or pass -TimeoutSec.
"@
}

$RootDir = Resolve-Path (Join-Path $PSScriptRoot "..")

if ([string]::IsNullOrWhiteSpace($GodotExe)) {
  $DefaultDir = "E:\Godot_v4.6-stable_win64.exe"
  $DefaultExe = Join-Path $DefaultDir "Godot_v4.6-stable_win64_console.exe"
  if (Test-Path $DefaultExe) {
    $GodotExe = $DefaultExe
  }
}

if ([string]::IsNullOrWhiteSpace($GodotExe) -or !(Test-Path $GodotExe)) {
  Write-Host "Godot exe not found. Set GODOT_WIN_EXE or pass -GodotExe."
  Usage
  exit 2
}

$tests = @()
if (![string]::IsNullOrWhiteSpace($One)) {
  $tests = @($One)
} else {
  $suiteDir = Join-Path $RootDir "tests"
  switch ($Suite) {
    "all" { $suiteDir = Join-Path $RootDir "tests" }
    "foundation" { $suiteDir = Join-Path $RootDir "tests\foundation" }
    "parser" { $suiteDir = Join-Path $RootDir "tests\parser" }
    "fetchers-static" { $suiteDir = Join-Path $RootDir "tests\fetchers\static" }
    "fetchers-browser" { $suiteDir = Join-Path $RootDir "tests\fetchers\browser" }
    "spiders" { $suiteDir = Join-Path $RootDir "tests\spiders" }
    "tooling" { $suiteDir = Join-Path $RootDir "tests\tooling" }
    default {
      Write-Host ("Unknown suite: {0}" -f $Suite)
      Usage
      exit 2
    }
  }

  $tests = Get-ChildItem -Path $suiteDir -Recurse -Filter "test_*.gd" -File -ErrorAction SilentlyContinue |
    Sort-Object FullName |
    ForEach-Object { $_.FullName }

  if ($tests.Count -eq 0) {
    Write-Host ("No tests found under {0}\\**\\test_*.gd" -f $suiteDir)
    exit 2
  }
}

$status = 0
foreach ($t in $tests) {
  $scriptPath = $t
  if (!(Test-Path $scriptPath)) {
    $scriptPath = Join-Path $RootDir $t
  }
  if (!(Test-Path $scriptPath)) {
    Write-Host "Missing test script: $t"
    $status = 1
    continue
  }

  Write-Host "--- RUN $t"
  $args = @()
  if ($ExtraArgs.Count -gt 0) { $args += $ExtraArgs }
  $args += @("--headless", "--path", $RootDir.Path, "--script", $scriptPath)

  $res = Run-ProcessCapture -FilePath $GodotExe -Args $args -WorkingDirectory $RootDir.Path -TimeoutSec $TimeoutSec
  if ($res.timed_out) {
    if (-not [string]::IsNullOrWhiteSpace($res.stdout)) { $res.stdout | Write-Host }
    if (-not [string]::IsNullOrWhiteSpace($res.stderr)) { $res.stderr | Write-Host }
    Write-Host ("TIMEOUT after {0}s: {1}" -f $TimeoutSec, $t)
    $status = 1
    continue
  }

  if (-not [string]::IsNullOrWhiteSpace($res.stdout)) { $res.stdout | Write-Host }
  if (-not [string]::IsNullOrWhiteSpace($res.stderr)) { $res.stderr | Write-Host }

  if ($res.exit_code -ne 0) { $status = 1 }
}

exit $status
