# Check for administrative privileges
function Test-AdminPrivileges {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check PowerShell version
function Test-PowerShellVersion {
    $requiredVersion = "5.1"
    $currentVersion = $PSVersionTable.PSVersion.ToString()
    return [version]$currentVersion -ge [version]$requiredVersion
}

# Check Windows Management Framework
function Test-WMFVersion {
    $requiredVersion = "5.1"
    try {
        $wmfVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PowerShell\3\PowerShellEngine" -Name "PowerShellVersion").PowerShellVersion
        return [version]$wmfVersion -ge [version]$requiredVersion
    }
    catch {
        return $false
    }
}

# Initialize environment
function Initialize-Environment {
    # Check administrative privileges
    if (-not (Test-AdminPrivileges)) {
        Write-Error "This script requires administrative privileges. Please run as Administrator."
        exit 1
    }

    # Check PowerShell version
    if (-not (Test-PowerShellVersion)) {
        Write-Error "This script requires PowerShell version 5.1 or later."
        exit 1
    }

    # Check Windows Management Framework
    if (-not (Test-WMFVersion)) {
        Write-Error "This script requires Windows Management Framework 5.1 or later."
        exit 1
    }

    # Set execution policy if needed
    $currentPolicy = Get-ExecutionPolicy
    if ($currentPolicy -eq "Restricted") {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
    }

    # Create report array
    $script:report = @()

    # Set error action preference
    $ErrorActionPreference = "Stop"
}

# Add section to report
function Add-ReportSection {
    param (
        [string]$Title,
        [array]$Content
    )
    
    $section = @{
        Title = $Title
        Content = $Content
    }
    
    $script:report += $section
}

# Format table for report
function Format-ReportTable {
    param (
        [array]$Data,
        [array]$Properties
    )
    
    $table = $Data | Select-Object $Properties | ConvertTo-Html -Fragment
    return $table
}

# Export functions
Export-ModuleMember -Function @(
    'Test-AdminPrivileges',
    'Test-PowerShellVersion',
    'Test-WMFVersion',
    'Initialize-Environment',
    'Add-ReportSection',
    'Format-ReportTable'
) 