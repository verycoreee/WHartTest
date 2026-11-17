# 停止本地开发依赖容器
# 只停不删：数据卷保留。不要用 docker compose down -v，那会删掉数据库数据。

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot

Set-Location $Root
Write-Host '停止 postgres / redis / qdrant ...' -ForegroundColor Cyan
docker compose stop postgres redis qdrant

Write-Host ''
docker ps -a --filter 'name=wharttest' --format 'table {{.Names}}\t{{.Status}}'
Write-Host ''
Write-Host '前后端窗口请各自 Ctrl+C 停止。' -ForegroundColor DarkGray
