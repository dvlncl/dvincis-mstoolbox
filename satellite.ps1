# System and Network Audit Script - PowerShell
# This script collects detailed network, system, software, and printer information
# and generates a comprehensive HTML report with clear section ordering.

# Import required functions from fuel.ps1
. .\fuel.ps1

# Initialize environment
Initialize-Environment

# =============================================
# FILE/OUTPUT SETTINGS
# =============================================
$ReportPath = "$env:USERPROFILE\Desktop\System_Network_Audit_Report.html"
$csvPath    = "panels.csv"   # Dynamic network targets

# =============================================
# HELPER: HTML section wrapper
# =============================================
$global:report = @()
function Add-Section ($title, $content) {
    if ([string]::IsNullOrEmpty($content)) {
        $content = "No data available or access denied"
    }
    $section = @"
<h2>$title</h2>
<pre>$content</pre>
"@
    $global:report += $section
    Write-Host "Added section: $title"  # Debug output
}

# ===================================================================
# 1. NETWORK SECTION  ------------------------------------------------
# ===================================================================

# Public IP
try { 
    $publicIP = Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5 
    Add-Section "Public IP" $publicIP
} catch { 
    Add-Section "Public IP" "Unable to retrieve public IP" 
}

# NIC / IP / Route data
try {
    Add-Section "Network Configuration" (Get-NetIPConfiguration | Out-String)
} catch {
    Add-Section "Network Configuration" "Access denied to network configuration"
}

try {
    Add-Section "Adapters" (Get-NetAdapter | Format-Table -AutoSize | Out-String)
} catch {
    Add-Section "Adapters" "Access denied to network adapters"
}

Add-Section "ARP Table" (arp -a | Out-String)
Add-Section "Routing Table" (route print | Out-String)

try {
    Add-Section "DNS Test (google.com)" (Resolve-DnsName -Name "www.google.com" | Out-String)
} catch {
    Add-Section "DNS Test" "Unable to resolve DNS"
}

Add-Section "Netstat (Top 10)" ((netstat -n | Select-String "ESTABLISHED" | Select-Object -First 10) | Out-String)

# Dynamic tests from panels.csv
if (Test-Path $csvPath) {
    $panelData = Import-Csv $csvPath -Header ID,Type,Target
    foreach ($entry in $panelData) {
        switch ($entry.Type.ToLower()) {
            "server"     { Add-Section "Ping (Server) $($entry.Target)"       (Test-Connection $entry.Target -Count 4 | Out-String) }
            "printer"    { Add-Section "Ping (Printer) $($entry.Target)"      (Test-Connection $entry.Target -Count 2 | Out-String) }
            "dns"        { Add-Section "DNS Resolve $($entry.Target)"         (Resolve-DnsName $entry.Target | Out-String) }
            "gateway"    {
                               $gw = (Get-NetIPConfiguration).IPv4DefaultGateway.NextHop
                               Add-Section "Ping (Gateway) $gw" (Test-Connection $gw -Count 2 | Out-String)
                           }
            "traceroute" { Add-Section "Traceroute to $($entry.Target)"       (tracert $entry.Target | Out-String) }
            "nbstat"     { Add-Section "NBStat $($entry.Target)"              (nbtstat -A $entry.Target | Out-String) }
        }
    }
} else {
    Add-Section "Dynamic Tests" "panels.csv not found - skipping custom network probes."
}

# Speedtest (CLI expected in PATH)
$SpeedTestCLI = (Get-Command speedtest.exe -ErrorAction SilentlyContinue).Source
if ($SpeedTestCLI) {
    try   { Add-Section "Speed Test" (& $SpeedTestCLI --accept-license --accept-gdpr | Out-String) }
    catch { Add-Section "Speed Test" "Speedtest CLI found but failed to run." }
} else {
    Add-Section "Speed Test" "Speedtest CLI not found in PATH. Download: https://www.speedtest.net/apps/cli"
}

# ===================================================================
# 2. SYSTEM SECTION  -------------------------------------------------
# ===================================================================
try {
    Add-Section "System Info" (Get-ComputerInfo | Select-Object CsName,OsName,OsArchitecture,WindowsVersion,OsBuildNumber,CsManufacturer,CsModel,BiosVersion,BiosReleaseDate | Out-String)
} catch {
    Add-Section "System Info" "Access denied to system information"
}

try {
    Add-Section "Uptime / Boot" ((Get-CimInstance Win32_OperatingSystem).LastBootUpTime | Out-String)
} catch {
    Add-Section "Uptime / Boot" "Access denied to uptime information"
}

try {
    Add-Section "CPU and Memory" (Get-CimInstance Win32_Processor | Select Name,MaxClockSpeed,NumberOfCores,NumberOfLogicalProcessors | Out-String)
} catch {
    Add-Section "CPU and Memory" "Access denied to CPU information"
}

try {
    Add-Section "Memory Status" ((Get-CimInstance Win32_OperatingSystem | Select TotalVisibleMemorySize,FreePhysicalMemory) | Out-String)
} catch {
    Add-Section "Memory Status" "Access denied to memory information"
}

