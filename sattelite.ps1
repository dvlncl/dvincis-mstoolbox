# sattelite.ps1 - System Telemetry Collection Script
# Author: Your Name
# Version: 1.0.0

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$OutputDirectory = ".\TelemetryOutput",

    [Parameter(Mandatory=$false)]
    [string]$ConfigFile = ".\config.csv",

    [Parameter(Mandatory=$false)]
    [switch]$GenerateHTML = $true,

    [Parameter(Mandatory=$false)]
    [switch]$TestPrint = $false
)

# Import required modules
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $scriptPath "TelemetryClasses.ps1")
. (Join-Path $scriptPath "TelemetryConfig.ps1")
. (Join-Path $scriptPath "TelemetryLogger.ps1")
. "$PSScriptRoot\TelemetryReport.ps1"

# Initialize configuration
$config = New-Object -TypeName TelemetryConfig
$config.OutputDirectory = $OutputDirectory
$config.ConfigFile = $ConfigFile
$config.GenerateHTML = $GenerateHTML
$config.TestPrint = $TestPrint

try {
    # Load configuration from file if it exists
    $config.LoadFromFile($ConfigFile)
    $config.Validate()

    # Initialize logger
    $logger = New-Object -TypeName TelemetryLogger -ArgumentList $config.LoggingConfig
    $logger.Info("Starting telemetry collection...")

    # Collect system information
    $logger.Info("Collecting system information...")
    $systemInfo = New-Object -TypeName SystemInfo
    $logger.Info("System information collected successfully.")

    # Collect network information
    $logger.Info("Collecting network information...")
    $networkInfo = New-Object -TypeName NetworkInfo
    $networkInfo.CollectNetworkInfo($config.TargetHosts, $config.Domains)
    $networkInfo.CollectTraceroute('8.8.8.8')
    $logger.Info("Network information collected successfully.")

    # Collect printer information
    $logger.Info("Collecting printer information...")
    $printerInfo = New-Object -TypeName PrinterInfo
    $printerInfo.CollectPrinterInfo()
    $printerInfo.CollectPrintJobs()
    $printerInfo.CollectPrinterPorts()
    if ($config.TestPrint) {
        $logger.Info("Performing test prints...")
        foreach ($printer in $printerInfo.Printers) {
            $printerInfo.TestPrint($printer.Name)
        }
    }
    $logger.Info("Printer information collected successfully.")

    # Collect path information
    $logger.Info("Collecting path information...")
    $pathInfo = New-Object -TypeName PathInfo
    $pathInfo.TestPathAccess($config.Paths)
    $pathInfo.CollectPathPermissions($config.Paths)
    $pathInfo.CollectPathOwners($config.Paths)
    $logger.Info("Path information collected successfully.")

    # Generate HTML report if requested
    if ($config.GenerateHTML) {
        $logger.Info("Generating HTML report...")
        $report = New-Object -TypeName TelemetryReport -ArgumentList $config.OutputDirectory, $config.ReportConfig, $systemInfo, $networkInfo, $printerInfo, $pathInfo
        $report.ReportFile = "C:\sattelite\SatteliteReport.html"
        if (-not (Test-Path "C:\sattelite")) {
            New-Item -ItemType Directory -Path "C:\sattelite" -Force | Out-Null
        }
        $report.GenerateReport()
        $logger.Info("HTML report generated successfully.")
    }

    # Save configuration
    $config.SaveToFile($ConfigFile)
    $logger.Info("Configuration saved successfully.")

    $logger.Info("Telemetry collection completed successfully.")
}
catch {
    $logger.Error("Error during telemetry collection: $_")
    throw
}
finally {
    if ($logger) {
        $logger.Dispose()
    }
} 