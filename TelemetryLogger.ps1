# TelemetryLogger.ps1 - Logging functionality module

class TelemetryLogger {
    [string]$LogFile
    [string]$LogLevel
    [int64]$MaxLogSize
    [int]$MaxLogFiles
    [bool]$Enabled
    [System.IO.StreamWriter]$LogWriter
    [hashtable]$LogLevels = @{
        "DEBUG" = 0
        "INFO" = 1
        "WARNING" = 2
        "ERROR" = 3
    }

    TelemetryLogger([hashtable]$Config) {
        $this.LogFile = $Config.LogFile
        $this.LogLevel = $Config.LogLevel
        $this.MaxLogSize = $Config.MaxLogSize
        $this.MaxLogFiles = $Config.MaxLogFiles
        $this.Enabled = $Config.Enabled
        $this.InitializeLogger()
    }

    [void] InitializeLogger() {
        try {
            if ($this.Enabled) {
                # Create log directory if it doesn't exist
                $logDir = Split-Path $this.LogFile -Parent
                if (-not (Test-Path $logDir)) {
                    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
                }

                # Rotate logs if needed
                $this.RotateLogs()

                # Initialize StreamWriter
                $this.LogWriter = [System.IO.StreamWriter]::new($this.LogFile, $true)
                $this.LogWriter.AutoFlush = $true
            }
        }
        catch {
            Write-Error "Error initializing logger: $_"
            throw
        }
    }

    [void] RotateLogs() {
        try {
            if (Test-Path $this.LogFile) {
                $fileInfo = Get-Item $this.LogFile
                if ($fileInfo.Length -ge $this.MaxLogSize) {
                    # Rotate existing log files
                    for ($i = $this.MaxLogFiles - 1; $i -ge 1; $i--) {
                        $oldFile = "$($this.LogFile).$i"
                        $newFile = "$($this.LogFile).$($i + 1)"
                        if (Test-Path $oldFile) {
                            if (Test-Path $newFile) {
                                Remove-Item $newFile -Force
                            }
                            Rename-Item $oldFile $newFile
                        }
                    }

                    # Rename current log file
                    if (Test-Path "$($this.LogFile).1") {
                        Remove-Item "$($this.LogFile).1" -Force
                    }
                    Rename-Item $this.LogFile "$($this.LogFile).1"
                }
            }
        }
        catch {
            Write-Error "Error rotating logs: $_"
            throw
        }
    }

    [void] Log([string]$Level, [string]$Message) {
        try {
            if (-not $this.Enabled) { return }

            # Check if message level is high enough to log
            if ($this.LogLevels[$Level] -lt $this.LogLevels[$this.LogLevel]) {
                return
            }

            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logMessage = "[$timestamp] [$Level] $Message"

            # Write to log file
            $this.LogWriter.WriteLine($logMessage)

            # Also write to console for immediate feedback
            switch ($Level) {
                "DEBUG" { Write-Debug $Message }
                "INFO" { Write-Host $Message }
                "WARNING" { Write-Warning $Message }
                "ERROR" { Write-Error $Message }
            }
        }
        catch {
            Write-Error "Error writing to log: $_"
            throw
        }
    }

    [void] Debug([string]$Message) {
        $this.Log("DEBUG", $Message)
    }

    [void] Info([string]$Message) {
        $this.Log("INFO", $Message)
    }

    [void] Warning([string]$Message) {
        $this.Log("WARNING", $Message)
    }

    [void] Error([string]$Message) {
        $this.Log("ERROR", $Message)
    }

    [void] Dispose() {
        try {
            if ($this.LogWriter) {
                $this.LogWriter.Close()
                $this.LogWriter.Dispose()
            }
        }
        catch {
            Write-Error "Error disposing logger: $_"
            throw
        }
    }
} 