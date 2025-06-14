# System and Network Audit Tool

A comprehensive PowerShell-based system and network audit tool that collects detailed information about Windows systems and generates HTML reports.

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

1. Clone the repository:
```powershell
git clone https://github.com/dvlncl/dvincis-mstoolbox.git
```

2. Navigate to the project directory:
```powershell
cd dvincis-mstoolbox
```

3. Run the script with administrative privileges:
```powershell
.\satellite.ps1
```

The script will generate an HTML report on your desktop named "System_Network_Audit_Report.html".

## Scripts

- `satellite.ps1`: Main system and network audit script
- `fuel.ps1`: Additional system analysis script

## Base64 Encoded Versions

The repository includes base64 encoded versions of the scripts:
- `satellite.b64`
- `fuel.b64`

## Contributing

Feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 