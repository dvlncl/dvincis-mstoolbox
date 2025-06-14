# 🛰️ Orbital Inspector

A PowerShell tool for domain reconnaissance and inspection. Orbital Inspector gathers a wide range of information about a target domain, including DNS, SSL, email authentication, open ports, and more.

## Features

- WHOIS lookup (requires `whois.exe`)
- DNS record inspection (A, CNAME, MX, TXT, NS)
- SPF, DKIM, and DMARC record checks
- SSL certificate information (subject, issuer, validity, thumbprint)
- HTTP header retrieval
- Technology detection via server headers
- Subdomain enumeration using crt.sh
- Common port scan (21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3389)
- Website preview (opens in browser)

## Prerequisites

- Windows PowerShell 5.1 or PowerShell 7+
- Administrative privileges recommended
- `whois.exe` (for WHOIS lookups; optional)

## Usage

1. Navigate to the Orbital Inspector tool:
```powershell
shambles orbitalInspector
```

2. Run the script with a domain name:
```powershell
.\orbital-inspector -Domain example.com
```

The script will:
- Display WHOIS info (if whois.exe is available)
- Show DNS records and email authentication settings
- Retrieve SSL certificate and HTTP header info
- Detect server technology
- Enumerate subdomains
- Scan common ports
- Optionally open the website in your browser

## Navigation

- Use `room` to return to the main toolbox
- Use `takt` to see all available tools
- Use `shambles [tool]` to navigate to another tool 