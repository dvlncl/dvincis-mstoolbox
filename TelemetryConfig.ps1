# TelemetryConfig.ps1 - Configuration management module

class TelemetryConfig {
    [string]$OutputDirectory
    [string]$ConfigFile
    [bool]$GenerateHTML
    [bool]$TestPrint
    [array]$TargetHosts
    [array]$Domains
    [array]$Paths
    [hashtable]$LoggingConfig
    [hashtable]$ReportConfig

    TelemetryConfig() {
        $this.OutputDirectory = ".\TelemetryOutput"
        $this.ConfigFile = ".\config.csv"
        $this.GenerateHTML = $true
        $this.TestPrint = $false
        $this.TargetHosts = @("8.8.8.8", "1.1.1.1")
        $this.Domains = @("google.com", "microsoft.com")
        $this.Paths = @("C:\Windows", "C:\Program Files")
        $this.LoggingConfig = @{
            Enabled = $true
            LogFile = ".\telemetry.log"
            LogLevel = "INFO"
            MaxLogSize = 10MB
            MaxLogFiles = 5
        }
        $this.ReportConfig = @{
            Title = "System Telemetry Report"
            Theme = "Modern"
            IncludeCharts = $true
            AutoOpen = $true
        }
    }

    [void] LoadFromFile([string]$ConfigPath) {
        try {
            if (Test-Path $ConfigPath) {
                $config = Import-Csv -Path $ConfigPath
                foreach ($row in $config) {
                    $property = $row.Property
                    $value = $row.Value
                    
                    switch ($property) {
                        "OutputDirectory" { $this.OutputDirectory = $value }
                        "ConfigFile" { $this.ConfigFile = $value }
                        "GenerateHTML" { $this.GenerateHTML = [System.Convert]::ToBoolean($value) }
                        "TestPrint" { $this.TestPrint = [System.Convert]::ToBoolean($value) }
                        "TargetHosts" { $this.TargetHosts = $value -split ',' }
                        "Domains" { $this.Domains = $value -split ',' }
                        "Paths" { $this.Paths = $value -split ',' }
                        "LoggingEnabled" { $this.LoggingConfig.Enabled = [System.Convert]::ToBoolean($value) }
                        "LogFile" { $this.LoggingConfig.LogFile = $value }
                        "LogLevel" { $this.LoggingConfig.LogLevel = $value }
                        "MaxLogSize" { $this.LoggingConfig.MaxLogSize = [System.Convert]::ToInt64($value) }
                        "MaxLogFiles" { $this.LoggingConfig.MaxLogFiles = [System.Convert]::ToInt32($value) }
                        "ReportTitle" { $this.ReportConfig.Title = $value }
                        "ReportTheme" { $this.ReportConfig.Theme = $value }
                        "IncludeCharts" { $this.ReportConfig.IncludeCharts = [System.Convert]::ToBoolean($value) }
                        "AutoOpen" { $this.ReportConfig.AutoOpen = [System.Convert]::ToBoolean($value) }
                    }
                }
            }
            else {
                Write-Warning "Config file not found at $ConfigPath. Using default settings."
            }
        }
        catch {
            Write-Error "Error loading configuration: $_"
            throw
        }
    }

    [void] SaveToFile([string]$ConfigPath) {
        try {
            $config = @(
                [PSCustomObject]@{ Property = "OutputDirectory"; Value = $this.OutputDirectory }
                [PSCustomObject]@{ Property = "ConfigFile"; Value = $this.ConfigFile }
                [PSCustomObject]@{ Property = "GenerateHTML"; Value = $this.GenerateHTML }
                [PSCustomObject]@{ Property = "TestPrint"; Value = $this.TestPrint }
                [PSCustomObject]@{ Property = "TargetHosts"; Value = $this.TargetHosts -join ',' }
                [PSCustomObject]@{ Property = "Domains"; Value = $this.Domains -join ',' }
                [PSCustomObject]@{ Property = "Paths"; Value = $this.Paths -join ',' }
                [PSCustomObject]@{ Property = "LoggingEnabled"; Value = $this.LoggingConfig.Enabled }
                [PSCustomObject]@{ Property = "LogFile"; Value = $this.LoggingConfig.LogFile }
                [PSCustomObject]@{ Property = "LogLevel"; Value = $this.LoggingConfig.LogLevel }
                [PSCustomObject]@{ Property = "MaxLogSize"; Value = $this.LoggingConfig.MaxLogSize }
                [PSCustomObject]@{ Property = "MaxLogFiles"; Value = $this.LoggingConfig.MaxLogFiles }
                [PSCustomObject]@{ Property = "ReportTitle"; Value = $this.ReportConfig.Title }
                [PSCustomObject]@{ Property = "ReportTheme"; Value = $this.ReportConfig.Theme }
                [PSCustomObject]@{ Property = "IncludeCharts"; Value = $this.ReportConfig.IncludeCharts }
                [PSCustomObject]@{ Property = "AutoOpen"; Value = $this.ReportConfig.AutoOpen }
            )

            $config | Export-Csv -Path $ConfigPath -NoTypeInformation
        }
        catch {
            Write-Error "Error saving configuration: $_"
            throw
        }
    }

    [void] Validate() {
        try {
            # Validate OutputDirectory
            if (-not (Test-Path $this.OutputDirectory)) {
                New-Item -ItemType Directory -Path $this.OutputDirectory -Force | Out-Null
            }

            # Validate LogFile directory
            $logDir = Split-Path $this.LoggingConfig.LogFile -Parent
            if (-not (Test-Path $logDir)) {
                New-Item -ItemType Directory -Path $logDir -Force | Out-Null
            }

            # Validate Paths
            foreach ($path in $this.Paths) {
                if (-not (Test-Path $path)) {
                    Write-Warning "Path not found: $path"
                }
            }

            # Validate LogLevel
            $validLogLevels = @("DEBUG", "INFO", "WARNING", "ERROR")
            if ($this.LoggingConfig.LogLevel -notin $validLogLevels) {
                $this.LoggingConfig.LogLevel = "INFO"
                Write-Warning "Invalid log level. Defaulting to INFO."
            }

            # Validate ReportTheme
            $validThemes = @("Modern", "Classic", "Dark", "Light")
            if ($this.ReportConfig.Theme -notin $validThemes) {
                $this.ReportConfig.Theme = "Modern"
                Write-Warning "Invalid report theme. Defaulting to Modern."
            }
        }
        catch {
            Write-Error "Error validating configuration: $_"
            throw
        }
    }
} 