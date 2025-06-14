# Navigation functions only - simplified
function global:room {
    Set-Location $PSScriptRoot
}

function global:shambles {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Tool
    )
    $toolPath = Join-Path (Join-Path $PSScriptRoot "tools") $Tool
    if (Test-Path $toolPath) {
        Set-Location $toolPath
        Write-Host "Shambles! Moved to $Tool" -ForegroundColor Green
    }
    else {
        Write-Host "Room not found: $Tool" -ForegroundColor Red
    }
}

function global:takt {
    $toolsPath = Join-Path $PSScriptRoot "tools"
    if (Test-Path $toolsPath) {
        $tools = Get-ChildItem -Path $toolsPath -Directory
        Write-Host "Available Tools:" -ForegroundColor Cyan
        Write-Host "----------------"
        foreach ($tool in $tools) {
            Write-Host "[TOOL] $($tool.Name)" -ForegroundColor Yellow
        }
        Write-Host "Use 'shambles [tool]' to navigate to a tool" -ForegroundColor Gray
        Write-Host "Use 'room' to return to main directory" -ForegroundColor Gray
    }
    else {
        Write-Host "Tools directory not found!" -ForegroundColor Red
    }
}

Write-Host "Dvincis MS Toolbox navigation loaded!" -ForegroundColor Green
Write-Host "Use 'takt' to see available tools" -ForegroundColor Cyan
Write-Host "Use 'shambles [tool]' to navigate to a tool" -ForegroundColor Cyan
Write-Host "Use 'room' to return to main directory" -ForegroundColor Cyan 