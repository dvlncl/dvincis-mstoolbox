# TelemetryClasses.ps1 - Contains all telemetry collection classes

class SystemInfo {
    [string]$ComputerName
    [string]$Manufacturer
    [string]$Model
    [string]$SerialNumber
    [string]$OSName
    [string]$OSVersion
    [string]$OSArchitecture
    [datetime]$LastBootTime
    [string]$Uptime
    [string]$TotalPhysicalMemory
    [int]$NumberOfProcessors
    [string]$ProcessorName
    [int]$ProcessorCores
    [int]$ProcessorThreads
    [array]$DiskInfo
    [string]$LastUpdateCheck
    [string]$WindowsDefenderStatus
    [array]$ServiceStatus
    [string]$JoinType
    [string]$JoinName
    [array]$BitLockerStatus
    [string]$FirewallStatus
    [array]$DefenderDetails
    [string]$UACLevel
    [array]$LocalAdmins
    [array]$SMARTStatus
    [array]$BatteryInfo
    [array]$TemperatureInfo
    [array]$InstalledSoftware
    [array]$RunningProcesses
    [array]$StartupPrograms
    [array]$RecentErrors
    [array]$BSODHistory

    SystemInfo() {
        $this.CollectSystemInfo()
    }

    [void] CollectSystemInfo() {
        try {
            $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem
            $OperatingSystem = Get-WmiObject -Class Win32_OperatingSystem
            $Processor = Get-WmiObject -Class Win32_Processor
            $PhysicalMemory = Get-WmiObject -Class Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum

            $this.ComputerName = $ComputerSystem.Name
            $this.Manufacturer = $ComputerSystem.Manufacturer
            $this.Model = $ComputerSystem.Model
            $this.SerialNumber = $ComputerSystem.SerialNumber
            $this.OSName = $OperatingSystem.Caption
            $this.OSVersion = $OperatingSystem.Version
            $this.OSArchitecture = $OperatingSystem.OSArchitecture
            $this.LastBootTime = $OperatingSystem.ConvertToDateTime($OperatingSystem.LastBootUpTime)
            $this.Uptime = (Get-Date) - $this.LastBootTime
            $this.TotalPhysicalMemory = [math]::Round($PhysicalMemory.Sum / 1GB, 2)
            $this.NumberOfProcessors = $ComputerSystem.NumberOfProcessors
            $this.ProcessorName = $Processor.Name
            $this.ProcessorCores = $Processor.NumberOfCores
            $this.ProcessorThreads = $Processor.NumberOfLogicalProcessors

            $this.CollectSecurityInfo()
            $this.CollectHardwareHealth()
            $this.CollectSoftwareInventory()
            $this.CollectEventLogs()
            $this.CollectDiskInfo()
            $this.CollectServiceStatus()
            $this.CollectJoinInfo($ComputerSystem)
        }
        catch {
            Write-Error "Error collecting system information: $_"
            throw
        }
    }

    [void] CollectSecurityInfo() {
        try {
            $this.CollectBitLockerStatus()
            $this.CollectFirewallStatus()
            $this.CollectDefenderDetails()
            $this.CollectUACLevel()
            $this.CollectLocalAdmins()
        }
        catch {
            Write-Error "Error collecting security information: $_"
            throw
        }
    }

    [void] CollectBitLockerStatus() {
        try {
            $this.BitLockerStatus = Get-WmiObject -Namespace "root\cimv2\Security\MicrosoftVolumeEncryption" -Class "Win32_EncryptableVolume" -ErrorAction Stop | ForEach-Object {
                @{
                    Drive = $_.DriveLetter
                    ProtectionStatus = $_.ProtectionStatus
                    ConversionStatus = $_.ConversionStatus
                    EncryptionMethod = $_.EncryptionMethod
                }
            }
        }
        catch {
            $this.BitLockerStatus = @(@{
                Drive = "N/A"
                ProtectionStatus = "Not Available"
                ConversionStatus = "Not Available"
                EncryptionMethod = "Not Available"
                Error = "Access denied or feature not available"
            })
        }
    }

    [void] CollectFirewallStatus() {
        try {
            $firewall = Get-NetFirewallProfile -ErrorAction Stop
            $this.FirewallStatus = @{
                Domain = $firewall | Where-Object { $_.Name -eq 'Domain' } | Select-Object -ExpandProperty Enabled
                Private = $firewall | Where-Object { $_.Name -eq 'Private' } | Select-Object -ExpandProperty Enabled
                Public = $firewall | Where-Object { $_.Name -eq 'Public' } | Select-Object -ExpandProperty Enabled
            }
        }
        catch {
            $this.FirewallStatus = @{
                Domain = "Not Available"
                Private = "Not Available"
                Public = "Not Available"
                Error = "Access denied or feature not available"
            }
        }
    }

