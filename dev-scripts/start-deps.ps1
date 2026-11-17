# 启动本地开发依赖：PostgreSQL / Redis / Qdrant
# 日常形态是「依赖跑容器 + 前后端跑本机源码」，全 Docker 只用于 CI 和部署。
# 用法：在 PowerShell 里执行 .\start-deps.ps1

$ErrorActionPreference = 'Stop'

# 项目根目录 = 本脚本所在目录的上一级
$Root = Split-Path -Parent $PSScriptRoot

function Test-DockerEngine {
    # docker info 能返回版本号才说明引擎可用；docker --version 只查客户端，不算数。
    # 注意：PowerShell 5.1 里原生命令的 stderr 压不住，只能靠 $LASTEXITCODE + 输出内容判断。
    # Windows PowerShell 5.1 里，ErrorActionPreference=Stop 时对原生命令 2>&1
    # 会把 stderr 当成终止性错误抛出来，所以这里临时降级为 Continue，用完还原。
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $out = & docker info --format '{{.ServerVersion}}' 2>&1
        if ($LASTEXITCODE -ne 0) { return $false }
        return ($out -match '^\d+\.\d+')
    } finally {
        $ErrorActionPreference = $prev
    }
}

if (-not (Test-DockerEngine)) {
    Write-Host 'Docker 引擎未运行，正在拉起 Docker Desktop...' -ForegroundColor Yellow
    $exe = 'C:\Program Files\Docker\Docker\Docker Desktop.exe'
    if (Test-Path $exe) { Start-Process $exe } else { throw "找不到 $exe，请手动打开 Docker Desktop。" }

    $ready = $false
    for ($i = 1; $i -le 60; $i++) {
        Start-Sleep -Seconds 3
        if (Test-DockerEngine) { Write-Host "引擎就绪（等待约 $($i * 3) 秒）" -ForegroundColor Green; $ready = $true; break }
    }
    if (-not $ready) { throw 'Docker 引擎 180 秒内未就绪，请手动打开 Docker Desktop 后重试。' }
}

Set-Location $Root
Write-Host '启动 postgres / redis / qdrant ...' -ForegroundColor Cyan
docker compose up -d postgres redis qdrant

# 等 postgres 健康检查通过：Django 启动时要连它，早了会 connection timeout
for ($i = 1; $i -le 40; $i++) {
    $status = docker ps --filter 'name=wharttest-postgres' --format '{{.Status}}'
    if ($status -match 'healthy') { break }
    Start-Sleep -Seconds 3
}

Write-Host ''
docker ps --filter 'name=wharttest' --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
Write-Host ''
Write-Host '依赖已就绪：PostgreSQL 8919 / Redis 8911 / Qdrant 8918' -ForegroundColor Green
Write-Host '下一步：.\start-backend.ps1 和 .\start-frontend.ps1（各开一个窗口）'
