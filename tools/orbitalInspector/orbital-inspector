# Orbital Inspector - PowerShell Edition
param(
    [Parameter(Mandatory=$true)]
    [string]$Domain
)

Write-Host "`n🛰️ Orbital Inspector scanning: $Domain`n"

# ------------------------
# 1. WHOIS Info (requires whois.exe)
# ------------------------
Write-Host "[ WHOIS Info ]"
if (Get-Command whois.exe -ErrorAction SilentlyContinue) {
    whois $Domain | Select-String -Pattern "Registrar|Registrant|Name Server|Expiry|Creation"
} else {
    Write-Host "whois.exe not found. Install from Sysinternals or use WSL."
}

# ------------------------
# 2. DNS Info
# ------------------------
Write-Host "`n[ DNS Records ]"
Resolve-DnsName -Name $Domain -Type A -ErrorAction SilentlyContinue

Write-Host "`n[ CNAME / MX / TXT / NS ]"
Resolve-DnsName -Name $Domain -Type CNAME -ErrorAction SilentlyContinue
Resolve-DnsName -Name $Domain -Type MX -ErrorAction SilentlyContinue
Resolve-DnsName -Name $Domain -Type TXT -ErrorAction SilentlyContinue
Resolve-DnsName -Name $Domain -Type NS -ErrorAction SilentlyContinue

# ------------------------
# 3. SPF / DKIM / DMARC Records
# ------------------------
Write-Host "`n[ SPF / DKIM / DMARC ]"
try {
    $spf = Resolve-DnsName -Name "$Domain" -Type TXT | Where-Object { $_.Strings -match "v=spf1" }
    $dmarc = Resolve-DnsName -Name "_dmarc.$Domain" -Type TXT -ErrorAction SilentlyContinue
    $dkim = Resolve-DnsName -Name "selector1._domainkey.$Domain" -Type TXT -ErrorAction SilentlyContinue

    if ($spf) {
        Write-Output "SPF: $($spf.Strings)"
    } else {
        Write-Output "SPF: Not found"
    }
    if ($dmarc) {
        Write-Output "DMARC: $($dmarc.Strings)"
    } else {
        Write-Output "DMARC: Not found"
    }
    if ($dkim) {
        Write-Output "DKIM: $($dkim.Strings)"
    } else {
        Write-Output "DKIM: Not found or selector missing"
    }
} catch {
    Write-Host "Error retrieving email authentication records."
}

# ------------------------
# 4. SSL Certificate Info
# ------------------------
Write-Host "`n[ SSL Certificate Info ]"
try {
    $sslClient = [System.Net.Sockets.TcpClient]::new($Domain, 443)
    $sslStream = New-Object System.Net.Security.SslStream($sslClient.GetStream(), $false, ({ $true }))
    $sslStream.AuthenticateAsClient($Domain)
    $cert = $sslStream.RemoteCertificate
    $x509 = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $cert
    Write-Output "Subject: $($x509.Subject)"
    Write-Output "Issuer: $($x509.Issuer)"
    Write-Output "Valid From: $($x509.NotBefore)"
    Write-Output "Valid To: $($x509.NotAfter)"
    Write-Output "Thumbprint: $($x509.Thumbprint)"
    $sslStream.Close(); $sslClient.Close()
} catch {
    Write-Host "Failed to retrieve SSL certificate info."
}

# ------------------------
# 5. HTTP Headers
# ------------------------
Write-Host "`n[ HTTP Headers ]"
try {
    $headers = Invoke-WebRequest -Uri "https://$Domain" -Method Head -UseBasicParsing
    $headers.Headers | Format-List
} catch {
    Write-Host "Unable to fetch HTTP headers."
}

# ------------------------
# 6. Technology Detection (basic - via headers)
# ------------------------
Write-Host "`n[ Technology Detection - Server Headers ]"
if ($headers.Headers["Server"] -or $headers.Headers["X-Powered-By"]) {
    Write-Output "Server: $($headers.Headers["Server"])"
    Write-Output "X-Powered-By: $($headers.Headers["X-Powered-By"])"
} else {
    Write-Host "Server/Technology headers not available."
}

# ------------------------
# 7. Subdomain Enumeration via crt.sh
# ------------------------
Write-Host "`n[ Subdomains via crt.sh ]"
try {
    $crtResults = Invoke-RestMethod -Uri "https://crt.sh/?q=%25.$Domain&output=json" -UseBasicParsing
    $crtResults | ForEach-Object { $_.name_value } | Sort-Object -Unique
} catch {
    Write-Host "Could not retrieve subdomain data from crt.sh"
}

# ------------------------
# 8. Common Port Scan (basic)
# ------------------------
Write-Host "`n[ Common Ports Scan ]"
$ports = @(21, 22, 23, 25, 53, 80, 110, 143, 443, 445, 3389)
foreach ($port in $ports) {
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $async = $tcpClient.BeginConnect($Domain, $port, $null, $null)
        $success = $async.AsyncWaitHandle.WaitOne(1000, $false)
        if ($success) {
            Write-Host "Port $port is OPEN"
            $tcpClient.Close()
        } else {
            Write-Host "Port $port is CLOSED"
        }
    } catch {
        Write-Host "Port $port is CLOSED"
    }
}

# ------------------------
# 9. Screenshot Website Preview (optional)
# ------------------------
# Write-Host "`n[ Screenshot (Preview if browser available) ]"
# try {
#     Start-Process "https://$Domain"
# } catch {
#     Write-Host "Unable to open website preview in browser."
# }

Write-Host "`n✅ Orbital inspection complete."
