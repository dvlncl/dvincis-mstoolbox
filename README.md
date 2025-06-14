# System and Network Audit Tool

A comprehensive PowerShell-based system and network audit tool that collects detailed information about Windows systems and generates HTML reports.

## Architecture

The tool consists of two main components:

1. `fuel.ps1` - Core Module
   - Handles all prerequisite environment checks
   - Manages PowerShell version and WMF requirements
   - Provides core reporting functions
   - Sets up execution environment
   - Must be present for satellite.ps1 to function

2. `satellite.ps1` - Main Audit Script
   - Depends on fuel.ps1 for core functionality
   - Performs system and network analysis
   - Generates comprehensive HTML reports
   - Requires administrative privileges

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
- `fuel.ps1` script (core module)

## Installation

1. Clone the repository:
```powershell
git clone https://github.com/dvlncl/dvincis-mstoolbox.git
```

2. Navigate to the project directory:
```powershell
cd dvincis-mstoolbox
```

3. Ensure all required files are present in the same directory:
   - `fuel.ps1` (core module)
   - `satellite.ps1` (main audit script)
   - `panels.csv` (network test configuration)

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

## Usage

Run the script with administrative privileges:
```powershell
.\satellite.ps1
```

The script will:
1. Load and initialize the core module (fuel.ps1)
2. Perform prerequisite environment checks
3. Execute system and network analysis
4. Generate an HTML report on your desktop named "System_Network_Audit_Report.html"

## Scripts

- `fuel.ps1`: Core module that provides:
  - Environment validation
  - Prerequisite checks
  - Core reporting functions
  - Execution environment setup

- `satellite.ps1`: Main audit script that:
  - Depends on fuel.ps1
  - Performs system analysis
  - Conducts network analysis
  - Generates HTML reports

## Base64 Encoded Versions

The repository includes base64 encoded versions of both scripts:
- `satellite.b64`
- `fuel.b64`

## Contributing

Feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 