# Dvincis MS Toolbox 🏴‍☠️

A collection of PowerShell tools for system administration and analysis, inspired by Trafalgar Law's abilities from One Piece.

## Navigation System

The toolbox uses a navigation system inspired by Law's abilities:

- `room` - Return to the main toolbox directory
- `shambles [tool]` - Navigate to a specific tool
- `takt` - List all available tools

### Example Usage

```powershell
# List all available tools
takt

# Navigate to satellite tool
shambles satellite

# Navigate to Orbital Inspector tool
shambles orbitalInspector

# Return to main toolbox
room
```

## Available Tools

### 🛰️ Satellite
A comprehensive system and network audit tool that collects detailed information about Windows systems and generates HTML reports.

[View Satellite Documentation](tools/satellite/README.md)

### 🛰️ Orbital Inspector
A PowerShell tool for domain reconnaissance and inspection. Orbital Inspector gathers a wide range of information about a target domain, including:
- WHOIS lookup (requires `whois.exe`)
- DNS record inspection (A, CNAME, MX, TXT, NS)
- SPF, DKIM, and DMARC record checks
- SSL certificate information (subject, issuer, validity, thumbprint)
- HTTP header retrieval
- Technology detection via server headers
- Subdomain enumeration using crt.sh
- Common port scan (21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3389)
- Website preview (opens in browser)

[View Orbital Inspector Documentation](tools/orbitalInspector/README.md)

## Architecture

Each tool in the toolbox consists of two main components:

1. `fuel.ps1` - Core Module
   - Handles all prerequisite environment checks
   - Manages PowerShell version and WMF requirements
   - Provides core reporting functions
   - Sets up execution environment
   - Must be present for tool functionality

2. Tool-specific script (e.g., `satellite.ps1`, `orbital-inspector`)
   - Depends on fuel.ps1 for core functionality
   - Performs specific tool operations
   - Generates reports and outputs

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

- Domain Reconnaissance & Inspection (Orbital Inspector)
  - WHOIS, DNS, SSL, email authentication, subdomains, ports, and more

- Report Generation
  - HTML-based reports
  - Detailed system information
  - Network analysis results
  - Security recommendations

## Prerequisites

- Windows PowerShell 5.1 or PowerShell 7+
- Administrative privileges
- Windows Management Framework 5.1 or later

## Installation

1. Clone the repository:
```powershell
git clone https://github.com/dvlncl/dvincis-mstoolbox.git
```

2. Navigate to the project directory:
```powershell
cd dvincis-mstoolbox
```

3. Initialize the navigation system:
```powershell
.\init.ps1
```

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

For Orbital Inspector:
```powershell
.\orbital-inspector -Domain example.com
```

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

- `orbital-inspector`: Domain reconnaissance script that:
  - Performs WHOIS, DNS, SSL, HTTP, subdomain, and port checks
  - Summarizes domain security and configuration

## Base64 Encoded Versions

The repository includes base64 encoded versions of both scripts:
- `satellite.b64`
- `fuel.b64`

## Contributing

Feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 