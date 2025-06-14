# 🛰️ Satellite

A comprehensive system and network audit tool that collects detailed information about Windows systems and generates HTML reports.

## Features

- System Information Collection
  - Basic system details
  - CPU and memory information
  - Disk information
  - Service status
  - Security settings
  - Group Policy information

- Network Analysis
  - Network configuration
  - Active connections
  - Network adapter status
  - DNS settings
  - Network security
  - Dynamic network testing using panels.csv

- Report Generation
  - HTML-based reports
  - Detailed system information
  - Network analysis results
  - Security recommendations

## Prerequisites

- Windows PowerShell 5.1 or PowerShell 7+
- Administrative privileges
- Windows Management Framework 5.1 or later

## Usage

1. Navigate to the satellite tool:
```powershell
shambles satellite
```

2. Run the script with administrative privileges:
```powershell
.\satellite.ps1
```

The script will:
1. Load and initialize the core module (fuel.ps1)
2. Perform prerequisite environment checks
3. Execute system and network analysis
4. Generate an HTML report on your desktop named "System_Network_Audit_Report.html"

## Network Testing Configuration

The `panels.csv` file defines network targets for testing. Each row specifies:
- `id`: Unique identifier for the test
- `type`: Type of network test (server, dns, printer, traceroute, gateway)
- `target`: Target address or hostname (leave empty for gateway)

Example configuration:
```csv
id,type,target
1,server,192.168.1.1
2,dns,8.8.8.8
3,printer,192.168.1.100
4,traceroute,google.com
5,gateway,
```

## Navigation

- Use `room` to return to the main toolbox
- Use `scalpel` to see all available tools
- Use `shambles [tool]` to navigate to another tool 