    [void] CollectDefenderDetails() {
        try {
            $defender = Get-MpComputerStatus -ErrorAction Stop
            $this.DefenderDetails = @{
                AntivirusEnabled = $defender.AntivirusEnabled
                AntispywareEnabled = $defender.AntispywareEnabled
                RealTimeProtectionEnabled = $defender.RealTimeProtectionEnabled
                LastFullScanTime = $defender.LastFullScanTime
                LastQuickScanTime = $defender.LastQuickScanTime
                AntivirusSignatureLastUpdated = $defender.AntivirusSignatureLastUpdated
            }
        }
        catch {
            $this.DefenderDetails = @{
                AntivirusEnabled = "Not Available"
                AntispywareEnabled = "Not Available"
                RealTimeProtectionEnabled = "Not Available"
                LastFullScanTime = "Not Available"
                LastQuickScanTime = "Not Available"
                AntivirusSignatureLastUpdated = "Not Available"
                Error = "Access denied or feature not available"
            }
        }
    }

    [void] CollectUACLevel() {
        try {
            $uac = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -ErrorAction Stop
            $this.UACLevel = if ($uac.EnableLUA -eq 1) { "Enabled" } else { "Disabled" }
        }
        catch {
            $this.UACLevel = "Not Available"
        }
    }

    [void] CollectLocalAdmins() {
        try {
            $admins = Get-WmiObject -Class Win32_GroupUser -ErrorAction Stop | Where-Object { $_.GroupComponent -like "*Administrators*" }
            $this.LocalAdmins = $admins | ForEach-Object {
                $_.PartComponent -replace '.*Name="([^"]+)".*', '$1'
            }
        }
        catch {
            $this.LocalAdmins = @("Not Available")
        }
    }

    [void] CollectHardwareHealth() {
        try {
            $this.CollectSMARTStatus()
            $this.CollectBatteryInfo()
            $this.CollectTemperatureInfo()
        }
        catch {
            Write-Error "Error collecting hardware health information: $_"
            throw
        }
    }

    [void] CollectSMARTStatus() {
        try {
            $this.SMARTStatus = Get-WmiObject -Namespace "root\wmi" -Class "MSStorageDriver_FailurePredictStatus" -ErrorAction Stop | ForEach-Object {
                @{
                    DeviceID = $_.InstanceName
                    PredictFailure = $_.PredictFailure
                    Reason = $_.Reason
                }
            }
        }
        catch {
            $this.SMARTStatus = @(@{
                DeviceID = "N/A"
                PredictFailure = "Not Available"
                Reason = "Feature not supported or access denied"
            })
        }
    }

    [void] CollectBatteryInfo() {
        try {
            $this.BatteryInfo = Get-WmiObject -Class Win32_Battery -ErrorAction Stop | ForEach-Object {
                @{
                    Name = $_.Name
                    EstimatedChargeRemaining = $_.EstimatedChargeRemaining
                    BatteryStatus = $_.BatteryStatus
                    DesignCapacity = $_.DesignCapacity
                    FullChargeCapacity = $_.FullChargeCapacity
                }
            }
        }
        catch {
            $this.BatteryInfo = @(@{
                Name = "N/A"
                EstimatedChargeRemaining = "Not Available"
                BatteryStatus = "Not Available"
                DesignCapacity = "Not Available"
                FullChargeCapacity = "Not Available"
                Error = "No battery found or access denied"
            })
        }
    }

    [void] CollectTemperatureInfo() {
        try {
            $this.TemperatureInfo = Get-WmiObject -Namespace "root\OpenHardwareMonitor" -Class "Sensor" -ErrorAction Stop | 
                Where-Object { $_.SensorType -eq "Temperature" } | ForEach-Object {
                    @{
                        Name = $_.Name
                        Value = $_.Value
                        Type = $_.SensorType
                    }
                }
        }
        catch {
            $this.TemperatureInfo = @(@{
                Name = "N/A"
                Value = "Not Available"
                Type = "Temperature"
                Error = "OpenHardwareMonitor not running or access denied"
            })
        }
    }

    [void] CollectSoftwareInventory() {
        try {
            $this.CollectInstalledSoftware()
            $this.CollectRunningProcesses()
            $this.CollectStartupPrograms()
        }
        catch {
            Write-Error "Error collecting software inventory: $_"
            throw
        }
    }

