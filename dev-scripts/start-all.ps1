# 一键启动：依赖容器 -> 后端窗口 -> 前端窗口
# 后端和前端各占一个独立 PowerShell 窗口，关掉窗口即停止对应服务。

$ErrorActionPreference = 'Stop'

# 1. 依赖（在当前窗口跑完就返回）
& (Join-Path $PSScriptRoot 'start-deps.ps1')

# 2. 开两个新窗口跑前后端
$ps = 'powershell.exe'
$common = @('-NoExit', '-NoProfile', '-ExecutionPolicy', 'Bypass')

Start-Process $ps -ArgumentList ($common + @('-File', ('"' + (Join-Path $PSScriptRoot 'start-backend.ps1') + '"')))
Start-Sleep -Seconds 2
Start-Process $ps -ArgumentList ($common + @('-File', ('"' + (Join-Path $PSScriptRoot 'start-frontend.ps1') + '"')))

Write-Host ''
Write-Host '已打开后端和前端两个窗口。' -ForegroundColor Green
Write-Host '浏览器打开 http://localhost:5173/ ，账号在项目根目录 .env 的 DJANGO_ADMIN_* 里。'
