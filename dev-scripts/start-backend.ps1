# 启动 WHartTest 后端（Django + Daphne，本机源码运行）
# 默认开启自动重载：改 Python 代码后自动重启。
# 若自动重载又出现退出清理、8000 连不上，用 .\start-backend.ps1 -NoReload 关掉它。

param(
    [switch]$NoReload
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Django = Join-Path $Root 'WHartTest_Django'
$Python = Join-Path $Django '.venv\Scripts\python.exe'

if (-not (Test-Path $Python)) {
    throw "找不到虚拟环境：$Python`n先按项目说明创建 .venv 并安装依赖。"
}

function Test-Port([int]$Port) {
    $client = New-Object System.Net.Sockets.TcpClient
    try { $client.Connect('127.0.0.1', $Port); return $true }
    catch { return $false }
    finally { $client.Dispose() }
}

# 先探数据库端口：不通的话 runserver 会死在 check_migrations，报 connection timeout
if (-not (Test-Port 8919)) {
    Write-Host 'PostgreSQL (127.0.0.1:8919) 连不上，先执行 .\start-deps.ps1' -ForegroundColor Red
    exit 1
}
if (-not (Test-Port 8911)) { Write-Host '提示：Redis (8911) 没通，跨域/缓存相关功能可能受影响。' -ForegroundColor Yellow }

Set-Location $Django

$cliArgs = @('manage.py', 'runserver', '127.0.0.1:8000')
if ($NoReload) { $cliArgs += '--noreload' }

Write-Host "启动后端：$Python $($cliArgs -join ' ')" -ForegroundColor Cyan
Write-Host '看到 "Starting ASGI/Daphne ... at http://127.0.0.1:8000/" 且没有回到提示符，就是起来了。' -ForegroundColor DarkGray
Write-Host '这个窗口要一直开着；Ctrl+C 停止。' -ForegroundColor DarkGray

& $Python @cliArgs