try {
    Add-Section "Disk Drives"  (Get-PhysicalDisk | Format-Table -AutoSize | Out-String)
} catch {
    Add-Section "Disk Drives" "Access denied to disk information"
}

Add-Section "Logical Drives" (Get-PSDrive -PSProvider FileSystem | Out-String)

try {
    Add-Section "BitLocker" (Get-BitLockerVolume | Select MountPoint,ProtectionStatus,VolumeStatus | Out-String)
} catch {
    Add-Section "BitLocker" "No BitLocker volumes found or access denied"
}

try {
    Add-Section "Windows Defender" (Get-MpComputerStatus | Out-String)
} catch {
    Add-Section "Windows Defender" "Access denied to Windows Defender information"
}

try {
    Add-Section "Firewall Profiles" (Get-NetFirewallProfile | Format-Table Name,Enabled,DefaultInboundAction,DefaultOutboundAction | Out-String)
} catch {
    Add-Section "Firewall Profiles" "Access denied to firewall information"
}

try {
    Add-Section "Local Admins" (Get-LocalGroupMember -Group "Administrators" | Out-String)
} catch {
    Add-Section "Local Admins" "Access denied to local administrators information"
}

try {
    Add-Section "Non-Running Services" (Get-Service | Where-Object Status -ne 'Running' | Select Name,Status | Out-String)
} catch {
    Add-Section "Non-Running Services" "Access denied to services information"
}

# ===================================================================
# 3. SOFTWARE SECTION  ----------------------------------------------
# ===================================================================
try {
    Add-Section "Startup Programs" (Get-CimInstance Win32_StartupCommand | Select Name,Command,Location | Out-String)
} catch {
    Add-Section "Startup Programs" "Access denied to startup programs information"
}

try {
    # Get both 32-bit and 64-bit installed applications
    $32bitApps = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | 
                 Select-Object DisplayName, DisplayVersion, Publisher, @{Name="AppID";Expression={$_.PSChildName}} | 
                 Where-Object DisplayName -ne $null
    $64bitApps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | 
                 Select-Object DisplayName, DisplayVersion, Publisher, @{Name="AppID";Expression={$_.PSChildName}} | 
                 Where-Object DisplayName -ne $null
    
    # Combine and sort the results
    $allApps = ($32bitApps + $64bitApps) | Sort-Object DisplayName | Format-Table -Property DisplayName, DisplayVersion, Publisher, AppID -AutoSize
    Add-Section "Installed Apps" ($allApps | Out-String)
} catch {
    Add-Section "Installed Apps" "Access denied to installed applications information"
}

# ===================================================================
# 4. GPO SECTION  ---------------------------------------------------
# ===================================================================
try {
    # Get GPO information
    $gpoInfo = @()
    
    # Get all GPOs
    $gpos = Get-GPO -All
    
    foreach ($gpo in $gpos) {
        $gpoDetails = @{
            'Name' = $gpo.DisplayName
            'ID' = $gpo.Id
            'Created' = $gpo.CreationTime
            'Modified' = $gpo.ModificationTime
            'Enabled' = $gpo.GpoStatus
            'Owner' = $gpo.Owner
        }
        $gpoInfo += [PSCustomObject]$gpoDetails
    }
    
    # Get GPO links
    $gpoLinks = Get-GPInheritance -Target $env:COMPUTERNAME | 
                Select-Object -ExpandProperty GpoLinks | 
                Select-Object DisplayName, Enabled, Enforced, Order
    
    Add-Section "Group Policy Objects" ($gpoInfo | Format-Table -AutoSize | Out-String)
    Add-Section "GPO Links" ($gpoLinks | Format-Table -AutoSize | Out-String)
    
    # Get GPO applied settings
    $gpoSettings = Get-GPResultantSetOfPolicy -Computer $env:COMPUTERNAME -ReportType XML
    Add-Section "Applied GPO Settings" ($gpoSettings | Out-String)
} catch {
    Add-Section "Group Policy Information" "Access denied to GPO information or GPO module not available"
}

# ===================================================================
# 5. PRINTER SECTION  -----------------------------------------------
# ===================================================================
try {
    Add-Section "Printers" (Get-Printer | Format-Table Name,DriverName,PortName,PrinterStatus | Out-String)
} catch {
    Add-Section "Printers" "Access denied to printer information"
}

# ===================================================================
# 6. HTML REPORT OUTPUT  --------------------------------------------
# ===================================================================
Write-Host "Generating report with $($global:report.Count) sections..."

$html = @"
<!DOCTYPE html>
<html>
<head>
    <title>System and Network Audit</title>
    <style>
        body { font-family: Consolas, monospace; }
        h1 { color: #2e6c80; }
        h2 { color: #4f81bd; }
        pre { background: #f4f4f4; padding: 10px; border: 1px solid #ddd; }
    </style>
</head>
<body>
    <h1>System and Network Audit</h1>
    $($global:report -join "<hr>")
</body>
</html>
"@

$html | Out-File $ReportPath -Encoding UTF8

Write-Host "Audit complete -> $ReportPath"
Start-Process $ReportPath
