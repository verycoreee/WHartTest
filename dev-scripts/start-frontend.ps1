# 启动 WHartTest 前端（Vite 开发服务器，本机源码运行）
# 前端不需要 Python 虚拟环境，用的是 Node.js 和 npm。

param(
    [int]$Port = 5173
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Vue = Join-Path $Root 'WHartTest_Vue'

if (-not (Test-Path $Vue)) { throw "找不到前端目录：$Vue" }

Set-Location $Vue

# 首次克隆或依赖变化时才需要装；已有 node_modules 就跳过
if (-not (Test-Path (Join-Path $Vue 'node_modules'))) {
    Write-Host '未检测到 node_modules，开始 npm install ...' -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) { throw 'npm install 失败，先解决依赖问题再启动。' }
}

Write-Host "启动前端：npm run dev -- --port $Port" -ForegroundColor Cyan
Write-Host '打开终端打印的 Local 地址，通常是 http://localhost:5173/' -ForegroundColor DarkGray
Write-Host '这个窗口要一直开着；Ctrl+C 停止。' -ForegroundColor DarkGray

npm run dev -- --port $Port