    [void] CollectInstalledSoftware() {
        try {
            $this.InstalledSoftware = Get-WmiObject -Class Win32_Product | ForEach-Object {
                @{
                    Name = $_.Name
                    Version = $_.Version
                    Vendor = $_.Vendor
                    InstallDate = $_.InstallDate
                }
            }
        }
        catch {
            Write-Error "Error collecting installed software: $_"
            throw
        }
    }

    [void] CollectRunningProcesses() {
        try {
            $this.RunningProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 | ForEach-Object {
                @{
                    Name = $_.Name
                    CPU = $_.CPU
                    WorkingSet = $_.WorkingSet
                    Threads = $_.Threads.Count
                }
            }
        }
        catch {
            Write-Error "Error collecting running processes: $_"
            throw
        }
    }

    [void] CollectStartupPrograms() {
        try {
            $this.StartupPrograms = Get-CimInstance -ClassName Win32_StartupCommand | ForEach-Object {
                @{
                    Name = $_.Name
                    Command = $_.Command
                    Location = $_.Location
                    User = $_.User
                }
            }
        }
        catch {
            Write-Error "Error collecting startup programs: $_"
            throw
        }
    }

    [void] CollectEventLogs() {
        try {
            $this.CollectRecentErrors()
            $this.CollectBSODHistory()
        }
        catch {
            Write-Error "Error collecting event logs: $_"
            throw
        }
    }

    [void] CollectRecentErrors() {
        try {
            $this.RecentErrors = Get-EventLog -LogName System -EntryType Error -Newest 10 -ErrorAction Stop | ForEach-Object {
                @{
                    TimeGenerated = $_.TimeGenerated
                    Source = $_.Source
                    Message = $_.Message
                    EventID = $_.EventID
                }
            }
        }
        catch {
            $this.RecentErrors = @(@{
                TimeGenerated = "N/A"
                Source = "N/A"
                Message = "No recent errors found or access denied"
                EventID = "N/A"
            })
        }
    }

    [void] CollectBSODHistory() {
        try {
            $this.BSODHistory = Get-WinEvent -FilterHashtable @{
                LogName = 'System'
                ID = 1001
            } -MaxEvents 5 -ErrorAction Stop | ForEach-Object {
                @{
                    TimeCreated = $_.TimeCreated
                    Message = $_.Message
                }
            }
        }
        catch {
            $this.BSODHistory = @(@{
                TimeCreated = "N/A"
                Message = "No BSOD history found or access denied"
            })
        }
    }

    [void] CollectDiskInfo() {
        try {
            $this.DiskInfo = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
                @{
                    Drive = $_.DeviceID
                    Size = [math]::Round($_.Size / 1GB, 2)
                    FreeSpace = [math]::Round($_.FreeSpace / 1GB, 2)
                    UsedSpace = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)
                }
            }
        }
        catch {
            Write-Error "Error collecting disk information: $_"
            throw
        }
    }

    [void] CollectServiceStatus() {
        try {
            $this.ServiceStatus = Get-Service | Where-Object { $_.Status -eq 'Running' } | ForEach-Object {
                @{
                    Name = $_.Name
                    DisplayName = $_.DisplayName
                    Status = $_.Status
                }
            }
        }
        catch {
            Write-Error "Error collecting service status: $_"
            throw
        }
    }

    [void] CollectJoinInfo($ComputerSystem) {
        try {
            $domain = $ComputerSystem.Domain
            $partOfDomain = $ComputerSystem.PartOfDomain
            $workgroup = $ComputerSystem.Workgroup
            $azureAdJoined = $null

            try {
                $dsreg = dsregcmd /status 2>$null
                if ($dsreg) {
                    $aadJoined = ($dsreg | Select-String 'AzureAdJoined\s*:\s*YES')
                    if ($aadJoined) { $azureAdJoined = $true } else { $azureAdJoined = $false }
                }
            }
            catch { $azureAdJoined = $false }

            if ($azureAdJoined) {
                $this.JoinType = 'Azure AD'
                $this.JoinName = $domain
            }
            elseif ($partOfDomain) {
                $this.JoinType = 'Active Directory'
                $this.JoinName = $domain
            }
            else {
                $this.JoinType = 'Workgroup'
                $this.JoinName = $workgroup
            }
        }
        catch {
            Write-Error "Error collecting join information: $_"
            throw
        }
    }
}

class NetworkInfo {
    [array]$PingResults
    [array]$DNSResults
    [array]$NetworkAdapters
    [array]$NetworkShares
    [array]$DNSServers
    [array]$Gateways
    [string]$Traceroute

    NetworkInfo() {
        $this.PingResults = @()
        $this.DNSResults = @()
        $this.NetworkAdapters = @()
        $this.NetworkShares = @()
        $this.DNSServers = @()
        $this.Gateways = @()
    }

