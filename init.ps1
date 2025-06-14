# Create navigation functions
function global:room {
    Set-Location $PSScriptRoot
}

function global:shambles {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Tool
    )
    
    $toolPath = Join-Path $PSScriptRoot $Tool
    if (Test-Path $toolPath) {
        Set-Location $toolPath
        Write-Host "Shambles! Moved to $Tool" -ForegroundColor Green
    }
    else {
        Write-Host "Room not found: $Tool" -ForegroundColor Red
    }
}

function global:scalpel {
    $tools = Get-ChildItem -Directory | Where-Object { $_.Name -ne ".git" }
    Write-Host "`nAvailable Tools:" -ForegroundColor Cyan
    Write-Host "----------------"
    foreach ($tool in $tools) {
        Write-Host "📦 $($tool.Name)" -ForegroundColor Yellow
    }
    Write-Host "`nUse 'shambles [tool]' to navigate to a tool" -ForegroundColor Gray
    Write-Host "Use 'room' to return to main directory" -ForegroundColor Gray
}

# Create tools directory if it doesn't exist
$toolsDir = Join-Path $PSScriptRoot "tools"
if (-not (Test-Path $toolsDir)) {
    New-Item -ItemType Directory -Path $toolsDir | Out-Null
}

# Move satellite to tools directory
$satelliteDir = Join-Path $toolsDir "satellite"
if (-not (Test-Path $satelliteDir)) {
    New-Item -ItemType Directory -Path $satelliteDir | Out-Null
}

# Move satellite files
$satelliteFiles = @("satellite.ps1", "fuel.ps1", "panels.csv")
foreach ($file in $satelliteFiles) {
    if (Test-Path $file) {
        Move-Item -Path $file -Destination $satelliteDir -Force
    }
}

Write-Host "`nDvincis MS Toolbox initialized!" -ForegroundColor Green
Write-Host "Use 'scalpel' to see available tools" -ForegroundColor Cyan
Write-Host "Use 'shambles [tool]' to navigate to a tool" -ForegroundColor Cyan
Write-Host "Use 'room' to return to main directory" -ForegroundColor Cyan 