    [void]CollectNetworkInfo([array]$TargetHosts, [array]$Domains) {
        try {
            $this.CollectPingResults($TargetHosts)
            $this.CollectDNSResults($Domains)
            $this.CollectNetworkAdapterInfo()
            $this.CollectNetworkShareInfo()
        }
        catch {
            Write-Error "Error collecting network information: $_"
            throw
        }
    }

    [void]CollectPingResults([array]$TargetHosts) {
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        foreach ($TargetHost in $TargetHosts) {
            try {
                $Ping = Test-Connection -ComputerName $TargetHost -Count 1 -ErrorAction Stop
                $Status = "Success"
                $ResponseTime = $Ping.ResponseTime
            }
            catch {
                $Status = "Failed"
                $ResponseTime = "N/A"
            }
            $this.PingResults += [PSCustomObject]@{
                Timestamp = $Timestamp
                TargetHost = $TargetHost
                Status = $Status
                ResponseTime = $ResponseTime
            }
        }
    }

    [void]CollectDNSResults([array]$Domains) {
        $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        foreach ($Domain in $Domains) {
            try {
                $DNSResult = Resolve-DnsName -Name $Domain -Type "A" -ErrorAction Stop
                $Result = ($DNSResult | Select-Object -ExpandProperty IPAddress -First 1) -join ", "
                if (-not $Result) { $Result = "No A record found" }
            }
            catch {
                $Result = "Query Failed"
            }
            $this.DNSResults += [PSCustomObject]@{
                Timestamp = $Timestamp
                Domain = $Domain
                RecordType = "A"
                Result = $Result
            }
        }
    }

    [void]CollectNetworkAdapterInfo() {
        try {
            Write-Host "Collecting network adapter information..."
            $Adapters = Get-NetAdapter | Where-Object Status -eq "Up"
            Write-Host "Found $($Adapters.Count) active network adapters"
            
            $this.NetworkAdapters = $Adapters | ForEach-Object {
                Write-Host "Processing adapter: $($_.Name)"
                
                $ip = (Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -ne $null }).IPAddress -join ', '
                if (-not $ip) { $ip = 'N/A' }
                Write-Host "  IP Address: $ip"
                
                $dns = (Get-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue).ServerAddresses
                if (-not $dns) { $dns = 'N/A' } else { $dns = $dns -join ', ' }
                Write-Host "  DNS Servers: $dns"
                
                $gw = (Get-NetIPConfiguration -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue).IPv4DefaultGateway.NextHop
                if (-not $gw) { $gw = 'N/A' } else { $gw = $gw -join ', ' }
                Write-Host "  Gateway: $gw"
                
                $dhcp = (Get-NetIPConfiguration -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue).IPv4Interface.Dhcp
                if ($null -eq $dhcp) { $dhcp = 'Unknown' } elseif ($dhcp) { $dhcp = 'DHCP' } else { $dhcp = 'Static' }
                [PSCustomObject]@{
                    Name = $_.Name
                    InterfaceDescription = $_.InterfaceDescription
                    Status = $_.Status
                    MacAddress = $_.MacAddress
                    IPAddress = $ip
                    DNSServers = $dns
                    Gateway = $gw
                    DHCP = $dhcp
                }
            }
            Write-Host "Network adapter collection complete. Found $($this.NetworkAdapters.Count) adapters with complete information."
        }
        catch {
            Write-Error "Error collecting network adapter information: $_"
            throw
        }
    }

    [void]CollectNetworkShareInfo() {
        try {
            $Shares = Get-WmiObject -Class Win32_Share
            $this.NetworkShares = $Shares | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    Path = $_.Path
                    Description = $_.Description
                    Type = $_.Type
                    AllowMaximum = $_.AllowMaximum
                }
            }
        }
        catch {
            Write-Error "Error collecting network share information: $_"
            throw
        }
    }

    [void]CollectTraceroute([string]$TargetHost = '8.8.8.8') {
        try {
            $this.Traceroute = tracert $TargetHost | Out-String
        } catch {
            $this.Traceroute = "Traceroute failed: $_"
        }
    }
}

class PrinterInfo {
    [array]$Printers
    [array]$PrintJobs
    [array]$PrinterPorts
    [array]$TestPrintResults

    PrinterInfo() {
        $this.Printers = @()
        $this.PrintJobs = @()
        $this.PrinterPorts = @()
        $this.TestPrintResults = @()
    }

    [void]CollectPrinterInfo() {
        try {
            $this.Printers = Get-Printer | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    DriverName = $_.DriverName
                    PortName = $_.PortName
                    Status = $_.PrinterStatus
                    IsDefault = $_.IsDefault
                    IsShared = $_.IsShared
                    IsLocal = $_.IsLocal
                    Type = $_.Type
                }
            }
        }
        catch {
            Write-Error "Error collecting printer information: $_"
            throw
        }
    }

    [void]CollectPrintJobs() {
        if (-not (Get-Command Get-PrintJob -ErrorAction SilentlyContinue)) {
            return
        }
        if ($this.Printers -and $this.Printers.Count -gt 0) {
            foreach ($printer in $this.Printers) {
                try {
                    if ($printer.Name -and ($printer.Type -eq $null -or $printer.Type -eq 'PrintQueue')) {
                        $jobs = Get-PrintJob -PrinterName $printer.Name -ErrorAction Stop | ForEach-Object {
                            [PSCustomObject]@{
                                Printer = $_.PrinterName
                                JobID = $_.Id
                                DocumentName = $_.DocumentName
                                Status = $_.JobStatus
                                SubmittedTime = $_.SubmittedTime
                                UserName = $_.UserName
                                Pages = $_.PagesPrinted
                                Size = $_.TotalPages
                            }
                        }
                        $this.PrintJobs += $jobs
                    }
                }
                catch {
                    # Suppress error, just skip this printer
                }
            }
        }
    }

    [void]CollectPrinterPorts() {
        try {
            $this.PrinterPorts = Get-PrinterPort | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    HostAddress = $_.HostAddress
                    PortNumber = $_.PortNumber
                    Protocol = $_.Protocol
                    Description = $_.Description
                }
            }
        }
        catch {
            Write-Error "Error collecting printer port information: $_"
            throw
        }
    }

    [void]TestPrint([string]$PrinterName) {
        try {
            $TestFile = "Test-Print.txt"
            "This is a test print job. Timestamp: $(Get-Date)" | Out-File $TestFile
            Start-Sleep -Seconds 1

            $PrintJob = Start-Process -FilePath "notepad.exe" -ArgumentList "/p", $TestFile -PassThru
            Start-Sleep -Seconds 2

            $Result = [PSCustomObject]@{
                PrinterName = $PrinterName
                Status = "Success"
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Error = $null
            }

            Remove-Item $TestFile -Force
        }
        catch {
            $Result = [PSCustomObject]@{
                PrinterName = $PrinterName
                Status = "Failed"
                Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Error = $_.Exception.Message
            }
        }

        $this.TestPrintResults += $Result
    }
}

class PathInfo {
    [array]$PathAccessResults
    [array]$PathPermissions
    [array]$PathOwners

    PathInfo() {
        $this.PathAccessResults = @()
        $this.PathPermissions = @()
        $this.PathOwners = @()
    }

    [void]TestPathAccess([array]$Paths) {
        foreach ($Path in $Paths) {
            try {
                $Access = Get-Acl -Path $Path
                $FormattedRights = $Access.Access | ForEach-Object {
                    [PSCustomObject]@{
                        Identity = $_.IdentityReference.Value
                        Rights = $_.FileSystemRights
                        Type = $_.AccessControlType
                    }
                }

                $Result = [PSCustomObject]@{
                    Path = $Path
                    Exists = $true
                    Access = $FormattedRights
                    Owner = $Access.Owner
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
            }
            catch {
                $Result = [PSCustomObject]@{
                    Path = $Path
                    Exists = $false
                    Access = $null
                    Owner = $null
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    Error = $_.Exception.Message
                }
            }

            $this.PathAccessResults += $Result
        }
    }

    [void]CollectPathPermissions([array]$Paths) {
        foreach ($Path in $Paths) {
            try {
                $ACL = Get-Acl -Path $Path
                $Permissions = $ACL.Access | ForEach-Object {
                    [PSCustomObject]@{
                        Path = $Path
                        Identity = $_.IdentityReference.Value
                        Rights = $_.FileSystemRights
                        Type = $_.AccessControlType
                        IsInherited = $_.IsInherited
                    }
                }
                $this.PathPermissions += $Permissions
            }
            catch {
                Write-Error "Error collecting permissions for path $Path : $_"
            }
        }
    }

    [void]CollectPathOwners([array]$Paths) {
        foreach ($Path in $Paths) {
            try {
                $ACL = Get-Acl -Path $Path
                $Owner = [PSCustomObject]@{
                    Path = $Path
                    Owner = $ACL.Owner
                    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                }
                $this.PathOwners += $Owner
            }
            catch {
                Write-Error "Error collecting owner for path $Path : $_"
            }
        }
    }
} 